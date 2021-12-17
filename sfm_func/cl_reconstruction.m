function [data] = cl_reconstruction(data)

maxnumtrials = data.cl_reconstruction.maxnumtrials;
maxdistance = data.cl_reconstruction.maxdistance;
confidence = data.cl_reconstruction.confidence;
numbundle = data.cl_reconstruction.numbundle;
maxiterations = data.cl_reconstruction.maxiterations;
absolutetolerance = data.cl_reconstruction.absolutetolerance;
relativetolerance = data.cl_reconstruction.relativetolerance;
fixedviewId = data.cl_reconstruction.fixedviewId;
reprojectionerror_threshold = data.cl_reconstruction.reprojectionerror_threshold;
numimages = data.basicinfo.numimages;
clpoints = data.plots.clpoints;
nummatch = data.basicinfo.nummatch;
pairs = data.plots.pairs;
match = data.plots.match;
intrinsics = data.basicinfo.intrinsics;
c = data.basicinfo.c;

%% add images to vSet
vSet = viewSet;    
vSet = addView(vSet,1,'Points',clpoints{1},'Orientation',eye(3), 'Location',zeros(1, 3));
for j = 2:numimages
    vSet = addView(vSet,j,'Points',clpoints{j});
end
for k= 1:nummatch
    vSet = addConnection(vSet,c(k,1),c(k,2),'Matches',pairs);
end

for k = 1:5
    try
        relativeOrient = cell(numimages,1);
        relativeLoc = cell(numimages,1);
        E = cell(numimages,1);
        orientation = cell(numimages,1);
        location = cell(numimages,1);
        for j = 2:numimages
            E{j} = estimateEssentialMatrix(match{(j-1)*2-1}, match{(j-1)*2}, intrinsics,'MaxNumTrials',maxnumtrials,'MaxDistance',maxdistance,'Confidence',confidence);
            [relativeOrient{j},relativeLoc{j}] = relativeCameraPose(E{j},intrinsics,match{(j-1)*2-1}, match{(j-1)*2});
            prevPose = poses(vSet, j-1);
            prevOrientation = prevPose.Orientation{1};
            prevLocation    = prevPose.Location{1};
            orientation{j} = relativeOrient{j} * prevOrientation;      
            location{j}    = prevLocation + relativeLoc{j} * prevOrientation;
            vSet = updateView(vSet, j, 'Orientation', orientation{j}, ...
             'Location', location{j});
        end

        tracks = findTracks(vSet); 
        precamPoses = poses(vSet);
        prexyzPoints = triangulateMultiview(tracks, precamPoses, intrinsics);

        %% refine points 
        xyzPoints = cell(numbundle,1);
        bucamPoses = cell(numbundle,1);
        bureprojectionErrors = cell(numbundle,1);
        meanreprojectionErrors = cell(numbundle,1);
        [xyzPoints{1}, bucamPoses{1}, bureprojectionErrors{1}] = bundleAdjustment(prexyzPoints, ...
            tracks, precamPoses, intrinsics,'MaxIterations',maxiterations,'AbsoluteTolerance',absolutetolerance,'RelativeTolerance',relativetolerance ,'FixedViewId', fixedviewId, ...
            'PointsUndistorted', true); %all default values from this function, see website (the link in the manual)
        meanreprojectionErrors{1} = mean(bureprojectionErrors{1});

        for i = 2:numbundle
            [xyzPoints{i}, bucamPoses{i}, bureprojectionErrors{i}] = bundleAdjustment(xyzPoints{i-1}, ...
               tracks, bucamPoses{i-1}, intrinsics,'MaxIterations',maxiterations,'AbsoluteTolerance',absolutetolerance,'RelativeTolerance',relativetolerance ,'FixedViewId', fixedviewId, ...
               'PointsUndistorted', true); %all default values from this function, see website (the link in the manual)
            meanreprojectionErrors{i} = mean(bureprojectionErrors{i});
        end
        allreprojectionErrors = nan(numbundle,1);
        for i = 1:numbundle
            allreprojectionErrors(i) = meanreprojectionErrors{i};
        end

        minreprojectionErrors = min(allreprojectionErrors);
        are = find(allreprojectionErrors == minreprojectionErrors);
        re = min(are);

        reprojectionErrors = cell2mat(bureprojectionErrors(re));
        meanreprojectionError = allreprojectionErrors(re);

        if meanreprojectionError < reprojectionerror_threshold
            break
        end
    catch
    end
end

if meanreprojectionError >= reprojectionerror_threshold
    errordlg(strcat('minreprojectionerror(', num2str(meanreprojectionError) ,')is over threshold(',num2str(reprojectionerror_threshold),').  Redo get_plots from the beginning (identify the position of each marker in images).'),'Reconstruction Error');
    error(strcat('minreprojectionerror(', num2str(meanreprojectionError) ,')is over threshold(',num2str(reprojectionerror_threshold),').  Redo get_plots from the beginning (identify the position of each marker in images).'));
end


acceptcamPoses = cell2table(bucamPoses(re));
camPoses = acceptcamPoses.Var1{1,1};
preclxyzPoints = cell2mat(xyzPoints(re));
vSet = updateView(vSet, camPoses);
camPoses = poses(vSet);

data.cl_reconstruction.vSet = vSet;
data.cl_reconstruction.tracks = tracks;
data.cl_reconstruction.camPoses = camPoses;
data.cl_reconstruction.preclxyzPoints  = preclxyzPoints;
data.cl_reconstruction.meanreprojectionError = meanreprojectionError;
data.cl_reconstruction.reprojectionErrors = reprojectionErrors;



figure; hold on; axis on;
plot(allreprojectionErrors);
title('mean reprojection error transition');
xlabel('num of bundle adjustment');
ylabel('mean reprojection error');

end
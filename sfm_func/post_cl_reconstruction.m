function [data] = post_cl_reconstruction(data)
numplots = data.basicinfo.numplots;
numclplots = data.basicinfo.numclplots;
eachplotname = data.basicinfo.eachplotname;
preclxyzPoints = data.cl_reconstruction.preclxyzPoints;
scaledistance = data.basicinfo.scaledistance;
camPoses = data.cl_reconstruction.camPoses;
numimages = data.basicinfo.numimages;
judgenc = data.basicinfo.judgenc;
date = data.basicinfo.date;
crowname = data.basicinfo.crowname;

clplots = [];
for i = 1:numplots
   nclplots = find(judgenc);
   if find(i == nclplots)
   else
       clplots = vertcat(clplots,i);
   end
end

judgebase = nan(numclplots,1);
clplotname = eachplotname(clplots);
for i = 1:numclplots
    judgebase(i) = contains(clplotname{i},'Scale');
end
r = find(judgebase == 1,2);
clearvars x y z

x = preclxyzPoints(:,1);
y = preclxyzPoints(:,2);
z = preclxyzPoints(:,3);

scaleestimate = ((x(r(1))-x(r(2)))^2 + (y(r(1))-y(r(2)))^2 + (z(r(1))-z(r(2)))^2)^0.5;
convertrate = scaledistance/scaleestimate;
postclxyzPoints = preclxyzPoints * convertrate;
preclcamPoses = camPoses;
for i = 1: numimages
  preclcamPoses.Location{i} = camPoses.Location{i} * convertrate;
end


%% change x to Y, y to X, z to -Z
clxyzPoints(:,1) = postclxyzPoints(:,2);
clxyzPoints(:,2) = postclxyzPoints(:,1);
clxyzPoints(:,3) = postclxyzPoints(:,3) * -1;
clcamPoses = preclcamPoses;
for i = 1: numimages
    clcamPoses.Location{i}(:,1) = preclcamPoses.Location{i}(:,2);
    clcamPoses.Location{i}(:,2) = preclcamPoses.Location{i}(:,1);
    clcamPoses.Location{i}(:,3) = preclcamPoses.Location{i}(:,3) * -1;
end

%% visualize

figure;
for i = 1:numimages
    R = clcamPoses.Orientation{i}*[-1,0,0;0,1,0;0,0,-1]*[0,-1,0;1,0,0;0,0,1]; %% rotation :Y axis 180. z axis 90
    t = clcamPoses.Location{i};
    pose = rigid3d(R,t);
    plotCamera('AbsolutePose',pose,'Opacity',0,'Size',3);
    text(clcamPoses.Location{i}(1,1)-5,clcamPoses.Location{i}(1,2)-5,clcamPoses.Location{i}(1,3)-5,strcat('camera',num2str(i)),'Color','red');
    hold on;
end

pcshow(clxyzPoints, [0 1 1], 'VerticalAxis', 'y', 'VerticalAxisDir', 'down','MarkerSize', 200);
for i = 1:numclplots
    text(clxyzPoints(i,1)-1,clxyzPoints(i,2)-1,clxyzPoints(i,3)-1,clplotname{i},'Color','y');
end

grid on
hold off

camorbit(0, -30);
title(strcat(num2str(date),'-',crowname,'-sfm-calibration result'))

clearvars x y z
for i = 1:numclplots
    x{i} = [];
    y{i} = [];
    z{i} = [];
    x{i} = clxyzPoints(i,1);
    y{i} = clxyzPoints(i,2);
    z{i} = clxyzPoints(i,3);
    text(x{i},y{i},z{i},eachplotname(i));
end
axis equal;

data.cl_reconstruction.convertrate = convertrate;
data.cl_reconstruction.clcamPoses = clcamPoses;
data.cl_reconstruction.preclcamPoses = preclcamPoses;

end
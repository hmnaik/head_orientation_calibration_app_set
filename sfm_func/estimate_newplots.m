function [data] = estimate_newplots(data)

judgenc = data.basicinfo.judgenc;
allpoints = data.plots.raw;
numimages = data.basicinfo.numimages;
raweyepoints = data.plots.eyepoints;
camPoses = data.cl_reconstruction.camPoses;
nummatch = data.basicinfo.nummatch;
c = data.basicinfo.c;
intrinsics = data.basicinfo.intrinsics;
preclxyzPoints = data.cl_reconstruction.preclxyzPoints;
structure = data.structure;

numeyeplots = sum(judgenc);
alleyepoints = allpoints;
cl = find(judgenc);
cl = cl.';
nc = (1:length(judgenc));
nc(:,cl) = [];

eyepoints = cell(length(raweyepoints),1);
for j = 1:numimages
    alleyepoints{j}(nc,:) = [];
    eyepoints{j} = rmmissing(raweyepoints{j});
end


eyevSet = viewSet; 
eyevSet = addView(eyevSet,1,'Points',eyepoints{1},'Orientation',camPoses.Orientation{1}, 'Location',camPoses.Location{1});
for j = 2:numimages
    eyevSet = addView(eyevSet,j,'Points',eyepoints{j},'Orientation',camPoses.Orientation{j}, 'Location',camPoses.Location{j});
end

eyematch = cell(2*nummatch,1);

alleyematch = cell(2*nummatch,1);
nummatcheye = cell(nummatch,1);
for k = 1:nummatch
    l = 2*k;
    alleyematch{l-1} = alleyepoints{c(k,1)};
    alleyematch{l} = alleyepoints{c(k,2)};
    for m = 1:numeyeplots
        F = isnan(alleyematch{l-1}(m,1));
        G = isnan(alleyematch{l}(m,1));
        if F == 0 && G == 0
            eyematch{l-1} = vertcat(eyematch{l-1},alleyematch{l-1}(m,:));
            eyematch{l} = vertcat(eyematch{l},alleyematch{l}(m,:));
        else
        end
    end
    nummatcheye{k} = size(eyematch{l});
    nummatcheye{k} = nummatcheye{k}(1);
end

matchpairs = cell(nummatch,1);
for k = 1:nummatch
    l = 2*k;
    for m = 1:nummatcheye{k}
        targetll = eyematch{l-1}(m,1);
        targetlr = eyematch{l-1}(m,2);
        targetrl = eyematch{l}(m,1);
        targetrr = eyematch{l}(m,2);
        eyepointsmatchll = find(eyepoints{c(k,1)}(:,1) == targetll);
        eyepointsmatchlr = find(eyepoints{c(k,1)}(:,2) == targetlr);
        eyepointsmatchrl = find(eyepoints{c(k,2)}(:,1) == targetrl);
        eyepointsmatchrr = find(eyepoints{c(k,2)}(:,2) == targetrr);
        samel = intersect(eyepointsmatchll,eyepointsmatchlr);
        samer = intersect(eyepointsmatchrl,eyepointsmatchrr);
        matchpair = [samel,samer];
        matchpairs{k} = vertcat(matchpairs{k},matchpair);
    end
end

for k = 1:nummatch
    eyevSet = addConnection(eyevSet,c(k,1),c(k,2),'Matches',matchpairs{k});
end
structure_eyebeak = cell(length(cl),1);
for i = 1:length(cl)
    a = cl(i);
    structure_eyebeak{i}.points = rmmissing(structure{a}.coordinate);  
    view = isnan(structure{a}.coordinate);
    id = [];
    for j = 1:length(view)
        if view(j,1) == 0
            id = horzcat(id,j);
        end
    end
    structure_eyebeak{i}.viewid = id;
end

for i = 1:length(cl)
    eyetracks(i) = pointTrack(structure_eyebeak{i}.viewid,structure_eyebeak{i}.points);
end
    
preeyexyzPoints = triangulateMultiview(eyetracks, camPoses, intrinsics);
prexyzPoints = nan(length(judgenc),3);
for i = 1:length(judgenc)
    nnc = find(nc == i);
    ncl = find(cl == i);
    if isempty(nnc)
        prexyzPoints(i,:) = preeyexyzPoints(ncl,:);
    else
        prexyzPoints(i,:) = preclxyzPoints(nnc,:);
    end
end

data.eye_reconstruction.eyevSet = eyevSet;
data.eye_reconstruction.matchpairs = matchpairs;
data.eye_reconstruction.eyetracks = eyetracks;
data.eye_reconstruction.prexyzPoints = prexyzPoints;

end

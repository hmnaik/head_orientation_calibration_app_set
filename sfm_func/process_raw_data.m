function [data] = process_raw_data(data)

numimages = data.basicinfo.numimages;
numplots = data.basicinfo.numplots;
eachplotname = data.basicinfo.eachplotname;
raw = data.plots.raw;

%% separate calibration points and eye points
clpoints = cell(data.basicinfo.numimages,1);
eyepoints = cell(data.basicinfo.numimages,1);
judgenc = nan(numimages,1);
for j = 1:numimages

    for i = 1:numplots
        judgenc(i) = contains(eachplotname(i),'nc-');
        if judgenc(i) == 0
            clpoints{j} = vertcat(clpoints{j},raw{j}(i,:));
            
        else  
            eyepoints{j} = vertcat(eyepoints{j},raw{j}(i,:));
        end
    end
end
for j = 1:numimages  
    clpoints{j} = rmmissing(clpoints{j});
    eyepoints{j} = rmmissing(eyepoints{j});
end

%% make pair sequence
nummatch = (numimages * (numimages-1))/2;
numclplots = numplots - sum(judgenc);
pairs = [];
pairs(:,1) = (1:numclplots);
pairs(:,2) = (1:numclplots);
pairs = uint32(pairs);

%% match 2D coordinates between images
b = combnk(1:numimages,2); 
c = flipud(b);
match = cell(nummatch*2,1);
for k= 1:nummatch
    match{2*k-1} = clpoints{c(k,1)}(pairs(:, 1), :);
    match{2*k} = clpoints{c(k,2)}(pairs(:, 2), :);
end

%% make plotname & coordinate structure
structure = cell(numplots,1);
for i = 1:numplots
    structure{i}.name = eachplotname{i};
    for j = 1:numimages
        structure{i}.coordinate(j,:) = raw{j}(i,:); 
    end   
end


data.plots.clpoints = clpoints;
data.plots.eyepoints = eyepoints;
data.plots.match = match;
data.plots.pairs = pairs;
data.basicinfo.nummatch = nummatch;
data.basicinfo.c = c;
data.basicinfo.numclplots = numclplots;
data.basicinfo.judgenc = judgenc;
data.structure = structure;

end

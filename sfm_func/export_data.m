function [data] = export_data(data)

numplots = data.basicinfo.numplots;
eachplotname = data.basicinfo.eachplotname;
xyzPointsmm = data.eye_reconstruction.xyzPointsmm;
date = data.basicinfo.date;
crowname = data.basicinfo.crowname;
filetitle = data.basicinfo.filetitle;

plotnameexcel = cell(1,numplots*3);
plotlabelexcel = cell(1,numplots*3);
for i = 1:numplots
    u = 3*i;
    plotnameexcel(u-2) = eachplotname(i);
    plotnameexcel(u-1) = eachplotname(i);
    plotnameexcel(u) = eachplotname(i);
    plotlabelexcel{u-2} = 'X';
    plotlabelexcel{u-1} = 'Y';
    plotlabelexcel{u} = 'Z';
end

empty = cell(1,numplots*3);
for i = 1:3*numplots
    empty{i} = NaN;
end
coordinates = nan(1,numplots*3);
for i = 1:numplots
    for r = 1:3
        coordinates(3*i-3+r) = xyzPointsmm(i,r);
    end
end


coordinates = num2cell(coordinates);
Tdata = vertcat(plotnameexcel,empty,empty,plotlabelexcel,coordinates);
Tdatalabel = {NaN;NaN;NaN;'Frame';1};
Tdatalabel2 = {NaN;NaN;NaN;'Time';0};
Tdata = table(Tdatalabel,Tdatalabel2,Tdata);
nummatchplots = (numplots*(numplots - 1))/2;
d = combnk(1:numplots,2);
estimate_mm = nan(nummatchplots,1);
plotspairtable = cell(nummatchplots,1);
clearvars x y z
x = xyzPointsmm(:,1);
y = xyzPointsmm(:,2);
z = xyzPointsmm(:,3);
for k = 1:nummatchplots
    dxl = x(d(k,1));
    dyl = y(d(k,1));
    dzl = z(d(k,1));
    dxr = x(d(k,2));
    dyr = y(d(k,2));
    dzr = z(d(k,2));
    distance = ((dxl-dxr)^2+(dyl-dyr)^2+(dzl-dzr)^2)^0.5;
    plotspair = strcat(eachplotname{d(k,1)},'-',eachplotname{d(k,2)});
    estimate_mm(k) = distance;
    plotspairtable{k} = plotspair;
end

Sdata = table(plotspairtable,estimate_mm);

%% save reconstruction data
if ~isfolder(['csv/',num2str(date),'/',crowname])
    mkdir(['csv/',num2str(date),'/',crowname]);
end

writetable(Tdata,strcat('csv/',num2str(date),'/',crowname,'/',filetitle,'_reconstruction.csv'),'WriteVariableNames',false);
writetable(Sdata,strcat('csv/',num2str(date),'/',crowname,'/','distance_reconstruction.csv'),'WriteVariableNames',false);

data.table.reconstruction = Tdata;
data.table.distance = Sdata;
end
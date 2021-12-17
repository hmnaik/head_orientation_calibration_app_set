function [data] = get_plot_coord(data,img)
numplots = data.basicinfo.numplots;
eachplotname = data.basicinfo.eachplotname;
date = data.basicinfo.date;
crowname = data.basicinfo.crowname;
numimages  = data.basicinfo.numimages;
plots = cell(numimages,1);
%% get plot coordination
point = cell(numimages,1);
G = cell(numimages,1);
h = figure;
for i = 1:numplots 
    for j = 1:numimages  
        hold on;
        h.WindowState = 'maximized';
        imshow(img{j}, 'InitialMagnification', 'fit');       
        if i >= 2
            for p = 2:i
                F = isempty(plots{j}(p-1,1));
                if F == 0
                    hold on;
                    plot(plots{j}(p-1,1),plots{j}(p-1,2),'+r');
                    text(plots{j}(p-1,1),plots{j}(p-1,2),eachplotname(p-1),'Color','r');
                else
                end
            end
        else
            
        end
        title(strcat(eachplotname(i),'-',num2str(j)),'FontSize',15);
        point{j} = ginput(1);
        G{j} = isempty(point{j});
        if G{j} == 1
            point{j} = [NaN,NaN];
        else
        end
    end
    for j = 1:numimages
        plots{j} = vertcat(plots{j},point{j});
    end
end
close all;
data.plots.raw = plots;

if ~isfolder(['matdata/',num2str(date),'/',crowname])
    mkdir(['matdata/',num2str(date),'/',crowname]);
end


end

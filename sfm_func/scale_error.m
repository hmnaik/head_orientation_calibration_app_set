function [data] = scale_error(data)

scalepair = strfind(table2cell(data.table.distance(:,1)),'Scale');
a = nan(length(scalepair),1);
for i = 1:length(scalepair)
    a(i) = length(scalepair{i});
end
numscaledis = find(a>1);
scaledis = table2cell(data.table.distance(numscaledis,2));
scale_error = nan(length(scaledis),1);
for i = 1:length(scaledis)
    scale_error(i) = scaledis{i} - data.basicinfo.scaledistance;
end
scale_error(1) = NaN;
scale_error = rmmissing(scale_error);
scale = table(scale_error);

data.table.scale = scale;

end
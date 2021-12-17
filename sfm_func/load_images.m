function [img] = load_images(data)
img = cell(data.basicinfo.numimages,1);
for j = 1:data.basicinfo.numimages
    img{j} = imread(strcat(data.basicinfo.selpath, '\', num2str(j), '.png'));
    img{j} = undistortImage(img{j},data.basicinfo.intrinsics);
end
end
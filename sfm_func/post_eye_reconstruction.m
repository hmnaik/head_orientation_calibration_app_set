function [data] = post_eye_reconstruction(data)

prexyzPoints = data.eye_reconstruction.prexyzPoints;
convertrate =data.cl_reconstruction.convertrate;
clcamPoses = data.cl_reconstruction.clcamPoses;
date = data.basicinfo.date;
crowname = data.basicinfo.crowname;
numimages = data.basicinfo.numimages;

eyexyzPoints = prexyzPoints * convertrate;


%% change x to Y, y to X, z to -Z
xyzPointsmm(:,1) = eyexyzPoints(:,2);
xyzPointsmm(:,2) = eyexyzPoints(:,1);
xyzPointsmm(:,3) = eyexyzPoints(:,3) * -1;

%% visualize% figure;

figure;
for i = 1:numimages
    R = clcamPoses.Orientation{i}*[-1,0,0;0,1,0;0,0,-1]*[0,-1,0;1,0,0;0,0,1]; %% rotation :Y axis 180. z axis 90
    t = clcamPoses.Location{i};
    pose = rigid3d(R,t);
    plotCamera('AbsolutePose',pose,'Opacity',0,'Size',3);
    text(clcamPoses.Location{i}(1,1)-5,clcamPoses.Location{i}(1,2),clcamPoses.Location{i}(1,3),strcat('camera',num2str(i)),'Color','red');
    hold on;
end

pcshow(xyzPointsmm,[0 1 1], 'VerticalAxis', 'y', 'VerticalAxisDir', 'down','MarkerSize', 200);
for i = 1:length(xyzPointsmm)
    text(xyzPointsmm(i,1)-1,xyzPointsmm(i,2)-1,xyzPointsmm(i,3)-1,data.basicinfo.eachplotname{i},'Color','y');
end
grid on
hold off

camorbit(0, -30);

title(strcat(num2str(date),'-',crowname,'-3D reconstruction'))

axis equal;

data.eye_reconstruction.xyzPointsmm = xyzPointsmm;

end
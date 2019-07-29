function printDetection(vid,points,filename)

% vid    : 3d frames sequence
% points : Nx4 detected points (x,y,scale,t)
% filename : Address of where to print file

outputVideo = VideoWriter([filename,'.avi']);
outputVideo.FrameRate = 30;
open(outputVideo);
frames = 1:size(vid,3);
xmax = size(vid,2);
ymax = size(vid,1);
for i = 1:numel(frames)

    ii = frames(i);
    img = vid(:,:,ii);
    
    ind = find(points(:,4) == ii);
    f = figure;
    f.PaperPosition = [0 0 ymax-1 xmax-1];
    set(f,'position',[0 0 1 1],'units','normalized');
    f.Visible='off';
    imshow(img,[]);
    viscircles(points(ind,1:2),3*points(ind,3),'EdgeColor','g');
    frame = getframe;
    writeVideo(outputVideo,frame.cdata(2:ymax,2:(xmax+1),:));
    close(f);
end
close(outputVideo)
end
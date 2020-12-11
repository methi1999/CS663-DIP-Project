%% Video Toonification
%% Define all parameters for Toonification here
%location of video file
%assumed 256 intensities in input image
location = 'xylophone.mp4';
myNumOfColors = 200;
myColorScale = [ [0:1/(myNumOfColors-1):1]' , ...
    [0:1/(myNumOfColors-1):1]' , [0:1/(myNumOfColors-1):1]' ];
%% Reads video and stores in a video file
tic;
vidObj = VideoReader(location);
framecount = 0;
frame = readFrame(vidObj);
h = size(frame, 1);
w = size(frame, 2);
duration_max = ceil(vidObj.FrameRate * vidObj.Duration);
image_out = zeros(duration_max, h*w, 3);

for i = 1:h
    for j = 1:w
        for k = 1:3
            image_out(framecount+1, (i-1)*w+j, k) = frame(i, j, k);
        end
    end
end

while(hasFrame(vidObj))
    framecount = framecount + 1;
    frame = readFrame(vidObj);
    
    for i = 1:h
        for j = 1:w
            for k = 1:3
                image_out(framecount+1, (i-1)*w+j, k) = frame(i, j, k);
            end
        end
    end
    
    if mod(framecount, 10) == 0
        fprintf('Current Time = %.3f sec\n', vidObj.CurrentTime);
    end
end
image_out = image_out(1:framecount, :, :);
toc;
%%
imagesc(uint8(image_out));
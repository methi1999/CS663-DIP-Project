%% Video Toonification
%% Define all parameters for Toonification here
%location of video file
%assumed 256 intensities in input image
location = '../data/horses.mp4';
save_inp_loc = '../data/in_h.mp4';
save_loc = '../data/out_h.mp4';
downsample_x = 5;
downsample_y = 5;
downsample_frame = 500;
spatial_sigma = 25;
intensity_sigma = 50;
lambda = 0.95;
edge_threshold = 0.13;
quantize = 8;
%% Reads video and stores in a video file
tic;
vidObj = VideoReader(location);
framecount = 0;
frame = readFrame(vidObj);
blankvid = double(frame(1:downsample_x:end, 1:downsample_y:end, :));

while(hasFrame(vidObj))
    framecount = framecount + 1;
    frame = readFrame(vidObj);
    blankvid(:,:,:,framecount) = double(frame(1:downsample_x:end, 1:downsample_y:end, :));
    if mod(framecount, 10) == 0
        fprintf('Current Time = %.3f sec\n', vidObj.CurrentTime);
    end
end
downsampled_vid = blankvid(:, :, :, 1:downsample_frame:end);
disp("Video downsampled and ready for processing");
toc;
%% Save Input Video for later comparisons
tic;
inputVid = VideoWriter(save_inp_loc);
inputVid.FrameRate = vidObj.FrameRate;
open(inputVid);
for t = 1:size(blankvid, 4)
    blankvid(:,:,:,t) = blankvid(:,:,:,t) / max(max(max(blankvid(:,:,:,t))));
    writeVideo(inputVid, blankvid(:, :, :, t));
end
close(inputVid);
disp("Video input has been saved");
toc;
%% Output Video is created
tic;
outputVid = VideoWriter(save_loc);
% Due to downsampling, we have to modify framerate of output video
outputVid.FrameRate = vidObj.FrameRate * 1.0 / downsample_frame;
open(outputVid);
for t = 1:size(downsampled_vid, 4)
    nxt_frame = myBilateralFiltering(downsampled_vid(:,:,:,t), spatial_sigma, intensity_sigma, 12);
    nxt_frame = floor(nxt_frame/quantize);
%     nxt_frame = floor(nxt_frame/quantize);
    for colors = 1:3
        edge_mat = edge(nxt_frame(:,:,colors), 'canny', edge_threshold);
        edge_mat = floor((256.0 / quantize) * edge_mat / max(max(max(edge_mat))));
        imagesc(edge_mat);
        nxt_frame(:,:,colors) = lambda * nxt_frame(:,:,colors) + (1-lambda) * edge_mat;
    end
    nxt_frame = nxt_frame/max(max(max(nxt_frame)));
    writeVideo(outputVid, nxt_frame);
    fprintf('Current Frame = %d\n', t);
end
close(outputVid);
disp("Video output has been created");
toc;
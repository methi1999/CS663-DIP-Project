%% Video Toonification
clear;
%% Define all parameters for Toonification here
%location of video file
%location = 'xylophone.mp4';
location = '../data/combined.mp4';
% save_inp_loc = '../data/in_combined';
save_out_loc = '../data/out_combined';
downsample_x = 4;
downsample_y = 5;
downsample_frame = 2;
num_iter = 10;
num_neighbor = 150;
windowsize = num_neighbor;
windowed=0;
onlyy=0;
lambda = 0.3;
edge_lambda=0.8;
edge_threshold = 0.16;
quantize=2;
anisotropic=0;
%% Reads video and stores in a video file
tic;
vidObj = VideoReader(location);
framecount = 0;
frame = readFrame(vidObj);
blankvid = double(frame(1:downsample_x:end, 1:downsample_y:end, :));

while(hasFrame(vidObj))
    framecount = framecount + 1;
    frame = readFrame(vidObj);
    blankvid(:,:,:,framecount) = (double(frame(1:downsample_x:end, 1:downsample_y:end, :)));
    if mod(framecount, 10) == 0
        fprintf('Current Time = %.3f sec\n', vidObj.CurrentTime);
    end
end
disp("Video downsampled and ready for processing");
disp(size(blankvid));
toc;

%% Shot Detection
tic;
downsampled_vid = blankvid(:, :, :, 1:downsample_frame:end);
boundaries = myShotDetection(downsampled_vid, 2.5);
fprintf('Total shots = %i\n', (size(boundaries,2)+1));
%% Mean Shift Segmentation on multiple Videos
start = 1;
% add last frame as the end 
boundaries = [boundaries, size(downsampled_vid, 4)];

spatial_sigma_l = {50, 150};
intensity_sigma_l = {50, 150};
time_sigma_l = {10, 20};
save_suffix = 0;

for s_sig = 1:length(spatial_sigma_l)
    for i_sig = 1:length(intensity_sigma_l)
        for t_sig = 1:length(time_sigma_l)
            
            spatial_sigma = spatial_sigma_l{s_sig};
            intensity_sigma = intensity_sigma_l{i_sig};
            time_sigma = time_sigma_l{t_sig};

            for segment = 1:size(boundaries,2)
                tic;
                fprintf("On segment %i\n", segment);
                curr_segment = downsampled_vid(:, :, :, start:boundaries(segment)-1);
                mnshftvid = myMeanShiftSegmentation(curr_segment,spatial_sigma,intensity_sigma,time_sigma,num_iter,num_neighbor,lambda,windowsize,windowed,onlyy);
                disp("Mean Shift segmentation done");
                toc;
                %% Canny Edge Addition
            %     tic;
            %     %mncannyvid = zeros(size(mnshftvid));
            %     cannyvid=VideoWriter(strcat('../data/cannyvidtrial',"_",num2str(segment)));
            %     open(cannyvid);
            %     for t =1:size(mnshftvid,4)
            %         nxt_frame = mnshftvid(:,:,:,t)/ max(max(max(mnshftvid(:,:,:,t))));
            %         for colors = 1:3
            %             edge_mat = edge(nxt_frame(:,:,colors), 'canny', edge_threshold);
            %             edge_mat = floor((256.0 / quantize) *edge_mat / max(max(max(edge_mat))))/256;%floor((256.0 / quantize) * 
            %             imagesc(edge_mat);
            %             nxt_frame(:,:,colors) = edge_lambda * nxt_frame(:,:,colors) + (1-edge_lambda) * edge_mat;
            %         end
            %         nxt_frame = nxt_frame/max(max(max(nxt_frame)));
            %         writeVideo(cannyvid,nxt_frame)
            %         %mncannyvid(:,:,:,t)=nxt_frame;
            %     end
            %     close(cannyvid);
            %     disp("Video Canny has been saved");
            %     toc;
                %% final video chunk
                final_vid(:, :, :, start:start+size(curr_segment, 4)-1) = mnshftvid;
                %% Save Input Video for later comparisons
            %     tic;
            %     inputVid = VideoWriter(strcat(save_inp_loc, "_", num2str(segment)));
            %     inputVid.FrameRate = vidObj.FrameRate;
            %     open(inputVid);
            %     for t = start:size(mnshftvid, 4)
            %         blankvid(:,:,:,t) = blankvid(:,:,:,t)/ max(max(max(blankvid(:,:,:,t))));
            %         writeVideo(inputVid, blankvid(:, :, :, t));
            %     end
            %     close(inputVid);
            %     disp("Video input has been saved");
            %     toc;
            % 
            %     %% Output Video is created
            %     tic;
            %     outputVid = VideoWriter(strcat(save_out_loc, "_", num2str(segment)));
            %     % Due to downsampling, we have to modify framerate of output video
            %     outputVid.FrameRate = vidObj.FrameRate * 1.0 / downsample_frame;
            %     open(outputVid);
            %     for t = 1:size(mnshftvid, 4)
            %         %mnshftvid(:,:,:,t)= rescale(mnshftvid())
            %         mnshftvid(:,:,:,t) = ((mnshftvid(:,:,:,t))/ max(max(max(mnshftvid(:,:,:,t)))));
            %         writeVideo(outputVid, mnshftvid(:, :, :, t));
            %     end
            %     close(outputVid);
            %     disp("Video output has been created");
                % for next segment
                start = boundaries(segment);
            end



            %% Does the actual Mean Shift segmentation
            %tic;
            %mnshftvid = myMeanShiftSegmentation(downsampled_vid,spatial_sigma,intensity_sigma,time_sigma,num_iter,num_neighbor,lambda,windowsize,windowed,onlyy);
            mnshftvid=final_vid;
            disp("Mean Shift segmentation done");
            toc;
            %% Canny Edge Addition
            tic;
            %mncannyvid = zeros(size(mnshftvid));
            cannyvid=VideoWriter(strcat('../data/cannyvidtrial_', int2str(save_suffix)));
            open(cannyvid);
            for t =1:size(mnshftvid,4)
                nxt_frame = mnshftvid(:,:,:,t)/ max(max(max(mnshftvid(:,:,:,t))));
                for colors = 1:3
                    edge_mat = edge(nxt_frame(:,:,colors), 'canny', edge_threshold);
                    edge_mat = floor((256.0 / quantize) *edge_mat / max(max(max(edge_mat))))/256;%floor((256.0 / quantize) * 
%                     imagesc(edge_mat);
                    nxt_frame(:,:,colors) = edge_lambda * nxt_frame(:,:,colors) + (1-edge_lambda) * edge_mat;
                end
                nxt_frame = nxt_frame/max(max(max(nxt_frame)));
                writeVideo(cannyvid,nxt_frame)
                %mncannyvid(:,:,:,t)=nxt_frame;
            end
            close(cannyvid);
            disp("Video Canny has been saved");
            toc;
            %% Save Input Video for later comparisons
            % tic;
            % inputVid = VideoWriter(save_inp_loc);
            % inputVid.FrameRate = vidObj.FrameRate;
            % open(inputVid);
            % for t = 1:size(blankvid, 4)
            %     blankvid(:,:,:,t) = blankvid(:,:,:,t)/ max(max(max(blankvid(:,:,:,t))));
            %     writeVideo(inputVid, blankvid(:, :, :, t));
            % end
            % close(inputVid);
            % disp("Video input has been saved");
            % toc;

            %% Output Video is created
            tic;
            outputVid = VideoWriter(strcat(save_out_loc, int2str(save_suffix)));
            save_suffix = save_suffix + 1;
            % Due to downsampling, we have to modify framerate of output video
            outputVid.FrameRate = vidObj.FrameRate * 1.0 / downsample_frame;
            open(outputVid);
            for t = 1:size(mnshftvid, 4)
                %mnshftvid(:,:,:,t)= rescale(mnshftvid())
                mnshftvid(:,:,:,t) = ((mnshftvid(:,:,:,t))/ max(max(max(mnshftvid(:,:,:,t)))));
                writeVideo(outputVid, mnshftvid(:, :, :, t));
            end
            close(outputVid);
            disp("Video output has been created");
            toc;
        end
    end
end
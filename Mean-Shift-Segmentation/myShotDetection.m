function y = myShotDetection(vidArray, factor)

    framecount = size(vidArray, 4);
    prev = vidArray(:, :, :, 1);
    rms = double(zeros(framecount-1, 1));

    cur_sum = 0;
    cur_num = 0;
    
    y = [];

    for i=2:framecount
        frame = vidArray(:, :, :, i);
        diff = sqrt(mean((frame - prev).^2, 'all'));
        rms(i-1) = diff;    

        if (cur_num > 0 && diff > factor*cur_sum/cur_num)
            y = [y, i];
            cur_sum = 0;
            cur_num = 0;
        end

        cur_sum = cur_sum + diff;
        cur_num = cur_num + 1;

        prev = frame;    
    end
    
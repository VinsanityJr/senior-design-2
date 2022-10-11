% make sure that no vid exists
if exist('vid', 'var')
    stop(vid)
end

clear
clc
close all

% create a video object for matlab to get images from
vid = videoinput('winvideo', 2, 'MJPG_640x480');

% set the video frame interval and number of images to take
set(vid,'TriggerRepeat',Inf); 
vid.FrameGrabInterval = 1;

% start the video object
start(vid)

% save the background image
background_image = getdata(vid, 1);
background_image = double(background_image) ./...
    max(max(double(background_image)));

% main loop
frame_counter = 0;
while true
    % get the new image frame
    frame_counter = frame_counter + 1;
    data = getdata(vid, frame_counter);
    data = squeeze(double(data) ./ double(max(max(data))));
    
    % background subtraction
    delta = data(:,:,:,1) - background_image;
    delta = abs(delta ./ max(max(delta)));
    
    % form a windowing matrix
    threshold = 0.4;
    window = sum(delta, 3) > threshold * 3;
    window = medfilt2(window);
         
         
    % window the data
    image(:, :, 1) = data(:, :, 1) .* window;
    image(:, :, 2) = data(:, :, 2) .* window;
    image(:, :, 3) = data(:, :, 3) .* window;
    
    % search for positions in the ring
    [centers, radii] = imfindcircles(window, [20, 50]);
    
    % get the pixel colors
    if ~isempty(centers)
        % make a vector to hold the color values
        colors = zeros(length(centers(:, 1)), 3);
        
        % grab each pixel and the color values
        for c = 1:length(centers(:, 1))
            point = round(centers(c, :));
            
            % get the color for this center point. I tried doing this in one
            % line; it broke spectacularly
            colors(c, 1) = data(point(2), point(1), 1);
            colors(c, 2) = data(point(2), point(1), 2);
            colors(c, 3) = data(point(2), point(1), 3);
        end
        
        colors
    end
    
    % show the image to the screen
    imshow(image, [0.0, 1.0]);
    viscircles(centers, radii, 'EdgeColor', 'm');
end

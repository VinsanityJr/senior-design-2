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
    data = double(data) ./ double(max(max(data)));
    
    % background subtraction
    delta = data(:,:,:,1) - background_image;
    delta = abs(delta ./ max(max(delta)));
    
    % form a windowing matrix
    threshold = 0.6;
    window = sum(delta, 3) > threshold * 3;
    window = medfilt2(window);
         
         
    % window the data
    image(:, :, 1) = data(:, :, 1, 1) .* window;
    image(:, :, 2) = data(:, :, 2, 1) .* window;
    image(:, :, 3) = data(:, :, 3, 1) .* window;
    
    % search for positions in the ring
    [centers, radii] = imfindcircles(window, [20, 50]);
    
    % show the image to the screen
    imshow(image, [0.0, 1.0]);
    viscircles(centers, radii, 'EdgeColor', 'w');
end

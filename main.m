% make sure that no vid exists
if exist('vid', 'var')
    stop(vid)
end

% create a video object for matlab to get images from
vid = videoinput('winvideo', 2, 'MJPG_640x480');

% set the video frame interval and number of images to take
set(vid,'TriggerRepeat',Inf); 
vid.FrameGrabInterval = 1;

% start the video object
start(vid)

% save the background image
background_image = getdata(vid, 1);

% parameters
black_threshold = 0.2 * 255;

% runtime variables
frame_counter = 1;

% get the grayscale of the background
binary = zeros(480, 640);
for m = 1:480
    for n = 1:640
        binary(m, n) = sum(background_image(m, n, :)) < black_threshold*3;
    end
end
imshow(binary)

% find the image crosshairs

figure()
% main loop
while true
    % get the new image frame
    frame_counter = frame_counter + 1;
    data = getdata(vid, frame_counter);
    
    % background subtraction
    delta = data(:,:,:,1) - background_image;
    
    % search for positions in the ring
    
    % show the image to the screen
    imshow(delta);
end

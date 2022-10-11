% create a video object for matlab to get images from
vid = videoinput('winvideo', 2, 'MJPG_640x480');

% set the video frame interval and number of images to take
set(vid,'TriggerRepeat',Inf); 
vid.FrameGrabInterval = 1;

% start the video object
start(vid)

% save the background image
background_image = getdata(vid, 1);

% runtime variables
frame_counter = 1;

% main loop
while true
    % get the new image frame
    frame_counter = frame_counter + 1;
    data = getdata(vid, frame_counter);
    
    % background subtraction
    delta = data(:,:,:,1) - background_image;
    
    % show the image to the screen
    imshow(delta);
end

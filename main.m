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
    delta = double(data(:,:,:,1) - background_image);
    delta = delta ./ max(max(delta));
    
    % form a windowing matrix
    threshold = [0.05, 0.02, 0.10];
    window = (delta(:, :, 1) > threshold(1)) | ...
             (delta(:, :, 2) > threshold(2)) | ...
             (delta(:, :, 3) > threshold(3));
    
    % window the data
    image(:, :, 1) = data(:, :, 1, 1) .* window;
    image(:, :, 2) = data(:, :, 2, 1) .* window;
    image(:, :, 3) = data(:, :, 3, 1) .* window;
    
    % search for positions in the ring
    [centers, radii] = imfindcircles(image, 100);
    
    if length(centers) > 1
        fprintf("center at %d, radius %d\n", centers(1), radii(1))
    end
    
    % show the image to the screen
    imshow(image);
end

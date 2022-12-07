% This function uses the camera object to take a snapshot of the board

function gamestate = take_snapshot(gamestate, threshold)
    % get the new image frame
    gamestate.image = double(getsnapshot(gamestate.cam));
    gamestate.image = gamestate.image ./ max(max(gamestate.image));
    
    % background subtraction
    gamestate.d_image = abs(gamestate.image - gamestate.bkgd_image);
    
    % form a windowing matrix
    gamestate.window = medfilt2(sum(gamestate.d_image, 3) > threshold * 3);
    gamestate.window = repmat(gamestate.window, 1, 1, 3);
    
    % window the original image
    gamestate.filtered_image = gamestate.image .* gamestate.window;
end
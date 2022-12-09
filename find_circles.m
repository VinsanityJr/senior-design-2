% This function uses the snapshot of the gameboard to find and classify
% condiments on the board

function gamestate = find_circles(gamestate, search_radii)
    % search for circles in the ring
    [centers, ~] = imfindcircles(gamestate.window(:, :, 1), search_radii);

    % get the pixel colors
    if ~isempty(centers)
        % length of centers:
        len = length(centers(:, 1));
        
        rgb_colors = zeros(len, 3);

        % calculate center of circles' degrees from x-axis 
        angles = atan2d(-(centers(:, 2) - 287), centers(:, 1) - 308);

        % grab each pixel and the color values
        for c = 1:len
            point = round(centers(c, :));
            
            % get the color for this center point. I tried doing this in one
            % line; it broke spectacularly
            rgb_colors(c, 1) = gamestate.image(point(2), point(1), 1);
            rgb_colors(c, 2) = gamestate.image(point(2), point(1), 2);
            rgb_colors(c, 3) = gamestate.image(point(2), point(1), 3);
        end

        for n = 1:len
            gamestate.circles{n, 1} = classify(rgb_colors(n,1), rgb_colors(n,2), rgb_colors(n,3));
            gamestate.circles{n, 2} = mod(angles(n), 360);
            gamestate.circles{n, 3} = centers(n);
        end
    end

end
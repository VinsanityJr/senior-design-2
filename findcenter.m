% takes input *greyscale image and finds crosshair center
% resolution is 640x480 WxH

% Assumptions:
%   * Greyscale image is being passed in
%   * Center Point of the camera image is within the inner circle

function [centerx,centery] = findcenter(image)
    
    dw = 0;
    dh = 0;
    
    % Circle Point 1
    while(true)
        current_pixel = image(320,240+dh);
        if current_pixel == 1
            x1 = 320;
            y1 = 240+dh;
            break;
        end
        dh = dh - 1;
    end

    % Circle Point 2
    while(true)
        current_pixel = image(320+dw, 240);
        if current_pixel == 1
            x2 = 320+dw;
            y2 = 240;
            break;
        end
        dw = dw-1;
    end

     % Circle Point 3
    dw = 0;
    while(true)
        current_pixel = image(320+dw, 240);
        if current_pixel == 1
            x3 = 320+dw;
            y3 = 240;
            break;
        end
        dw = dw+1;
    end


    % calculate and return center of the circle
    D = 2*(x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2));
    centerx = ((x1*x1+y1*y1)*(y2-y3) + (x2*x2+y2*y2)*(y3-y1) + (x3*x3+y3*y3)*(y1-y2)) / D;
    centery = ((x1*x1+y1*y1)*(x3-x2) + (x2*x2+y2*y2)*(x1-x3) + (x3*x3+y3*y3)*(x2-x1)) / D;

end 
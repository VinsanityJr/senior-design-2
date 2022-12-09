% housekeeping
clear
clc
close all

telapsed = 'none';

set_param('simulink_model', 'SimulationCommand', 'start');

% gobal variables
colors = {'Red'; 'Blue'; 'Green'; 'Yellow'};
threshold = 0.18;
search_radii = [10, 20];
motor_delay = 3;
actuator_big_delay = 12;
actuator_delay = 3;
offset = 98;

% make sure that no camera object exists (from a previous run)
if exist('vid', 'var')
    stop(cam)
end

% create a video object for matlab to get images from
gamestate.cam = videoinput('winvideo', 1, 'MJPG_640x480');

% initialize circles locations
gamestate.circles = {};
motor_target_candidates = {};
target_angle = [0, 0];

% move to origin
% set_param('simulink_model/desiredPosition', 'Value', '0');
% while abs(get_param('simulink_model/currentPosition', 'RuntimeObject').InputPort(1).Data) < 0.5; end  

% get and save the background image
gamestate.bkgd_image = double(getsnapshot(gamestate.cam));
gamestate.bkgd_image = gamestate.bkgd_image ./ max(max(gamestate.bkgd_image));

% main loop
while true
    % Open Gui.
    %gamestate.circles = {};
    waitfor(appGUI);

    % start clock
    tstart = tic;

    % Take and process the current state of the gameboard
    gamestate = take_snapshot(gamestate, threshold);
    
    % find and classify the condiments present on the gameboard
    gamestate = find_circles(gamestate, search_radii);

    if isempty(gamestate.circles)
        error("No condiments on gameboard");
    end

    % reset motor status variables
    distance = 360;
    motor_target = 1;
    
    % sort the list by angles
    gamestate.circles = sortrows(gamestate.circles, 2);

    % prune the list
    [a, ~] = size(gamestate.circles);
    for c = 1:a
        for d = 1:a
            if (c ~= d) && abs(gamestate.circles{d, 2} - gamestate.circles{c, 2}) < 3
                if gamestate.circles{d, 2} > gamestate.circles{c, 2}
                    gamestate.circles{c, 1} = "None";
                else
                    gamestate.circles{d, 1} = "None";
                end
            end
        end
    end

    % control logic
    for c = 1:length(condiments)
        
        retrieval_angle = 0;
        
        % find desired target location
        [a, ~] = size(gamestate.circles);
        for  n = 1:a
            if strcmp(gamestate.circles{n, 1}, condiments{c}) ...
                    && (gamestate.circles{n, 2} > 270 ...
                    || gamestate.circles{n, 2} < 90)
                retrieval_angle = gamestate.circles{n, 2} - offset;
            end
        end
            


        % find desired destination location
        %destination_angle = 136 + 16*(length(condiments)-c) - offset;
        dest_angles = [141, 154, 165, 178];
        destination_angle = dest_angles(length(condiments)-c+1)- offset;
        % 140 151 162 173

        % go to desired location
        set_param('simulink_model/desiredPosition', 'Value', num2str(retrieval_angle));
        while abs(get_param('simulink_model/currentPosition', 'RuntimeObject').InputPort(1).Data - retrieval_angle) < 0.5; end
        
        % go down
        set_param('simulink_model/Act-Down', 'Value', '1');
        fprintf("Actuator Down\n");
        pause(actuator_delay);
        set_param('simulink_model/Act-Down', 'Value', '0');
        fprintf("Actuator Downn't\n");

        % activate electromagnet
        set_param('simulink_model/Emag', 'Value', '1');
        fprintf("Electromagnet electromagneting\n");
    
        % go up
        set_param('simulink_model/Act-Up', 'Value', '1');
        fprintf("Actuator Up\n");
        pause(actuator_delay);
        set_param('simulink_model/Act-Up', 'Value', '0');
        fprintf("Actuator Upn't\n");
            
        % go to desired output location
        set_param('simulink_model/desiredPosition', 'Value', num2str(destination_angle));
        while abs(get_param('simulink_model/currentPosition', 'RuntimeObject').InputPort(1).Data - destination_angle) < 0.5; end
        
        % go down
        set_param('simulink_model/Act-Down', 'Value', '1');
        fprintf("Actuator Down\n");
        pause(actuator_delay);
        set_param('simulink_model/Act-Down', 'Value', '0');
        fprintf("Actuator Downn't\n");

        % activate electromagnet
        set_param('simulink_model/Emag', 'Value', '0');
        fprintf("Electromagnet electromagnetingn't\n");
    
        % go up
        set_param('simulink_model/Act-Up', 'Value', '1');
        fprintf("Actuator Up\n");
        pause(actuator_delay);
        set_param('simulink_model/Act-Up', 'Value', '0');
        fprintf("Actuator Upn't\n");
    end

    telapsed = toc(tstart);
    telapsed = num2str(telapsed);
end
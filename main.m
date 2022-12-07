% housekeeping
clear
clc
close all

set_param('simulink_model', 'SimulationCommand', 'start');

% gobal variables
colors = {'Red'; 'Blue'; 'Green'; 'Yellow'};
threshold = 0.1;
search_radii = [20, 35];
motor_delay = 3;
actuator_delay = 3;

% make sure that no camera object exists (from a previous run)
if exist('vid', 'var')
    stop(cam)
end

% create a video object for matlab to get images from
gamestate.cam = videoinput('winvideo', 2, 'MJPG_640x480');

% initialize circles locations
gamestate.circles = {};
motor_target_candidates = {};
target_angle = [0, 0];

% initialize the motor position to 0
gamestate.motor_pos = 0;

% get and save the background image
gamestate.bkgd_image = double(getsnapshot(gamestate.cam));
gamestate.bkgd_image = gamestate.bkgd_image ./ max(max(gamestate.bkgd_image));

% main loop
while true
    % Present GUI to user
    % GUI STUFF
    condiments = {'red', 'blue', 'green', 'yellow'};
    
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

    % control logic
    for c = 1:length(condiments)
        
        % find desired target location
        for  n = 1:length(gamestate.circles)
            if gamestate.circles{c, 1} == condiments{1} ...
                    && gamestate.circles{c, 2} > 180 ...
                    && gamestate.circles{c, 2} < 90 ...
                    %% DISTANCE_COMPARE- ensure closest distance
                retrieval_angle = gamestate.circles{c, 2};
            end
        end
            
        % find desired destination location
        destination_angle = 45 + 20*c; % calculate the destination angle 

        % go to desired location
        set_param('simulink_model/desiredPosition', 'Value', num2str(retrieval_angle));
        while abs(get_param('simulink_model/currentPosition').InputPort(1).Data - retrieval_angle) < 0.5; end
        
        % go down
        set_param('simulink_model/Act-Down', 'Value', '1');
        pause(actuator_delay);
        set_param('simulink_model/Act-Down', 'Value', '0');
    
        % activate electromagnet
        set_param('simulink_model/Emag', 'Value', '1');
    
        % go up
        set_param('simulink_model/Act-Up', 'Value', '1');
        pause(actuator_delay);
        set_param('simulink_model/Act-Up', 'Value', '0');
            
        % go to desired output location
        set_param('simulink_model/desiredPosition', 'Value', num2str(destination_angle));
        while abs(get_param('simulink_model/currentPosition').InputPort(1).Data - target_angle) < 0.5; end
 
        % go down
        set_param('simulink_model/Act-Down', 'Value', '1');
        pause(actuator_delay);
        set_param('simulink_model/Act-Down', 'Value', '0');
    
        % deactivate electromagnet
        set_param('simulink_model/Emag', 'Value', '0');
    
        % go up
        set_param('simulink_model/Act-Up', 'Value', '1');
        pause(actuator_delay);
        set_param('simulink_model/Act-Up', 'Value', '0');
    end
end
% housekeeping
clear
clc
close all

telapsed = 'none';

set_param('simulink_model', 'SimulationCommand', 'start');

% gobal variables
colors = {'Red'; 'Blue'; 'Green'; 'Yellow'};
threshold = 0.2;
search_radii = [10, 20];
motor_delay = 3;
actuator_delay = 3;
offset = 110;

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
    % Open Gui
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

    % control logic
    for c = 1:length(condiments)
        
        % find desired target location
        for  n = 1:length(gamestate.circles)
            if strcmp(gamestate.circles{c, 1}, condiments{1}) ...
                    && mod(gamestate.circles{c, 2}, 360) - 180 >-90 ...
                    || mod(gamestate.circles{c, 2}, 360) - 180 < 90 ...
                    %% DISTANCE_COMPARE- ensure closest distance
                retrieval_angle = gamestate.circles{c, 2} - offset;
            end
        end
            
        % find desired destination location
        destination_angle = 140 + 11 * (length(condiments) - c) - offset;
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
        while abs(get_param('simulink_model/currentPosition', 'RuntimeObject').InputPort(1).Data - target_angle) < 0.5; end
        
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
    clockGUI;

end
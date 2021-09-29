%{
Ray Chen (rchen63@buffalo.edu)
Project 1:  Fuzzy Controller Project
           - This project is aim to create a fuzzy logic system for the
           robot to run from the starting location to the destination.
Inputs: starting location and destination location
        - Do not input a distance larger than 4999, it may cause error.
        - When running the code, it would firstly ask you to input x-coordination
        of the starting location, enter a number and press enter key, and
        repeat this step for the next few inputs.
Outputs: 
         - Weight of each membership function
         - New speed
         - New Angular velocity
         - Time

Fuzzy Logic Designer is used in project.
(https://www.mathworks.com/help/fuzzy/fuzzylogicdesigner-app.html)

%}

clear
clc
format compact
fs = readfis("membership_Function.fis");  %import the fuzzy logic system from the .fis file
sx = input("Input the x-axis of the starting location\n"); %sx is the x-axis of the starting location
sy = input("Input the y_axis of the starting location\n");  %sy is the y-axis of the starting location
dx = input("Input the x-axis of the destination\n");  %dx is the x-axis of the destination
dy = input("Input the y_axis of the destination\n");  %dy is the y-axis of the destination
distance = sqrt((sx-dx)^2+(sy-dy)^2);
current_location_x=sx; %current location is the starting location
current_location_y=sy;
current_angle=0;        %Initial angle is 0.
time=0;                 %Initial time is 0.
if distance <= 4999         %The distance should not be greater than 4999.
    while distance <= 4999 && distance>1 && time < 1800
       
        angle_to_xaxis = atan((dy - current_location_y)/(dx - current_location_x)); %The angle between destination and x-axis of the current location
        angle_to_xaxis = angle_to_xaxis/(pi) * 180;                 % change radian to degree
        
        % if the desination has a higher y-coordinate value than that of
        % current location, the angle from x-axis ranges from 0 degree to 180 degree.
        % if the destination has a lower y-coordinate value than that of
        % current location, the angle from x-axis ranges from 0 degree to -180 degree.
        if dx-current_location_x>=0 && dy-current_location_y>=0
            %do nothing
        elseif dx-current_location_x<0 && dy-current_location_y>0
            angle_to_xaxis = angle_to_xaxis + 180;  
        elseif dx-current_location_x<0 && dy-current_location_y<=0
            angle_to_xaxis = angle_to_xaxis - 180;
        elseif dx-current_location_x>=0 && dy-current_location_y<0
            %do nothing;
        end
        
        angle_to_des = (angle_to_xaxis - current_angle);             %angle away from the destination

           %Adjust the angle to be in range [-180, 180]
        if angle_to_des > 180                               
            angle_to_des = angle_to_des - 360 ;
        elseif angle_to_des < -180                          
            angle_to_des = angle_to_des + 360;
        end
                    
        [outputs,input_mf] = evalfis(fs,[distance,angle_to_des]);           %membership function has two outputs, speed and angular_velocity
        
        fprintf("Time: ");
        disp(time);

        weight_of_distance_mf = [input_mf(1,1),input_mf(6,1),input_mf(11,1),input_mf(16,1),input_mf(21,1)];
        weight_of_angle_to_des_mf = [input_mf(1,2),input_mf(2,2),input_mf(3,2),input_mf(4,2),input_mf(5,2)];

        % Output the weight of each membership function
        fprintf("Weight of distance membership function = [%0.3f %0.3f %0.3f %0.3f %0.3f] \n",weight_of_distance_mf)  
        fprintf("Weight of angle membership function = [%0.3f %0.3f %0.3f %0.3f %0.3f] \n",weight_of_angle_to_des_mf)
        
        speed = outputs(1);
        angular_velocity = outputs(2);

        % Output new speed and new angular velocity. Speed is in unit [m/s],
        % and angular velocity is in unit [degree/s]
        fprintf("New Speed = %0.3f m/s \n", speed)
        fprintf("New angular velocity = %0.3f degree/s \n",angular_velocity )
        change_in_angle = angular_velocity * 0.1;                %how much the robot turns in 100ms

        current_angle = current_angle + change_in_angle;         %Current angle after 100ms
        if current_angle > 180                                     % Adjust the angle to be range in [-180, 180]
            current_angle = current_angle - 360 ;
        elseif current_angle < -180
            current_angle = current_angle + 360;
        end

        change_in_x = cos(current_angle/(180/pi)) * speed * 0.1 ; %displacement in x in 100ms
        change_in_y = sin(current_angle/(180/pi)) * speed * 0.1  ;%displacement in y in 100ms
        current_location_x = current_location_x + change_in_x;    %new x
        current_location_y = current_location_y + change_in_y;    %new y
        distance = sqrt((current_location_x-dx)^2+(current_location_y-dy)^2); %current distance away from the destination
        time = time + 0.1; %time past
        fprintf("-------------------------------------------------\n") % Seperation line between each time stamp.
    end
else
    fprintf("Distance is %0.3f, it should be less than 4999 meters.\n",distance); % if distance is higher than 4999m, output this message.
end
disp("Total Time: ") % Output the total time after the robot reaches the destination.
disp(time)



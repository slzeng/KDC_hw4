% Part1.m
clear


for fileIndex = 0:9
   clearvars -except fileIndex
   
   fileIndexString = int2str(fileIndex);
   inFile = ['p1n0' fileIndexString]
   
   fprintf('Processing %s\n', inFile);
   
   % Load the data to be evaluated.
   markerFile = fopen(inFile,'r');
   formatSpec = '%f';
   markerData = fscanf(markerFile,formatSpec);
   fclose(markerFile);

   numValues = size(markerData,1);
   numRows = numValues / 24;

   markerData2 = reshape(markerData,24,numRows)';

   clear markerData;
   markerData{numRows} = ones(3,8);
   for I = 1:numRows
      markerData{I} = markerData2(I,:);  % these are ordered [x1 y1 z1 x2 y2 z2...]
   end

   % initialize the state
   % The state is [x y z x' y' z' q0 q1 q2 q3 wx wy wz]  (1x13)
   markers = markerData{1};
   
   

   [q,t] = markers2pose02(markers); % q: (1x4) t: (1x3)
   X = [t 0 0 0 q 0 0 0];  % Current predicted state
   x = X;   % current best estimate of state
   xMinus1 = x;% last best estimate of state

   % Initialize the A and P matrices.  For the first time ONLY it will be directly
   % specified.  All future iterations will have it be calculated
   P = 0.1*eye(13); % last confidence matrix

   K = zeros(13,24); % Kalman gain
   R = eye(24); % We may not need this

   Q = 1e-7*eye(13);  % The values set in the Q matrix affect how smooth the result is.

   Q(1,1) = 1e-10;
   Q(2,2) = 1e-10;
   Q(3,3) = 1e-10;
   Q(4,4) = 1e-10;
   Q(5,5) = 1e-10;
   Q(6,6) = 1e-10;

   lastZ = X; % used to determine the linear and angular velocities for z
   % z = zeros(24,1);  % this will be modified.  I am setting its size only.
   z = markerData2;

   I = [1.571428571428571, 0, 0;
        0, 5.362637362637362, 0;
        0, 0, 7.065934065934067];

   % for each step we run the prediction equations first then the update
   % equations

   outputMatrix = repmat(X,numRows,1);

   figure(1)
   clf

      
   for i = 1:(numRows-1)
      % ############################
      % ### Prediction equations ###
      % ############################
      
      X = predictNewState(x(i,:)'); % predicted next state
      F = calculateJacobian(@predictNewState,13,13,X); % the jacobian of the next state

      P = F*P*F' + Q;  % predicted covariance estimate

      % ########################
      % ### Update equations ###
      % ########################
      H = calculateJacobian(@pose2markers02,13,24,X); % the jacobian between the state and the markers
      y(i,:) = z(i+1,:)' - pose2markers02(X); % the difference between what we measure and what we predict
      S = H*P*H' + R;   % innovation (or residual) covariance
      K = P*H'*inv(S); % the Kalman gain

      x(i+1,:) = (X + K*y(i,:)')';  % this is the current best estimate of the state
      clf
      %drawAlien02(pose2markers02(x(i,:)'),'k') % the previous best estimate of the state is in black
      %drawAlien02(pose2markers02(X),'r--') % the predicted state is in red and is dotted
      drawAlien02(pose2markers02(x(i+1,:)'),'b') % the best estimate of the state is in blue
      drawAlien02(z(i+1,:)','g') % the raw markers are in green.
      
      % indicate what frame it is processing
      frameString = ['Frame ' int2str(i)];
      text(X(1)-1.5,X(2)-9,frameString);
      
      % Set some limits on the figure to make sure we can see what is going on
      % This centers the alien within the figure 
      xlim([X(1) - 10,X(1) + 10])
      ylim([X(2) - 10,X(2) + 10])
      zlim([X(3) - 10,X(3) + 10])

      drawnow
      


      P = (eye(length(X),length(X))-K*H)*P;

   end % of going through all of the frames
   disp(' ');
   disp('Done!');

   
   
   % Plot out our results
   figure('Position', [1, 100, 1800, 400],'Name',inFile,'NumberTitle','off');
   subplot(1,4,1);
   plot(x(:,1:3)) % position
   subplot(1,4,2); 
   plot(x(:,4:6)); % velocity
   subplot(1,4,3);
   plot(x(:,7:10)); % quaternion
   subplot(1,4,4);
   plot(x(:,11:13));  % angular velocity
   drawnow
   
   % Write our data to an output file.  
   outFile = ['p1a0' fileIndexString];
   outputFile = fopen(outFile,'w');
      for I = 1:numRows
         for J = 1:13
            fprintf(outputFile, '%6.4f\t',x(I,J));
         end
         fprintf(outputFile, '\n');
      end
   fclose(outputFile);

end



% figure(1)
% plot(x)
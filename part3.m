% Part3.m
clear


for fileIndex = 0:9
   clearvars -except fileIndex
   
   fileIndexString = int2str(fileIndex);
   inFile = ['p3n0' fileIndexString];
   
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

   % p = eye(13); % current confidence matrix

   K = zeros(13,24); % Kalman gain

   % H = zeros(13); % model of sensors
   R = eye(24); % We may not need this

   Q = 1e-7*eye(13);

   Q(1,1) = 1e-10;
   Q(2,2) = 1e-10;
   Q(3,3) = 1e-10;
   Q(4,4) = 1e-10;
   Q(5,5) = 1e-10;
   Q(6,6) = 1e-10;

   lastZ = X; % used to determine the linear and angular velocities for z

   z = markerData2;

   I = [1.571428571428571, 0, 0;
        0, 5.362637362637362, 0;
        0, 0, 7.065934065934067];


   disp('Doing the Kalman filtering.');
   fprintf('Processing frame 001');
   for i = 1:(numRows-1)
      fprintf('\b\b\b%03d',i+1);
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

      
% % Uncomment this stuff to see the kalman filtering process
%       clf
%       %drawAlien02(pose2markers02(x(i,:)'),'k') % the previous best estimate of the state is in black
%       %drawAlien02(pose2markers02(X),'r--') % the predicted state is in red and is dotted
%       drawAlien02(pose2markers02(x(i+1,:)'),'b') % the best estimate of the state is in blue
%       drawAlien02(z(i+1,:)','g') % the raw markers are in green.
%       
%       % indicate what frame it is processing
%       frameString = ['Frame ' int2str(i)];
%       text(X(1)-1.5,X(2)-9,frameString);
%       
%       % Set some limits on the figure to make sure we can see what is going on
%       % This centers the alien within the figure 
%       xlim([X(1) - 10,X(1) + 10])
%       ylim([X(2) - 10,X(2) + 10])
%       zlim([X(3) - 10,X(3) + 10])
% 
%       drawnow
      % pause

      P = (eye(length(X),length(X))-K*H)*P;



   end % of going through all of the frames
   disp(' ');
   disp('Done.');

   
   % At this point it has tracked all of the frames.   Let's unrotate/untranslate all 
   % of the artifacts and then find the mean of their markers.  The result should be 
   % the locations of the markers.  The kalman filter doesn't converge for about 100 
   % frames so just skip over the first 99 frames.
   
   unrotatedNoisyMarkers = zeros(numRows-100 +1,24);
   disp('Removing transformations from the noisy markers');
   fprintf('processing frame 100');
   for I = 100:numRows
      fprintf('\b\b\b%d',I);
      unrotatedNoisyMarkers(I-99,:) = markerData2(I,:);
      
      % undo the translation
      tempTranslation = repmat(x(I,1:3),1,8);
      unrotatedNoisyMarkers(I-99,:) = unrotatedNoisyMarkers(I-99,:) - tempTranslation;
      
      % undo the rotation
      tempMatrix = reshape(unrotatedNoisyMarkers(I-99,:),3,8)';  % makes it 8x3
      rotMatrix = quat2rotm(x(I,7:10));
      tempMatrix = tempMatrix * rotMatrix;
      unrotatedNoisyMarkers(I-99,:) = reshape(tempMatrix',1,24);
      
%       % draw stuff to verify that I did things correctly.
%       clf
%       drawAlien02(unrotatedNoisyMarkers(I,:),'k');
%       axis equal
%       drawnow
   end
   fprintf('\n');
   disp('done');
   
   
   % Now find the mean position of the markers
   actualMarkerPositions = mean(unrotatedNoisyMarkers);
   
   % Now reposition these markers using the rotations and translations that
   % were found previously
   
   disp('Putting the adjusted markers back into the proper location');
   repositionedMarkers = zeros(size(x,1),24);
   for I = 1:size(x,1) % Go through every frame
      repositionedMarkers(I,:) = pose2markers03(x(I,:),actualMarkerPositions);
      % draw stuff to verify that I did things correctly.
%       clf
%       drawAlien02(z(I,:),'g');
%       drawAlien02(repositionedMarkers(I,:),'b');
%       xlim([x(I,1) - 10,x(I,1) + 10])
%       ylim([x(I,2) - 10,x(I,2) + 10])
%       zlim([x(I,3) - 10,x(I,3) + 10])
%       drawnow
   end
   
   
   
   
%    % Plot out our results
%    figure('Position', [1, 100, 1800, 400],'Name',inFile,'NumberTitle','off');
%    subplot(1,4,1);
%    plot(x(:,1:3)) % position
%    subplot(1,4,2); 
%    plot(x(:,4:6)); % velocity
%    subplot(1,4,3);
%    plot(x(:,7:10)); % quaternion
%    subplot(1,4,4);
%    plot(x(:,11:13));  % angular velocity
%    drawnow
   
   disp('Writing the output file');
   % Write our data to an output file.  
   outFile = ['p3a0' fileIndexString];
   outputFile = fopen(outFile,'w');
      for I = 1:numRows
         for J = 1:13
            fprintf(outputFile, '%6.4f\t',x(I,J));
         end
         for J = 1:24
            fprintf(outputFile, '%6.4f\t',repositionedMarkers(I,J));
         end
         fprintf(outputFile, '\n');
      end
   fclose(outputFile);

end



% figure(1)
% plot(x)
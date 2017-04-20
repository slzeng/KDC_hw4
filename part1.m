% Part1.m
clear
% TODO:   Modifiy this code to go through all of the files automatically once 
%         we have it working for one of them.  Just need to increment
%         fileIndex in a for loop

fileIndex = 5;
fileIndexString = int2str(fileIndex);
inFile = ['p1n0' fileIndexString]




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

Q = 1e-5*eye(13);

Q(1,1) = 1e-10;
Q(2,2) = 1e-10;
Q(3,3) = 1e-10;
Q(4,4) = 1e-10;
Q(5,5) = 1e-10;
Q(6,6) = 1e-10;

% Q(4,4) = 1e-6;
% Q(5,5) = 1e-6;
% Q(6,6) = 1e-6;

lastZ = X; % used to determine the linear and angular velocities for z
% z = zeros(24,1);  % this will be modified.  I am setting its size only.
z = markerData2;

I = [1.571428571428571, 0, 0;
     0, 5.362637362637362, 0;
     0, 0, 7.065934065934067];
% I = [ 0.7833   -0.0001   -0.0009
%    -0.0001    0.1750     0.0003
%    -0.0009    0.0003    0.5965];
% for each step we run the prediction equations first then the update
% equations

outputMatrix = repmat(X,numRows,1);
covs = [];

figure(1)
clf

for i = 1:(numRows-1)
   % ############################
   % ### Prediction equations ###
   % ############################
   
   % figure out the new A matrix using our dynamic model from the last
   % homework
   % TODO:   Write function that calculates the A matrix
   %A = calculateAmatrix(xMinus1);  % I think that this is what is needed
   %X = A * xMinus1; % no Bu because there is no input


   X = predictNewState(x(i,:)');
   F = calculateJacobian(@predictNewState,13,13,X);

   P = F*P*F' + Q;
   
   % ########################
   % ### Update equations ###
   % ########################
   H = calculateJacobian(@pose2markers02,13,24,X);
   y(i,:) = z(i+1,:)' - pose2markers02(X);
   S = H*P*H' + R;
   K = P*H'*inv(S);

   x(i+1,:) = (X + K*y(i,:)')';
   clf
   drawAlien02(pose2markers02(x(i,:)'),'k')
   drawAlien02(pose2markers02(X),'r--')
   drawAlien02(pose2markers02(x(i+1,:)'),'b')
   drawAlien02(z(i+1,:)','g')
   % xlim([0,30])
   % ylim([-30,0])
   % zlim([-10,20])

   xlim([-25,10])
   ylim([-15,10])
   zlim([-10,10])
   drawnow
   % pause
   
   
   % norm(x(i+1,11:13))
   % pause
   P = (eye(length(X),length(X))-K*H)*P;
   covs(i,:) = diag(P);

   
end % of going through all of the frames



% Write our data to an output file.  
% outFile = ['p1a0' fileIndexString]
% outputFile = fopen(outFile,'w');
%    for I = 1:numRows
%       for J = 1:13
%          fprintf(outputFile, '%6.4f\t',outputMatrix(I,J));
%       end
%       fprintf(outputFile, '\n');
%    end
%    fclose(outputFile);





figure(1)
plot(x)
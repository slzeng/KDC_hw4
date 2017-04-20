function [quaternion, position] = markers2pose02(m)
   % m should be the marker information for a single frame. 

   
   % m is in the form [x1 y1 z1 x2 y2 z2 x3 y3 z3....]
   
   
   % Make it be a (8x3) matrix in the form 
   % [x1 y1 z1]
   % [x2 y2 z2]
   % ...
   % [x8 y8 z8]
   
   m = reshape(m,3,8)';
   
   % position is the location of the COM
   % rotMatrix can be used to rotate a clean, unrotated alien into position
   
   
   % Get the original markers centered around the origin.
   cm =           [-1.5 -3 -4.5;... % cm = clean markers
                   -1.5 -3 -1.5;...
                   -1.5  1 -4.5;...
                   -1.5  1 -1.5;...
                     .5 -3 -4.5;...
                     .5 -3 -1.5;...
                     .5  1 -4.5;...
                     .5  1 -1.5];
   centroidCleanMarkers = mean(cm);

   for I = 1:8
      cm(I,:) = cm(I,:) - centroidCleanMarkers;
   end               

   markers = m;
   centroidNoisyMarkers = mean(markers);

   for J = 1:8
      markers(J,:) = markers(J,:) - centroidNoisyMarkers;
   end  

   % The markers now are centered on the origin and are ready to be compared
   % to the clean markers.

   % Create a covariance matrix between the two marker sets
   covarianceMatrix = cm' * markers;

   [u,~,v] = svd(covarianceMatrix);

   rotMatrix = (v*u');
   rotMatrix = rotMatrix;
   %rotatedmarkers is now oriented properly.  Find the translation.
   position = centroidNoisyMarkers;
   
   % rotate the COM by the same amount and add to the translation that was
   % found
   rotatedCOM = (rotMatrix * (-centroidCleanMarkers)')';
   position = position + rotatedCOM;
   quaternion = rotm2quat(rotMatrix);
end













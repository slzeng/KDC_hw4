function markersOut = pose2markers02(state)
  translation = state(1:3)';
  quaternion = state(7:10)';

   % Get the original markers centered around the origin.
   cm =           [-1.5 -3 -4.5;... % cm = clean markers
                   -1.5 -3  1.5;...
                   -1.5  1 -4.5;...
                   -1.5  1  1.5;...
                     .5 -3 -4.5;...
                     .5 -3  1.5;...
                     .5  1 -4.5;...
                     .5  1  1.5];
                  
   rotationMatrix = quat2rotm(quaternion);
   % rotationMatrix = rotationMatrix*eul2rotm([0,0,pi/2]);               
   markers = rotationMatrix * cm';

   for I = 1:8
      markers(:,I) = markers(:,I) + translation';
   end
   
   markers = markers';
   
   % this new version needs the markers to be in a 24x1 vector
   markersOut = [markers(1,:) markers(2,:) markers(3,:) markers(4,:) markers(5,:) markers(6,:) markers(7,:) markers(8,:)]';
   
   
end
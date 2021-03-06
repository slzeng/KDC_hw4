function markersOut = pose2markers03(state, cleanMarkers)
% This function takes a state and rotates and translates the clean markers
% into position
  translation = state(1:3)';
  quaternion = state(7:10);


   cm = reshape(cleanMarkers,3,8)'; % makes it be 8 rows by 3 columns

   rotationMatrix = quat2rotm(quaternion);            
   markers = rotationMatrix * cm';  %3x3 * 3x8 = 3x8

   for I = 1:8
      markers(:,I) = markers(:,I) + translation;
   end

   markers = markers';

   % this new version needs the markers to be in a 24x1 vector
      markersOut = [markers(1,:) markers(2,:) markers(3,:) markers(4,:) markers(5,:) markers(6,:) markers(7,:) markers(8,:)]';
   
   
end
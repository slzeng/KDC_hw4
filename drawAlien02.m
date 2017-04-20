function drawAlien02(m,color)
   % draws the alien in the specified color
   % The markers are now a 24x1 vector so rearrange them back into the form
   % that I used to use.
   m = reshape(m,3,8)';
   
   hold on;
   % rearrange the markers for easier drawing
   m2 = [m(1,:);...
         m(2,:);...
         m(4,:);...
         m(3,:);...
         m(7,:);...
         m(8,:);...
         m(6,:);...
         m(5,:);...
         m(1,:);...
         m(3,:)];
   plot3(m2(:,1),m2(:,2),m2(:,3),color);
   
   m2 = [m(5,:); m(7,:)];
   plot3(m2(:,1),m2(:,2),m2(:,3),color);
   m2 = [m(8,:); m(4,:)];
   plot3(m2(:,1),m2(:,2),m2(:,3),color);
   m2 = [m(6,:); m(2,:)];
   plot3(m2(:,1),m2(:,2),m2(:,3),color);
   
   axis equal;
end


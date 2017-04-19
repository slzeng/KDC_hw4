function drawAlien03(m,color)
   % draws the alien in the specified color
   % The markers are now a 24x1 vector so rearrange them back into the form
   % that I used to use.
   m = reshape(m,3,8)';
   
   
   
   % Conditionally draw each line segment based on if it has data for both
   % markers or not.  
   hold on;
   conditionallyDrawLineSegment(m(1,:),m(2,:),color);
   conditionallyDrawLineSegment(m(2,:),m(4,:),color);
   conditionallyDrawLineSegment(m(4,:),m(3,:),color);
   conditionallyDrawLineSegment(m(3,:),m(7,:),color);
   conditionallyDrawLineSegment(m(7,:),m(8,:),color);
   conditionallyDrawLineSegment(m(8,:),m(6,:),color);
   conditionallyDrawLineSegment(m(6,:),m(5,:),color);
   conditionallyDrawLineSegment(m(5,:),m(1,:),color);
   conditionallyDrawLineSegment(m(1,:),m(3,:),color);
   conditionallyDrawLineSegment(m(5,:),m(7,:),color);
   conditionallyDrawLineSegment(m(8,:),m(4,:),color);
   conditionallyDrawLineSegment(m(6,:),m(2,:),color);
   axis equal;
end


function conditionallyDrawLineSegment(point1, point2, color)
   point1good = point1(1) ~= 1e10;
   point2good = point2(1) ~= 1e10;
   
   if point1good && point2good
      
      m2 = [point1;point2];
      plot3(m2(:,1),m2(:,2),m2(:,3),color);
   end
end
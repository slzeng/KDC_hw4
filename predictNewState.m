function [next_state] = predictNewState(state) 
    % [COM, trans, angVel, Rot]

    I = [1.571428571428571, 0, 0;
         0, 5.362637362637362, 0;
         0, 0, 7.065934065934067];
    % I = [ 0.7833   -0.0001   -0.0009
    %    -0.0001    0.1750     0.0003
    %    -0.0009    0.0003    0.5965];
    dt = 0.1;
    COM = state(1:3);
    velocity = state(4:6);
    quat = state(7:10);
    angVel = state(11:13);
    
    COM = COM + velocity*dt;
    
    rot = quat2rotm(quat');

    % I = I*rot';
    % angVel = rot'*angVel;
    wdot = inv(I)*(-cross(angVel, I*angVel)); 
    angVel = angVel + wdot.*dt; 
    
    % angVel = rot*angVel_body;

    % dR = [1 -angVel(3)*dt angVel(2)*dt; 
    %       angVel(3)*dt 1 -angVel(1)*dt; 
    %      -angVel(2)*dt angVel(1)*dt 1]; 
    % dR = W*rot
    % det(dR)
    dR = eul2rotm(angVel');
    rot = dR*rot; %multiply on the left since wrt to fixed frame
    quat = rotm2quat(rot);

    next_state = [COM;velocity;quat';angVel];
end
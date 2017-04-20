function [J] = calculateJacobian(func, inputSize, outputSize, x) 

    %[x,y,z,xd,yd,q0,q1,q2,q3,wx,wy,wz]
    delta = 1*10^-7;
    J = zeros(outputSize, inputSize); 
    for i = 1:inputSize 
        varPlus = x; 
        varPlus(i) = varPlus(i) + delta; 
        varMinus = x;
        varMinus(i) = varMinus(i) - delta; 
        J(:,i) = ( func(varPlus) - func(varMinus) )'./(2*delta);
    end 
end 
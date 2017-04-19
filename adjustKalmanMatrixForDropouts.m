function K = adjustKalmanMatrixForDropouts(Kin, inputData)
   % this function takes a look at the input data and makes a column of the
   % K matrix be zeros where it sees a value of 1e10
   % Kin is a 13x24 matrix
   K = Kin;
   for I = 1:24
      if inputData(I) == 1e10
         K(:,I) = zeros(13,1);
      end
   end
   
end
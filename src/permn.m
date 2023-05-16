% PERMN(V,N,K) - return the k-th permutation
% Simplified version of "Jos (10584) (2022). permn (https://www.mathworks.com/matlabcentral/fileexchange/7147-permn), MATLAB Central File Exchange. Retrieved March 1, 2022."
function M = permn(V, N, K)
nV = numel(V);
V = reshape(V, 1, []); % make input a row vector
B = nV.^(1-N:0);
I = ((K(:)-.5) * B); % matrix multiplication
I = rem(floor(I), nV) + 1;
M = V(I);
end

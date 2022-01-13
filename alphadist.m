% function to calculate alpha distance from a vector
% input: V = (v_1,...,v_n) row vector
% example: >> ad = alphadist([35,35,30,30,20])
% output: ad = 0.667, the alpha distance in range [0,1]
function alphadist = alphadist(V)

n = numel(V);
S = sum(V);
v_avg = S/n;
x = min(V);
y = max(V);

eqt = floor((S-n*x)/(y-x));
alpha_w = sum(abs(v_avg - V));
alpha_max = (y - v_avg) * eqt + abs(x - v_avg + mod((S-n*x),(y-x))) + (v_avg - x) * (n - 1 - eqt);

alphadist = alpha_w / alpha_max;

% return zero for NaN
if isnan(alphadist)
    alphadist = 0;
end

end
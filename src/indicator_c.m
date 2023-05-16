% indicator Network Complexity, C = average number of non-redundant arcs per node
function c = indicator_c(DSM)

% todo call standard DSM preprocessor here
n = sum(diag(DSM)>0); % number of non-zero activities (in diagonal)
a = numel(DSM(DSM>0))-n; % number of non-zero arcs (a) 

if (mod(n,2) == 0) % when n is even
    c = min(max((log(a/(n-1))) / (log((n.^2) / (4*n-4))),0),1);
else % when n is odd
    c = min(max((log(a/(n-1))) / (log(((n.^2)-1) / (4*(n-1)))),0),1);
end

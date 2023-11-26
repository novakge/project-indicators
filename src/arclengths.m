% calculate length of arcs for structural indicators
function nl=arclengths(DSM,l,L)
dsm=DSM(diag(DSM)==1,diag(DSM)==1);
W=L(:,1);
nl=0;

% % original version with nested loops
% n=size(dsm,1);
% for i=1:n-1 % check values in rows of upper triangle
%     for j=i+1:n % ...
%         if any(dsm(i,j)) % if there is any precedence relation
%             if abs(W(i)-W(j))==l % that is connected to the next progressive level
%                 nl=nl+1; % increment length
%             end
%         end
%     end
% end

% improved version with vectorization
idx = find(triu(dsm,1) & (abs(W(:) - W(:)')==l)); % store indices of relations for next progressive level
nl = numel(idx); % count number of indices

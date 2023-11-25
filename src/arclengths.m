% calculate length of arcs for structural indicators

function nl=arclengths(DSM,l,L)
dsm=DSM(diag(DSM)==1,diag(DSM)==1);
n=size(dsm,1);
W=L(:,1);
nl=0;

for i=1:n-1
    for j=i+1:n
        if any(dsm(i,j))
            if abs(W(i)-W(j))==l
                nl=nl+1;
            end
        end
    end
end
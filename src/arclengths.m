function nl=arclengths(DSM,l)
dsm=DSM(diag(DSM)==1,diag(DSM)==1);
n=size(dsm,1);
L=pl(dsm);
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
function [BP,RESFUNC]=resfunc(DSM,SST,T,R)
n=numel(T); %Number of elements in vector T
%Initialisation
SFT=SST+T; 
%Forward pass
for i=1:(n-1)
    for j=(i+1):n
        if DSM(i,j)>0 %If there is a dependency between task i and task j...
            if SST(j)<SFT(i) 
                SST(j)=SFT(i);
                SFT(j)=SST(j)+T(j);
            end
        end
    end
end
BP=sort(union(SST,SFT));
b=numel(BP); %number of breakpoints
r=numel(R(1,:)); %number of resources
RESFUNC=zeros(b,r);
for i=1:b
    RESFUNC(i,:)=sum(R(find((SST<=BP(i))&(SFT>BP(i))),:),1); %calculate resource function
end

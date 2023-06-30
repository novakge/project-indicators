%Author: Zsolt T. Kosztyán Ph.D. habil., University of Pannonia,
%Faculty of Economics, Department of Quantitative Methods
%Optimized version: Gergely Novák
%----------------
%Evaluate EST, EFT, LST and LFT times of activity
%Evaluate the project duration. This code contains only 1-depth for cycles
%in order to help the parallelization
%----------------
%Outputs:
%TPT: Total Project Time (scalar)
%EST: Early Start Time (N by 1 vector)
%EFT: Early Finish Time (N by 1 vector)
%LST: Latest Start Time (N by 1 vector)
%LFT: Latest Finish Time (N by 1 vector)
%----------------
%Inputs:
%DSM: Dependeny Structure Matrix (N by N matrix (logic plan))
%T: Duration time (N by 1 vector)
%----------------
%Usage: 
%[TPT,EST,EFT,LST,LFT]=tptfast(DSM,T)
%----------------
%Example: - Calculate TPT and EST,LST,EFT,LFTs
% %    |1,1,0|    |3|
% %DSM=|0,1,0|, T=|4|
% %    |0,0,1|    |5|
%
%[TPT,EST,EFT,LST,LFT]=tptfast([[1,1,0];[0,1,0];[0,0,1]],[3,4,5]')

function [TPT,EST,EFT,LST,LFT]=tptfaster(DSM,T)
DSM=round(DSM); % DSM must be binary matrix
T=real(T); % T must be real
N=numel(T); % Number of elements in vector T
EST=zeros(N,1); % EST will be an N by 1 null vector at the first step
T(diag(DSM)==0)=0; % The escluded task duration is irrelevant=>set to be 0
T=reshape(T,[],1); % T must be column vector
EFT=EST+T; % EFTi=ESTi+Ti (i=1..N)
dsm=triu(DSM,1);
dsm(diag(DSM)==0,:)=0; 
dsm(:,diag(DSM)==0)=0;

for i=1:N % Forward pass
    EST(i:end)=max(dsm(:,i:end).*EFT(:))'; % EST calculated step by step
    EFT(i:end)=EST(i:end)+T(i:end); % EFTi=ESTi+Ti (i=1..N)
end

TPT=max(EFT); % TPT is the makespan of the longest path
LFT=repmat(TPT,N,1); % LFTi=TPT (i=1..N)
LST=LFT-T; % LSTi=LFTi-Ti (i=1..N)
dsm_t = transpose(dsm); % Transpose before loop
TPTDSM=(dsm_t.*LST)'; % Preallocate doing the first step, start with second loop

for i=N:-2:1 % Backward pass
    TPTDSM(i:-1:1,i:-1:1)=(dsm_t(i:-1:1,i:-1:1).*LST(i:-1:1))'; % Calculate LST step by step
    TPTDSM(isnan(TPTDSM) | TPTDSM == 0) = TPT; % Independent tasks' LFT = TPT
    LFT=min(TPTDSM,[],2); % Calculate LFT
    LST(i:-1:1)=LFT(i:-1:1)-T(i:-1:1); % LSTi=LFTi-Ti (i:=1..N)
end
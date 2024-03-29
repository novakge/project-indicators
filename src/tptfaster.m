%Author: Zsolt T. Kosztyán Ph.D. habil., University of Pannonia,
%Faculty of Economics, Department of Quantitative Methods
%Optimization: Gergely L. Novák, Ph.D.
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
%[TPT,EST,EFT,LST,LFT]=tptfaster(DSM,T)
%----------------
%Example: - Calculate TPT and EST,LST,EFT,LFTs
% %    |1,1,0|    |3|
% %DSM=|0,1,0|, T=|4|
% %    |0,0,1|    |5|
%
%[TPT,EST,EFT,LST,LFT]=tptfaster([[1,1,0];[0,1,0];[0,0,1]],[3,4,5]')

function [TPT,EST,EFT,LST,LFT]=tptfaster(DSM,T)
DSM=round(DSM); % DSM must be binary matrix
T=real(T); % T must be real
N=numel(T); % Number of elements in vector T
EST=zeros(N,1); % EST will be an N by 1 null vector at the first step
T(diag(DSM)==0)=0; % The excluded task duration is irrelevant => set to 0
T=reshape(T,[],1); % T must be column vector
EFT=EST+T; % EFTi=ESTi+Ti (i=1..N)
dsm=triu(DSM,1); % Only upper triangle
dsm(diag(DSM)==0,:)=0; % Delete successors
dsm(:,diag(DSM)==0)=0; % Delete predecessors

for i=1:N % Forward pass
    EST(1:i)=max(dsm(1:i,1:i).*EFT(1:i))'; % EST calculated step by step
    EFT(1:i)=EST(1:i)+T(1:i); % EFTi=ESTi+Ti (i=1..N)
end

TPT=max(EFT); % TPT is the makespan of the longest path
LFT=repmat(TPT,N,1); % LFTi=TPT (i=1..N)
LST=LFT-T; % LSTi=LFTi-Ti (i=1..N)
dsm_t = transpose(dsm); % Transpose before loop
TPTDSM = zeros(N, N); % Pre-allocate
TPT_mask = (~dsm_t.*TPT)'; % Create a mask matrix to overwrite all zero with TPT faster

for i=N:-1:1 % Backward pass
    TPTDSM(i:-1:1,i:-1:1) = (dsm_t(i:-1:1,i:-1:1) .* LST(i:-1:1))' + TPT_mask(i:-1:1,i:-1:1); % Calculate LST step by step (overwrite zeros using TPT mask and ignoring precedence relations)
    TPTDSM(TPTDSM == 0) = TPT; % Independent tasks' LFT = TPT, leftovers possible after masking (LFT=T case)
    LFT=min(TPTDSM,[],2,'omitnan'); % Calculate LFT (logical indexing applied before)
    LST(i:-1:1)=LFT(i:-1:1)-T(i:-1:1); % LSTi=LFTi-Ti (i:=1..N)
end

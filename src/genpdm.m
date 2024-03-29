% generates the k-th possible multiproject combination
% sampling is easy by calling the function with the desired arguments e.g. to calculate indicators
% memory efficient as each instance is generated on the fly, no array used for storing all combinations (problem with high number of instances)
% dsmid=the k-th combination of matrix, n=number of tasks, p=number of projects, r=number of resources, tvalues=values for time, rvalues=values for resources 
% example #1: to get the possible iterations ranges for the planned size:
% >> [~,~,dsm_possible,t_possible,r_possible] = genpdm(1,1,1,3,3,1,[0,1],[1,2])
% output  #1: [262143,512,512] // PDM generated with these parameters will be the last combination
% example #2: to get k-th combination with desired sizes
% >> [PDM,num_activities] = genpdm(262143,512,512,3,3,1,[0,1],[1,2])
% output  #2: PDM with the desired k-th combination instance, number of activities array

function [PDM,num_activities,dsm_possible,t_possible,r_possible] = genpdm(dsmid,tid,rid,n,p,r,tvalues,rvalues)

% parameters for generation
n = n; % number of tasks (input parameter)
p = p; % number of projects (input parameter)
r = r; % number of renewable resources
r_values = rvalues; % possible resource demand values to assign
t_values = tvalues; % possible time demand values to assign

num_activities = 0;
for pp=1:p
    num_activities(pp) = n;
end

% calculate values needed for function call
num_bits_dsm = p*(n*(n-1)/2); % number of bits considered, only upper triangle excluding diagonal, only relations
dsm_possible = 2^num_bits_dsm-1; % all possible PDM ids

% prepare all time demand combinations (TD)
t_elem = length(t_values);
t_places = p*n*1;
t_possible = t_elem^t_places;

% prepare all resource demand combinations (RD)
r_elem = length(r_values);
r_places = p*n*r;
r_possible = r_elem^r_places;


% plausibility checks before creating the matrix
if dsmid > dsm_possible || dsmid < 0
    error('DSM combination %d is out of range [0,%d]!\n',dsmid, dsm_possible);
end
if tid > t_possible || tid <= 0
    error('Time combination %d is out of range [1,%d]!\n',tid, t_possible);
end
if rid > r_possible || rid <= 0
    error('Resource combination %d is out of range [1,%d]!\n',rid, r_possible);
end

% create DSM combination
DSM = eye(p*n,p*n); % initialize PDM=DSM+RD+TD
bits = bitshift(1,num_bits_dsm-1:-1:0); % bitshift for decimal to binary directly
bits(bits==0) = 0.001; % avoid division by zero with a small epsilon value
digits = rem(floor(dsmid./bits),2); % create the k-th dependency combination for n tasks

% create LD combination
id = 1;
for prj=1:p
    for tsk=(prj*n)-n+1:prj*n
        for dep=tsk+1:prj*n
        	DSM(tsk,dep) = digits(id);
            id = id + 1;
        end
    end
end

% create TD combination
TD = permn(t_values,t_places,tid)'; % transpose to column vector

% create RD combination
RD = permn(r_values,r_places,rid); % transpose not necessary
RD = reshape(RD,[],r); % then split into r columns

% create dummy cost domain
CD = zeros(size(DSM,1),1);

% return merged PDM
PDM = [DSM TD CD RD]; % hint: sparse matrix actually takes more storage & computation time

end % function

% Old implementations of TD and RD, a bit slower than actual based on permn
% TD = zeros(t_places,1);
% t_temp = zeros(t_places,1);
% for i=1:tid
%     TD(:,1) = t_values(t_temp+1);
%     for j=t_places:-1:1
%         t_temp(j,1) = t_temp(j,1)+1;
%         if (t_temp(j,1) == t_elem)
%             t_temp(j,1) = 0;
%         else
%             break;
%         end
%     end
% end
%
% create RD combination
% RD = zeros(r_places,1); % use rx1 instead of rxr and split later
% r_temp = zeros(r_places,1);
% for k=1:rid
%     RD(:,1) = r_values(r_temp+1);
%     
%     for m=r_places:-1:1
%         r_temp(m,1) = r_temp(m,1)+1;
%         if (r_temp(m,1) == r_elem)
%             r_temp(m,1) = 0;
%         else
%             break;
%         end
%     end
% end
% RD = reshape(RD,[],r); % then split into r columns

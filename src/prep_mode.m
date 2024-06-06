% function prep_mode: preprocess PDM by removing all redundant and inefficient modes to reduce search space by updating UB constraint vectors
function [PDM,UBcon] = prep_mode(PDM, num_r_resources, num_modes)

% input #1 PDM (matrix)
%PDM = [1,0,0 3,3,3, -1,-1,-1, 1,1,1  1,1,1;
%       0,1,0 3,3,3, -1,-1,-1, 2,3,2  2,3,2;
%       0,0,1 3,3,3, -1,-1,-1, 4,4,6  4,4,6];

% input #2 number of renewable resources
% input #3 number of execution modes

% example
% [PDM,UBcon] = prep_mode(PDM,3,4) % 3 resources with 4 modes

% output #1 modified PDM matrix without redundant/inefficient modes
% output #2 updated upper bound constraint vector

% prepare short handles
n = size(PDM,1);
r = num_r_resources;
w = num_modes;

% prepare vector for new upper bound constraints
UBcon = w*ones(n,1); % init to number of modes, update later for removed modes

% extract TD, CD, RD submatrices with modes from PDM
CD = PDM(:,n+w+1:n+2*w);
TD = PDM(:,n+1:n+w);
RD = PDM(:,n+2*w+1:n+2*w+w*r);

%% reprocess modes, e.g., having the same time and the same resource demands between modes of each renewable resources
%% rule #1 -> redundant nodes with same values of time and resource demands
%% rule #2 -> inefficient modes
% check time demand of each mode
% if time demand is equal but there is greater or equal for all resources, remove inefficient mode
% if resource demands are the same for all resources, and time is higher or equal, remove the mode


for ww=1:w % maximum number of iterations needed is the number of modes (or a stop condition)
    % reset all indices of duplicated time values
    duplicate_res_ind = zeros(n,r*w);

    for task=1:n % tasks

        for mode=1:w-1 % current mode

            for mode_ref=mode+1:w % next mode

                if TD(task,mode) > 0 && TD(task,mode_ref) > 0 % not zero

                    if TD(task,mode) > TD(task,mode_ref) % time is higher

                        for res=1:r % check modes within resources for inefficiency, always keep lower value

                            if RD(task, (res*w-w) + mode) > 0 && RD(task, (res*w-w) + mode_ref) > 0 % not zero

                                if RD(task, (res*w-w) + mode) > RD(task, (res*w-w) + mode_ref) % 1st value is greater
                                    duplicate_res_ind(task, (res*w-w) + mode) = 1; % mark 1st to remove
                                    
                                elseif RD(task, (res*w-w) + mode) == RD(task, (res*w-w) + mode_ref) % the 2nd is greater
                                    duplicate_res_ind(task, (res*w-w) + mode) = 1; % mark both to remove
                                    duplicate_res_ind(task, (res*w-w) + mode_ref) = 1; % mark both to remove
                                end

                            end
                        end % time higher, resource higher or equal case

                    elseif  TD(task,mode) == TD(task,mode_ref) % time is equal

                        for res=1:r % check modes within resources for inefficiency, always keep lower value
                            if RD(task, (res*w-w) + mode) > 0 && RD(task, (res*w-w) + mode_ref) > 0 % not zero

                                if RD(task, (res*w-w) + mode) > RD(task, (res*w-w) + mode_ref) % 1st value is greater
                                    duplicate_res_ind(task, (res*w-w) + mode) = 1; % mark 1st to remove
                                elseif RD(task, (res*w-w) + mode) < RD(task, (res*w-w) + mode_ref) % the 2nd is greater
                                    duplicate_res_ind(task, (res*w-w) + mode_ref) = 1; % mark 2nd to remove
                                else % both equal
                                    duplicate_res_ind(task, (res*w-w) + mode) = 1; % mark both to remove
                                    duplicate_res_ind(task, (res*w-w) + mode_ref) = 1; % mark both to remove
                                end
                            end
                        end % time equal, resource higher or equal case
                    end
                end % time
            end % reference mode

        end % mode

        % sum up results for each resource and each mode and remove where necessary
        for mm=1:w
            rem_count = 0;

            for rr=1:r
                if duplicate_res_ind(task,(rr*w-w)+mm) == 1
                    rem_count = rem_count + 1; % keep track of same modes found
                end
            end

            if rem_count == r % if all resources have the same or greater values for same modes e.g., mode1res1 equals mode1res2 than mode1 can be removed for both res1-2

                % remove the higher and avoid to remove both duplicate so that no mode left
                PDM = rem_mode(PDM,task,mm,r,w);

                % reconstruct submatrices
                CD = PDM(:,n+w+1:n+2*w);
                TD = PDM(:,n+1:n+w);
                RD = PDM(:,n+2*w+1:n+2*w+w*r);

                UBcon(task) = UBcon(task) - 1; % decrease upper bound (or increase lower bound in case of right-shift)

                break;
            end
        end

    end % task
end % "while"

PDM; % return

% rule #3 -> infeasible modes -> only for nonrenewable resources, ignore

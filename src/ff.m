% calculate indicator Free Float (Slack)
function FF = ff(DSM, EST, EFT)

n = size(DSM,1); % number of activities in DSM
FF = Inf(n,1); % pre-allocate variable to store Free Float of all tasks
FF(n,1) = 0; % last element always has zero free float

for i=1:n-1 % forward pass
    for j=(i+1):n
        if DSM(i,i) > 0
            if DSM(j,j) > 0
                if DSM(i,j) > 0 % task i and task j are connected
                    if (EST(j) - EFT(i) > 0) % free float should be non-zero
                        if (EST(j) - EFT(i) < FF(i)) % should be the minimum
                            FF(i) = EST(j) - EFT(i); % of all successors' early start - early finish of current task
                        end
                    end
                end
            end
        end
    end % j
    if FF(i) == Inf
        FF(i) = 0; % store the minimum free float or zero for task i
    end
end % i
end

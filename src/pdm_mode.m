% function to extract a single-mode PDM based on a mode selection vector

function PDM_mode = pdm_mode(PDM,w,r,n,mode_selection) % function to get the PDM for a vector containing selected modes

% extract DSM
DSM = PDM(:,1:n);

% create dummy CD
CD = zeros(n,1); % cost is not supported yet

% extract TD for the w-th mode t1 t2 ... tw
TD = zeros(n,1);
for i = 1:n
    TD(i) = PDM(i,n+round(mode_selection(i))); % if it is not an integer, round the index
end

% extract RD for mode w: r1w1 r1w2 ... r2w1 r2w3 r2w3 ... rrww
RD = zeros(n,r);
for i=1:n
    for j=1:r
        RD(i,j) = PDM(i, n + (2*w) + (j*w) - w + round(mode_selection(i))); % get resources for actual mode (ordered by modes)
    end
end

% re-construct PDM with the combination of modes
PDM_mode = [DSM,TD,CD,RD];

end
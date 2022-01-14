extension_filter = '*.mat'; % select extension
directory = 'test';
browse_dir = fullfile(directory, extension_filter); % look for all files with the extension in given subfolder
files = dir(browse_dir);

for i=1:size(files) % iterate through all files in given directory
    
    % prepare inputs
    load(fullfile(directory,files(i).name),'PDM','constr','num_r_resources','num_modes','num_activities','sim_type');
    
    % check (multi)project size based on number of activities row vector
    num_projects = numel(num_activities); % note: all tasks, might include zeros/flexible ones
    
    if (num_projects) > 1
       	% pre-calculate start-end offset of each project based on number of activities
        prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
        prj_ends = cumsum(num_activities(1:end));
        n = sum(num_activities);
        r = num_r_resources;
        
        % get individual elements of PDM from the superset
        PDMs = {};
        DSMs = {};
        RDs  = {};
        TDs  = {};
        CDs  = {};
        % get PDM for each project
        for j = 1:num_projects
            DSMs{j} = PDM(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j)); % get single DSMs for all project
            TDs{j}  = PDM(prj_starts(j):prj_ends(j),n+1); % get single (n x 1) time domain matrices for all projects
            CDs{j}  = PDM(prj_starts(j):prj_ends(j),n+2); % get single (n x 1) cost domain matrices for all projects
            RDs{j}  = PDM(prj_starts(j):prj_ends(j),n+2+1:n+2+r); % get single (n x r) resource domain matrices for all projects
            % merge to separate PDMs
            PDMs{j} = [DSMs{j} TDs{j} CDs{j} RDs{j}];
        end
    end
    
    % and for e.g. the RS's alphadistance (variation) we need separate values also, the aggregate RS is already fine.
    % TODO: handle zero tasks globally here, not separately in all indicators
    % TODO: only single mode is supported at the moment
    
    
    
    % indicators using DSM(s) as input
    DSM = PDM(:,1:size(PDM,1)); % number of rows is used instead of num_activities as it can be a row vector for multiprojects
    c = indicator_c(DSM);
    cnc = indicator_cnc(DSM);
    
    
    % get local indicators
    for j=1:num_projects
        [i1(j),i2(j),i3(j),i4(j),i5(j),i6(j)] = indicators(DSMs{j});
        os(j) = indicator_os(DSMs{j});
    end
    
    % get global indicators
    os_s = indicator_os(DSM);
    [i1_s,i2_s,i3_s,i4_s,i5_s,i6_s] = indicators(DSM);
    
    % get alpha distance
    alpha_i1 = alphadist(i1); % number of activities already considers flexible tasks
    alpha_i2 = alphadist(i2); % serial-parallel indicator already considers flexible tasks
    
    xdensity = indicator_xdensity(DSM);
    tdensity = indicator_tdensity(DSM);
    
    
    % indicators using PDM as input
    PDM = PDM;
    [XDUR,VADUR] = indicator_duration(PDM, 1);
    [NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK] = indicator_slack(PDM, 1);
    gini = indicator_gini(PDM, num_r_resources);
    
    
    
    
    % indicators using PSM as input, if it is a multimode, select one (first) mode only
    PSM=PDM;
    [arlf,narlf,narlf_] = indicator_narlf(PSM, num_activities, num_r_resources);
    [RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL,TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT] = indicators_resource(PSM,num_r_resources,constr);
    % TODO group individual indicators (separate DSMs) and global ones (DSM superset)
    
    % calculate a_RS from individual values here before averaging
    a_RS = alphadist(RS);
    % average RS here when alpha_RS is already calculated
    RS=mean(RS);
    
    
    
    % further indicators go here:
    % UF, varUF
    % MP Multi-project Parallellity
    % MF Multi-project Float
    % CR ???
    % RD Resource Dedication
    % PD Project Dedication
    % IS Independence Strength;
    % a_IS variation of IS

    % TODO UF / MAUF check
    % TODO multiproject version, maybe divide only here with TPT_MAX (TPT OF DMSset)
    
end



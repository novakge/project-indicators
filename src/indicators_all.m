% wrapper script to batch run all (multi)project indicators for the different flexibility factors

clear % clear all obsolete variables

% constants
extension_filter = '*.mat'; % select extension
dir_src = '../src/'; % where the code is stored
dir_in = '../data/'; % directory containing dataset
dir_done = '../results/'; % where to move processed data instances to be able to continue where left off
dir_gen = '../results/'; % where to save all generated flexible mat files

dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember( {dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory

currdate = datestr(now,'yyyymmdd-HHMMSS');
[~,~] = mkdir(dir_gen); % always create dir, ignore if existing
results = strcat(dir_gen,'results-',currdate,'.csv');
data = fopen(results,'w');

% parameters
rng = 123; % initialize random seed for reproducibility
substruct_type = ["maximal","maximin","minimax","minimal"]; % pre-defined flexible->fixed structures
ff = [0,0.1,0.2,0.3,0.4]; % flexibility factors array (containing flexibility parameters - fp)


% start to store header in file
fprintf(data,'type;subtype;filename;c;cnc;XDUR;VADUR;os;NSLACK;PCTSLACK;XSLACK;XSLACK_R;TOTSLACK_R;MAXCPL;NFREESLK;PCTFREESLK;XFREESLK;tdensity;xdensity;fr;sr;fp;num_modes;num_activities;num_r_resources;rf;mean(ru);ru;mean(pctr);pctr;xdmnd;dmnd;mean(rs);rs;mean(rc);rc;xutil;util;xcon;tcon;totofact;ofact;ufact;totufact;database;');
% extended indicators list
fprintf(data,'num_projects;sum(num_activities);a_RS;alpha_i1;alpha_i2;arlf;narlf;narlf_;c_total;cnc_total;DMND_total;gini;gini_total;i1;i1_total;i2;i2_total;i3;i3_total;i4;i4_total;i5;i5_total;i6;i6_total;MAXCPL_total;NFREESLK_total;NSLACK_total;OFACT_total;os_total;PCTFREESLK_total;mean(PCTR_total);PCTR_total;PCTSLACK_total;mean(RC_total);RC_total;RF_total;mean(RS_total);RS_total;mean(RU_total);RU_total;TCON_total;tdensity_total;TOTOFACT_total;TOTSLACK_R_total;TOTUFACT_total;UFACT_total;UTIL_total;VADUR_total;XCON_total;xdensity_total;XDMND_total;XDUR_total;XFREESLK_total;XPCTR_total;XRC_total;XRS_total;XRU_total;XSLACK_R_total;XSLACK_total;XUTIL_total;');
% extended list with mean values
fprintf(data,'mean(c);mean(cnc);mean(XDUR);mean(VADUR);mean(os);mean(NSLACK);mean(PCTSLACK);mean(XSLACK);mean(XSLACK_R);mean(TOTSLACK_R);mean(MAXCPL);mean(NFREESLK);mean(XFREESLK);mean(tdensity);mean(xdensity);mean(RF);mean(XDMND);mean(XUTIL);mean(XCON);mean(TOTOFACT);mean(OFACT);mean(UFACT);mean(TOTUFACT);mean(DMND_total);mean(gini);mean(i2);mean(i3);mean(i4);mean(i5);mean(i6);mean(OFACT_total);mean(UFACT_total);mean(ap);ap_total;mean(comps);comps_total;mean(degrees_total);mean(NARC);NARC_total;NARC_inter;NARC_inter_ratio;mode\n'); % stop with newline


for d=1:size(dirlist,1) % go through all directories
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    % store actual database folder name for output folder
    folder_mirror = strsplit(browse_dir,filesep); % get name of database
    
    % TEST ONLY: PRELIMINARY RUN WITH randomly selected instance samples from each dataset (directory), for the final run, this must be removed!
    % filelist = filelist(randsample(size(filelist,1),20));
    
    % load all files in the defined folder and calculate all indicators
    for i=1:size(filelist)
        
        % load variables from next file
        release_dates = 0; % available only for multiprojects, initialize
        load(fullfile(filelist(i).folder,filelist(i).name),'PDM','constr','num_r_resources','num_modes','num_activities','sim_type','release_dates');
        
        % get number of projects based on number of activities vector
        num_projects = numel(num_activities); % can change later on with flexibility
        n = sum(num_activities); % n is the total number of each projects activities, can change later on with flexibility
        r = num_r_resources; % number of renewable resources
        w = num_modes; % number of execution modes
        

        
        % calculate initial start-end offset of each project based on number of activities
        prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
        prj_ends = cumsum(num_activities(1:end));
        DSM_global = PDM(:,1:size(PDM,1)); % DSM will be the same for all modes
        
        % generating flexibility for all defined structures
        % random (uniform) generation for all potential (=1) tasks/dependencies between [0,1]
        fixed_indexes = DSM_global==1; % find all fixed tasks/dependency positions in the DSM (diagonal)
        fixed_task_indexes = logical(fixed_indexes - triu(fixed_indexes,1)); % keep the diagonal, indexes of tasks
        fixed_dep_indexes = triu(fixed_indexes,1); % keep the upper triangle, indexes of dependencies
        
        flex_task_rand = rand(1,nnz(fixed_task_indexes)); % create a vector with random numbers, i.e., maximal set of possible flexible tasks
        flex_dep_rand = rand(1,nnz(fixed_dep_indexes)); % create a vector with random numbers, i.e., maximal set of possible flexible dependencies
        
        for mode=1:num_modes % select different modes
            
            % extract PDM for a given mode (time, resource)
            DSM_mode = PDM(:,1:size(PDM,1)); % DSM will be the same for all modes but need to reset
            
            TD_mode = PDM(:,size(PDM,1)+mode); % get durations of actual mode
            CD_mode = zeros(n,1); % cost is always zero for the given mode
            RD_mode = PDM(:,n+2*w+(mode-1)*r+1:n+2*w+(mode-1)*r+r); % get resources for actual mode (ordered by modes)
            
            PDM_mode = [DSM_mode TD_mode CD_mode RD_mode]; % merge to PDM
            
            orig_done = 0; % init/reset flag to skip further original=maximal (ff=0) structures
            
            for s=1:numel(substruct_type) % calculate indicators for each defined structure
                
                for k=1:numel(ff) % calculate indicators for each flexibility factor
                    
                    if ((substruct_type(s) == "maximal" || ff(k) == 0) && (orig_done == 1))
                        continue; % skip maximal or original ff=0 structures after the first was already generated
                    end
                    
                    % always reset global PDM and DSM for each flexibility version (max,maxmin,minmax,min...,etc.)
                    PDM_global = PDM_mode;
                    DSM_global = PDM_mode(:,1:size(PDM,1)); % number of rows is used instead of num_activities as it can be a row vector for multiprojects
                    
                    flex_task_values = flex_task_rand; % always reset, later tailor to the specific flexibility
                    flex_dep_values = flex_dep_rand; % always reset, later tailor to the specific flexibility
                    
                    flex_task_values(flex_task_rand>ff(k)) = 1; % tasks greater than the flexibility ratio will be re-written with 1
                    flex_dep_values(flex_dep_rand>ff(k)) = 1; % dependencies greater than the flexibility ratio will be re-written with 1
                    
                    % put flexible values already to DSM for calculating the f-ratio and s-ratio before removing any tasks/dependencies
                    PDM_global(fixed_task_indexes) = flex_task_values;
                    PDM_global(fixed_dep_indexes) = flex_dep_values;
                    
                    fr = fratio(PDM_global); % ratio of flexible dependencies
                    sr = sratio(PDM_global); % ratio of supplementary tasks
                    
                    switch substruct_type(s)
                        
                        case "maximal" % maximal (original) case
                            flex_task_values(flex_task_rand<=ff(k)) = 1; % tasks lower than or equal to the flexibility ratio will be included
                            flex_dep_values(flex_dep_rand<=ff(k)) = 1; % dependencies lower than or equal to the flexibility ratio will be included
                            
                            orig_done = 1; % keep track of original structure, do it only once
                        
                        case "maximin" % maximin case - flexible dependencies will be zeroed
                            flex_task_values(flex_task_rand<=ff(k)) = 1; % tasks lower than or equal to the flexibility ratio will be included
                            flex_dep_values(flex_dep_rand<=ff(k)) = 0; % dependencies lower than or equal to the flexibility ratio will be zeroed
                        
                        case "minimax" % minimax case - flexible tasks will be zeroed
                            flex_task_values(flex_task_rand<=ff(k)) = 0; % tasks lower than or equal to the flexibility ratio will be zeroed
                            flex_dep_values(flex_dep_rand<=ff(k)) = 1; % dependencies lower than or equal to the flexibility ratio will be included
                                                    
                        case "minimal" % minimal case - flexible tasks/dependencies will be zeroed
                            flex_task_values(flex_task_rand<=ff(k)) = 0; % tasks lower than or equal to the flexibility ratio will be zeroed
                            flex_dep_values(flex_dep_rand<=ff(k)) = 0; % dependencies lower than or equal to the flexibility ratio will be zeroed
                       
                        otherwise
                            disp('Error: undefined structure!')
                    end
                    
                    % apply the already decided flexible values for the PDM also
                    PDM_global(fixed_task_indexes) = flex_task_values;
                    PDM_global(fixed_dep_indexes) = flex_dep_values;
                    
                    % re-count number of tasks remaining for each original project after flexible ones will be removed based on original structure
                    num_activities_flex = []; % reset every loop to avoid leftovers at original indices when projects are removed
                               
                    for j=1:num_projects
                        num_activities_flex(j) = nnz(diag(PDM_global(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j))));
                    end
                    num_activities_flex = nonzeros(num_activities_flex)';

                    
                    % then remove zero tasks and their demands + dependencies
                    DSM_global = PDM_global(:,1:size(PDM_global,1)); % update DSM_global before removing tasks
                    PDM_global(diag(DSM_global==0),:)=[]; % remove all less-than-or-equal to flexibility factor activities and their dependencies from PDM
                    PDM_global(:,diag(DSM_global)==0)=[]; % remove all less-than-or-equal to flexibility factor activities and their dependencies and demands from PDM
                    DSM_global = PDM_global(:,1:size(PDM_global,1)); % update DSM_global after removing tasks
                    
                    % re-calculate total number of activities without supplementary tasks and flexible dependencies after all removed
                    n_flex = sum(num_activities_flex); % total number of activities now without flexible tasks and dependencies equivalent to sum(num_activities)
                    num_projects_flex = nnz(num_activities_flex); % consider removed projects also
                    release_dates_flex = zeros(1,num_projects_flex); % update optional release dates with flexible number of projects
                    
                    % re-calculate start-end offset of each project based on number of activities
                    prj_starts_flex = cumsum([1,num_activities_flex(1:end-1)]); % starting with 1 for the first project, ignoring last entry
                    prj_ends_flex = cumsum(num_activities_flex(1:end));
                    
                    % for a multiproject, extract local content from the superset PDM
                    % prepare cells for individual elements of the PDM superset
                    PDM_local = {};
                    DSM = {};
                    RD  = {};
                    TD  = {};
                    CD  = {};
                    
                    % get all separate domains of each project
                    for j = 1:num_projects_flex
                        DSM{j} = PDM_global(prj_starts_flex(j):prj_ends_flex(j),prj_starts_flex(j):prj_ends_flex(j)); % get single DSMs for all project
                        TD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+1); % get single (n x 1) time domain matrices for all projects
                        CD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+2); % get single (n x 1) cost domain matrices for all projects
                        RD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+2+1:n_flex+2+r); % get single (n x r) resource domain matrices for all projects
                        
                        PDM_local{j} = [DSM{j} TD{j} CD{j} RD{j}]; % concatenate for separate PDMs
                    end
                    
                    
                    % start calculating different indicators
                    %% local DSM based indicators (logical structure) calculated for individual projects
                    i1=0;
                    i2=0;
                    i3=0;
                    i4=0;
                    i5=0;
                    i6=0;
                    c=0;
                    cnc=0;
                    os=0;
                    xdensity=0;
                    tdensity=0;
                    g=0;
                    ap=0;
                    comps=0;
                    cut=0;
                    bins=0;
                    degrees=0;
                    narc=0;
                    narc_inter=0;
                    narc_inter_possible=0;
                    
                    for j=1:num_projects_flex
                        [i1(j),i2(j),i3(j),i4(j),i5(j),i6(j)] = indicators(DSM{j});
                        c(j) = indicator_c(DSM{j});
                        cnc(j) = indicator_cnc(DSM{j});
                        os(j) = indicator_os(DSM{j});
                        
                        xdensity(j) = indicator_xdensity(DSM{j});
                        tdensity(j) = indicator_tdensity(DSM{j});
                        
                        g = graph(DSM{j},'upper','omitSelfLoops');
                        [~,cut] = biconncomp(g);
                        bins = conncomp(g);
                        ap(j) = numel(cut); % numer of articulation points
                        comps(j) = max(bins); % number of connected components
                        degrees(j) = mean(degree(g));
                        narc(j) = numel(DSM{j}(triu(DSM{j},1)>0)); % number of arcs for each DSM
                    end
                    % get alpha distances (variaton)
                    alpha_i1 = alphadist(i1); % number of activities already considers flexible tasks
                    alpha_i2 = alphadist(i2); % serial-parallel indicator already considers flexible tasks
                    
                    
                    %% global DSM based indicators (logical structure) calculated for combined project
                    [i1_total,i2_total,i3_total,i4_total,i5_total,i6_total] = indicators(DSM_global); % deal(-1);
                    c_total = indicator_c(DSM_global);
                    cnc_total = indicator_cnc(DSM_global);
                    os_total = indicator_os(DSM_global);
                    
                    xdensity_total = indicator_xdensity(DSM_global);
                    tdensity_total = indicator_tdensity(DSM_global);
                    
                    g = graph(DSM_global, 'upper', 'omitSelfLoops'); % or remove ones from diagonal
                    [~,cut] = biconncomp(g);
                    bins = conncomp(g);
                    comps_total = max(bins); % get number of connected components of graph
                    ap_total = numel(cut); % numer of global articulation points
                    degrees_total = mean(degree(g));
                    narc_total = numel(DSM_global(triu(DSM_global,1)>0)); % number of arcs for superset DSM
                    
                    % number of inter-project (portfolio) precedence relations
                    DSM_inter = DSM_global;
                    for j=1:num_projects_flex
                        DSM_inter(prj_starts_flex(j):prj_ends_flex(j),prj_starts_flex(j):prj_ends_flex(j)) = 0; % remove all tasks and intra-project dependencies from global matrix
                        narc_inter_possible = narc_inter_possible + num_activities_flex(j)*(num_activities_flex(j)-1)/2; % calculate upper triangles (excluding diagonal) of individual projects, i.e. n(n-1)/2
                    end
                    narc_inter = nnz(triu(DSM_inter,1));
                    % ratio of intra-project and inter-project precedence relations
                    narc_inter_ratio = narc_inter / narc_inter_possible;
                    % division by zero is unlikely, but if happens, replace NaN with 0
                    if isnan(narc_inter_ratio)
                        narc_inter_ratio=0;
                    end
                    
                    %% local PDM based indicators calculated for individual projects
                    
                    % time and resource related indicators
                    XDUR=0;
                    VADUR=0;
                    NSLACK=0;
                    PCTSLACK=0;
                    XSLACK=0;
                    XSLACK_R=0;
                    TOTSLACK_R=0;
                    MAXCPL=0;
                    NFREESLK=0;
                    PCTFREESLK=0;
                    XFREESLK=0;
                    gini=0;
                    for j=1:num_projects_flex
                        % activity duration related
                        [XDUR(j),VADUR(j)] = indicator_duration(PDM_local{j},1);
                        
                        % slack related
                        [NSLACK(j),PCTSLACK(j),XSLACK(j),XSLACK_R(j),TOTSLACK_R(j),MAXCPL(j),NFREESLK(j),PCTFREESLK(j),XFREESLK(j)] = indicator_slack(PDM_local{j},1);
                        
                        % resource related
                        gini(j) = indicator_gini(PDM_local{j}, num_r_resources);
                    end
                    
                    
                    %% global PDM based indicators calculated for combined project
                    
                    % time and resource related indicators
                    % activity duration related
                    [XDUR_total,VADUR_total] = indicator_duration(PDM_global, 1);
                    
                    % slack related
                    [NSLACK_total,PCTSLACK_total,XSLACK_total,XSLACK_R_total,TOTSLACK_R_total,MAXCPL_total,NFREESLK_total,PCTFREESLK_total,XFREESLK_total] = indicator_slack(PDM_global,1);
                    
                    % resource related
                    gini_total = indicator_gini(PDM_global, num_r_resources);
                    
                    % Note: multiprojects we have only single mode databases at the moment
                    
                    % global calculations
                    % resource related
                    [arlf,narlf,narlf_] = indicator_narlf(PDM_global, num_activities_flex, num_r_resources, release_dates_flex);
                    % global vs local calculation might differ
                    [RF_total,RU_total,PCTR_total,DMND_total,XDMND_total,RS_total,RC_total,UTIL_total,XUTIL_total,TCON_total,XCON_total,OFACT_total,TOTOFACT_total,UFACT_total,TOTUFACT_total] = indicators_resource(PDM_global,num_r_resources,constr); % TPT_max information is not needed as the DSM superset is given
                    % calculate a_RS from individual values here before averaging
                    a_RS = alphadist(RS_total);
                    % average RS when alpha_RS is already calculated
                    XPCTR_total=mean(PCTR_total); %
                    XRS_total=mean(RS_total); %
                    XRU_total=mean(RU_total); %
                    XRC_total=mean(RC_total); %
                    
                    % local calculations
                    RF=0;
                    RU={};
                    PCTR={};
                    DMND={};
                    XDMND=0;
                    RS={};
                    RC={};
                    UTIL={};
                    XUTIL=0;
                    TCON={};
                    XCON=0;
                    OFACT={};
                    TOTOFACT=0;
                    UFACT={};
                    TOTUFACT=0;
                    for j = 1:num_projects_flex
                        [RF(j),RU{j},PCTR{j},DMND{j},XDMND(j),RS{j},RC{j},UTIL{j},XUTIL(j),TCON{j},XCON(j),OFACT{j},TOTOFACT(j),UFACT{j},TOTUFACT(j)] = indicators_resource(PDM_local{j},num_r_resources,constr,MAXCPL_total); % TPT_max information is given as separate PDMs are given as inputs but we need the longest CPL
                    end
                    
                    %% Output for each flexible structure variant
                    % write variables in defined order to a csv file
                    if ff(k) == 0
                        struct_type = 'max';
                    else
                        struct_type = 'min';
                    end
                    % print results into file
                    
                    % section #1
                    fprintf(data,'%s;%s;%s;[%s];[%s];[%s];[%s];[%s];', struct_type, substruct_type(s), filelist(i).name, num2str(c), num2str(cnc), num2str(XDUR), num2str(VADUR), num2str(os));
                    fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];', num2str(NSLACK), num2str(PCTSLACK), num2str(XSLACK), num2str(XSLACK_R), num2str(TOTSLACK_R), num2str(MAXCPL), num2str(NFREESLK), num2str(PCTFREESLK), num2str(XFREESLK));
                    fprintf(data,'[%s];[%s];%s;%s;%s;%s;[%s];', num2str(tdensity), num2str(xdensity), num2str(fr), num2str(sr), num2str(ff(k)), num2str(num_modes), num2str(num_activities_flex));
                    fprintf(data,'%s;[%s];%s;[%s];%s;[%s];[%s];[%s];%s;[%s];%s;[%s];', num2str(num_r_resources), num2str(RF), num2str(mean(cell2mat(RU(:)))), num2str(cellfun(@mean, RU)), num2str(mean(cell2mat(PCTR(1,:)))), num2str(mean(cell2mat(PCTR(:)))), num2str(XDMND), num2str(cell2mat(DMND)), num2str(XRS_total), num2str(cell2mat(RS)), num2str(XRC_total), num2str(cell2mat(RC)));
                    fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];%s;', num2str(XUTIL), num2str(cell2mat(UTIL)), num2str(XCON), num2str(cell2mat(TCON)), num2str(TOTOFACT), num2str(cell2mat(OFACT)), num2str(cell2mat(UFACT)), num2str(TOTUFACT), dirlist(d).name);
                    
                    % section #2
                    fprintf(data,'%s;%s;%s;%s;%s;', num2str(num_projects_flex), num2str(sum(num_activities_flex)),num2str(a_RS),num2str(alpha_i1),num2str(alpha_i2));
                    fprintf(data,'%s;%s;%s;%s;%s;[%s];', num2str(arlf),num2str(narlf),num2str(narlf_),num2str(c_total),num2str(cnc_total),num2str(DMND_total));
                    fprintf(data,'%s;%s;[%s];%s;[%s];%s;[%s];%s;[%s];%s;[%s];%s;[%s];%s;', num2str(gini),num2str(gini_total),num2str(i1),num2str(i1_total),num2str(i2),num2str(i2_total),num2str(i3),num2str(i3_total),num2str(i4),num2str(i4_total),num2str(i5),num2str(i5_total),num2str(i6),num2str(i6_total));
                    fprintf(data,'%s;%s;%s;[%s];%s;%s;%s;[%s];%s;%s;[%s];', num2str(MAXCPL_total),num2str(NFREESLK_total),num2str(NSLACK_total),num2str(OFACT_total),num2str(os_total),num2str(PCTFREESLK_total),num2str(mean(PCTR_total)),num2str(PCTR_total),num2str(PCTSLACK_total),num2str(mean(RC_total)),num2str(RC_total));
                    fprintf(data,'%s;%s;[%s];%s;[%s ];[%s];%s;%s;%s;%s;[%s];[%s];', num2str(RF_total),num2str(mean(RS_total)),num2str(RS_total),num2str(mean(RU_total)),num2str(RU_total),num2str(TCON_total),num2str(tdensity_total),num2str(TOTOFACT_total),num2str(TOTSLACK_R_total),num2str(TOTUFACT_total),num2str(UFACT_total),num2str(UTIL_total));
                    fprintf(data,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;', num2str(VADUR_total),num2str(XCON_total),num2str(xdensity_total),num2str(XDMND_total),num2str(XDUR_total),num2str(XFREESLK_total),num2str(XPCTR_total),num2str(XRC_total),num2str(XRS_total),num2str(XRU_total),num2str(XSLACK_R_total),num2str(XSLACK_total),num2str(XUTIL_total));
                    
                    % section #3 for mean values
                    fprintf(data,'%s;%s;%s;%s;%s;', num2str(mean(c)), num2str(mean(cnc)), num2str(mean(XDUR)), num2str(mean(VADUR)), num2str(mean(os)));
                    fprintf(data,'%s;%s;%s;%s;%s;%s;%s;%s;', num2str(mean(NSLACK)), num2str(mean(PCTSLACK)), num2str(mean(XSLACK)), num2str(mean(XSLACK_R)), num2str(mean(TOTSLACK_R)), num2str(mean(MAXCPL)), num2str(mean(NFREESLK)), num2str(mean(XFREESLK)));
                    fprintf(data,'%s;%s;', num2str(mean(tdensity)), num2str(mean(xdensity)));
                    fprintf(data,'%s;%s;', num2str(mean(RF)), num2str(mean(XDMND)));
                    fprintf(data,'%s;%s;%s;%s;%s;%s;', num2str(mean(XUTIL)), num2str(mean(XCON)), num2str(mean(TOTOFACT)), num2str(mean(cell2mat(OFACT))), num2str(mean(cell2mat(UFACT))), num2str(mean(TOTUFACT)));
                    fprintf(data,'%s;%s;%s;%s;%s;%s;%s;', num2str(mean(DMND_total)), num2str(mean(gini)), num2str(mean(i2)),num2str(mean(i3)),num2str(mean(i4)),num2str(mean(i5)),num2str(mean(i6)));
                    fprintf(data,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s', num2str(mean(OFACT_total)), num2str(mean(UFACT_total)),num2str(mean(ap)),num2str(ap_total),num2str(mean(comps)),num2str(comps_total),num2str(degrees_total),num2str(mean(narc)),num2str(narc_total),num2str(narc_inter),num2str(narc_inter_ratio),num2str(mode));
                    
                    % close
                    fprintf(data,'\n'); % end with a newline
                    
                    % save each generated instance
                    fp = ff(k); % copy to single variable for matlab save

                    % store original variables for saving with standardized names
                    PDM_temp = PDM;
                    num_activities_temp = num_activities;
                    num_projects_temp = num_projects;
                    
                    PDM = PDM_global; % keep variable name standard in MAT file
                    num_activities = num_activities_flex; % keep variable name standard in MAT file
                    num_projects = num_projects_flex; % keep variable name standard in MAT file
                    
                    [~,fname]=fileparts(filelist(i).name); % get filename without extension to construct meaningful a filename
                    [~,~] = mkdir(dir_gen,strcat(string(folder_mirror(end-1)),'_gen')); % create dir for generated instances, ignore if existing or empty
                    save(strcat(strcat(dir_gen,string(folder_mirror(end-1)),'_gen','/'),fname,'_',substruct_type(s),'_fp',num2str(real(ff(k)*10)),'_mode',num2str(mode),'.mat'),'PDM','constr','num_r_resources','num_modes','num_activities','num_projects','sim_type','release_dates','fp');
                    
                    % restore original variables after saving
                    PDM = PDM_temp;
                    num_activities = num_activities_temp;
                    num_projects = num_projects_temp;
                    
                end % loop flexibility factors
                
            end % loop flexible structures
            
        end % loop modes
        
        
        % move actual instance to "done" folder to be able to continue if run is aborted for any reason
        % [~,~] = mkdir(dir_done,strcat(string(folder_mirror(end-1)))); % create dir, ignore if existing or empty
        % movefile(fullfile(filelist(i).folder,filelist(i).name),strcat(dir_done,string(folder_mirror(end-1))));
        
        if mod(i,100)==0 % write percentage every 20th item
            fprintf('%f%%\n',i/size(filelist,1)*100); % end with a newline
        end
        
    end % loop files
    fprintf('Processing directory: %d of %d\n', d, size(dirlist,1)); % end with a newline
end % loop folders

status = fclose(data); % close result file and get the status of the operation

% optionally replace dot with comma (instance name)
% system(strcat('convert-dot.bat' + " " + results));
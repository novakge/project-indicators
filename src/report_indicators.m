% calculate all (multi)project indicators for the generated flexible structures and put results into a summary csv file
% example input:
% example usage:
% example output:

clear % clear all obsolete variables

% constants
extension_filter = '*.mat'; % select extension
dir_in = '../results/structures/'; % where generated flexible mat files are stored
dir_report = '../results/reports/'; % where generated flexible mat files are stored
dir_done = '../results/done/'; % where already processed data is moved

dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember( {dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory

currdate = datestr(now,'yyyymmdd-HHMMSS'); % make filename rather unique with a timestamp
[~,~] = mkdir(dir_report); % always create dir, ignore if existing
results = strcat(dir_report,'results-',currdate,'.csv');
data = fopen(results,'w');

% parameters
rng(123); % initialize random seed for reproducibility
ff = [0,0.1,0.2,0.3,0.4]; % flexibility factors array (containing flexibility parameters - fp)


% start to store header in file
fprintf(data,'database;filename;struct_type;c;cnc;XDUR;VADUR;os;NSLACK;PCTSLACK;XSLACK;XSLACK_R;TOTSLACK_R;MAXCPL;NFREESLK;PCTFREESLK;XFREESLK;tdensity;xdensity;fr;sr;fp;num_modes;num_activities;num_r_resources;rf;mean(ru);ru;mean(pctr);pctr;xdmnd;dmnd;mean(rs);rs;mean(rc);rc;xutil;util;xcon;tcon;totofact;ofact;ufact;totufact;');
% extended indicators list
fprintf(data,'num_projects;sum(num_activities);a_RS;alpha_i1;alpha_i2;arlf;narlf;narlf_;c_total;cnc_total;DMND_total;gini;gini_total;i1;i1_total;i2;i2_total;i3;i3_total;i4;i4_total;i5;i5_total;i6;i6_total;MAXCPL_total;NFREESLK_total;NSLACK_total;OFACT_total;os_total;PCTFREESLK_total;mean(PCTR_total);PCTR_total;PCTSLACK_total;mean(RC_total);RC_total;RF_total;mean(RS_total);RS_total;mean(RU_total);RU_total;TCON_total;tdensity_total;TOTOFACT_total;TOTSLACK_R_total;TOTUFACT_total;UFACT_total;UTIL_total;VADUR_total;XCON_total;xdensity_total;XDMND_total;XDUR_total;XFREESLK_total;XPCTR_total;XRC_total;XRS_total;XRU_total;XSLACK_R_total;XSLACK_total;XUTIL_total;');
% extended list with mean values
fprintf(data,'mean(c);mean(cnc);mean(XDUR);mean(VADUR);mean(os);mean(NSLACK);mean(PCTSLACK);mean(XSLACK);mean(XSLACK_R);mean(TOTSLACK_R);mean(MAXCPL);mean(NFREESLK);mean(XFREESLK);mean(tdensity);mean(xdensity);mean(RF);mean(XDMND);mean(XUTIL);mean(XCON);mean(TOTOFACT);mean(OFACT);mean(UFACT);mean(TOTUFACT);mean(DMND_total);mean(gini);mean(i2);mean(i3);mean(i4);mean(i5);mean(i6);mean(OFACT_total);mean(UFACT_total);mean(ap);ap_total;mean(comps);comps_total;mean(degrees_total);mean(NARC);NARC_total;NARC_inter;NARC_inter_ratio;mode\n'); % stop with newline


for d=1:size(dirlist,1) % go through all directories
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    % store actual database folder name for output folder
    folder_mirror = strsplit(browse_dir,filesep); % get name of database
    
    fprintf('\nProcessing directory %d of %d      ', d, size(dirlist,1)); % report folder progress (end with a newline)
    
    % load all files in the defined folder and calculate all indicators
    for i=1:size(filelist)
        
        % load variables from next file
        release_dates = 0; % available only for multiprojects, initialize
        load(fullfile(filelist(i).folder,filelist(i).name),'PDM','constr','num_r_resources','num_modes','num_activities','sim_type','release_dates','fp','sr','fr','struct_type','mode');
        
        % get number of projects based on number of activities vector
        num_projects = numel(num_activities); % can change later on with flexibility
        n = sum(num_activities); % n is the total number of each projects activities, can change later on with flexibility
        r = num_r_resources; % number of renewable resources
        w = num_modes; % number of execution modes
        
        % calculate initial start-end offset of each project based on number of activities
        prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
        prj_ends = cumsum(num_activities(1:end));
        DSM_global = PDM(:,1:size(PDM,1)); % DSM will be the same for all modes
        PDM_global = PDM;
        
        % for a multiproject, extract local content from the superset PDM
        % prepare cells for individual elements of the PDM superset
        PDM_local = {};
        DSM = {};
        RD  = {};
        TD  = {};
        CD  = {};
        
        % get all separate domains of each project
        for j = 1:num_projects
            DSM{j} = PDM_global(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j)); % get single DSMs for all project
            TD{j}  = PDM_global(prj_starts(j):prj_ends(j),n+1); % get single (n x 1) time domain matrices for all projects
            CD{j}  = PDM_global(prj_starts(j):prj_ends(j),n+2); % get single (n x 1) cost domain matrices for all projects
            RD{j}  = PDM_global(prj_starts(j):prj_ends(j),n+2+1:n+2+r); % get single (n x r) resource domain matrices for all projects
            
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
        
        for j=1:num_projects
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
        for j=1:num_projects
            DSM_inter(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j)) = 0; % remove all tasks and intra-project dependencies from global matrix
            narc_inter_possible = narc_inter_possible + num_activities(j)*(num_activities(j)-1)/2; % calculate upper triangles (excluding diagonal) of individual projects, i.e. n(n-1)/2
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
        for j=1:num_projects
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
        [arlf,narlf,narlf_] = indicator_narlf(PDM_global, num_activities, num_r_resources, release_dates);
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
        for j = 1:num_projects
            [RF(j),RU{j},PCTR{j},DMND{j},XDMND(j),RS{j},RC{j},UTIL{j},XUTIL(j),TCON{j},XCON(j),OFACT{j},TOTOFACT(j),UFACT{j},TOTUFACT(j)] = indicators_resource(PDM_local{j},num_r_resources,constr,MAXCPL_total); % TPT_max information is given as separate PDMs are given as inputs but we need the longest CPL
        end
        
        %% Output for each flexible structure variant
        % write variables in defined order to a csv file, print results into file
        
        % section #1
        fprintf(data,'%s;%s;%s;[%s];[%s];[%s];[%s];[%s];', dirlist(d).name, filelist(i).name, struct_type, num2str(c), num2str(cnc), num2str(XDUR), num2str(VADUR), num2str(os));
        fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];', num2str(NSLACK), num2str(PCTSLACK), num2str(XSLACK), num2str(XSLACK_R), num2str(TOTSLACK_R), num2str(MAXCPL), num2str(NFREESLK), num2str(PCTFREESLK), num2str(XFREESLK));
        fprintf(data,'[%s];[%s];%s;%s;%s;%s;[%s];', num2str(tdensity), num2str(xdensity), num2str(fr), num2str(sr), num2str(fp), num2str(num_modes), num2str(num_activities));
        fprintf(data,'%s;[%s];%s;[%s];%s;[%s];[%s];[%s];%s;[%s];%s;[%s];', num2str(num_r_resources), num2str(RF), num2str(mean(cell2mat(RU(:)))), num2str(cellfun(@mean, RU)), num2str(mean(cell2mat(PCTR(1,:)))), num2str(mean(cell2mat(PCTR(:)))), num2str(XDMND), num2str(cell2mat(DMND)), num2str(XRS_total), num2str(cell2mat(RS)), num2str(XRC_total), num2str(cell2mat(RC)));
        fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];', num2str(XUTIL), num2str(cell2mat(UTIL)), num2str(XCON), num2str(cell2mat(TCON)), num2str(TOTOFACT), num2str(cell2mat(OFACT)), num2str(cell2mat(UFACT)), num2str(TOTUFACT));
        
        % section #2
        fprintf(data,'%s;%s;%s;%s;%s;', num2str(num_projects), num2str(sum(num_activities)),num2str(a_RS),num2str(alpha_i1),num2str(alpha_i2));
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
        fprintf(data,'\n'); % end file with a newline
        
        if mod(i,ceil(numel(filelist)/50))==0 % report file progress
            fprintf('\b\b\b\b\b[%02.f%%]',i/numel(filelist)*100);
        end
        if i==numel(filelist)
            fprintf('\b\b\b\b\b\b\b  [done]\n');
        end
        
        % move processed instance to "done" folder to be able to continue if run is aborted for any reason
        [~,~] = mkdir(dir_done,strcat(string(folder_mirror(end-1)))); % create dir, ignore if existing or empty
        movefile(fullfile(filelist(i).folder,filelist(i).name),strcat(dir_done,string(folder_mirror(end-1))));

        
    end % loop files
    
end % loop folders

status = fclose(data); % close result file and get status
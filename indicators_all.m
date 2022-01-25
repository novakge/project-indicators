% wrapper script to batch run all (multi)project indicators for the different flexibility factors
%
% +---------------------------------------------+--------+-------+
% |  	  		   		Indicator				| Global | Local |
% +---------------------------------------------+--------+-------+
% | C, CNC, OS									|    X   |   X   | // differs for local and global
% | I1,I2,I3,I4,I5,I6							|    X   |   X   | // differs for local and global
% | alpha_I1, alpha_I2							|    X   |   X   | // differs for local and global
% | Gini										|    X   |       | // only global
% | XDENSITY, TDENSITY							|        |   X   | // TDENSITY global=local, XDENSITY differs locally
% | XDUR,VADUR									|    X   |       | // XDUR global=local, VADUR global~local
% | NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R	|    X   |   X   | // test if the same, then global
% | MAXCPL,NFREESLK,PCTFREESLK,XFREESLK			|    X   |   X   | // test if the same, then global
% | ARLF,NARLF,NARLF_'                          |    X   |   X   | // uses both global and local infos already
% | RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL		|    X   |   X   | // test if the same, then global
% | TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT		|    X   |   X   | // test if the same, then global
% | alpha_RS									|        |   X   | // only local
% | fr,sr										|    X   |   X   | // global=local (for sure)
% +---------------------------------------------+--------+-------+

% original order from previous results XLS
% type,filename,c,cnc,XDUR,VADUR,os,NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK,tdensity,xdensity,fr,sr,ff,num_modes,num_activities,num_r_resources,rf,mean(ru),ru,mean(pctr),pctr,mean(dmnd),dmnd,mean(rs),rs,mean(rc),rc,mean(util),util,mean(tcon),tcon,ofact,ufact,database
% proposed new order
% type,filename,c,cnc,XDUR,VADUR,os,NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK,tdensity,xdensity,fr,sr,ff,num_modes,num_activities,num_r_resources,rf,mean(ru),ru,mean(pctr),pctr,xdmnd,dmnd,mean(rs),rs,mean(rc),rc,xutil,util,xcon,tcon,totofact,ofact,ufact,totufact,database

clear % clear all obsolete variables

% constants
extension_filter = '*.mat'; % select extension
directory = 'data';

dirlist = dir(fullfile(directory, '**\*.*')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders in list
tf = ismember( {dirlist.name}, {'.', '..'});
dirlist(tf) = []; % remove current and parent directory

currdate = datestr(now,'yyyymmdd-HHMM');
results = strcat('results-',currdate,'.csv');
data = fopen(results,'w');

% parameters
rng = 123; % initialize random seed for reproducibility
ff = [0,0.1,0.2,0.3,0.4]; % flexibility factors array

% start to store header in file
fprintf(data,'type;filename;c;cnc;XDUR;VADUR;os;NSLACK;PCTSLACK;XSLACK;XSLACK_R;TOTSLACK_R;MAXCPL;NFREESLK;PCTFREESLK;XFREESLK;tdensity;xdensity;fr;sr;ff;num_modes;num_activities;num_r_resources;rf;mean(ru);ru;mean(pctr);pctr;xdmnd;dmnd;mean(rs);rs;mean(rc);rc;xutil;util;xcon;tcon;totofact;ofact;ufact;totufact;database\n');


for d=1:size(dirlist,1) % go through all directories
    browse_dir = fullfile(directory,dirlist(d).name, extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    % load all files in the defined folder and calculate all indicators
    for i=1:size(filelist)
        
        % load variables from next file
        load(fullfile(filelist(i).folder,filelist(i).name),'PDM','constr','num_r_resources','num_modes','num_activities','sim_type');
        
        % check (multi)project size based on number of activities vector
        num_projects = numel(num_activities); % can change later on with flexibility
        n = sum(num_activities); % n is the total number of each projects activities, can change later on with flexibility
        r = num_r_resources; % number of renewable resources
        w = num_modes; % number of execution modes
        
        % calculate initial start-end offset of each project based on number of activities
        prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
        prj_ends = cumsum(num_activities(1:end));
        
        for k=1:numel(ff) % calculate indicators for each flexibility factor
            
            % reset global PDM and extract global DSM for each flexibility version (max,min,... etc.)
            PDM_global = PDM;
            DSM_global = PDM(:,1:size(PDM,1)); % number of rows is used instead of num_activities as it can be a row vector for multiprojects
            
            % generating flexibility and minimal maximal (=original, where ff=0) structures
            % random (uniform) generation for all potential (=1) tasks/dependencies between [0,1]
            fixed_indexes = DSM_global==1; % find all fixed tasks/dependencies in DSM
            flexible_values = rand(1,nnz(fixed_indexes)); % create a vector with random numbers
            flexible_values(flexible_values>ff(k)) = 1; % tasks/dependencies greater than the flexibility ratio will be re-written with 1
            
            % put flexible values already to DSM for calculating the f-ratio and s-ratio before removing any tasks/dependencies
            PDM_global(fixed_indexes) = flexible_values;
            fr = fratio(PDM_global); % ratio of flexible dependency
            sr = sratio(PDM_global); % ratio of supplementary tasks
            flexible_values(flexible_values<=ff(k)) = 0; % tasks/dependencies lower than or equal to the flexibility ratio will be overwritten with 0
            PDM_global(fixed_indexes) = flexible_values; % update PDM again after actual zeroing
            
            % maximin and minimax structures are not considered at the moment, note only
            % PDM_maxmin = floor(triu(PDM(:,1:size(PDM,1)),1))+diag(ceil(diag(PDM))); % tasks-in / dependencies-out
            % PDM_minmax = ceil(triu(PDM(:,1:size(PDM,1)),1))+diag(floor(diag(PDM))); % tasks-out / dependencies-in
            
            % re-count number of tasks remaining for each original project after flexible ones will be removed based on original structure
            for j=1:num_projects
                num_activities_flex(j) = nnz(diag(PDM_global(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j))));
            end
            
            % then remove zero tasks and their demands + dependencies
            DSM_global = PDM_global(:,1:size(PDM_global,1)); % update DSM_global before removing tasks
            PDM_global(diag(DSM_global==0),:)=[]; % remove all less-than-or-equal to flexibility factor activities and their dependencies from PDM
            PDM_global(:,diag(DSM_global)==0)=[]; % remove all less-than-or-equal to flexibility factor activities and their dependencies and demands from PDM
            DSM_global = PDM_global(:,1:size(PDM_global,1)); % update DSM_global after removing tasks
            
            % re-calculate total number of activities without supplementary tasks and flexible dependencies after all removed
            n_flex = sum(num_activities_flex); % total number of activities now without flexible tasks and dependencies equivalent to sum(num_activities)
            num_projects_flex = nnz(num_activities_flex); % consider removed projects also
            
            % re-calculate start-end offset of each project based on number of activities
            prj_starts_flex = cumsum([1,num_activities_flex(1:end-1)]); % starting with 1 for the first project, ignoring last entry
            prj_ends_flex = cumsum(num_activities_flex(1:end));
            
            % for a multiproject, extract local content from the superset PDM
            % prepare cells for individual elements of the PDM superset
            PDM_local = {};
            PSM = {};
            DSM = {};
            RD  = {};
            TD  = {};
            CD  = {};
            
            % get all separate domains of each project
            for j = 1:num_projects
                DSM{j} = PDM_global(prj_starts_flex(j):prj_ends_flex(j),prj_starts_flex(j):prj_ends_flex(j)); % get single DSMs for all project
                TD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+1); % get single (n x 1) time domain matrices for all projects
                CD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+2); % get single (n x 1) cost domain matrices for all projects
                RD{j}  = PDM_global(prj_starts_flex(j):prj_ends_flex(j),n_flex+2+1:n_flex+2+r); % get single (n x r) resource domain matrices for all projects
                
                PDM_local{j} = [DSM{j} TD{j} CD{j} RD{j}]; % concatenate for separate PDMs
            end
            
            
            % start calculating different indicators
            %% local DSM based indicators (logical structure) calculated for individual projects
            for j=1:num_projects
                [i1(j),i2(j),i3(j),i4(j),i5(j),i6(j)] = indicators(DSM{j});
                c(j) = indicator_c(DSM{j});
                cnc(j) = indicator_cnc(DSM{j});
                os(j) = indicator_os(DSM{j});
                
                xdensity(j) = indicator_xdensity(DSM{j});
                tdensity(j) = indicator_tdensity(DSM{j});
            end
            % get alpha distances (variaton)
            alpha_i1 = alphadist(i1); % number of activities already considers flexible tasks
            alpha_i2 = alphadist(i2); % serial-parallel indicator already considers flexible tasks
            
            
            %% global DSM based indicators (logical structure) calculated for combined project
            [i1_total,i2_total,i3_total,i4_total,i5_total,i6_total] = indicators(DSM_global);
            c_total = indicator_c(DSM_global);
            cnc_total = indicator_cnc(DSM_global);
            os_total = indicator_os(DSM_global);
            
            xdensity_total = indicator_xdensity(DSM_global);
            tdensity_total = indicator_tdensity(DSM_global);
            
            
            %% local PDM based indicators calculated for individual projects
            
            % time and resource related indicators
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
            
            
            %% PSM based indicators (if it is a multimode, select one (first) mode only)
            
            % prepare PSM by selecting first mode in PDM cells (formally, because currently we have only single mode multiproject databases)
            for j = 1:num_projects
                % merge to separate PDMs
                PSM{j} = [DSM{j} TD{j}(:,1) CD{j}(:,1) RD{j}(:,1:num_modes:num_modes*num_r_resources)]; % select first modes for TD,CD,RD
            end
            % then create PSM_all from cells with first mode selected already
            PSM_all = [DSM_global cat(1,TD{:}) cat(1,CD{:}) cat(1,RD{:})];
            
            % global calculations
            % resource related
            [arlf,narlf,narlf_] = indicator_narlf(PSM_all, num_activities_flex, num_r_resources);
            % TODO test if global vs local differs, if not, keep global and note in overview ascii table
            [RF_total,RU_total,PCTR_total,DMND_total,XDMND_total,RS_total,RC_total,UTIL_total,XUTIL_total,TCON_total,XCON_total,OFACT_total,TOTOFACT_total,UFACT_total,TOTUFACT_total] = indicators_resource(PSM_all,num_r_resources,constr); % TPT_max information is not needed as the DSM superset is given
            % calculate a_RS from individual values here before averaging
            a_RS = alphadist(RS_total);
            % average RS when alpha_RS is already calculated
            XPCTR_total=mean(PCTR_total); %
            XRS_total=mean(RS_total); %
            XRU_total=mean(RU_total); %
            XRC_total=mean(RC_total); %
            
            % local calculations
            for j = 1:num_projects
                [RF(j),RU{j},PCTR{j},DMND{j},XDMND(j),RS{j},RC{j},UTIL{j},XUTIL(j),TCON{j},XCON(j),OFACT{j},TOTOFACT(j),UFACT{j},TOTUFACT(j)] = indicators_resource(PSM{j},num_r_resources,constr,MAXCPL_total); % TPT_max information is given as separate PSMs are given as inputs but we need the longest CPL
            end
            
            %% Output for each flexible structure variant
            % write variables in defined order to a csv file
            if ff(k) == 0
                type_struct = 'max';
            else
                type_struct = 'min';
            end
            % print results into file
            
            % section #1
            fprintf(data,'%s;%s;[%s];[%s];[%s];[%s];[%s];', type_struct,filelist(i).name, num2str(c), num2str(cnc), num2str(XDUR), num2str(VADUR), num2str(os));
            fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];', num2str(NSLACK), num2str(PCTSLACK), num2str(XSLACK), num2str(XSLACK_R), num2str(TOTSLACK_R), num2str(MAXCPL), num2str(NFREESLK), num2str(PCTFREESLK), num2str(XFREESLK));
            fprintf(data,'[%s];[%s];%s;%s;%s;%s;[%s];', num2str(tdensity), num2str(xdensity), num2str(fr), num2str(sr), num2str(ff(k)), num2str(num_modes), num2str(num_activities));
            fprintf(data,'%s;[%s];%s;[%s];%s;[%s];[%s];[%s];%s;[%s];%s;[%s];', num2str(num_r_resources), num2str(RF), num2str(mean(cell2mat(RU(:)))), num2str(cellfun(@mean, RU)), num2str(mean(cell2mat(PCTR(1,:)))), num2str(mean(cell2mat(PCTR(:)))), num2str(XDMND), num2str(cell2mat(DMND)), num2str(XRS_total), num2str(cell2mat(RS)), num2str(XRC_total), num2str(cell2mat(RC)));
            fprintf(data,'[%s];[%s];[%s];[%s];[%s];[%s];[%s];[%s];%s;', num2str(XUTIL), num2str(cell2mat(UTIL)), num2str(XCON), num2str(cell2mat(TCON)), num2str(TOTOFACT), num2str(cell2mat(OFACT)), num2str(cell2mat(UFACT)), num2str(TOTUFACT), dirlist(d).name);
            
            % section #2
            %fprintf(data,'%s;%s;%s;',num2str(xxx)); % further indicators go here
            fprintf(data,'\n'); % stop with a newline
            
            
            
        end % loop flexibility factors
    end % loop files
end % loop folders

% optionally replace dot with comma (instance name)
fclose(data); % close result file
system(strcat('convert-dot.bat' + " " + results));

        %% Changelog
        % new order with extended indicators for multiproject;
        % - some resource average (xdmnd, xutil, xcon) now calculated inside
        % - average resource indicators named as X[...]
        % - added totofact, totufact
        % - keep fr, sr, ff (not slack-FF)
        % - add TPT_max information for multiproject UTIL calculation when separate PSMs are calculated

        
        %% Notes, remarks
        % only single modes are supported at the moment
        % UF = MAUF = UTIL, when calculated for the superset DSM (TPT_max given). In Van Eynde (2020), UF calculated seemingly for the 1st resource and somewhat differs from this calculation.        
       
        %% Further planned indicators are:
        % IS Independence Strength
        % a_IS variation of IS
        % varUF (variance of UF) or VA-UTIL (but differs)
        
        %% Indicators not applied
        % MP Multi-project Parallellity
        % MF Multi-project Float
        % CR = ?
        % RD Resource Dedication
        % PD Project Dedication
        
        %% TODOs
        % num_projects, mean(num_activities)
        % idea for flexible resources
        % add NARLF, alphas etc. in a logical way, create new order
        % idea of combining real-world projects into multiproject or company example comparison
% wrapper script to batch run all (multi)project indicators for different PDM combinations
%
% +---------------------------------------------+--------+-------+
% |  	  		   		Indicator				| Global | Local |
% +---------------------------------------------+--------+-------+
% | C, CNC, OS									|    X   |   X   |
% | I1,I2,I3,I4,I5,I6							|    X   |   X   |
% | alpha_I1, alpha_I2							|    X   |   X   |
% | Gini										|    X   |       |
% | XDENSITY, TDENSITY							|        |   X   |
% | XDUR,VADUR									|    X   |       |
% | NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R	|    X   |   X   |
% | MAXCPL,NFREESLK,PCTFREESLK,XFREESLK			|    X   |   X   |
% | ARLF,NARLF,NARLF_'                          |    X   |   X   |
% | RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL		|    X   |   X   |
% | TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT		|    X   |   X   |
% | alpha_RS									|        |   X   |
% | fr,sr										|    X   |   X   |
% | ap, comps, degrees                          |    X   |   X   |
% +---------------------------------------------+--------+-------+

% original order from previous results XLS
% type,filename,c,cnc,XDUR,VADUR,os,NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK,tdensity,xdensity,fr,sr,ff,num_modes,num_activities,num_r_resources,rf,mean(ru),ru,mean(pctr),pctr,mean(dmnd),dmnd,mean(rs),rs,mean(rc),rc,mean(util),util,mean(tcon),tcon,ofact,ufact,database
% proposed new order, see below

clear % clear all obsolete variables

% constants
currdate = datestr(now,'yyyymmdd-HHMMSS');
results = strcat('results_fact-',currdate,'.csv');
data = fopen(results,'w');

% flexibility parameters, now fixed
type_struct = 'max'; % flexibility already considered by combinations
sr = 0;
fr = 0;
ff = 0;

% start to store header in file
fprintf(data,'type,filename,c,cnc,XDUR,VADUR,os,NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK,tdensity,xdensity,fr,sr,ff,num_modes,num_activities,num_r_resources,rf,mean(ru),ru,mean(pctr),pctr,xdmnd,dmnd,mean(rs),rs,mean(rc),rc,xutil,util,xcon,tcon,totofact,ofact,ufact,totufact,database,');
% extended indicators list
fprintf(data,'num_projects,sum(num_activities),a_RS,alpha_i1,alpha_i2,arlf,narlf,narlf_,c_total,cnc_total,DMND_total,gini,gini_total,i1,i1_total,i2,i2_total,i3,i3_total,i4,i4_total,i5,i5_total,i6,i6_total,MAXCPL_total,NFREESLK_total,NSLACK_total,OFACT_total,os_total,PCTFREESLK_total,mean(PCTR_total),PCTR_total,PCTSLACK_total,mean(RC_total),RC_total,RF_total,mean(RS_total),RS_total,mean(RU_total),RU_total,TCON_total,tdensity_total,TOTOFACT_total,TOTSLACK_R_total,TOTUFACT_total,UFACT_total,UTIL_total,VADUR_total,XCON_total,xdensity_total,XDMND_total,XDUR_total,XFREESLK_total,XPCTR_total,XRC_total,XRS_total,XRU_total,XSLACK_R_total,XSLACK_total,XUTIL_total,');
% extended list with mean values
fprintf(data,'mean(c),mean(cnc),mean(XDUR),mean(VADUR),mean(os),mean(NSLACK),mean(PCTSLACK),mean(XSLACK),mean(XSLACK_R),mean(TOTSLACK_R),mean(MAXCPL),mean(NFREESLK),mean(XFREESLK),mean(tdensity),mean(xdensity),mean(RF),mean(XDMND),mean(XUTIL),mean(XCON),mean(TOTOFACT),mean(OFACT),mean(UFACT),mean(TOTUFACT),mean(DMND_total),mean(gini),mean(i2),mean(i3),mean(i4),mean(i5),mean(i6),mean(OFACT_total),mean(UFACT_total),mean(ap),ap_total,mean(comps),comps_total,mean(degrees_total),mean(NARC),NARC_total,NARC_inter,NARC_inter_ratio\n'); % stop with newline

% generation size parameters
p = 3; % covers also lower values
n = 5; % covers also lower values
r = 1;
num_r_resources = r;
tvalues = [1]; % possible assigned value(s) for time
rvalues = [1]; % possible assigned value(s) for resource(s)
num_modes = 1;

dsmid = 1; % initialize
dsmid_low = 1;
dsmid_high = 2^(p*(n*(n+1)/2));
sample_size = 25000;
dsmid_step = dsmid_high/sample_size;

tid = 1; % initialize
tid_low = 1;
tid_step = 1;
tid_high = 1;

rid = 1; % initialize
rid_low = 1;
rid_step = 1;
rid_high = 1;


% get possible combinations upper limit
[~,~,dsm_possible,t_possible,r_possible] = genpdm(dsmid,tid,rid,n,p,r,tvalues,rvalues);

% do some checks
% ...

% prepare constr!, num_modes, num_activities, release_dates, num_projects
constr = [-1,-1,1,1]; % TODO: dummy, 3rd position will be the resource limit

for rid=rid_low:rid_step:rid_high % go through all resource combos
    for tid=tid_low:tid_step:tid_high % go through all time combos
        for dsmid=dsmid_low:dsmid_step:dsmid_high % go through all project combos
            
            [PDM,num_activities,~,~,~] = genpdm(dsmid,tid,rid,n,p,r,tvalues,rvalues);
            
            if isempty(PDM)
                warning('PDM is empty!\n');
                continue;
            end
            
            % calculate initial start-end offset of each project based on number of activities
            prj_starts = cumsum([1,num_activities(1:end-1)]); % starting with 1 for the first project, ignoring last entry
            prj_ends = cumsum(num_activities(1:end));
            num_projects = numel(num_activities);
            n_total = sum(num_activities);
            release_dates = zeros(num_projects);
            % reset global PDM and extract global DSM
            PDM_global = PDM;
            DSM_global = PDM(:,1:size(PDM,1)); % number of rows is used instead of num_activities as it can be a row vector for multiprojects
            
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
                DSM{j} = PDM_global(prj_starts(j):prj_ends(j),prj_starts(j):prj_ends(j)); % get single DSMs for all project
                TD{j}  = PDM_global(prj_starts(j):prj_ends(j),n_total+1); % get single (n x 1) time domain matrices for all projects
                CD{j}  = PDM_global(prj_starts(j):prj_ends(j),n_total+2); % get single (n x 1) cost domain matrices for all projects
                RD{j}  = PDM_global(prj_starts(j):prj_ends(j),n_total+2+1:n_total+2+r); % get single (n x r) resource domain matrices for all projects
                
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
            [i1_total,i2_total,i3_total,i4_total,i5_total,i6_total] = indicators(DSM_global);
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
            
            
            %% PSM based indicators (if it is a multimode, select one (first) mode only)
            
            % prepare PSM by selecting first mode in PDM cells (formally, because currently we have only single mode multiproject databases)
            for j=1:num_projects
                % merge to separate PDMs
                PSM{j} = [DSM{j} TD{j}(:,1) CD{j}(:,1) RD{j}(:,1:num_modes:num_modes*num_r_resources)]; % select first modes for TD,CD,RD
            end
            % then create PSM_all from cells with first mode selected already
            PSM_all = [DSM_global cat(1,TD{:}) cat(1,CD{:}) cat(1,RD{:})];
            
            % global calculations
            % resource related
            [arlf,narlf,narlf_] = indicator_narlf(PSM_all, num_activities, num_r_resources, release_dates);
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
                [RF(j),RU{j},PCTR{j},DMND{j},XDMND(j),RS{j},RC{j},UTIL{j},XUTIL(j),TCON{j},XCON(j),OFACT{j},TOTOFACT(j),UFACT{j},TOTUFACT(j)] = indicators_resource(PSM{j},num_r_resources,constr,MAXCPL_total); % TPT_max information is given as separate PSMs are given as inputs but we need the longest CPL
            end
            
            %% Output
            % write variables in defined order to a csv file
            % print results into file
            
            % section #1
            fprintf(data,'%s,%s,[%s],[%s],[%s],[%s],[%s],', num2str(type_struct), num2str(dsmid), num2str(c), num2str(cnc), num2str(XDUR), num2str(VADUR), num2str(os));
            fprintf(data,'[%s],[%s],[%s],[%s],[%s],[%s],[%s],[%s],[%s],', num2str(NSLACK), num2str(PCTSLACK), num2str(XSLACK), num2str(XSLACK_R), num2str(TOTSLACK_R), num2str(MAXCPL), num2str(NFREESLK), num2str(PCTFREESLK), num2str(XFREESLK));
            fprintf(data,'[%s],[%s],%s,%s,%s,%s,[%s],', num2str(tdensity), num2str(xdensity), num2str(fr), num2str(sr), num2str(ff), num2str(num_modes), num2str(num_activities));
            fprintf(data,'%s,[%s],%s,[%s],%s,[%s],[%s],[%s],%s,[%s],%s,[%s],', num2str(num_r_resources), num2str(RF), num2str(mean(cell2mat(RU(:)))), num2str(cellfun(@mean, RU)), num2str(mean(cell2mat(PCTR(1,:)))), num2str(mean(cell2mat(PCTR(:)))), num2str(XDMND), num2str(cell2mat(DMND)), num2str(XRS_total), num2str(cell2mat(RS)), num2str(XRC_total), num2str(cell2mat(RC)));
            fprintf(data,'[%s],[%s],[%s],[%s],[%s],[%s],[%s],[%s],%s,', num2str(XUTIL), num2str(cell2mat(UTIL)), num2str(XCON), num2str(cell2mat(TCON)), num2str(TOTOFACT), num2str(cell2mat(OFACT)), num2str(cell2mat(UFACT)), num2str(TOTUFACT), num2str('generated'));
            
            % section #2
            fprintf(data,'%s,%s,%s,%s,%s,', num2str(num_projects), num2str(sum(num_activities)),num2str(a_RS),num2str(alpha_i1),num2str(alpha_i2));
            fprintf(data,'%s,%s,%s,%s,%s,[%s],', num2str(arlf),num2str(narlf),num2str(narlf_),num2str(c_total),num2str(cnc_total),num2str(DMND_total));
            fprintf(data,'%s,%s,[%s],%s,[%s],%s,[%s],%s,[%s],%s,[%s],%s,[%s],%s,', num2str(gini),num2str(gini_total),num2str(i1),num2str(i1_total),num2str(i2),num2str(i2_total),num2str(i3),num2str(i3_total),num2str(i4),num2str(i4_total),num2str(i5),num2str(i5_total),num2str(i6),num2str(i6_total));
            fprintf(data,'%s,%s,%s,[%s],%s,%s,%s,[%s],%s,%s,[%s],', num2str(MAXCPL_total),num2str(NFREESLK_total),num2str(NSLACK_total),num2str(OFACT_total),num2str(os_total),num2str(PCTFREESLK_total),num2str(mean(PCTR_total)),num2str(PCTR_total),num2str(PCTSLACK_total),num2str(mean(RC_total)),num2str(RC_total));
            fprintf(data,'%s,%s,[%s],%s,[%s ],[%s],%s,%s,%s,%s,[%s],[%s],', num2str(RF_total),num2str(mean(RS_total)),num2str(RS_total),num2str(mean(RU_total)),num2str(RU_total),num2str(TCON_total),num2str(tdensity_total),num2str(TOTOFACT_total),num2str(TOTSLACK_R_total),num2str(TOTUFACT_total),num2str(UFACT_total),num2str(UTIL_total));
            fprintf(data,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,', num2str(VADUR_total),num2str(XCON_total),num2str(xdensity_total),num2str(XDMND_total),num2str(XDUR_total),num2str(XFREESLK_total),num2str(XPCTR_total),num2str(XRC_total),num2str(XRS_total),num2str(XRU_total),num2str(XSLACK_R_total),num2str(XSLACK_total),num2str(XUTIL_total));
            
            % section #3 for mean values
            fprintf(data,'%s,%s,%s,%s,%s,', num2str(mean(c)), num2str(mean(cnc)), num2str(mean(XDUR)), num2str(mean(VADUR)), num2str(mean(os)));
            fprintf(data,'%s,%s,%s,%s,%s,%s,%s,%s,', num2str(mean(NSLACK)), num2str(mean(PCTSLACK)), num2str(mean(XSLACK)), num2str(mean(XSLACK_R)), num2str(mean(TOTSLACK_R)), num2str(mean(MAXCPL)), num2str(mean(NFREESLK)), num2str(mean(XFREESLK)));
            fprintf(data,'%s,%s,', num2str(mean(tdensity)), num2str(mean(xdensity)));
            fprintf(data,'%s,%s,', num2str(mean(RF)), num2str(mean(XDMND)));
            fprintf(data,'%s,%s,%s,%s,%s,%s,', num2str(mean(XUTIL)), num2str(mean(XCON)), num2str(mean(TOTOFACT)), num2str(mean(cell2mat(OFACT))), num2str(mean(cell2mat(UFACT))), num2str(mean(TOTUFACT)));
            fprintf(data,'%s,%s,%s,%s,%s,%s,%s,', num2str(mean(DMND_total)), num2str(mean(gini)), num2str(mean(i2)),num2str(mean(i3)),num2str(mean(i4)),num2str(mean(i5)),num2str(mean(i6)));
            fprintf(data,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s', num2str(mean(OFACT_total)), num2str(mean(UFACT_total)),num2str(mean(ap)),num2str(ap_total),num2str(mean(comps)),num2str(comps_total),num2str(degrees_total),num2str(mean(narc)),num2str(narc_total),num2str(narc_inter),num2str(narc_inter_ratio));
            
            % close
            fprintf(data,'\n'); % end with a newline
            
        end % loop dsm/project combinations
    end % loop time combinations
end % loop resource combinations

status = fclose(data); % close result file and get the status of the operation
% flexible structure generator for all structure types on all flexibility levels
function fsg(dir_in)

if nargin == 0
    % use default folder if argument not given
    dir_in = '../data/'; % default directory containing dataset(s)
else
    % process folder given as argument
end

% constants
extension_filter = '*.mat'; % select extension
dir_gen = '../results/structures/'; % folder to save all generated flexible mat files
dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember({dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory
[~,~] = mkdir(dir_gen); % always create dir, ignore if existing

% parameters
rng(123); % fix random seed for reproducibility
struct_type = ["original","maximal","maximin","minimax","minimal"]; % pre-defined flexible->fixed structures
ff = [0,0.1,0.2,0.3,0.4]; % flexibility factors array (containing flexibility parameters - fp)

for d=1:size(dirlist,1) % go through all directories
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    % store actual database folder name for output folder
    folder_mirror = strsplit(browse_dir,filesep); % get name of database
    
    fprintf('\nProcessing directory %d of %d      ', d, size(dirlist,1)); % report folder progress (end with a newline)
    
    % load all files in the defined folder
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
        
        original_done = 0; % init/reset flag to skip further original structures
        
        for mode=1:num_modes % select different modes
            
            % extract PDM for a given mode (time, resource)
            DSM_mode = PDM(:,1:size(PDM,1)); % DSM will be the same for all modes but need to reset
            
            TD_mode = PDM(:,size(PDM,1)+mode); % get durations of actual mode
            CD_mode = zeros(n,1); % cost is always zero for the given mode
            RD_mode = PDM(:,n+2*w+(mode-1)*r+1:n+2*w+(mode-1)*r+r); % get resources for actual mode (ordered by modes)
            
            PDM_mode = [DSM_mode TD_mode CD_mode RD_mode]; % merge to PDM
            
            maximal_done = 0; % init/reset flag to skip further maximal (ff=0) structures
                            
            for s=1:numel(struct_type) % calculate indicators for each defined structure
                
                for k=1:numel(ff) % calculate indicators for each flexibility factor
                    
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
                    
                    switch struct_type(s)
                        
                        case "original"
                            
                            if (ff(k) == 0) && (original_done == 0)
                                
                                PDM_global = PDM; % keep original PDM with all modes
                                
                                flex_task_values(flex_task_rand<=ff(k)) = 1; % tasks lower than or equal to the flexibility ratio will be included
                                flex_dep_values(flex_dep_rand<=ff(k)) = 1; % dependencies lower than or equal to the flexibility ratio will be included
                                original_done = 1; % keep track of original structure, do it only once
                                
                            else
                                continue; % skip original structures after the first was already generated
                            end
                            
                        case "maximal" % maximal case
                            
                            if (ff(k) == 0) && (maximal_done == 0)
                                flex_task_values(flex_task_rand<=ff(k)) = 1; % tasks lower than or equal to the flexibility ratio will be included
                                flex_dep_values(flex_dep_rand<=ff(k)) = 1; % dependencies lower than or equal to the flexibility ratio will be included
                                maximal_done = 1; % keep track of maximal structure, do it only once
                            else
                                continue; % skip maximal ff=0 structures after each mode was already generated
                            end
                            
                        case "maximin" % maximin case - flexible dependencies will be zeroed
                            
                            if (ff(k) > 0) % if flexibility parameter is 0, structure is equivalent to maximal (no flexible dep/task to remove) -> skip
                            	flex_task_values(flex_task_rand<=ff(k)) = 1; % tasks lower than or equal to the flexibility ratio will be included
                                flex_dep_values(flex_dep_rand<=ff(k)) = 0; % dependencies lower than or equal to the flexibility ratio will be zeroed
                            else
                                continue; % skip original structures after the first was already generated
                            end
                            
                        case "minimax" % minimax case - flexible tasks will be zeroed
                            
                            if (ff(k) > 0) % if flexibility parameter is 0, structure is equivalent to maximal (no flexible dep/task to remove) -> skip
                                flex_task_values(flex_task_rand<=ff(k)) = 0; % tasks lower than or equal to the flexibility ratio will be zeroed
                                flex_dep_values(flex_dep_rand<=ff(k)) = 1; % dependencies lower than or equal to the flexibility ratio will be included
                            else
                                continue; % skip structure
                            end
                            
                        case "minimal" % minimal case - flexible tasks/dependencies will be zeroed
                            
                            if (ff(k) > 0) % if flexibility parameter is 0, structure is equivalent to maximal (no flexible dep/task to remove) -> skip
                                flex_task_values(flex_task_rand<=ff(k)) = 0; % tasks lower than or equal to the flexibility ratio will be zeroed
                                flex_dep_values(flex_dep_rand<=ff(k)) = 0; % dependencies lower than or equal to the flexibility ratio will be zeroed
                            else
                                continue; % skip structure
                            end
                            
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
                    
                    
                    % save each generated instance
                    fp = ff(k); % copy to single variable for matlab save
                    struct_type_temp = struct_type;
                    struct_type = struct_type(s);
                    % store original variables for saving with standardized names
                    PDM_temp = PDM;
                    num_activities_temp = num_activities;
                    num_projects_temp = num_projects;
                    
                    PDM = PDM_global; % keep variable name standard in MAT file
                    num_activities = num_activities_flex; % keep variable name standard in MAT file
                    num_projects = num_projects_flex; % keep variable name standard in MAT file
                    
                    [~,fname]=fileparts(filelist(i).name); % get filename without extension to construct meaningful a filename
                    [~,~] = mkdir(dir_gen,strcat(string(folder_mirror(end-1)),'_gen')); % create dir for generated instances, ignore if existing or empty
                    
                    if struct_type == "original"
                        mode_temp = mode; % save original mode as for original instances this will be forced to 0
                        mode = 0; % all modes included in original, 0 means no selection
                        save(strcat(strcat(dir_gen,string(folder_mirror(end-1)),'_gen','/'),fname,'_',struct_type,'.mat'),'PDM','constr','num_r_resources','num_modes','num_activities','num_projects','sim_type','release_dates','fp','sr','fr','struct_type','mode');
                        mode = mode_temp; % restore mode for other structures
                    else
                        save(strcat(strcat(dir_gen,string(folder_mirror(end-1)),'_gen','/'),fname,'_',struct_type,'_fp',num2str(real(ff(k)*10)),'_mode',num2str(mode),'.mat'),'PDM','constr','num_r_resources','num_modes','num_activities','num_projects','sim_type','release_dates','fp','sr','fr','struct_type','mode');    
                    end
                    
                    % restore original variables after saving
                    PDM = PDM_temp;
                    num_activities = num_activities_temp;
                    num_projects = num_projects_temp;
                    struct_type = struct_type_temp;
                    
                    
                end % loop flexibility factors
                
            end % loop flexible structures
            
        end % loop modes
        
        if mod(i,ceil(numel(filelist)/50))==0 % report file progress
            fprintf('\b\b\b\b\b[%02.f%%]',i/numel(filelist)*100);
        end
        if i==numel(filelist)
            fprintf('\b\b\b\b\b\b\b [done]\n');
        end
        
    end % loop files
    
end % loop folders

end % function
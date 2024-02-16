% calculate all project indicators by optimizing modes selection for lower and upper bound of all instances
% put results into a summary csv file
% save all optimized instances for the combined mode selection for LB and UB
%
% example input: multimode instances folder
% example usage: >> report_ranges
% example output: << (results*.csv, saved *.mat)

clear % clear all obsolete variables

% constants for file/folder handling
extension_filter = '*.mat'; % select extension
dir_in = '../data/'; % where generated flexible mat files are stored
dir_report = '../results/reports/'; % where generated flexible mat files are stored
dir_modes = '../results/modes/'; % folder to save all generated flexible mat files
[~,~] = mkdir(dir_modes); % always create dir, ignore if existing
dir_done = '../results/done/'; % where already processed data is moved

dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember( {dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory

currdate = datestr(now,'yyyymmdd-HHMMSS'); % make filename unique with a timestamp
[~,~] = mkdir(dir_report); % always create dir, ignore if existing
[~,~] = mkdir(dir_done); % always create dir, ignore if existing
results = strcat(dir_report,'results-',currdate,'.csv');
data = fopen(results,'w');

% start to store header (columns) in report
fprintf(data,'database;filename;indicator;LB;UB;LBmodes;UBmodes;LBUBruntime\r\n'); % print header line with column names

indicator_list = ["xdur";"vadur";"nslack";"pctslack";"xslack";"xslack_r";"totslack_r";"maxcpl";"nfreeslk";"pctfreeslk"; ...
    "xfreeslk";"gini";"narlf";"rf";"ru";"pctr";"dmnd";"xdmnd";"rs";"a_rs";"rc";"util";"xutil";"tcon";"xcon"; ...
    "ofact";"totofact";"ufact";"totufact"];

for d=1:size(dirlist,1) % go through all directories

    % prepare folder and filenames
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    folder_mirror = strsplit(browse_dir,filesep); % get name of current database

    fprintf('\nProcessing directory %d of %d      ', d, size(dirlist,1)); % report folder progress (end with a newline)

    % load all files in the defined folder and calculate all indicators
    for i=1:size(filelist)

        %% load variables from next file
        load(fullfile(filelist(i).folder,filelist(i).name),'PDM','constr','num_r_resources','num_modes','num_activities');
        
        %% calculate all indicators LB,UB
        for j=1:numel(indicator_list)

            %% prepare folders and filenames of new instances
            [~,fname]=fileparts(filelist(i).name); % get filename without extension to construct meaningful a filename
            [~,~]=mkdir(dir_modes,strcat(string(folder_mirror(end-1)),'_modes')); % create dir for generated instances, ignore if existing or empty

            %% calculate LB, UB by optimizing modes selection for the given indicators
            indicator = indicator_list(j);
            
            tic % measure runtime of optimization
            [LB,UB,LBmodes,UBmodes] = indicator_ranges(PDM,num_modes,num_r_resources,constr,indicator);
            LBUBtime = toc; % store runtime

            % store PDM with optimized modes combination
            PDM_LB = pdm_mode(PDM,num_modes,num_r_resources,num_activities,LBmodes);
            PDM_UB = pdm_mode(PDM,num_modes,num_r_resources,num_activities,UBmodes);

            %% save each instance
            save(strcat(strcat(dir_modes,string(folder_mirror(end-1)),'_modes','/'),fname,'_',indicator,'_LB_UB','.mat'),'PDM','PDM_LB','PDM_UB','constr','num_r_resources','num_modes','num_activities','LB','LBmodes','UB','UBmodes','indicator');

            %% report each instance
            % write variables in defined order to a csv file, print results into file
            fprintf(data,'%s;%s;%s;%f;%f;%s;%s;%s;%s;%f',dirlist(d).name,filelist(i).name,indicator,LB,UB,mat2str(LBmodes),mat2str(UBmodes),string(LBUBtime));
            fprintf(data,'\r\n'); % end row with a newline

        end % loop indicators

        %% report progress
        if mod(i,ceil(numel(filelist)/50))==0 % report file progress
            fprintf('\b\b\b\b\b[%02.f%%]',i/numel(filelist)*100);
        end
        if i==numel(filelist)
            fprintf('\b\b\b\b\b\b\b  [done]\n');
        end

        % move processed data to "done" folder to be able to continue if run is aborted for any reason
        [~,~] = mkdir(dir_done,strcat(string(folder_mirror(end-1)))); % create dir, ignore if existing or empty
        movefile(fullfile(filelist(i).folder,filelist(i).name),strcat(dir_done,string(folder_mirror(end-1))));

    end % loop files

end % loop folders

status = fclose(data); % close result file and get status

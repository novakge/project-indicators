% script to convert all generated MAT structures to JSON file format
% example input: '../results/structures/' -> a folder containing the generated *.mat file structures
% example usage #1: >> convert_mat_json('../results/structures/') -> to process an (optionally) specified folder
% example usage #2: >> convert_mat_json -> to process all folders in results folder
% example output: output folder(s) with the converted JSON file format /results/structures_json/*.json'

function convert_mat_json(dir_in)

if nargin == 0
    % use default folder if argument not given
    dir_in = '../results/structures/'; % default directory containing dataset(s)
else
    % process folder given as argument
end

% constants
extension_filter = '*.mat'; % select extension
dir_out = '../results/structures_json/'; % folder to save all generated flexible mat files

dirlist = dir(fullfile(dir_in, '**')); % get list of files and folders in any subfolder
dirlist = dirlist([dirlist.isdir]); % keep only folders and subfolders in list
tf = ismember({dirlist.name}, {'.', '..'}); % remove "." and ".." entries
dirlist(tf) = []; % remove current and parent directory
[~,~] = mkdir(dir_out); % always create dir, ignore if existing

for d=1:size(dirlist,1) % go through all directories
    browse_dir = fullfile(dirlist(d).folder,dirlist(d).name,extension_filter); % look for all files with the extension in current subfolder
    filelist = dir(browse_dir);
    
    % store actual database folder name for output folder
    folder_mirror = strsplit(browse_dir,filesep); % get name of database
    
    fprintf('\nProcessing directory %d of %d      ', d, size(dirlist,1)); % report folder progress (end with a newline)
    
    % load all files in the defined folder
    for i=1:size(filelist)
        
        % initialize and load variables from next file
        
        % load variables from MAT file for only the specified variables
        pdm_file = load(fullfile(filelist(i).folder,filelist(i).name),'PDM');
        mat_file = load(fullfile(filelist(i).folder,filelist(i).name),'constr','num_r_resources','num_modes','num_activities','num_projects','sim_type','release_dates','fp','sr','fr','struct_type','mode');
%        test_file = load(fullfile(filelist(i).folder,filelist(i).name),'PDM','constr','num_r_resources','num_modes','num_activities','num_projects','sim_type','release_dates','fp','sr','fr','struct_type','mode');
        
        % convert and display MAT container to a JSON formatted string
        json_pdm = jsonencode(pdm_file); % keep short format for large PDMs
        json_vars = jsonencode(mat_file,PrettyPrint=true); % preserve a readable format
        json_vars = json_vars(1:end-1);
        json_vars(end)=',';
        json_string = strjoin({json_vars,json_pdm(2:end-1)},'\n  ');
        json_string = strjoin({json_string,''},'\n}');
        
%         % parse and display the JSON string back to MAT data structure
%         json_mat = jsondecode(json_string);
%         
%         %% for DEBUG
%          disp(json_string);
%          disp(json_mat);
%         %
%         % access and display all entries in JSON
%         field_names = fieldnames(json_mat);
%          
%         for j=1:numel(field_names)
%            field_name = field_names{j};
%            field_value = json_mat.(field_name);
%            
%            % display field name and value
%            disp(['Field Name: ' field_name]);
%            disp(['Field Value: ' mat2str(field_value)]);
%         end
%         
%         % note: JSON decoding behavior can lead to row vectors being interpreted
%         % as column vectors due to JSON format representation differences.
%         % post-processing (e.g., transposing) is recommended in such case(s), an example is given below:
%         
%         json_mat.struct_type = string(json_mat.struct_type);
%         json_mat.constr = json_mat.constr';
%         json_mat.num_activities = json_mat.num_activities';
%         json_mat.release_dates = json_mat.release_dates';
%         
%         % verify that the structures are identical in MAT and JSON after post-processing
%         if ~isequal(json_mat,test_file)
%             warning('Difference between MAT and JSON! Please verify.');
%         end
        
        %% save converted JSON string to files
        [~,~] = mkdir(dir_out,strcat(string(folder_mirror(end-1)))); % create dir for generated instances, ignore if existing or empty
        json_file = strcat(dir_out,string(folder_mirror(end-1)),'/',filelist(i).name(1:end-4),'.json');
        fid = fopen(json_file, 'w');
        fprintf(fid, '%s', json_string);
        fclose(fid);
        
        %% display progress
        if mod(i,ceil(numel(filelist)/50))==0 % report file progress
            fprintf('\b\b\b\b\b[%02.f%%]',i/numel(filelist)*100);
        end
        if i==numel(filelist)
            fprintf('\b\b\b\b\b\b\b [done]\n');
        end
        
    end % loop files
    
end % loop folders

end % function
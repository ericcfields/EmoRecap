%Return subset of subjects based on the presence of biosemi file or EEGset
%type and absence of another EEGset type
%
%INPUTS
% present  - string indicating a set type to draw subjects from; e.g.
%            'preart'
% missing  - string indicating a set type that has not been created yet for
%            the subject; e.g., 'postart'; [] will return all subjects
%            specified by the present input
% main_dir - The main study directory
%
% Possible inputs for present and missing:
%  - 'bdf'
%  - 'raw'
%  - 'car'
%  - 'ICA'
%  - 'preart'
%  - 'postart'
%  - 'erp'
%  - 'bad_epochs'
%
% Default with no input is equivalent to get_subset('bdf')
%
%Author: Eric Fields
%Version Date: 27 June 2018

function subs_subset = get_subset(present, missing, main_dir)

    %Set defaults for missing arguments
    if nargin < 3
        main_dir = pwd;
    end
    if nargin < 2
        missing = [];
    end
    if ~nargin
        present = 'bdf';
    end
    
    %Check inputs
    allowed_inputs = {'bdf', 'raw', 'car', 'ICA', 'preart', 'postart', 'erp', 'bad_epochs'};
    if ~any(strcmpi(present, allowed_inputs))
        error('Input is incorrect. See >>help get_subset');
    end
    if ~any(strcmpi(missing, allowed_inputs)) && ~isempty(missing)
        error('Input is not correct. See >>help get_subset');
    end
    
    %Get subject files
    bdf_files       = get_files(fullfile(main_dir, 'biosemi_bdf'), 'bdf');
    eeg_files       = get_files(fullfile(main_dir, 'EEGsets'), '.set');
    ica_files       = get_files(fullfile(main_dir, 'ICA'), 'w.txt');
    bad_epoch_files = get_files(fullfile(main_dir, 'ICA'), 'bad_epochs.mat');
    erp_files       = get_files(fullfile(main_dir, 'ERPsets'), '.erp');
    erp_files       = erp_files(~contains(erp_files, 'Hz'));
    
    %Get subject IDs for present
    if strcmpi(present, 'bdf')
        subs1 = cellfun(@(x) x(1:end-4), bdf_files, 'UniformOutput', false);
        %Get rid of repeats (mutliple BDF files per subject)
        subs1 = cellfun(@(x) x(1:12), subs1, 'UniformOutput', false);
        subs1 = unique(subs1);
    elseif strcmpi(present, 'ICA')
        subs1 = cellfun(@(x) x(1:end-9), ica_files, 'UniformOutput', false);
    elseif strcmpi(present, 'ERP')
        subs1 = cellfun(@(x) x(1:end-4), erp_files, 'UniformOutput', false);
    elseif strcmpi(present, 'bad_epochs')
        subs1 = cellfun(@(x) x(1:end-15), bad_epoch_files, 'UniformOutput', false);
    else
        subs1 = eeg_files(not(cellfun('isempty', strfind(eeg_files, present)))); %#ok<STRCL1>
        subs1 = cellfun(@(x) x(1:end-(length(present)+5)), subs1, 'UniformOutput', false);
    end
    
    %Get subject IDs for missing
    if ~isempty(missing)
        if strcmpi(missing, 'bdf')
            subs2 = cellfun(@(x) x(1:end-4), bdf_files, 'UniformOutput', false);
            %Get rid of repeats (mutliple BDF files per subject)
            subs2 = cellfun(@(x) x(1:12), subs2, 'UniformOutput', false);
            subs2 = unique(subs2);
        elseif strcmpi(missing, 'ICA')
            subs2 = cellfun(@(x) x(1:end-9), ica_files, 'UniformOutput', false);
        elseif strcmpi(missing, 'ERP')
            subs2 = cellfun(@(x) x(1:end-4), erp_files, 'UniformOutput', false);
        elseif strcmpi(missing, 'bad_epochs')
            subs2 = cellfun(@(x) x(1:end-15), bad_epoch_files, 'UniformOutput', false);
        else
            subs2 = eeg_files(not(cellfun('isempty', strfind(eeg_files, missing)))); %#ok<STRCL1>
            subs2 = cellfun(@(x) x(1:end-(length(missing)+5)), subs2, 'UniformOutput', false);
        end
    end
    
    %Get subset
    if isempty(missing)
        subs_subset = subs1;
    else
        subs_subset = subs1(~ismember(subs1, subs2));
    end
    
end

function files = get_files(directory, extension)
%Get files in a given directory with a given extension

    files = dir(directory);
    files = {files.name};
    if nargin > 1 && ~isempty(extension)
        files = files(not(cellfun('isempty', strfind(files, extension)))); %#ok<STRCL1>
    end

end

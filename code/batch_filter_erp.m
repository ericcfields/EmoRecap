%Create low pass filtered version of all ERPsets in a directory
%
%INPUTS
% lp_thresh      - half-amplitude cut-off for low pass filter
% sub_ids        - cell array of subject IDs to filter; it is assumed that
%                  ERPsets are named in the form 'sub_id.erp'
% erp_directory  - main study folder {default: current working directory
%                  {default: current working directory}
% overwrite      - boolean specifying whether to overwiret ERPsets that 
%                  alreadyexist {default: false}
%
%Author: Eric Fields
%Version Date: 5 July 2017

function batch_filter_erp(lp_thresh, sub_ids, erp_directory, overwrite)

    if nargin < 3
        erp_directory = pwd;
    end
    if nargin < 4
        overwrite = false;
    end

    for i = 1:length(sub_ids)
        
        sub_id = sub_ids{i};
        filt_setname = sprintf('%s_%dHzLP.erp', sub_id, lp_thresh);
        
        %Skip existing filtered sets
        if exist(fullfile(erp_directory, filt_setname), 'file') && ~overwrite
            fprintf('\n%s already exists (skipping)\n\n', filt_setname);
            continue;
        end

        [~, ~, ~, ~] = eeglab;
        
        fprintf('\nCreating %s\n', filt_setname);
        %Load ERPset
        ERP = pop_loaderp('filename', [sub_id '.erp'], 'filepath', erp_directory);
        %Filter
        ERP = pop_filterp(ERP, 1:34, 'Cutoff', lp_thresh, 'Design', 'butter', 'Filter', 'lowpass', 'Order', 2);
        %Save
        ERP = pop_savemyerp(ERP, 'erpname', sprintf('%s_%dHzLP', sub_id, lp_thresh), ... 
                            'filename', sprintf('%s_%dHzLP.erp', sub_id, lp_thresh), ... 
                            'filepath', erp_directory, 'Warning', 'off'); %#ok<NASGU>

    end
    
end
    
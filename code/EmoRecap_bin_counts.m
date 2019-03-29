%Record bin counts for EmoRecap
%
%Author: Eric Fields
%Version Date: 30 May 2018

function [bin_counts, bin_counts_values] = EmoRecap_bin_counts(main_dir, xls_output)
    
    %Make sure code folder is on path
    addpath('code');
    
    %Study directory
    if nargin < 2
        xls_output = true;
    end
    if ~nargin
        main_dir = pwd;
    end

    %Start eeglab
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>

    %Get subjects to loop over
    sub_ids = get_subset('erp');

    %Bin counts spreadsheet
    bin_counts_file = fullfile(main_dir, 'belist', 'EmoRecap_bin_counts.xlsx');

    for i = 1:length(sub_ids)

        sub_id = sub_ids{i};

        %Load ERPset
        ERP = pop_loaderp('filename', [sub_id '.erp'], ... 
                          'filepath', fullfile(main_dir, 'ERPsets'));

        %Add to bin counts cell array
        if i ==1
            bin_counts = [ ['bin_#'; num2cell(1:length(ERP.bindescr))'] [{'bin_descr'}; ERP.bindescr'] ];
        end           
        bin_counts = [bin_counts [ERP.subject; num2cell(ERP.ntrials.accepted')]]; %#ok<AGROW>

    end

    %Write to spreadsheet
    if xls_output
        xlswrite(bin_counts_file, bin_counts)
    end
    
    if nargout > 1
        bin_counts_values = cell2mat(bin_counts(2:end, 3:end));
    end
    
end

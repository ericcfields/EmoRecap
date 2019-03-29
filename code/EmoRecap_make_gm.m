%Make GM file from usable subjects for EmoRecap
%
%Author: Eric Fields
%Version Date: 27 March 2019

%% Set-up

clearvars; close all;

%Full path for data directory and relevant files
if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end

%Usability status from data log to include in ERPs
use_status = {'YES', 'PROBABLY'};

%Low pass filter to use for viewing
lp_filt = 10;

%Delete current GM files and lists
cd(fullfile(main_dir, 'ERPsets', 'GM_files'))
delete *.erp
% delete *.txt
cd(main_dir);


%% Make GM lists

[~, ~, data_log] = xlsread(fullfile(main_dir, 'EmoRecap_EEG_DataLog.xlsx'));
data_log = data_log(cellfun('isclass', data_log(:,1), 'char'), :);

data_log = data_log(cell2mat(cellfun(@(x) ~(length(x)==1 && isnan(x)), data_log(:,2), 'UniformOutput', false)), :);
usable_idx = ismember(data_log(:,2), use_status);

%Create text file of usabel ERPsets
usable_subs = data_log(usable_idx);
gm_list_file = fullfile(main_dir, 'ERPsets', 'GM_files', 'EmoRecap_gm_list.txt');
f_gm = fopen(gm_list_file, 'wt');
for i = 1:length(usable_subs)
    sub_id = usable_subs{i};
    fprintf(f_gm, '%s\\ERPsets\\%s.erp\n', main_dir, sub_id);
end
fclose(f_gm);

%% Make GM ERPsets

subset = {'', '_Remember&Know'};

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

for i = 1:length(subset)
    
    sub_list = fullfile(main_dir, 'ERPsets', 'GM_files', sprintf('EmoRecap_gm_list%s.txt', subset{i}));

    %Create GM ERP for AGAT
    ERP = pop_gaverager(sub_list, 'Criterion', 35, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'on');
    ERP.subject = '';
    ALLERP = ERP; 
    CURRENTERP = 1;
    ERP = pop_savemyerp(ERP, 'erpname', sprintf('EmoRecap_GM%s_%dsubs_WEIGHTED', subset{i}, length(ERP.workfiles)), ...
                        'filename', sprintf('EmoRecap_GM%s_%dsubs_WEIGHTED.erp', subset{i}, length(ERP.workfiles)), ... 
                        'filepath', fullfile(main_dir, 'ERPsets', 'GM_files'), 'Warning', 'on');
    ALLERP(CURRENTERP) = ERP;

    %Average usable ERPsets
    ERP = pop_gaverager(sub_list, 'Criterion', 35, 'ExcludeNullBin', 'on', 'SEM', 'on', 'Weighted', 'off');
    ERP.subject = '';
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;
    ERP = pop_savemyerp(ERP, 'erpname', sprintf('EmoRecap_GM%s_%dsubs', subset{i}, length(ERP.workfiles)), ...
                        'filename', sprintf('EmoRecap_GM%s_%dsubs.erp', subset{i}, length(ERP.workfiles)), ... 
                        'filepath', fullfile(main_dir, 'ERPsets', 'GM_files'), 'Warning', 'on');
    ALLERP(CURRENTERP) = ERP;
    %Create filtered ERPset
    ERP = pop_filterp(ERP,  1:34 , 'Cutoff', lp_filt, 'Design', 'butter', 'Filter', 'lowpass', 'Order', 2);
    ERP.erpname = [ERP.erpname sprintf('_%dHzLP', lp_filt)];
    ERP.filename = ''; ERP.filepath = '';
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;
    
end
                
eeglab redraw; erplab redraw;

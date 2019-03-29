%Peform artifact rejection/correction for subject that has an existing
%preart EEGset
% 1. Load preart set
% 2. Add ICA weights
% 3. Open artifact rejection script
%
%Author: Eric Fields
%Version Date: 22 February 2018

clearvars; close all; clc;

%% Parameters

%Full path for data directory and relevant files
if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end

%Default artifact rejection script
default_arf = fullfile(main_dir, 'arf', 'EmoRecap_default_arf.m');

%Batch processing
% subject_ids = get_subset('erp', [], main_dir);

%% Set-up

cd(main_dir);
addpath(fullfile(main_dir, 'arf'));
addpath(fullfile(main_dir, 'code'));
if isunix()
    addpath('/gsfs0/data/fields/Documents/MATLAB/eeglab14_1_1b_ECF');
end

%If subject_ids variable is not defined above, prompt user
if ~exist('subject_ids', 'var') || isempty(subject_ids)
    subject_ids = input('\n\nSubject ID:  ','s');
end
if strcmpi(subject_ids, 'rand')
    subject_ids = rand_sub('preart', 'postart', main_dir);
    if isempty(subject_ids)
        return;
    end
end

%Parse subject ID input
%If subject_ids is a cell array, use as is
if iscell(subject_ids)
    sub_ids = subject_ids;
%If subject_ids is a text file, read lines into cell array
elseif exist(subject_ids, 'file')
    sub_ids = {};
    f_in = fopen(subject_ids);
    while ~feof(f_in)
        sub_ids = [sub_ids fgetl(f_in)]; %#ok<AGROW>
    end
    fclose(f_in);
%If subject_ids is a string (i.e., single subject), convert to cell array
elseif ischar(subject_ids)
    sub_ids = {subject_ids};
else
    error('\nInappropriate value for subject_ids variable\n');
end

%Batch processing?
if length(sub_ids) > 1
    batch_proc = true;
    compute_erps = true;
else
    batch_proc = false;
end

%% Run

for i = 1:length(sub_ids)
    
    sub_id = sub_ids{i};

    %Start EEGLAB
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>

    %Load preart EEGset
    EEG = pop_loadset('filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

    %Check for ICA weights
    if isempty(EEG.icaweights)
        user_resp = questdlg('No ICA weights. Continue?');
        if ~strcmpi('Yes', user_resp)
            eeglab redraw;
            return
        end
    end

    %Open or run arf script
    sub_arf = fullfile(main_dir, 'arf', sprintf('arf_%s.m', sub_id));
    if ~exist(sub_arf, 'file')
        fprintf('\nSubject arf script doesn''t exist, so I will create one.\n\n');
        copyfile(default_arf, sub_arf);
    end
    if batch_proc
        run(sub_arf)
    else
        edit(sub_arf);
    end
    
end

eeglab redraw;
erplab redraw;
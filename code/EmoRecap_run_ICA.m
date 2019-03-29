%Run ICA on epoched data for EmoRecap
%
%Author: Eric Fields
%Version Date: 23 February 2018

clearvars; close all;

%% Set-up

%Full path for data directory and relevant files
if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end

%Update paths
cd(main_dir);
addpath(fullfile(main_dir, 'code'));
if isunix()
    addpath('/gsfs0/data/fields/Documents/MATLAB/eeglab14_1_1b_ECF');
end

%Find subjects with pre-ICA rejection but no ICA weights
sub_ids = get_subset('bad_epochs', 'ICA', main_dir);

%% Run ICA

for i = 1:length(sub_ids)
    
    sub_id = sub_ids{i};

    %% Load and prep training set

    %start EEGLAB
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>

    %Load preart set
    EEG = pop_loadset('filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.subject '_ICAtrain'], 'gui', 'off');
    
    %Check that data is epoch mean baselined
    assert(abs(mean(EEG.data(:))) < 0.1);
    
    %Load bad epochs
    load(fullfile(main_dir, 'ICA', [sub_id '_bad_epochs.mat']), 'bad_epochs');
    
    %Remove bad epochs
    if ~isempty(bad_epochs)
        EEG = pop_rejepoch(EEG, bad_epochs, 0);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    end

    %% Run ICA
    
    %ICA algorithm
    tic
    EEG = pop_runica(EEG, 'extended', 1);
    fprintf('\nICA took %.1f minutes.\n\n', toc/60)
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_ICA'], 'gui', 'off'); %#ok<ASGLU>

    %Save ICA weights
    pop_expica(EEG, 'weights', fullfile(main_dir, 'ICA', [sub_id '_ICAw.txt']));

    %% Add weights to preart set

    %clear and restart EEGLAB
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>

    %Load preart set
    EEG = pop_loadset('filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

    %Import ICA weights
    EEG = pop_editset(EEG, 'icaweights', fullfile(main_dir, 'ICA', [sub_id '_ICAw.txt']));
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

    %Save pre-artifact rejection EEGset
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
end

eeglab redraw;

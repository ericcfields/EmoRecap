%Preprocessing script for EmoRecap ERP
%
%AUTHOR: Eric Fields
%VERSION DATE: 5 June 2018

%This script performs the following processing steps according to
%parameters given below:
% 1. Import data from Biosemi bdf file
% 2. Assign channel locations and delete blank channels
% 3. Re-reference the data
% 4. Shift event codes to correct for delay
% 5. Delete gaps and breaks
% 6. Apply filters with half-amplitude cut-offs given
% 7. Bin and epoch data according to bin descriptor file

%clear the workspace and close all figures/windows
clearvars; close all;


%% ***** PARAMETERS *****

%Script defining pre-processing parameters
EmoRecap_preproc_params;

%String, cell array, or text file giving IDs of subjects to process
% subject_ids = get_subset('raw', [], main_dir);

%% ***** SET-UP *****

%Paths
cd(main_dir)
addpath(fullfile(main_dir, 'code'));
if isunix()
    addpath('/gsfs0/data/fields/Documents/MATLAB/eeglab14_1_1b_ECF');
end

%If subject_ids variable is not defined above, prompt user
if ~exist('subject_ids', 'var') || isempty(subject_ids)
    subject_ids = input('\n\nSubject ID:  ','s');
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

%Batch processing report
if length(sub_ids) > 1
    batch_proc = true;
    fprintf('\n\n**********************************************************\n')
    fprintf('\n\nBatch processing %d subjects\n\n', length(sub_ids))
    disp(sub_ids)
    fprintf('\n\n**********************************************************\n')
else
    batch_proc = false;
end

%Create folder structure if it doesn't exist
if ~exist(fullfile(main_dir, 'arf'), 'dir')
    mkdir(fullfile(main_dir, 'arf'))
end
if ~exist(fullfile(main_dir, 'belist'), 'dir')
    mkdir(fullfile(main_dir, 'belist'))
end
if ~exist(fullfile(main_dir, 'EEGsets'), 'dir')
    mkdir(fullfile(main_dir, 'EEGsets'))
end
if ~exist(fullfile(main_dir, 'ERPsets'), 'dir')
    mkdir(fullfile(main_dir, 'ERPsets'))
end

%% ***** DATA PROCESSING *****

%Loop through subjects and run all pre-processing steps
for i = 1:length(sub_ids)
    
    sub_id = sub_ids{i};
    
    %start EEGLAB
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>
    
    %% Import EEG and channel locations

    %Import data or load existing raw set
    if exist(fullfile(main_dir ,'EEGsets', [sub_id '_raw.set']), 'file')

        %Load existing raw set
        fprintf('\nRaw set already exists. Loading %s\n\n', fullfile(main_dir, 'EEGsets', [sub_id '_raw.set']));
        EEG = pop_loadset('filename', [sub_id '_raw.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

    else
        
        %Import data from multiple biosemi bdf files
        EEG = EmoRecap_import_raw(sub_id, main_dir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
        
        %Check that the correct number of channels was recorded
        if EEG.nbchan ~= 40
            if batch_proc
                warning('Expected 40 channels; data contains %d. Skipping %s', EEG.nbchan, sub_id);
            else
                eeglab redraw;
                error('Expected 40 channels; data contains %d.', EEG.nbchan);
            end
        end
        
        %Add channel names
        EEG = pop_editset(EEG, 'chanlocs', fullfile(main_dir, 'scalp_chan_names.elp'));
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %Add channel locations
        EEG = pop_chanedit(EEG, 'lookup', chanlocs_file);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %Add names of external electrodes
        EEG = pop_chanedit(EEG, ...
                           'changefield', {33 'labels' 'LO1'}, ...
                           'changefield', {34 'labels' 'SO2'}, ...
                           'changefield', {39 'labels' 'M1'}, ...
                           'changefield', {40 'labels' 'M2'});
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

        %Save raw data as EEG set
        EEG = pop_saveset(EEG, 'filename', [sub_id '_raw'], 'filepath', fullfile(main_dir, 'EEGsets'));
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %Write file of event code counts
        code_count_file = fullfile(main_dir, 'belist', [sub_id '_raw_counts.txt']);
        f_out = fopen(code_count_file, 'wt');
        fprintf(f_out, 'event_code\tcount\n'); %header
        all_event_codes = unique({EEG.event.type});
        for c = 1:length(all_event_codes)
            event_code = all_event_codes{c};
            fprintf(f_out, '%s\t%d\n', event_code, sum(strcmpi(event_code, {EEG.event.type})));
        end
        fclose(f_out);

    end

    %Remove channels with no data
    EEG = pop_select(EEG, 'nochannel', remove_chans);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_rchan'], 'gui', 'off');

    %% Downsample
    
    if resample_rate
        EEG = pop_resample( EEG, resample_rate);
        EEG.setname = EEG.setname(1:end-10); %removes ' resampled' from the end of the setname'
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_dsample'], 'gui', 'off');
    end
    
    %% Re-reference

    EEG = eeg_checkset(EEG);
    EEG = pop_reref(EEG, ref_chans);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_ref'], 'gui', 'off');
    
    
    %% Shift event codes
    
    if ec_shift
        EEG  = pop_erplabShiftEventCodes(EEG, 'DisplayEEG', 0, ...
                                         'DisplayFeedback', 'both', 'Eventcodes', 1:255, ...
                                         'Rounding', 'nearest', 'Timeshift', ec_shift);
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_shifted'], 'gui', 'off');
    end
    

    %% Delete breaks and gaps
    try
        EEG  = pop_erplabDeleteTimeSegments(EEG , 'displayEEG', 0, 'endEventcodeBufferMS', epoch_time(2) + 10e3, ...
                                            'startEventcodeBufferMS', -epoch_time(1) + 10e3, 'timeThresholdMS',  30e3);
    catch
        EEG  = pop_erplabDeleteTimeSegments(EEG, 'displayEEG', 0, 'maxDistanceMS', 30e3, ...
                                            'startEventCodeBufferMS', epoch_time(2) + 10e3, ... 
                                            'endEventCodeBufferMS',  -epoch_time(1) + 10e3);
    end
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_delgaps'], 'gui', 'off');
    

    %% Filtering

    if high_pass
        EEG  = pop_basicfilter(EEG, 1:length(EEG.chanlocs), 'Boundary', boundary_code, ...
                               'Cutoff', high_pass, 'Design', 'butter', 'Filter', 'highpass', ... 
                               'Order', 2, 'RemoveDC', 'on');
    end
    if low_pass
        EEG  = pop_basicfilter(EEG, 1:length(EEG.chanlocs), 'Boundary', boundary_code, ... 
                               'Cutoff', low_pass, 'Design', 'butter', 'Filter', 'lowpass', ... 
                               'Order',  2, 'RemoveDC', 'on');
    end
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_filt'], 'gui', 'off');
    
    
    %% Bin and epoch

    %Create event list
    EEG  = pop_creabasiceventlist(EEG, 'AlphanumericCleaning', 'on', 'BoundaryNumeric', {-99}, 'BoundaryString', {'boundary'}, ... 
                                  'Eventlist', fullfile(main_dir, 'belist', [sub_id '_eventlist.txt'])); 
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_elist'], 'gui', 'off');
    
    %Add memory flags to EEG.EVENTLIST
    EEG = EmoRecap_add_flags(EEG);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

    %Assign events to bins
    EEG  = pop_binlister(EEG, 'BDF', bin_desc_file, 'ExportEL', fullfile(main_dir, 'belist', [sub_id '_binlist.txt']), 'IndexEL', 1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG');
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_bins'], 'gui', 'off');

    %Extract epochs from bins
    EEG = pop_epochbin(EEG, epoch_time,  epoch_time);
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', [EEG.setname '_be'], 'gui', 'off');
    
    %Check that encoding and retrieval bins match
    if ~ all(EEG.EVENTLIST.trialsperbin(20:28) == EEG.EVENTLIST.trialsperbin(84:92)) ...
    || ~all(EEG.EVENTLIST.trialsperbin(30:38) == EEG.EVENTLIST.trialsperbin(93:101)) ...
    || ~all(EEG.EVENTLIST.trialsperbin(40:48) == EEG.EVENTLIST.trialsperbin(102:110)) ...
    || ~all(EEG.EVENTLIST.trialsperbin(50:58) == EEG.EVENTLIST.trialsperbin(111:119))
        warndlg(sprintf('Encoding and retrieval bin numbers don''t match for %s\n', sub_id));
    end
    
    %Add ICA weights if they exist
    if exist(fullfile(main_dir, 'ICA', [sub_id '_ICAw.txt']), 'file')
        fprintf('Adding ICA weights from %s', fullfile(main_dir, 'ICA', [sub_id '_ICAw.txt']));
        EEG = pop_editset(EEG, 'icaweights', fullfile(main_dir, 'ICA', [sub_id '_ICAw.txt']));
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    end
    
    %Save pre-artifact rejection EEGset
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);


end

eeglab redraw; erplab redraw;

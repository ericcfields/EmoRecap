%Identify epochs to exclude from ICA training
%
%Author: Eric Fields
%Version Date: 20 February 2018

clearvars; close all; clc;

%Full path for data directory and relevant files
if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
    addpath('/gsfs0/data/fields/Documents/MATLAB/eeglab14_1_1b_ECF');
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end

%Get subject
sub_id = input('\n\nSubject ID:  ','s');
if strcmpi(sub_id, 'rand')
    sub_id = rand_sub('preart', 'bad_epochs', main_dir);
    if isempty(sub_id)
        return;
    end
end

%Start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>

%Load preart set
EEG = pop_loadset('filename', [sub_id '_preart.set'], 'filepath', fullfile(main_dir, 'EEGsets'));
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

eeglab redraw;

%Open window for rejection
pop_eegplot(EEG, 1, 1, 0);

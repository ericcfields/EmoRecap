%Processing parameters for EmoRecap
%
%Author: Eric Fields
%Version Date: 20 February 2018

%Full path for data directory and relevant files
if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end

%Channel locations information
chanlocs_file = fullfile(fileparts(which('eeglab.m')), 'plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');

%Bin descriptor file
bin_desc_file = fullfile(main_dir, 'EmoRecap_bin_desc.txt');

%Code used to denote boundary events
boundary_code = 'boundary';

%Reference electrodes
ref_chans = [35, 36]; %mastoids

%Filtering for continuous data
%High-pass filters should be applied here; low pass filters can be applied later
high_pass = 0.1;
low_pass  = false;

%Epoch information
epoch_time    = [-200, 1100];
% baseline_time = [-200, -1];

%Empty channels to remove
remove_chans = {'EXG3', 'EXG4', 'EXG5', 'EXG6'};

%New sampling rate
resample_rate = false;

%Event code shift
ec_shift = false;

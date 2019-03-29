%Make GND variable/file for EmoRecap ERP
%
%Author: Eric Fields
%Version Date: 27 March 2019

clearvars; close all;

if isunix()
    main_dir = '/gsfs0/data/kensinel/canlab/EEG_DATA/EmoRecap/DATA';
else
    main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
end
cd(fullfile(main_dir, 'stats'));
addpath('C:\Users\ecfne\Documents\MATLAB\dmgroppe-Mass_Univariate_ERP_Toolbox-10dc5c7');

%Get files to include in GND
sub_files = strsplit(fileread(fullfile(main_dir, '\ERPsets\GM_files\EmoRecap_gm_list_Remember&Know.txt')), '\n');
sub_files = sub_files(contains(sub_files, '.erp'));
sub_files = cellfun(@(x) [x(1:end-4) '_10HzLP.erp'], sub_files, 'UniformOutput', false);

%Make sure all EEGLAB functions are on the MATLAB path
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; 
close all;

%Create a GND structure
GND = erplab2GND(sub_files, ...
                'exclude_chans', {'LO1', 'SO2', 'blink', 'biEOG'}, ...
                'exp_name', 'EmoRecap', ...
                'out_fname', 'EmoRecap.GND');

%Downsample the data in the GND from 512Hz to 128 Hz using boxcar filter
%Filter averages together each time point with the surrounding 2 time
%points
GND = decimateGND(GND, 4, 'boxcar', [-200 -1], 'yes', 0);

% Visually examine data
gui_erp(GND)

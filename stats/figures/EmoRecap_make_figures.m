%Make components for EmoRecap figures
%
%Author: Eric Fields
%Version Date: 6 March 2019

clearvars; close all;

%% Parameters

%Key directoris
main_dir = '\\brain510.bc.edu\LabShareFolder\Bowen, Holly\EmoRecap_ERP\EEGLAB_Analysis\DATA';
fig_dir = fullfile(main_dir, 'stats', 'figures');

%ERP grand mean file
GM_file = 'EmoRecap_GM_Remember&Know_25subs.erp';

%GND file with FMUT results
GND_file = fullfile(main_dir, 'stats', 'EmoRecap_128Hz_wResults.GND');


%% Set-up

%Path stuff
cd(main_dir);
addpath('C:\Users\ecfne\Documents\MATLAB\dmgroppe-Mass_Univariate_ERP_Toolbox-10dc5c7');
addpath('C:\Users\ecfne\Documents\Eric\Coding\FMUT_development\FMUT');
addpath(fig_dir);

%Start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%Load GM file
ERP = pop_loaderp('filename', GM_file, 'filepath', fullfile(main_dir, 'ERPsets', 'GM_files'));
eeglab redraw; erplab redraw;

%Load GND
load(GND_file, '-mat');


%% Scalp maps

for bin = [123:140, 144:150]
    make_scalp_map_image(ERP, bin, [-1.75, 1.75], sprintf('EmoRecap_scalp_maps_%s.tif', ERP.bindescr{bin}), fig_dir);
end


%% Waveforms

chans = {'Fz', 'Pz'};

make_chan_image(ERP, [66:68, 79], chans, 'EmoRecap_ValEffect_Remember&Know', fig_dir);
make_chan_image(ERP, [26:28, 79], chans, 'EmoRecap_ValEffect_Remember', fig_dir);
make_chan_image(ERP, [36:38, 79], chans, 'EmoRecap_ValEffect_Know', fig_dir);
make_chan_image(ERP, [46:48, 79], chans, 'EmoRecap_ValEffect_Guess', fig_dir);
make_chan_image(ERP, [56:58, 79], chans, 'EmoRecap_ValEffect_New', fig_dir);
make_chan_image(ERP, [76:78, 79], chans, 'EmoRecap_ValEffect_Guess&New', fig_dir);


%% Raster plots

f_scale_limits = [0, 20];

make_raster_image(GND, 1, 'EmoRecap_raster_ValenceMain.tif', fig_dir, f_scale_limits);
make_raster_image(GND, 2, 'EmoRecap_raster_POS-NEU.tif', fig_dir, f_scale_limits);
make_raster_image(GND, 3, 'EmoRecap_raster_NEG-NEU.tif', fig_dir, f_scale_limits);

GND.F_tests(12).desired_alphaORq = 0.1; %Show marginally significant cluster
make_raster_image(GND, 12, 'EmoRecap_raster_NEU-NEW.tif', fig_dir, f_scale_limits);


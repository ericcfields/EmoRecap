%Save list of bad epochs to exclude from ICA training
%
%First, mark bad epochs via visual inspectsion
%This script will then save a list of the marked epochs, which the ICA
%script can use later
%
%Author: Eric Fields
%Version Date: 23 May 2018

%Check if enough data is left for ICA
if ((EEG.pnts / (EEG.srate/128)) * sum(~EEG.reject.rejmanual)) < (30 * length(EEG.chanlocs)^2)
    warndlg('You may not have enough data points for reliable ICA training');
end

%Get bad epochs
bad_epochs = find(EEG.reject.rejmanual);
pct_bad_epochs = length(bad_epochs) / EEG.trials;

%Save bad epochs
save(fullfile(main_dir, 'ICA', [sub_id '_bad_epochs.mat']), 'bad_epochs', 'pct_bad_epochs');

%Report percent bad
fprintf('\n%.0f%% of epochs rejected\n\n', pct_bad_epochs*100);
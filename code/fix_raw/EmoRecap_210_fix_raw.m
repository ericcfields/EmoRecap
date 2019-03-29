%Fix problems in raw data for EmoRecap_210
%
%Author: Eric Fields
%Version Date: 5 June 2018

%The wrong list order was input for Test Block B and the wrong event codes
%were sent. This script replaces the incorrect event codes with the correct
%ones.

%Get trigger information
[~, ~, trigger_map] = xlsread(fullfile(main_dir, 'code', 'fix_raw', 'EmoRecap_210_correct_triggers.xlsx'));
old_triggers = cell2mat(trigger_map(2:end, 4))';
new_triggers = cell2mat(trigger_map(2:end, 5))';
assert(length(old_triggers) == length(new_triggers));

%Events in full dataset that came from Test_B
studyB_idx = 99:292;

%Codes representing trial onset (instead of responses, etc.)
trial_codes = [1:192, 250];
%Check that there are 96 trials in this subset
assert(sum(ismember(cell2mat(cellfun(@str2num, {EEG.event(99:292).type}, 'UniformOutput', false)), [1:192, 250])) == 96);

%Loop through events in Test_B and change relevant event codes
trial = 0;
for ev = studyB_idx
    if ismember(str2double(EEG.event(ev).type), trial_codes)
        trial = trial + 1;
        assert(str2double(EEG.event(ev).type) == old_triggers(trial));
        EEG.event(ev).type = num2str(new_triggers(trial));
    end
end
assert(trial == 96);

%Check that codes now match new_triggers
updated_codes = cell2mat(cellfun(@str2num, {EEG.event(studyB_idx).type}, 'UniformOutput', false));
assert(isequal(updated_codes(ismember(updated_codes, trial_codes)), new_triggers));

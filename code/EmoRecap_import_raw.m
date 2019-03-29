%Import Biosemi bdf files into a raw set in the correct order for EmoRecap
%
%Author: Eric Fields
%Version Date: 20 June 2018

function EEG = EmoRecap_import_raw(sub_id, main_dir)

    if ~exist('main_dir', 'var')
        main_dir = pwd;
    end

    %Import block order information
    [~, ~, sub_block_order] = xlsread(fullfile(main_dir, 'code', 'EmoRecap_SubBlockOrder.csv'));

    %Get block order by sub_id
    sub_idx = find(cell2mat(sub_block_order(:,1)) == str2num(sub_id(end-2:end))); %#ok<ST2NM>
    assert(length(sub_idx) == 1);
    block_order = sub_block_order(sub_idx, 2:end);

    %Create local versions of EEGLAB variables
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; %#ok<ASGLU>
    
    %Read in sets for subject
    for pt = 1:length(block_order)
        study_part = block_order{pt};
        if isnan(study_part)
            continue;
        end
        EEG = pop_biosig(fullfile(main_dir, 'biosemi_bdf', sprintf('%s_%s.bdf', sub_id, study_part)));
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', [sub_id '_' study_part], 'gui', 'off'); %#ok<ASGLU>
    end
    
    %Deal with recordings with extra channels
    if ismember(sub_id, {'EmoRecap_229'})
        set_idx = find(~([ALLEEG.nbchan] == 40));
        for pt = set_idx
            EEG = ALLEEG(pt);
            CURRENTSET = pt;
            channels_to_remove = {EEG.chanlocs(33:(EEG.nbchan-8)).labels};
            EEG = pop_select(EEG, 'nochannel', channels_to_remove);
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
            EEG = eeg_checkset(EEG);
        end
    elseif ~all([ALLEEG.nbchan] == 40)
        errordlg('Some sets have the wrong number of channels.');
    end
    
    %Merge sets
    EEG = pop_mergeset(ALLEEG, 1:length(ALLEEG));
    EEG.subject = sub_id;
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', sub_id, 'gui', 'off'); %#ok<ASGLU>

    %Fix any problems with the raw data
    sub_fix_raw_script = fullfile(main_dir, 'code', 'fix_raw', sprintf('%s_fix_raw.m', sub_id));
    if exist(sub_fix_raw_script, 'file')
        addpath(fullfile(main_dir, 'code', 'fix_raw'));
        run(sub_fix_raw_script);
    end
    
end
%EmoRecap
%Add flags to encoding trials to indicate later memory judgment for item
%
%Flag 1: Remember
%Flag 2: Know
%Flag 3: Guess
%Flag 4: New
%Flag 5: matching event is missing
%
%Author: Eric Fields
%Version Date: 23 May 2018

function EEG = EmoRecap_add_flags(EEG)

    fprintf('\n\nAdding subsequent memory flags.\n\n');

    event_num = [];
    flag = [];
    for evc = 1:192

        %Get locations of items
        ev_idx = find(ismember([EEG.EVENTLIST.eventinfo.code], evc));
        
        if length(ev_idx) == 2
            
            %Event occurs at both encoding and retrieval!
        
            %Make sure the first instance has encoding marker
            assert(ismember(EEG.EVENTLIST.eventinfo(ev_idx(1)+1).code, 201:206));
            %Make sure second instance has memory response
            assert(ismember(EEG.EVENTLIST.eventinfo(ev_idx(2)+1).code, 195:198));

            %Add to event_num and flag arrays
            event_num(end+1) = ev_idx(1); %#ok<AGROW>
            switch EEG.EVENTLIST.eventinfo(ev_idx(2)+1).code
                case 195
                    flag(end+1) = 1; %#ok<AGROW>
                case 196
                    flag(end+1) = 2; %#ok<AGROW>
                case 197
                    flag(end+1) = 3; %#ok<AGROW>
                case 198
                    flag(end+1) = 4; %#ok<AGROW>
            end
            
        elseif length(ev_idx) == 1
            
            %Report whether encoding or retrieval is missing
            if ismember(EEG.EVENTLIST.eventinfo(ev_idx+1).code, 201:206)
                fprintf('Event code %d only occurs at encoding.\n', evc);
            elseif ismember(EEG.EVENTLIST.eventinfo(ev_idx+1).code, 195:198)
                fprintf('Event code %d only occurs at retrieval.\n', evc);
            else
                error('Event code %d only occurs once, but cannot be categorized as encoding or retrieval.', evc);
            end
            
            %Add flag 5 to indicate missing event
            event_num(end+1) = ev_idx; %#ok<AGROW>
            flag(end+1) = 5; %#ok<AGROW>
            
        elseif isempty(ev_idx)
            
            %Event code does not occur (e.g., some blocks weren't
            %completed)
            fprintf('Event code %d doesn''t exist.\n', evc);
            
        elseif length(ev_idx) > 2
            
            %No event code should occur more than twice
            error('Event code %d occurs %d times.');
            
        else
            
            error('This block of code should never be reached.');
            
        end

    end

    %Set flags
    EEG = set_elist_user_flag(EEG, event_num, flag);

    %Update EEG.history
    hist_command = 'EEG = EmoRecap_add_flags(EEG)';
    EEG = eeg_hist(EEG, hist_command);

end


function EEG = set_elist_user_flag(EEG, event_num, flag, value)
%Set user flags in ERPLAB's EVENTLIST struct
%
%INPUTS:
% event_num - event indices in EEG.EVENTLIST.eventinfo
% flag      - flag to set for each event in event_num
% value     - value to set the flag (must be 0 or 1) {default: 1}
%
%OUTPUTS:
% EEG       - EEG struct with EVENTLIST use flags updated

    %If no value input, turn flag on
    if nargin < 4
        value = 1;
    end
    
    %Check inputs
    if ~all(ismember(value, [0, 1]))
        error('value input must be 0 or 1')
    end
    if length(value) ~= 1 && length(value) ~= length(event_num)
        error('The value parameter is not the same size as the number of events');
    end
    if length(event_num) ~= length(flag)
        error('Number of events must match number of flags');
    end
    
    %User flags start at flag 9
    flag = flag + 8;
    
    %If setting the flag to the same value for every event, resize value
    %input to match
    if length(value) == 1
        value = repmat(value, [1, length(event_num)]);
    end
    
    %Loop through events and update flags
    for i = 1:length(event_num)
        ev = event_num(i);
        EEG.EVENTLIST.eventinfo(ev).flag = bitset(EEG.EVENTLIST.eventinfo(ev).flag, flag(i), value(i));
    end
    
end

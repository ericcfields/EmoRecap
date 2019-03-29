%Return a EEG random subject
%
%INPUTS
% present  - string indicating a set type to draw subjects from; e.g.
%            'preart'
% missing  - string indicating a set type that has not been created yet for
%            the subject; e.g., 'postart'
% main_dir - The main study directory
%
% With no input, function will return a random subject from among the
% Biosemi bdf files
%
%Author: Eric Fields
%Version Date: 10 November 2017

function sub_id = rand_sub(present, missing, main_dir)

    %Set defaults for missing arguments
    if nargin < 3
        main_dir = pwd;
    end
    if nargin < 2
        missing = [];
    end
    if ~nargin
        present = 'bdf';
    end

    subs_subset = get_subset(present, missing, main_dir);
    
    %get random subject
    if isempty(subs_subset)
        fprintf('\n\nNo subjects left!\n\n');
        sub_id = [];
    else
        sub_id = subs_subset{randi(length(subs_subset))};
    end
    
end

%Make image file of effect at each channel individually
%
%INPUTS
% ERP       - ERPLAB ERPset
% bins      - Bins to plot
% chans     - Channels to make image for
% filename  - Name of image file without fullpath or extension (channel
%             name will be appended by function
% filepath  - directory to save image
% file_fmt  - image format for file (e.g., 'tif')
% line_spec - cell array of line formats (e.g., {'k-', 'b-.'})
%
%Author: Eric Fields
%Version Date: 6 March 2019

function make_chan_image(ERP, bins, chans, filename, filepath, file_fmt, line_spec)
    
    %Set defaults
    if nargin < 7
        line_spec = {'k-', 'b-.', 'r--', 'g:', 'm-.'};
    end
    if nargin < 6
        file_fmt = 'tif';
    end
    if nargin < 5
        filepath = pwd;
    end
    
    %Remove dot in file format
    if strcmpi('.', file_fmt(1))
        file_fmt = file_fmt(2:end);
    end

    for i = 1:length(chans)
        
        %Get channel number from label
        chan_num = find(strcmpi(chans{i}, {ERP.chanlocs.labels}));

        %Create waveform for valence effect + new
        ERP = pop_ploterps(ERP, bins, chan_num, ... 
                           'AutoYlim', 'on', ... 
                           'Axsize', [0.05 0.08], ... 
                           'BinNum', 'on', ... 
                           'Blc', 'pre', ... 
                           'Box', [1, 2], ... 
                           'ChLabel', 'on', ...
                           'FontSizeChan', 14, ... 
                           'FontSizeLeg', 14, ... 
                           'FontSizeTicks', 14, ... 
                           'LegPos', 'bottom', ... 
                           'Linespec', line_spec(1:length(bins)), ... 
                           'LineWidth',  1.5, ...
                           'Maximize', 'on', ... 
                           'MinorTicksX', 'on', ... 
                           'Position', [119.25, 14.3333, 106.875, 31.9048], ... 
                           'Style', 'Classic', ... 
                           'Tag', 'ERP_figure', ... 
                           'Transparency', 0, ... 
                           'xscale', [-199.0 1097.0  -100 0:200:1000], ... 
                           'YDir', 'reverse');

        %Save figure
        im_file = fullfile(filepath, sprintf('%s_%s.%s', filename, chans{i}, file_fmt));
        chan_fig = gcf;
        saveas(chan_fig, im_file, file_fmt);
        close(chan_fig);

        %Load image
        I = imread(im_file);
        %Crop and save
        I_crop = imcrop(I, [299   67  814  453]);
        imwrite(I_crop, im_file);

    end

end

%Create image file of scalp maps in 100 ms time windows from 0 to 1000
%
%EXAMPLE USAGE
% make_scalp_map_image(ERP, 10, [-2 2], 'EmoEffect_scalp_map.tif', 'C:\Users\ecfne\Pictures');
%
%INPUTS
% ERP            - ERPLAB ERPset
% bin            - Bin to plot (usually a bin containing a difference wave)
% voltage_scale  - two number vector giving the upper and lower limits of
%                  the voltage on the map {default: [-2.5, 2.5]}
% filename       - name of image file including file extension
% filepath       - location to save image
%
%Author: Eric Fields
%Version Date: 15 March 2019

function make_scalp_map_image(ERP, bin, voltage_scale, filename, filepath)

    if nargin < 3
        voltage_scale = [-2.5, 2.5];
    end
    if nargin < 4
        filename = sprintf('%_scalp_map.tif', ERP.bindescr{bin});
    end
    if nargin < 5
        filepath = pwd;
    end

    ERP = pop_scalplot(ERP,  bin, ... 
                       [0 100; 100 200; 200 300; 300 400; 400 500; 500 600; 600 700; 700 800; 800 900; 900 1000], ... 
                       'Blc', 'pre', ...
                       'Colorbar', 'on', ... 
                       'Colormap', 'jet', ... 
                       'Electrodes', 'on', ... 
                       'FontName', 'Courier New', ... 
                       'FontSize',  10, ... 
                       'Legend', '', ...
                       'Maplimit', voltage_scale, ...
                       'Mapstyle', 'both', ... 
                       'Maptype', '2D', ... 
                       'Mapview', '+X', ... 
                       'Plotrad',  0.55, ... 
                       'Value', 'mean', ...
                       'Maximize', 'on'); %#ok<NASGU>

    %Save figure
    im_file = fullfile(filepath, filename);
    chan_fig = gcf;
    saveas(chan_fig, im_file);
    close(chan_fig);

    %Load image
    I = imread(im_file);
    %Crop and save
    I_crop = imcrop(I, [112.51, 491.51, 2152.98, 218.98]);
    imwrite(I_crop, im_file);

end
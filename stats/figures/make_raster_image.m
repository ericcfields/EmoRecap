%Make raster plot image
%
%INPUTS
% GND            - MUT GND variable
% filename       - name for image file including format, but not path
% filepatj       - Directory to save image {default: current directory}
% f_scale_limits - Lower and upper limits for F scale, e.g. [0, 20]
%                  {default: auto limits}
%
%Author: Eric Fields
%Version Date: 6 March 2019

function make_raster_image(GND, test_id, filename, filepath, f_scale_limits)
    
    %Set defaults
    if nargin < 5
        f_scale_limits = false;
    end
    if nargin < 4
        filepath = pwd;
    end

    raster_size = [0, 0, 0.5 0.75];

    %Create raster
    if f_scale_limits
        F_sig_raster(GND, test_id, 'use_color', 'rgb', 'scale_limits', f_scale_limits);
    else
        F_sig_raster(GND, test_id, 'use_color', 'rgb');
    end
        
    %Resize
    raster_fig = gcf;
    set(raster_fig, 'Units', 'Normalized', 'OuterPosition', raster_size);
    
    %Save
    raster_file = fullfile(filepath, filename);
    saveas(raster_fig, raster_file);
    close(raster_fig);
    
    %Crop
    I = imread(raster_file);
    I_crop = imcrop(I, [43.5, 56.5, 1134, 715]);
    imwrite(I_crop, raster_file);
    
end
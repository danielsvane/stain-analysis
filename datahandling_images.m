function datahandling_images()

    % This program needs export_fig, subplot_tight and barwitherr to work

    clc; clf; clear all; close all;
    warning('off', 'all'); % Disable warnings from imfindcircles()
    
    factor = 200/196; % 196px = 200um
    
    % Folders to analyze (will end up like 'data/Gr 1 ctrl 4h/Subfolder_001/')
    folders = {'Gr 1 ctrl 4h', 'Gr 1 ctrl 48h', 'Gr 1 30s 4h', 'Gr 1 30s 48h', 'Gr 1 10min 4h', 'Gr 1 10min 48h', 'Gr 1 1h 4h', 'Gr 1 1h 48h', 'Gr 1 24h 4h', 'Gr 1 24h 48h'};
    % Labels for bar plot
    labels = {'Control', '30s', '10min', '1h', '24h'};
    % Headers for excel sheet
    headers = {'File', '4h cell count', '48h cell count', '4h cell coverage [%]', '48h cell coverage [%]', '4h average cell area [um^2]', '4h average cell area [um^2]'};
    
    count_averages = [];
    count_errors = [];
    coverage_averages = [];
    coverage_errors = [];
    area_averages = [];
    area_errors = [];

    % For temporarily saving data, needed for silly excel sheet formatting
    counts_4h = [];
    counts_48h = [];
    coverages_4h = [];
    coverages_48h = [];
    areas_4h = [];
    areas_48h = [];
    left_column = {};
    data = [];
    
    % Loop all folders
    for k = 1:length(folders)
        folder = ['data/' folders{k} '/Subfolder_001/'];
        files = dir([folder '*.tif']);

        areas = [];
        coverages = [];
        counts = [];
        
        % Loop every third image in folder
        for i = 1:length(files)/3
            file_count = files((i-1)*3+2);
            file_area = files((i-1)*3+1);
            
            disp(['Analyzing image: ' folder file_area.name]);
            
            % Open DAPI and phalloidin colored images
            img_dapi = imread([folder file_count.name]);
            img_phalloidin = imread([folder file_area.name]);

            % Insert black reactangle over the scale bar
            img_count = insertShape(img_dapi, 'FilledRectangle', [25, 3, 205, 35], 'Color', 'black', 'Opacity', 1);
            img_area = insertShape(img_phalloidin, 'FilledRectangle', [25, 3, 205, 35], 'Color', 'black', 'Opacity', 1);            

            % Convert image to black and white
            img_area = im2bw(img_area, 0.03);
            % Fill in gaps
            img_area = imfill(img_area, 'holes');

            area_white = bwarea(img_area);
            [width, height] = size(img_area);
            area = width*height;

            disp(['Analyzing image: ' folder file_count.name]);
            
            img_count = rgb2gray(img_count);
            % Find intensity peaks of cells to seperate close clusters
            img_count = imextendedmax(img_count, 5);
            % Find all regions of white color
            props = regionprops('table', img_count, 'Centroid');
            count = size(props.Centroid, 1);
            
            % Save some examples of image manipulation
            if (k == 10 && i == 1)
                figure;
                
                subplot_tight(2, 2, 1);
                subimage(img_dapi);
                text(1250, 100, 'A', 'color', 'white', 'fontsize', 20);
                axis off;
                
                subplot_tight(2, 2, 2);
                subimage(img_count);
                text(1250, 100, 'B', 'color', 'white', 'fontsize', 20);
                axis off;
                
                subplot_tight(2, 2, 3);
                subimage(img_phalloidin);
                text(1250, 100, 'C', 'color', 'white', 'fontsize', 20);
                axis off;
                
                subplot_tight(2, 2, 4);
                subimage(img_area);
                text(1250, 100, 'D', 'color', 'white', 'fontsize', 20);
                axis off;
                
                export_fig('results/datahandling_sample.png', '-native');
            end
            
            coverages = [coverages area_white/area*100];
            areas = [areas area_white*factor^2/count];
            counts = [counts count/(area*factor^2*1e-8)];
            
            % Generating excel sheet column titles
            if mod(k, 2)
                left_column{i} = [labels{(k-1)/2+1} ' sample ' num2str(i)];
            end

        end
        
        % Formatting data for excel sheet
        if mod(k, 2) % 4h set
            counts_4h = counts;
            coverages_4h = coverages;
            areas_4h = areas;
        else % 48h set
            counts_48h = counts;
            coverages_48h = coverages;
            areas_48h = areas;
            data = [data; horzcat(left_column', num2cell([counts_4h', counts_48h', coverages_4h', coverages_48h', areas_4h', areas_48h']))];
        end
        
        % Save means and errors of data
        count_averages = [count_averages mean(counts)];
        count_errors = [count_errors error(counts)];
        coverage_averages = [coverage_averages mean(coverages)];
        coverage_errors = [coverage_errors error(coverages)];
        area_averages = [area_averages mean(areas)];
        area_errors = [area_errors error(areas)];
        
    end
    
    xlswrite('results/results.xlsx', vertcat(headers, data))
    
    createplot(count_averages, count_errors, labels, 'Cell count [cm^{-2}]', 'Number of cells', 'counts')
    createplot(coverage_averages, coverage_errors, labels, 'Surface coverage [%]', 'Cell coverage of surface', 'coverage')
    createplot(area_averages, area_errors, labels, 'Cell area [\mum^2]', 'Average cell area', 'area')
    
end

function createplot(averages, errors, labels, label_str, title_str, filename)
    figure
    averages = reshape(averages, 2, [])';
    errors = reshape(errors, 2, [])';
    barwitherr(errors, averages)
    set(gca, 'XTickLabel', labels)
    set(gca, 'XTickLabelRotation', 45)
    legend('4h incubation', '48h incubation', 'location', 'northwest')
    ylabel(label_str)
    xlabel('Coating time')
    title(title_str)
    saveas(gcf, ['results/' filename '.png'])
    saveas(gcf, ['results/' filename], 'epsc')
end

% Calculates SEM (standard error of mean)
function err = error(values)
    err = std(values)/sqrt(length(values));
end
function datahandling_ca

    clc; clf; clear all; close all;

    labels = {'Control', '30s', '10min', '1h', '24h'};
    degrees = [];

    degrees(1) = mean([107.7 107.3]);
    degrees(2) = mean([101.7 100.5]);
    degrees(3) = mean([102.9 105.6]);
    degrees(4) = mean([102 102.2]);
    degrees(5) = mean([95.38 95.86]);
    
    errors = [];
    errors(1) = mean([9.698 8.414]);
    errors(2) = mean([4.778 4.866]);
    errors(3) = mean([7.438 4.294]);
    errors(4) = mean([3.992 3.841]);
    errors(5) = mean([1.636 1.766]);
    
    barwitherr(errors, degrees, 0.4)
    
    set(gca, 'XTickLabel', labels)
    xlabel('Coating time')
    ylabel('Contact angle [\circ]')
    title('Contact angle of coating')
    
    saveas(gcf, 'results/ca.png')
    saveas(gcf, 'results/ca', 'epsc')
end


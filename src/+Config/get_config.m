function [value] = get_config(param)
    global global_config;

    if isempty(global_config)
        
        %set the defaults

        %make sure to run init.m to reset the changes
                
        global_config = [];
        global_config.LOWER_SIZE_BOUND = 40;
        global_config.MUMFORD_SHAH_LAMBDA = 0.15;
        global_config.WHITE_DISCARD_THRESHOLD = 0.9;
        global_config.MIN_CLUMP_AREA = 500;
        global_config.MAX_CLUMP_AREA = 10000;
        global_config.CLUMP_ADJUST_THRESHOLD = 0.5;
        global_config.CLUMP_MUMFORD_SHAH_LAMBDA = 0.05;
        global_config.CLUMP_THRESHOLD = 0.9;  
        global_config.CLUMP_THRESHOLD_MIN_SIZE = 60;
        global_config.USE_DEEP_FILTER = 1;   
        global_config.DEEP_FILTER_THRESHOLD = 0.67;   

    end
    if exist('param','var')
        value = global_config.(param);
    else
        value = [];
    end
end


function [] = set_config(param,value)
    global global_config;    
    Config.get_config(); %make sure global config exists
    global_config.(param) = value;
end


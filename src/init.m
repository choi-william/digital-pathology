% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

%close all;
clear;
global global_config;
global_config = [];

addpath(genpath('library'));
addpath common;
addpath ../src;

%initialize config
global config;
config = IniConfig();
config.ReadFile('../config.ini');

global dataPath;
dataPath = GetFullPath('../data');

global srcPath;
srcPath = GetFullPath('../src');

%suppress warnings
warning('off','images:initSize:adjustingMag')

% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Initalizes program. This should be called before running any files.


%close all;
clear;
global global_config;
global_config = [];

RANDOM_SEED = 23;
rng(RANDOM_SEED);

addpath(genpath('library'));
addpath common;
addpath ../src;

%suppress warnings
warning('off','images:initSize:adjustingMag')

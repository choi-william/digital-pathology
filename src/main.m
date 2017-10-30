run('init.m');

PATH = '../../images';

 %testbox set
im1 = DPImage('real',[PATH '/11.tif']);
im2 = DPImage('real',[PATH '/21.tif']);
im3 = DPImage('real',[PATH '/31.tif']);
im4 = DPImage('real',[PATH '/12.tif']);
im5 = DPImage('real',[PATH '/22.tif']);
im6 = DPImage('real',[PATH '/32.tif']);
im7 = DPImage('real',[PATH '/13.tif']);
im8 = DPImage('real',[PATH '/23.tif']);
im9 = DPImage('real',[PATH '/33.tif']);

% % % 
Display.display_stages(im1);
Display.display_stages(im2);
Display.display_stages(im3);
Display.display_stages(im4);
Display.display_stages(im5);
Display.display_stages(im6);
Display.display_stages(im7);
Display.display_stages(im8);
Display.display_stages(im9);
Display.display_stages(im10);

%DONT WORRY ABOUT THIS%
%Pipeline.run_all_files(0); 

%William Choi Test 
% im001 = DPImage('real',[dataPath '/subImage_test' '/11.tif']);
% im002 = DPImage('real',[dataPath '/subImage_test' '/21.tif']);
% im003 = DPImage('real',[dataPath '/subImage_test' '/31.tif']);
% im004 = DPImage('real',[dataPath '/subImage_test' '/12.tif']);
% im005 = DPImage('real',[dataPath '/subImage_test' '/22.tif']);
% im007 = DPImage('real',[dataPath '/subImage_test' '/13.tif']);
% im008 = DPImage('real',[dataPath '/subImage_test' '/23.tif']);
% 
% Display.display_stages(im001);
% Display.display_stages(im002);
% Display.display_stages(im003);
% Display.display_stages(im004);
% Display.display_stages(im005);
% Display.display_stages(im007);
% Display.display_stages(im008);

%%% IF YOU WANT TO RUN THE FULL ANALYSIS ON AN .SVS or .TIF IMAGE
%Pipeline.pathology_analysis(0);

%steps to running:
%
% run the analysis above ^^^^
%
% it will prompt for a slide to analyze, select it
%
% it will prompt for a directory to save analysis, select a folder where
% all the files will go in
%
% the output folder now contains a visualization.mat and a /blockImg folder
%
% move those two files into /data, and run +GUI/main.m to visualize the
% analysis







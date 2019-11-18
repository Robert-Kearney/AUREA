%% apexInit
%% Set McCRIB working environment
% Set Variad=which('apexInit')
curDir=pwd;
d=which('apexInit');
i=strfind(d,'rek');
baseDir=d(1:i-1)
SourceCodeRoot=[ baseDir 'NPR_GROUP/APEX/CODE/BitBucket'];
DataRoot=[baseDir 'NPR_Group' ];     %Path to the root directory of APEX Dropbox
GitRoot=['C:\Program Files\Git\bin'];        %Path to the Git bin directory
% Run Configuration
cd([SourceCodeRoot '\Utilities']);
setMcCRIBS_Env(SourceCodeRoot,DataRoot);
McCRIB_DATA_ROOT=getenv('McCRIB_DATA_ROOT');
cd(curDir); 
disp(pwd);
disp('apexInit initialization done');


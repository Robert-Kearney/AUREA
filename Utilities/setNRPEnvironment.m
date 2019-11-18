function [] = setNRPEnvironment(SourceCodeRoot,DataRoot)
%SETNRPENVIRONMENT Sets the MATLAB environment
%   to work on NRP projects.
%	[] = setNRPEnvironment(SourceCodeRoot,DataRoot)
%       adds the functions in SourceCodeRoot to the
%       MATLAB path, and sets the environment variable
%       NRP_ROOT equal to DataRoot.
%
%   INPUT
%   SourceCodeRoot is a string with the path to the
%       NRP source code repository.
%   DataRoot is a string with the path to the NRP
%       folder on Dropbox.
%
%   EXAMPLE
%   % Run this code before starting to work on any NRP project
%       SourceCodeRoot='YOUR_PATH_TO_THE_SOURCE_CODE_REPOSITORY\apex';
%       DataRoot='YOUR_PATH_TO_THE_NRP_DIRECTORY_IN_DROPBOX\NRP';
%       cd([SourceCodeRoot '\Utilities']);
%       setNRPEnvironment(SourceCodeRoot,DataRoot);
%       NRP_ROOT=getenv('NRP_ROOT');	%Use this line to get the environment variable defining the NRP root directory.
%       cd(NRP_ROOT);
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
%
%
%Copyright (c) 2013-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
%McGill University
%All rights reserved.
% 
%Redistribution and use in source and binary forms, with or without modification, are 
%permitted provided that the following conditions are met:
% 
%1. Redistributions of source code must retain the above copyright notice, this list of 
%   conditions and the following disclaimer.
% 
%2. Redistributions in binary form must reproduce the above copyright notice, this list of 
%   conditions and the following disclaimer in the documentation and/or other materials 
%   provided with the distribution.
% 
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
%EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
%MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
%COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
%EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
%HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
%TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    deprecate({'setMcCRIBS_Env'});

    addpath(genpath(SourceCodeRoot),'-end');
    setenv('NRP_ROOT',DataRoot);
end
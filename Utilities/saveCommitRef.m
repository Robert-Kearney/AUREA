function [] = saveCommitRef(SaveDir,FileName,TextMsg,ShowMsgs)
%SAVECOMMITREF Saves an HTML file with a link
%   to the current local Bitbucket Git commit.
%	[] = saveCommitRef(SaveDir,FileName,TextMsg,ShowMsgs)
%
%   INPUT
%   SaveDir is a string with the path of the
%       directory where the HTML file will be
%       saved (e.g., '.\' for the current
%       working directory).
%   FileName is a string with the name of the
%       HTML file (default: 'GeneratedBy').
%   TextMsg is an M-by-1 array of strings with
%       a message to be printed on the HTML
%       file (default: {}). Each element from
%       the array is printed as a separate line.
%   ShowMsgs is a flag indicating if messages
%       should be sent to the standard output
%       (default: false).
%
%   OUTPUT
%
%   EXAMPLE
%   saveCommitRef('.\',[],{'Hello World!';'This is line 2';'This is line 3'});    %Saves the HTML file in the current directory.
%
%   VERSION HISTORY
%   2016_04_08 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] McCRIB group: Naming/Plotting Standards for Code, Figs and Symbols.
%
%
%Copyright (c) 2016, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('SaveDir','var') || isempty(SaveDir)
        SaveDir='.\';
    end
    if ~exist('FileName','var') || isempty(FileName)
        FileName='GeneratedBy';
    end
    if ~exist('TextMsg','var') || isempty(TextMsg)
        TextMsg={};
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    st=dbstack;
    stLen=size(st,1);
    CommitSHA=currentBitbucketCommit();
    fid=fopen([SaveDir FileName '.html'],'w');
    fprintf(fid,'%s\n','<html>');
    fprintf(fid,'%s\n','<head>');
    fprintf(fid,'%s\n','<title>Generated by ...</title>');
    fprintf(fid,'%s\n','</head>');
    fprintf(fid,'%s\n','<body>');
    if ~isempty(TextMsg)
        fprintf(fid,'%s\n','<h2>Message</h2>');
        for ixMsgLine=1:length(TextMsg)
            fprintf(fid,'%s\n',['<p>' TextMsg{ixMsgLine} '</p>']);
        end
        fprintf(fid,'%s\n','<hr>');
    end
    fprintf(fid,'%s\n','<h2>Details</h2>');
    fprintf(fid,'%s\n',['<i>' FileName '.html</i> was generated on: ' datestr(now) '.<br><br>']);
    fprintf(fid,'%s\n',['Commit: <a href="https://bitbucket.org/carlos_roblesrubio/apex/src/' CommitSHA '">' CommitSHA '</a>.<br><br>']);
    fprintf(fid,'%s\n','Function Call Stack:<br><ol>');
    for ixStack=2:stLen
        fprintf(fid,'%s\n',['<li>' st(2).name '&nbsp;(line ' num2str(st(2).line) ')</li> ']);
    end
    fprintf(fid,'%s\n','</ol>');
    fprintf(fid,'%s\n','</body>');
    fprintf(fid,'%s\n','</html>');
    fclose(fid);
end
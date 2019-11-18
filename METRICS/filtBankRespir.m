function [TotPWR_RR,TotPWR_MV,MaxPWR_MV,MaxPWR_RR,FMAX,FMAXi] = filtBankRespir(X,N,Fs,ShowMsgs)
%FILTBANKRESPIR Implements a Filter Bank for respiratory   signals as described in [1].
%   [TotPWR_RR,TotPWR_MV,MaxPWR_MV,MaxPWR_RR,FMAX,FMAXi] = filtBankRespir(X,N,Fs,ShowMsgs)
%       returns the Maximum power in the Movement
%       Artifact Band (MaxPWR_MV), the Maximum power
%       in the Respiratory Rate Band (MaxPWR_RR), and the
%       respiratory frequency with the maximum power.
%
%   INPUT
%   X is an M-by-1 vector with either a ribcage or
%       abdomen respiratory inductive plethysmography (RIP)
%       signal.
%   N is a scalar value with the length (in sample points)
%       of the sliding window.
%   Fs is a scalar value with the sampling frequency
%       (default = 50Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output (default = false).
%
%   OUTPUT
%   TotPWR_RR is an M-by-1 vector with the total power
%       in the Respiratory Rate Band for each sample.
%   TotPWR_MV is an M-by-1 vector with the total power
%       in the Movement Artifact Band for each sample.
%   MaxPWR_MV is an M-by-1 vector containing the Maximum
%       power in the Movement Artifact Band for each
%       sample.
%   MaxPWR_RR is an M-by-1 vector containing the Maximum
%       power in the Respiratory Rate Band for each sample.
%   FMAX is an M-by-1 vector containing the respiratory
%       frequency with the maximum power. This represents
%       a respiratory frequency estimate.
%   FMAXi is an M-by-1 vector containing the index of the
%       filter (in the respiratory frequency band) with
%       maximum power at each sample.
%
%   EXAMPLE
%   [~,~,~,~,FMAX,~]=filtBankRespir(X,N,Fs);
%
%   VERSION HISTORY
%   2015_04_16 - Added selective filter output (CARR).
%   2015_04_16 - Replaced transfer function design of filters by zero-pole-gain design (CARR).
%   2015_04_16 - Function now returns the frequency FMAX instead of the filter index (CARR).
%   2015_04_16 - Renamed to better reflect use (CARR).
%   Modified by Carlos A. Robles-Rubio (CARR) to work with the filter bank in [1], and include Fs parameter.
%   Original - Created from code probably developed by Ahmed Aoude.
%
%   REFERENCES
%   [1] A. Aoude, R. E. Kearney, K. A. Brown, H. Galiana, and
%       C. A. Robles-Rubio,
%       "Automated Off-Line Respiratory Event Detection for the
%       Study of Postoperative Apnea in Infants,"
%       IEEE Trans. Biomed. Eng., vol. 58, pp. 1724-1733, 2011.
%
%
%Copyright (c) 2011-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end
    
    xlen=length(X);

    % Define the cut-off frequencies
    dF=0.2;
    Fl=[0:0.15:1.8]';
    Fh=Fl+dF;
    Freqs=mean([Fl Fh],2);

    [numFilters,~]=size(Fl);

    Rp=0.1;
    Rs=50;
    n=[6;3;3;3;3;3;3;3;3;3;3;3;3];
    Wn={0.2/(Fs/2)};
    for index=2:numFilters
        Wn{index}=[Fl(index) Fh(index)]/(Fs/2);
    end

    Filt_signal=zeros(xlen,numFilters);

    %Create the filters
    for index=1:numFilters
        [z{index},p{index},k{index}]=ellip(n(index),Rp,Rs,Wn{index});
    end
    
    %Filter the signals with the Filter Bank
    for index=1:numFilters
        [SOS,G]=zp2sos(z{index},p{index},k{index});
        Filt_signal(:,index)=filtfilt(SOS,G,X);
        if ShowMsgs
            h_filt{index}=dfilt.df2sos(SOS,G);
        end
    end
    
    if ShowMsgs
        myStr='fvtool(';
        for index=1:numFilters
            myStr=[myStr 'h_filt{' num2str(index) '},'];
        end
        myStr=[myStr '''FrequencyScale'',''linear'',''Fs'',Fs);'];
        eval(myStr);
    end
    
    clear z p k Rp Rs n Wn dF Fs nc X;

    Pwr_signal=zeros(xlen,numFilters);
    b=ones(N,1)./N;
    for index=1:numFilters
        Pwr_signal(:,index)=filter2S(b,Filt_signal(:,index).^2,2);
    end
    
    TotPWR_RR=sum(Pwr_signal(:,3:13),2);
    TotPWR_MV=sum(Pwr_signal(:,1:2),2);
    
    Pwr_signal=Pwr_signal';
    clear Filt_signal b;

    [MaxPWR_MV,MaxPWR_MV_index] = max(Pwr_signal(1:2,:));
    [MaxPWR_RR,MaxPWR_RR_index] = max(Pwr_signal(3:13,:));

    MaxPWR_MV=MaxPWR_MV';
    MaxPWR_RR=MaxPWR_RR';

    MaxPWR_MV_index=MaxPWR_MV_index';
    MaxPWR_RR_index=MaxPWR_RR_index';

    FMAXi=MaxPWR_RR_index+2;
    FMAX=Freqs(FMAXi);
end
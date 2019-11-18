function [TotPWR_HR,TotPWR_MV,MaxPWR_MV,MaxPWR_HR,FMAX] = filtBankCardiac(X,N,HR_Freqs,TopFreq,Fs,ShowMsgs)
%FILTBANKCARDIAC Implements a Filter Bank for cardiac signals.
%   [TotPWR_HR,TotPWR_MV,MaxPWR_MV,MaxPWR_HR,FMAX] = filtBankCardiac(X,N,HR_Freqs,TopFreq,Fs,ShowMsgs)
%       returns the Maximum power in the Movement
%       Artifact Band (MaxPWR_MV), the Maximum power
%       in the Heart Rate Band (MaxPWR_HR), and the
%       HR frequency with the maximum power.
%
%   INPUT
%   X is an M-by-1 vector with either the electrocardiogram
%       or photoplethysmography signal.
%   N is a scalar value with the length (in sample points)
%       of the sliding window.
%   HR_Freqs is a struct array with the limits of the
%       heart rate band. It has the following fields:
%       * Fl, a scalar with the lower limit. The default
%         is 1.5 Hz.
%       * Fh, a scalar with the higher limit. The default
%         is 4 Hz.
%   TopFreq is a scalar with the last frequency represented
%       in the filter bank. The default is 5 Hz.
%   Fs is a scalar value with the sampling frequency
%       (It should be used with the default 50 Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output (default = false).
%
%   OUTPUT
%   TotPWR_HR is an M-by-1 vector with the total power
%       in the Heart Rate Band for each sample.
%   TotPWR_MV is an M-by-1 vector with the total power
%       in the Movement Artifact Band for each sample.
%   MaxPWR_MV is an M-by-1 vector containing the Maximum
%       power in the Movement Artifact Band for each
%       sample.
%   MaxPWR_HR is an M-by-1 vector containing the Maximum
%       power in the Heart Rate Band for each sample.
%   FMAX is an M-by-1 vector containing the Heart Rate
%       frequency with the maximum power. This represents
%       a cardiac frequency estimate.
%
%   EXAMPLE
%   [~,~,~,~,FMAX]=filtBankCardiac(X,N,[],[],Fs);
%
%   VERSION HISTORY
%   2015_04_15 - Renamed to better reflect use (CARR).
%   2011_09_21 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] D. Precup, C. A. Robles-Rubio, K. A. Brown, L. Kanbar,
%       J. Kaczmarek, S. Chawla, G. M. Sant’anna, and R. E. Kearney,
%       "Prediction of Extubation Readiness in Extreme Preterm
%       Infants Based on Measures of Cardiorespiratory Variability,"
%       in Conf. Proc. 34rd IEEE Eng. Med. Biol. Soc., San Diego, USA,
%       2012, pp. 5630-5633.
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

    if ~exist('HR_Freqs','var') || isempty(HR_Freqs)
        HR_Freqs.Fl=1.5;
        HR_Freqs.Fh=4;
    end
    if ~exist('TopFreq','var') || isempty(TopFreq)
        TopFreq=5;
    end
    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    xlen=length(X);

    % Define the cut-off frequencies
    dF=0.02;
    Fh=(dF:dF:TopFreq)';
    Fl=Fh-dF;
    Fl(1)=0;
    Fh(end)=TopFreq;
    Freqs=mean([Fl Fh],2);
    [numFilters,~]=size(Fl);
    ixFilt_HR_Fl=find(Freqs>=HR_Freqs.Fl,1,'first');
    ixFilt_HR_Fh=find(Freqs<=HR_Freqs.Fh,1,'last');

    Rp=0.1;
    Rs=50;
    n=ones(numFilters,1).*5;
    n(1)=10;
    Wn{1}=Fh(1)/(Fs/2);
    for index=2:numFilters
        Wn{index}=[Fl(index) Fh(index)]/(Fs/2);
    end

    Filt_signal=zeros(xlen,numFilters);

    %Create the filters
    for index=1:numFilters
        [z{index},p{index},k{index}]=ellip(n(index),Rp,Rs,Wn{index});
    end
    
    % Filter the signals with the Filter Bank
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
    
    clear z p k SOS G Rp Rs n Wn dF nc h_filt;

    Pwr_signal=zeros(xlen,numFilters);
    b=ones(N,1)./N;
    for index=1:numFilters
        Pwr_signal(:,index)=filter2S(b,Filt_signal(:,index).^2);
    end

    TotPWR_HR=sum(Pwr_signal(:,ixFilt_HR_Fl:ixFilt_HR_Fh),2);
    TotPWR_MV=sum(Pwr_signal(:,1:ixFilt_HR_Fl-1),2);

    Pwr_signal=Pwr_signal';
    [MaxPWR_MV,MaxPWR_MV_index]=max(Pwr_signal(1:ixFilt_HR_Fl-1,:));
    [MaxPWR_HR,MaxPWR_HR_index]=max(Pwr_signal(ixFilt_HR_Fl:ixFilt_HR_Fh,:));
    Pwr_signal=Pwr_signal';

    MaxPWR_MV=MaxPWR_MV';
    MaxPWR_HR=MaxPWR_HR';

    MaxPWR_MV_index=MaxPWR_MV_index';
    MaxPWR_HR_index=MaxPWR_HR_index';

    FMAXi=MaxPWR_HR_index+ixFilt_HR_Fl-1;
    FMAX=Freqs(FMAXi);
end
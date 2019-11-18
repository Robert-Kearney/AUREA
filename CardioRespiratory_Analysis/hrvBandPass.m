function [X_V,X_L,X_H] = hrvBandPass(X,FilterParams,Fs,ShowMsgs)
%HRVBANDPASS Band-pass filtered components for heart and respiratory rate variability analysis
%	[X_V,X_L,X_H] = hrvBandPass(X,FilterParams,Fs,ShowMsgs)
%       returns the Very Low Frequency (VLF), Low Frequency
%       (LF), and High Frequency (HF) components of X.
%
%   INPUT
%   X is an M-by-1 vector with either the cardiac or
%       respiratory frequency.
%   FilterParams is a struct array with the parameters
%       of the band-pass filters. It has the following
%       fields:
%       * Fc is a struct array with the cut-off
%         frequencies for each band. Fc has the
%         following fields:
%         + VLF is a 1-by-2 vector with the low and high
%           cut-off frequencies (in Hz) for the VLF band.
%           The default is [0.01 0.035].
%         + LF is a 1-by-2 vector with the low and high
%           cut-off frequencies (in Hz) for the LF band.
%           The default is [0.045 0.19].
%         + HF is a 1-by-2 vector with the low and high
%           cut-off frequencies (in Hz) for the HF band.
%           The default is [0.22 1.99].
%       * HalfOrder is a struct array defining the order
%         of the band-pass filters. Order has the
%         following fields:
%         + VLF is a scalar integer value with the half
%           the order of the VLF band-pass filter
%           (default = 4).
%         + LF is a scalar integer value with the half
%           the order of the LF band-pass filter
%           (default = 5).
%         + HF is a scalar integer value with the half
%           the order of the HF band-pass filter
%           (default = 6).
%   Fs is a scalar value with the sampling frequency
%       (default = 50 Hz).
%   ShowMsgs is a flag indicating if messages should be
%       sent to the standard output (default = false).
%
%   OUTPUT
%   X_V is an M-by-1 vector containing the VLF component
%       of signal X.
%   X_L is an M-by-1 vector containing the LF component
%       of signal X.
%   X_H is an M-by-1 vector containing the HF component
%       of signal X.
%
%   EXAMPLE
%   Fs=50;  %In Hz
%   [X_V,X_L,X_H]=hrvBandPass(X,[],Fs,true);
%   %Get the power of X_L over a sliding window of length Npwr
%	Npwr=5*60*Fs+1;    %In samples
%	b=ones(Npwr,1)./Npwr;
%	X_L_pwr=filter2S(b,X_L.^2);
%
%   VERSION HISTORY
%   2015_04_15 - Created by Carlos A. Robles-Rubio (CARR).
%
%   REFERENCES
%   [1] D. Precup, C. A. Robles-Rubio, K. A. Brown, L. Kanbar,
%       J. Kaczmarek, S. Chawla, G. M. Sant’anna, and R. E. Kearney,
%       "Prediction of Extubation Readiness in Extreme Preterm
%       Infants Based on Measures of Cardiorespiratory Variability,"
%       in Conf. Proc. 34th IEEE Eng. Med. Biol. Soc.,
%       San Diego, USA, 2012, pp. 5630-5633.
%
%
%Copyright (c) 2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

	if ~exist('FilterParams','var') || ~isstruct(FilterParams)
        %The cut-off frequencies
        FilterParams.Fc.VLF=[0.01 0.035];   %VLF: 0.01 - 0.04 Hz
        FilterParams.Fc.LF=[0.045 0.19];    %LF:  0.04 - 0.20 Hz
        FilterParams.Fc.HF=[0.22 1.99];     %HF:  0.20 – 2.00 Hz
        
        %The filters' half order
        FilterParams.HalfOrder.VLF=4;
        FilterParams.HalfOrder.LF=5;
        FilterParams.HalfOrder.HF=6;
    end
    if ~exist('Fs','var') || isempty(Fs)
        Fs=50;
    end
    if ~exist('ShowMsgs','var') || isempty(ShowMsgs)
        ShowMsgs=false;
    end

    %Design band-pass filters
    [zv,pv,kv]=ellip(FilterParams.HalfOrder.VLF,0.01,50,FilterParams.Fc.VLF/(Fs/2));
    [sosv,gv]=zp2sos(zv,pv,kv);
    [zl,pl,kl]=ellip(FilterParams.HalfOrder.LF,0.01,50,FilterParams.Fc.LF/(Fs/2));
    [sosl,gl]=zp2sos(zl,pl,kl);
    [zh,ph,kh]=ellip(FilterParams.HalfOrder.HF,0.01,50,FilterParams.Fc.HF/(Fs/2));
    [sosh,gh]=zp2sos(zh,ph,kh);
    
    if ShowMsgs
        hv=dfilt.df2sos(sosv,gv);
        hl=dfilt.df2sos(sosl,gl);
        hh=dfilt.df2sos(sosh,gh);
        hfvt=fvtool(hv,hl,hh,'FrequencyScale','log','Fs',Fs);
        legend(hfvt,'VLF','LF','HF');
    end
    
    %Get the band-passed components
	X_V=filtfilt(sosv,gv,X);
    X_L=filtfilt(sosl,gl,X);
    X_H=filtfilt(sosh,gh,X);
end
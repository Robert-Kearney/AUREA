function [BRC,BAB,BSU,BDI,BPH] = breathStat(RC,AB,Nb,Nmu1,Navg,Fs)
%BREATHSTAT Breathing test statistics
%   [BRC,BAB,BSU,BDI,BPH] = breathStat(RC,AB,Nb,Navg,Fs)
%      returns the breathing statistics from the
%      respiratory signals RC and AB.
%
%   INPUT
%   RC and AB are M-by-1 vectors with ribcage and
%      abdominal signals respectively.
%   Nb is a scalar value with the length (in
%      sample points) of the sliding window
%      used to estimate the breathing power.
%   Nmu1 is a scalar value with the length (in
%      sample points) of the sliding window
%      used to estimate the signal's mean.
%   Navg is a scalar value with the length
%      (in sample points) of the smoothing
%      window.
%   Fs is a scalar value with the sampling
%      frequency (default=50Hz).
%
%   OUTPUT
%   BRC is an M-by-1 vector containing the
%      ribcage Breathing statistic.
%   BAB is an M-by-1 vector containing the
%      abdomen Breathing statistic.
%   BSU is an M-by-1 vector containing the
%      synchronous Breathing statistic.
%   BDI is an M-by-1 vector containing the
%      asynchronous Breathing statistic.
%   BPH is an M-by-1 vector containing the
%      estimate of the phase between RC and AB
%      in percent of 180 degrees.
%
%   VERSION HISTORY
%   Created by: Carlos A. Robles-Rubio.
%
%   References:
%   [1] C. A. Robles-Rubio, K. A. Brown, and R. E. Kearney,
%       "Detection of Breathing Segments in Respiratory Signals,"
%       in Conf. Proc. 34rd IEEE Eng. Med. Biol. Soc., San Diego,
%       USA, 2012, pp. 6333-6336.
%
%
%Copyright (c) 2012-2015, Carlos Alejandro Robles Rubio, Karen A. Brown, and Robert E. Kearney, 
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

    if ~exist('Fs') | isempty(Fs)
        Fs=50;
    end

    %Binarize the signals and obtain the rising edge
    RCm1=momStat(RC,1,Nmu1,Fs);
    RCm12=momStat(RC,2,Nmu1,Fs);
    RCm2=momStat(RC,1,Navg,Fs);
    RCbin1=double(RCm2>RCm1);
    RCbin2=double(RCm2>(RCm1+0.5.*sqrt(RCm12)));
    RCbin3=double(RCm2>(RCm1-0.5.*sqrt(RCm12)));
    RCdbin1=abs(diff(RCbin1));
    RCdbin2=abs(diff(RCbin2));
    RCdbin3=abs(diff(RCbin3));
    RCdbinT=RCdbin1;%+RCdbin2+RCdbin3;
    ABm1=momStat(AB,1,Nmu1,Fs);
    ABm2=momStat(AB,1,Navg,Fs);
    ABbin1=double(ABm2>ABm1);
    ABdbin1=abs(diff(ABbin1));
    ABdbinT=ABdbin1;
    SUbin1=(RCbin1+ABbin1)/2;
    DIbin1=(RCbin1-ABbin1)/2;

%% Breathing test statistics (BRC,BAB,BSU)
    %High-pass filter the binary signals
    [b,a]=ellip(4,0.1,50,0.5/(Fs/2),'high');
    RCbinHp=filtfilt(b,a,RCbin1);
    ABbinHp=filtfilt(b,a,ABbin1);
    SUbinHp=filtfilt(b,a,SUbin1);
    DIbinHp=filtfilt(b,a,DIbin1);
    
    %Compute the power of the high-pass filtered signals
    b=ones(Nb,1)./Nb;
    BRC=filter2S(b,RCbinHp.^2);
    BAB=filter2S(b,ABbinHp.^2);
    BSU=filter2S(b,SUbinHp.^2);
    BDI=filter2S(b,DIbinHp.^2);

%% Phase estimation (BPH)
    %XOR of the binary signals
    u = xor(RCbin1,ABbin1);
    %Moving average on a window of size Nb of u, representing the degree
    %of asynchrony
    b=ones(Nb,1)./Nb;
    BPH=filter2S(b,u);
end
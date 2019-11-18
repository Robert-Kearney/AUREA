function [ Metricsnew] = decimateCardiorespiratoryMetrics( Metrics, OrigSamplingRate, NewSamplingRate,nOrder )
%DECIMATECARDIORESPIRATORYMETRICS function to decimate original metrics signals to a lower sampling rate.
%
% [ Metricsnew] = decimateCardiorespiratoryMetrics( Metrics, OrigSamplingRate, NewSamplingRate,nOrder )
%
%   INPUT
%   METRICS           1x1 STRUCT containing M fields, where each field is
%                     an Mx1 metric. (computed from CARDIORESPIRATORYMETRICS
%                     function found in APEX Git directory.)
%   ORIGSAMPLINGRATE  1x1 DOUBLE Original sampling rate of metrics file
%                     (typically equal to 50 Hz).
%   NEWSAMPLINGRATE   1x1 DOUBLE Desired output sampling rate.
%   NORDER            1x1 DOUBLE Order of Finite Impulse Response (FIR)
%                     filter used to decimate.
%
%   OUTPUT
%   METRICSNEW        1x1 STRUCT containing M fields, where each
%                     field is a decimated metric.
%
%   EXAMPLE
%   [Metricsnew]=decimateCardiorespiratoryMetrics(a02b15a1254c_CardiorespiratoryMetrics, 50, 10, 500)
%   figure;plot((1:1:length(Metricsnew.respfrq_ABDxxx_filtbnk)).*(1/10), Metricsnew.respfrq_ABDxxx_filtbnk, 'r')
%   hold on;plot((1:1:length(a02b15a1254c_CardiorespiratoryMetrics.respfrq_ABDxxx_filtbnk)).*(1/50), a02b15a1254c_CardiorespiratoryMetrics.respfrq_ABDxxx_filtbnk, 'b')
%   legend('Decimated', 'Orig')
%
%   VERSION HISTORY
%   2016-06-20: First version by Lara Kanbar
%

%Copyright (c) 2013-2016, L. Kanbar, R. E. Kearney, G. M. Sant'Anna
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


if ~exist('nOrder') | isempty(nOrder)
    nOrder=500;%FIR filter order
end

%Obtain variable names within CardiorespiratoryMetrics
varnames = fieldnames(Metrics);

%Decimation Parameters
r = OrigSamplingRate/NewSamplingRate; % reduce sampling rate by a factor of r

%Decimate Signals
for iMetric = 1:length(varnames)
    metrictemp=decimate(Metrics.(varnames{iMetric}),r, nOrder,'fir');
    %Smooth the signal using a 3-point moving average, to get rid of
    %sinusoidal oscilltions at sharp corners.
    Metricsnew.(varnames{iMetric})  = smo(metrictemp, 1);
    clear metrictemp
end


end


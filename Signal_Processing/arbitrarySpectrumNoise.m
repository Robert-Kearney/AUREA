function [x] = arbitrarySpectrumNoise(x,Sxx,maxProp,verbose,Fs)
%ARBITRARYSPECTRUMNOISE Noise with arbitrary power spectrum
%   [x] = arbitrarySpectrumNoise(x,Sxx)
%      returns a realization of noise with
%      a given PDF and arbitrary power spectrum.
%
%   INPUT
%   x is an M-by-1 vector with an iid sample
%      from a given distribution.
%   Sxx is an P-by-1 vector defining the desired
%	   spectrum for the data in x.
%   maxProp is a scalar with the maximum proportion
%      of change accepted for convergence.
%   verbose is a logical flag. Set to 1 to
%       show progress bar.
%   Fs is a scalar with the sampling frequency.
%
%   OUTPUT
%   x is an M-by-1 vector containing the data
%      from the input x with arbitrary spectrum Sxx.
%
%   VERSION HISTORY
%   2013_09_05: Created by Carlos A. Robles-Rubio.
%
%   References:
%   [1] J. M. Nichols, C. C. Olson, J. V. Michalowicz, and F. Bucholtz,
%       "A simple algorithm for generating spectrally colored,
%       non-Gaussian signals," Probabilistic Engineering Mechanics,
%       vol. 25, pp. 315-322, 7// 2010.
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

    P=length(Sxx);
    N=length(x);
    Sxx=interp1(linspace(-Fs/2,Fs/2,P),Sxx,linspace(-Fs/2,Fs/2,N))';
    Sxx(floor(N/2)+1)=0;                        % zero out the DC component (remove mean)
    Xf=sqrt(2*pi*N*Fs*Sxx);                     % Convert PSD to Fourier amplitudes
    Xf=ifftshift(Xf);                           % Put in Matlab FT format
    vs=(2*pi*Fs/N)*sum(Sxx)*(N/(N-1));          % Get signal variance (as determined by PSD)
%     x=x*sqrt(vs/var(x));                        % guarantee new data match this variance
    mx=mean(x); x=x-mx;                         % subtract the mean
    xo=sort(x);                                 % store sorted signal xo with correct PDF
    k=1; indxp=zeros(N,1);                      % initialize counter
    if verbose
        myH=waitbar(0,'Noise with arbitrary PSD...');
    end
    while(k)
        Rk=fft(x);                              % Compute FT
        Rp=atan2(imag(Rk),real(Rk));            % Get phases
        x=real(ifft((exp(1i.*Rp)).*abs(Xf)));	% Give signal correct PSD
        [~,indx]=sort(x);                       % Get rank of signal with correct PSD
        x(indx)=xo;                             % rank reorder (simulate nonlinear transform)
        k=k+1;                                  % increment counter
        if verbose
            waitbar(mean(indx==indxp));
        end
        if(mean(indx==indxp)>1-maxProp)         % if we converged, stop
            k=0;
        end
        indxp=indx;                             % re-set ordering for next iter
    end
    if verbose
        close(myH);
    end
    x=x+mx;                                     % Put back in the mean
end
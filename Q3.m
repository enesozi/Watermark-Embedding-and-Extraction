%% 3) Watermark on Frequency Domain
% Represent the grey-scale image watermark as a two dimensional MxN matrix
A = imread('wm.bmp');
% Convert this matrix into a one dimensional array
concatImage = reshape(A,1,numel(A));

[f,fs] = audioread('son.wav');
N = size(f,1);             
y = fft(f(:,1), N);    %Convert to frequence domain
bins = 20000;       % This is for the bin size.
n=1;                % Start index fro peak bits.
peakBits = linspace(0,0,4060);

% Loop all bins and finds peak values within each bins
% Then stores those indexes in a vector.
for i=1:N/bins
    [pxx_peaks,location]=findpeaks(real(y((i-1)*bins+1:i*bins)),'NPEAKS',5);
    for j=1:5
    peakBits(n) = location(j);
    n = n + 1;
    end
end
% Assign watermark bits to the peak values
for i=1:4060
   y(peakBits(i))=concatImage(i); 
end
% Assign watermark bits to the peak values
for i=1:36
    y(peakBits(4060)+i)=concatImage(4060+i); 
end
% Makes ifft
RecovSound=ifft(y);
P=audioplayer(RecovSound,fs);
%P.play;

%% Calculate SNR
residual_noise = f - RecovSound; 
snr_after = mean( f .^ 2 ) / mean( residual_noise .^ 2 ); 
snr_after_db = 10 * log10( snr_after );
fprintf('SNR value is %f \n',snr_after_db);

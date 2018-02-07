%% 3) Watermark on Frequency Domain
% Represent the grey-scale image watermark as a two dimensional MxN matrix
A = imread('wm.bmp');
% Convert this matrix into a one dimensional array
concatImage = reshape(A,1,numel(A));

[f,fs] = audioread('son.wav');
N = size(f,1);             
y = fft(f(:,1), N);    %Convert to frequence domain


% Loop all bins and finds peak values within each bins
% Then stores those indexes in a vector.
for i=1:100
  y(i)=concatImage(i); 
end
for i=1:3996
  y(i+7199)=concatImage(i+100); 
end
% Makes ifft
RecovSound=ifft(y);
P=audioplayer(RecovSound,fs);
P.play;

%% Calculate SNR
residual_noise = f - RecovSound; 
snr_after = mean( f .^ 2 ) / mean( residual_noise .^ 2 ); 
snr_after_db = 10 * log10( snr_after );
fprintf('SNR value is %f \n',snr_after_db);

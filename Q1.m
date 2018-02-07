%% 1.1) Preprocessing
%  MxN matrix of image that is watermark
A = imread('wm.bmp');
% Convert A into a one dimensional array
A1d = reshape(A,1,numel(A));
% Convert one dimensional array to bit array.
ByteImage = decimalToBinaryVector(A1d);
% One dimensional array to hold bits.
Abits= reshape(ByteImage,1,numel(ByteImage));
% Hoping Sequence
hSeq = [2,3,3,4,5];
% Read sound file.
[afile,fs] = audioread('son.wav','native');
% Convert sound matrix to byte vector.
audioBytes = typecast(afile,'uint8');

%% 1.2) Watermark Embedding

% For all bits in Abits
% Change a byte in every four byte
% of audio signal, that is audioBytes
for i=0:length(Abits)-1
    pos = hSeq(mod(i,5)+1);
    b = Abits(i+1);
    if (b == 1)
    audioBytes(4*i+1) = bitor(audioBytes(4*i+1),2^(pos-1));
    else
    audioBytes(4*i+1) = bitand(audioBytes(4*i+1),255-2^(pos-1));
    end    
end

%% 1.3) Watermark Extraction
% Array for holding bits which are embedded to sound.
bitArray = linspace(0,0,(4096*8));
% Extract bits of image embeddded to the sound.
for i=0:length(bitArray)-1
    pos = hSeq(mod(i,5)+1);
    embeddedBit = bitand(audioBytes(4*i+1),2^(pos-1))/(2^(pos-1));
    bitArray(i+1) = embeddedBit;
end

% Bit array to binary matrix
recImgBytes = reshape(bitArray,[],8);
% Binary vec to decimal Vec 
imgDec = binaryVectorToDecimal(recImgBytes);
% imgDec to Decimal matrix with the size of 64*64
recImg = reshape(imgDec,64,64);
% 2D gray-scale matrix of image
mat2gray(recImg);
%% Snr Calculation.
% Convert watermarked auido matrix back to sound.
p=audioplayer(typecast(audioBytes,'int16'),fs);
p.play;
recoveredSound=typecast(audioBytes,'int16');
residual_noise = afile - recoveredSound; 
snr_after = mean( afile .^ 2 ) / mean( residual_noise .^ 2 ); 
snr_after_db = 10 * log10( snr_after );
fprintf('SNR value is %f \n',snr_after_db);


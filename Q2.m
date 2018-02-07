%% 2.1) Preprocessing
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
[afile,fs] = audioread('son.wav');
% Convert sound matrix to byte vector.
audioBytes = typecast(afile,'uint8');
len = numel(audioBytes);
H1 = linspace(0,0,len/2);
% Fill H1
for i=1:len/2
    H1(i) = (audioBytes(2*i-1) - audioBytes(2*i))/2;
end
L1 = linspace(0,0,len/2);
% Fill L1
for i=1:len/2
    L1(i) = (audioBytes(2*i-1) + audioBytes(2*i))/2;
end
H2 = linspace(0,0,len/4);
% Fill H2
for i=1:len/4
    H2(i) = (L1(2*i-1) - L1(2*i))/2;
end
L2 = linspace(0,0,len/4);
% Fill L2
for i=1:len/4
L2(i) = (L1(2*i-1) + L1(2*i))/2;
end
% Concanate L2,H2,H1 
concatAudio = cat(2,L2,H2,H1);

%% 2.2) Watermark Embedding

% For all bits in Abits
% Change a byte in every four byte
% of audio signal, that is concatAudio
for i=0:length(Abits)-1
    pos = hSeq(mod(i,5)+1);
    b = Abits(i+1);
    if (b == 1)
    concatAudio(4*i+1) = bitor(concatAudio(4*i+1),2^(pos-1));
    else
    concatAudio(4*i+1) = bitand(concatAudio(4*i+1),255-2^(pos-1));
    end    
end
% Inverse Operations
% Get length to be used.
% Get the arrays used for concatenation.
len4 = numel(concatAudio)/4;
L2E=concatAudio(1:len4);
H2E=concatAudio(len4+1:2*len4);
H1E=concatAudio(2*len4+1:end);
L1E=linspace(0,0,len4*2);
Sprime=linspace(0,0,len4*4);

% L1E
for i=1:len4
   L1E(2*i-1)=L2E(i)+H2E(i);
   L1E(2*i)=L2E(i)-H2E(i);
end

% Sprime 
for i=1:2*len4
   Sprime(2*i-1)=L1E(i)+H1E(i);
   Sprime(2*i)=L1E(i)-H1E(i);
end
%recovSound is recovered audio byte array.
recoveredSound=Sprime';
%% 2.3) Watermark Extraction
%Apply 2 level DWT to the recoveredSound.
%These are the steps used at the beginning.
len2 = numel(recoveredSound);
H1rs=linspace(0,0,len2/2);
L1rs=linspace(0,0,len2/2);
for i=1:numel(H1rs)
    H1rs(i)=(recoveredSound(2*i-1)-recoveredSound(2*i))/2;
    L1rs(i)=(recoveredSound(2*i-1)+recoveredSound(2*i))/2;
end
H2rs=linspace(0,0,len2/4);
L2rs=linspace(0,0,len2/4);
for i=1:numel(H2rs)
    H2rs(i)=(L1rs(2*i-1)-L1rs(2*i))/2;
    L2rs(i)=(L1rs(2*i-1)+L1rs(2*i))/2;
end
% Concate create new array.
ConcatArray=cat(2,L2rs,H2rs,H1rs);
% Array for holding bits which are embedded to sound.
bitArray = linspace(0,0,(4096*8));
% Extract bits of image embeddded to the sound.
for i=0:length(bitArray)-1
    pos = hSeq(mod(i,5)+1);
    embeddedBit = bitand(ConcatArray(4*i+1),2^(pos-1))/(2^(pos-1));
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
% recovSound is recovered audio byte array.
residual_noise = double(audioBytes) - recoveredSound; 
snr_after = mean( audioBytes .^ 2 ) / mean( residual_noise .^ 2 ); 
snr_after_db = 10 * log10( snr_after );
fprintf('SNR value is %f \n',snr_after_db);
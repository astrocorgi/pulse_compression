% pulse compression 

%fname = '~/Dropbox/Alaska/pulsecomp/block_files/raw/aug26_21_raw.mat';
fname = '~/Dropbox/Alaska/UAF/2016/all/block_files/may28_8.mat'
% get a reference chirp

load ~/Dropbox/Alaska/UAF/2015/aug2015_old/high/aug26_11_high.mat
%load ~/Dropbox/Alaska/UAF/2016/all/block_files/may28_8.mat
ref_chirp = block.ch0(1550:2050,225);
plot(ref_chirp);
t = 1:length(ref_chirp);
t=t';
p=polyfit(t,ref_chirp,2);
ref_chirp=(ref_chirp-p(1)*t.^2-p(2)*t-p(3));
plot (ref_chirp)

load(fname);
cutoff = 1100;
t=1:(size(block.ch0,1)-cutoff+1);
t=t';

ref_chirp(length(ref_chirp):length(t)) = 0;
ref_chirp_fft=fft(ref_chirp);
ref_chirp_fft(1:length(ref_chirp_fft)/2)=0;

for k=1:size(block.ch0,2)
    signal = block.ch0(cutoff:end,k);
    p=polyfit(t,signal,2);
    signal=signal-p(1)*t.^2-p(2)*t-p(3);
    signal_fft = fft(signal);
    cc_fft=signal_fft.*conj(ref_chirp_fft);
    cc = ifft(cc_fft);
    data(k,:) = abs(cc(1:5000));
end
figure(3)
imagesc(log(abs(data')))
colorbar
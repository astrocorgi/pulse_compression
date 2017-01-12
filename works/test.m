% pulse compression 

fname = '~/Dropbox/Alaska/pulsecomp/block_files/raw/aug26_33_raw.mat';

% get a reference chirp

load ~/Dropbox/Alaska/UAF/aug2015/high/aug26_11_high.mat
ref_chirp = block.ch0(1550:2050,225);
plot(ref_chirp);
t = 1:length(ref_chirp);
t=t';
p=polyfit(t,ref_chirp,2);
ref_chirp=(ref_chirp-p(1)*t.^2-p(2)*t-p(3));
plot (ref_chirp)

load(fname);
cutoff = 1273;
t=1:(size(block.ch0,1)-cutoff+1);
t=t';

ref_chirp(length(ref_chirp):length(t)) = 0;
ref_chirp_fft=fft(ref_chirp);
ref_chirp_fft(1:length(ref_chirp_fft)/2)=0;

cc_fft=ref_chirp_fft.*conj(ref_chirp_fft);
cc = ifft(cc_fft);
figure(3);
plot(abs(cc));
%plot (ref_chirp);
%hold all
%plot (abs(cc));

% pulse compression 

fname = '2015/aug29/20150829_202334';

% get a reference chirp

load 2015/aug29/stacked_combined_2
ref_chirp = rec.ch0(200,1882:3000);
t = 1:length(ref_chirp);
p=polyfit(t,ref_chirp,2);
ref_chirp=(ref_chirp-p(1)*t.^2-p(2)*t-p(3));

load(fname);

cutoff = 1400;

t=1:(size(rec.ch0,2)-cutoff+1);

ref_chirp(1053:length(t))=0;

ref_chirp_fft = fft(ref_chirp);
ref_chirp_fft(1:length(ref_chirp_fft)/2)=0;


for k=1:size(rec.ch0,1)
    signal = rec.ch0(k,cutoff:end);
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
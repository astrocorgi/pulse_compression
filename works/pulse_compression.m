% pulse compression 

fname = '2015/aug26/20150826_204429';

% get a reference chirp

load 2015/aug26/stacked_combined_11
ref_chirp = rec.ch0(10,1470:4500);
t = 1:length(ref_chirp);
p=polyfit(t,ref_chirp,2);
ref_chirp=(ref_chirp-p(1)*t.^2-p(2)*t-p(3));
ref_chirp(609:length(signal))=0;

ref_chirp_fft = fft(ref_chirp);
ref_chirp_fft(1:5926/2)=0;

load(fname);

t=1:(size(rec.ch0,2)-1073);

for k=1:size(rec.ch0,1)
    signal = rec.ch0(k,1074:end);
    p=polyfit(t,signal,2);
    signal=signal-p(1)*t.^2-p(2)*t-p(3);
    signal_fft = fft(signal);
    cc_fft=signal_fft.*conj(ref_chirp_fft);
    cc = ifft(cc_fft);
    data(k,:) = abs(cc(1:5000));
end
imagesc(log(abs(data')))
colorbar
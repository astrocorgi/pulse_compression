%% Creating a basic pulse compression algorithm
%  This script applies a pulse compression algorithm to test data taken
%  from the Jack Holt group UTIG server $MARS/orig/supl/UAF/raws.
%  First it plots the data, and then it applies pulse compression and
%  a Hamming window to the signal. Algorithm was created using methods
%  from https://en.wikipedia.org/wiki/Pulse_compression.
%
%       Created by Cassie Stuurman


clear all
close all

data = load('test_data/stacked_combined_4.mat');
data = data.rec; %taking it down a layer of struct`

%parsing the data
L = data.samples; %number of samples in each trace
lat = data.lat; %latitude data
lon = data.lon; %longitude data
time = data.time;
dt = data.dt; %I'm guessing this is the sampling rate [s]
Fs = 1/dt; %sampling frequency [Hz]
n_traces = length(data.elev);
low_gain_amp = data.ch0; %trace data
high_gain_amp = data.ch1; %trace data

%create a loop here ~later~ that runs through each trace, or consider
%vectorizing
n = 1;
max_t = L*dt;
t = linspace(0,max_t,L-1);
trace_data = low_gain_amp(n,:);
plot(t,trace_data);
xlabel('Time,(s)');
ylabel('Gain');

%% take the Fourier transform of the pulse signal

fourier = fft(trace_data);

%creating the frequency vector
P2 = abs(fourier/max(fourier)); %two-sided spectrum, normalized 
P1 = P2(1:L/2+1); %one-sided spectrum
P1(2:end-1) = P1(2:end-1);

f = Fs*(0:(L/2))/L; %frequency vector

figure
plot(f,P1);
title('Fourier spectrum of the simple pulse');
ylabel('Amplitude');
xlabel('Frequency (Hz)');

%% Applying a Hamming window

weirdnum = 3000;

P1 = P1(1:weirdnum); %Why weirdnum?
ham = hamming(weirdnum)'; %create a hamming window using MATLAB's handy function
hammed_fq = ham.*P1; %the signal with hamming window applied, freq domain

figure
plot(f(1:weirdnum),hammed_fq);
hold on
plot(f(1:weirdnum),ham)
legend('Fourier Transform with window applied','Hamming window');
title('Hamming Window');
xlabel('Frequency, (Hz)');
ylabel('Amplitude');

%% Converting back to time domain

hammed_time = ifft(hammed_fq); %signal, hamming window applied, time domain
hammed_time = abs(hammed_time/max(hammed_time));
hammed_time = circshift(hammed_time',[length(hammed_time)/2,0]);
figure
interval_of_interest = 2000;
hammed_time = hammed_time';
ham_interesting = hammed_time(interval_of_interest:(length(hammed_time)-interval_of_interest));
plot(t(1:interval_of_interest),ham_interesting);
xlabel('Time, (s)');
ylabel('Amplitude');
title('Signal with Hamming Window Applied, time domain');






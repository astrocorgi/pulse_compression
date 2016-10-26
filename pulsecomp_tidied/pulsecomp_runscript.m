%% test

close all
clear all
cd('/Users/igadmin/Dropbox/Masters/pulsecompression');
RadarData = Data('block_files/high/aug29_2_high.mat');

%extract reference chirp info. Indices, tracks, and numbers
%were all picked manually by looking at individuals traces and then
%recorded in an excel file. This excel file was used to target individual
%reference chirps and then create an average out of all of them.

RefChirp = ReferenceChirp('reference_chirps/refpulse_aug_29_2.csv');



PulseComp = PulseCompression(RadarData,RefChirp);

%% Convolution pulsecomp

close all
clear all
cd('/Users/igadmin/Dropbox/Masters/pulsecompression');
RadarData = Data('high/aug26_11_high.mat');

RefChirp = ReferenceChirp('reference_chirps/refpulse_aug_26_11.csv');
    
PulseComp = ConvolutionPulseComp(RadarData,RefChirp);

%% Recipe pulsecomp aug26_11

close all
clear all
cd('/Users/igadmin/Dropbox/Masters/pulsecompression');
RadarData = Data('high/aug26_11_high.mat');

RefChirp = ReferenceChirp('reference_chirps/refpulse_aug_26_11.csv');
    
PulseComp = PulseCompRecipe(RadarData,RefChirp,1450);

%% doing aug26_13 next

close all
clear all
cd('/Users/igadmin/Dropbox/Masters/pulsecompression');
RadarData = Data('high/aug26_13_high.mat');

RefChirp = ReferenceChirp('reference_chirps/refpulse_aug_26_11.csv');
    
PulseComp = PulseCompRecipe(RadarData,RefChirp,1100);

%% aug_26_22_raw

close all
clear all
cd('/Users/igadmin/Dropbox/Masters/pulsecompression');
RadarData = Data('raw/block_files/aug26_22_raw.mat');

RefChirp = ReferenceChirp('reference_chirps/refpulse_aug_26_11.csv');
    
PulseComp = PulseCompRecipe(RadarData,RefChirp,1500);


%% working with Jack May 6th 2016
% look at august 29_2, the reference chirp is at the start and really
% straightforward. look for chirp closest to 5
% microseconds.
%aug29_11 went from ocean onto glacier, if there's any doubt you can look
%here. it has a good chirp.

%for august 26_10, we have a chirp. use the chirp closest to 5 microseconds
% run map coverage in the dropbox

%August 26_15 (not chirped, don't test), August 26_16 is really good to test too
%compare aug26_15[not processed] and aug26_16[processed] to see how chirp
%does. chirped at 5 MHz bandwidth.

%aug26_17 is good too [5 microsecond chirp needed]
%aug26_11 is good too [5 microsecond chirp needed]
%aug26_13 is good too
%then do as many aug26 as possible

close all
clear all
RadarData = Data('block_files/aug26/aug26_2_high.mat');

%extract reference chirp info. Indices, tracks, and numbers
%were all picked manually by looking at individuals traces and then
%recorded in an excel file. This excel file was used to target individual
%reference chirps and then create an average out of all of them.

RefChirp = ReferenceChirp('refpulse_info2.csv');

PulseComp = PulseCompression(RadarData,RefChirp);

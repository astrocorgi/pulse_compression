classdef PulseCompRecipe < handle
    %PULSECOMPRECIPE uses the methods outlined through correspondence with
    %Dr. John Holt to apply a pulse compression algorithm to the amplitude
    %data in the Data class. The recipe is as follows:
    %
    % 1.  Detrend the reference chirp. 
    % 2.  Take FFT of reference chirp.  You will have dual spectra.  
    %     It should be centered around zero.  
    % 3.  Apply Hamming (or Hanning) window on the positive side only, so  
    %     that you effectively zero out half of it.
    % 4.  Save this for later.
    % 
    % Next, take your signal (the echo data):
    % 
    % 5. Chop off all the outgoing signal crap at the beginning.  It adds 
    % all sorts of energy all over the spectrum and needs to go.
    % 6. Detrend the rest.
    % 7. Take FFT.
    % 
    % Assemble ingredients:
    % 
    % 8. Multiply those two FFTs.
    % 9. Take inverse FFT.
    % 10.  Take magnitude.
    % 11.  Multiply amplitudes by two.
    %
    % --Recipe outlined by John Holt and Scott Kempf
    %   
    %   The inputs for this class are the "Data" and "ReferenceChirp"
    %   classes, and a [x_start] crop vector. The crop vector
    %   specifies the start and end sample along each trace. This is used
    %   to remove the signal "crap" (a la step 5). See pulsecomp_runscript 
    %   for an example of how to use these classes.
    %
    %       Created by Cassie Stuurman, May 2016
    
    properties
        Data            %input data [class object]
        DataCrop        %first sample of each trace after cropping [int]
        EndCrop
        CleanData       %amplitude data after cropping and detrending
        CleanNumSamples %number of samples after cropping 
        ReferenceChirp  %input reference chirp [class object]
        Frequency       %frequency counterpart to input time vector [Hz]
        FreqChirp       %the FFT of the reference chirp
        HammingChirp    %reference chirp with positive side Hamming windowed
        FreqData        %the FFT of the amplitude data
        MultData        %the filtered FreqChirp multiplied by FreqData
        CompData        %pulse compressed data
        Version         %version number of pulse compression code. Change this if you make major changes!
    end
    
    methods
        function obj = PulseCompRecipe(data,reference_chirp,data_crop)
            %this is the constructor method for the class
            obj.Version = 1;
            obj.Data = data;                                     %input Data [class object]
            obj.ReferenceChirp = reference_chirp;                %input Reference Chirp [class object]
            obj.DataCrop=data_crop;                              %this is the start sample of each trace [int]
            obj.EndCrop = 5000;                                  %length(amp); %end sample of each trace (TURN INTO INPUT LATER)
            obj.CleanNumSamples = obj.EndCrop-data_crop;         %number of samples after cropping [int]
            obj.referenceFourierTransform;                       %apply the Fourier transform
            obj.referenceHamming;                                %apply a Hamming window to the FFT refchirp
            obj.referenceTest;
            obj.dataClean;                                       %remove the "crap" at start of signal
            obj.dataFourierTransform;                            %take FFT of amplitude data
            obj.multiplySpectra;                                 %multiply the windowed refchirp to the cleaned amplitude data, in frequency domain
            obj.inverseFourier;                                  %flip back to the time domain
            obj.plotResults;                                     %showing results   
            obj.outputFile;                                      %write output block file
        end
        
        function referenceFourierTransform(obj)
            %This method takes the FFT of the detrended reference chirp and
            %shifts it so it is centered at 0.
            
            max_t = obj.ReferenceChirp.Duration*obj.Data.SampleRate; %max time [s]
            Fs = 1/obj.Data.SampleRate; %sampling frequency [Hz]
            time = linspace(0,max_t,obj.ReferenceChirp.ChirpLength); %for some reason the number of samples is one greater than the columns of actual data
            L = double(obj.ReferenceChirp.ChirpLength); %length of chirp
            
            %take the Fourier transform of the reference chirp
            chirpdata = detrend((obj.ReferenceChirp.RefAverage))'; %rotate, fft takes columnwise transform
            chirpdata = detrendnonlin(chirpdata); %remove higher order detrends from chirp
            obj.FreqChirp = fft(chirpdata,obj.CleanNumSamples);
            obj.FreqChirp = fftshift(obj.FreqChirp);
            figure(1)
            subplot(2,1,1)
            plot(chirpdata);
            title('Reference Chirp');
            subplot(2,1,2);
            plot(abs(obj.FreqChirp))
            title('Shifted reference chirp frequency spectrum');
            
        end
        
        function referenceHamming(obj)
            %Here we apply the Hamming window to the positive side of the
            %FFT of the reference chirp
            
            L = obj.CleanNumSamples; %length of chirp fft (same as num samples after cropping)
            midpoint=ceil(L/2); %finding midpoint
            positive_freqchirp = obj.FreqChirp((midpoint):end); %isolating positive side of spectrum
            window = hamming(length(positive_freqchirp)); %create the Hamming window
            pos_hamming = 2.*window.*positive_freqchirp;%window.*positive_freqchirp; %apply the Hamming window
            obj.HammingChirp = [(0.*obj.FreqChirp(1:midpoint)); pos_hamming]; %combine windowed and non-windowed FFT chirp data
            
            %plotting
            figure(2)
            subplot(2,1,1)
            plot(abs(pos_hamming));
            title('The positive side of the reference chirp spectrum');
            subplot(2,1,2)
            plot(abs(obj.HammingChirp));
            title('The combined windowed and non-windowed FFT chirp');
        end
        
        function referenceTest(obj)
            mult_test=obj.FreqChirp.*conj(obj.HammingChirp(1:length(obj.FreqChirp)));
            figure(6)
            plot(abs(mult_test))
            title('Reference Chirp Test');
        end
        
        function dataClean(obj)
            %This method crops the data according to the input data_crop,
            %removing the output signal noise at the beginning of each
            %trace. It then detrends each trace.
            amp = obj.Data.Amplitude';
            start_crop = obj.DataCrop; %start sample of each trace
            end_crop = obj.EndCrop;
            obj.CleanNumSamples = obj.Data.NumSamples - start_crop; %number of samples in each trace of cropped data
            ampcrop=amp(start_crop:end_crop,:); %cropped data
            obj.CleanData=detrend(ampcrop);
%             for k =1:length(obj.Data.NumTraces);
%                 obj.CleanData(:,k)=detrendnonlin(obj.CleanData(:,k),3);
%             end
            figure(3)
            subplot(2,1,1)
            imagesc(obj.CleanData);
            colormap(gray);
            title('Tidied (detrended and cropped) amplitude data');
        end
        
        function dataFourierTransform(obj)
            %This method takes the Fourier transform of the "clean" data
            %output by the previous method.
            
            max_t = obj.Data.NumSamples*obj.Data.SampleRate; %max time [s]
            Fs = 1/obj.Data.SampleRate; %sampling frequency [Hz]
            time = linspace(0,max_t,obj.Data.NumSamples); %for some reason the number of samples is one greater than the columns of actual data
            data = obj.CleanData; %turn columnwise

            %Now take its Fourier transform
            obj.FreqData = fftshift(fft(data));
            %obj.Frequency = Fs*(0:(obj.Data.NumSamples-1))/obj.Data.NumSamples;
            figure(3)
            subplot(2,1,2)
            plot(abs(obj.FreqData));
            title('power spectrum of all individual traces');
            ylabel('power');
            xlabel('Frequency (Hz)');
        end
        
        function multiplySpectra(obj)
            obj.MultData = bsxfun(@times,obj.FreqData,conj(obj.HammingChirp));
        end
        
        function inverseFourier(obj)
            obj.CompData = 2*abs(ifft(obj.MultData)).^2;
            figure(4)
            subplot(2,1,1)
            imagesc(obj.CompData(1:end,:));
            title('Pulse compressed data');
            subplot(2,1,2)
            imagesc(10*log10(obj.CompData(1:3000,:))); %log10 here for a different feel
            colormap(gray)
            title('Log of the pulse compressed data');
        end
        
        function plotResults(obj)
            %trace = obj.ReferenceChirp.Trace; uncomment if you want to
            %plot the reference chirp trace
            trace = 200;%obj.ReferenceChirp.Trace;
            %Trace results
            figure(5)
            subplot(3,1,1)
            plot(obj.CleanData(:,trace));
            title_text = sprintf('Trace %d detrended amplitude data',trace);
            title(title_text);
            
            subplot(3,1,2)
            plot(abs(obj.FreqData(:,trace)));
            title_text = sprintf('Trace %d Fourier Transform, zero-centred',trace);
            title(title_text);
            
            subplot(3,1,3)
            plot(obj.CompData(:,trace));
            title_text = sprintf('Trace %d pulse compressed data',trace);
            title(title_text);
        end
        
        function outputFile(obj)
            %This writes the results of the pulse compression to a block
            %file that is then saved in /comp_output_files/. 
            
            %pad the output file with zeros
            zero_front = zeros(obj.DataCrop,obj.Data.NumTraces);
            zero_end = zeros(obj.Data.NumSamples - obj.EndCrop -1,obj.Data.NumTraces);
            padded_compdata = [zero_front; obj.CompData; zero_end];
            padded_cleandata = [zero_front; obj.CleanData; zero_end];
            block = struct(...
                'amp',    	      padded_compdata,... %amp is updated to the linear power of the pulse compressed data, CompData.
                'clutter',        obj.Data.Clutter,...
                'ch0',            padded_cleandata,... %ch0 is the DETRENDED, CROPPED version of original amplitude
                'dist',           obj.Data.Dist,...
                'dist_lin',       obj.Data.Dist_Lin,...
                'dt',             obj.Data.SampleRate,...
                'elev_air',       obj.Data.Elevation,...
                'elev_air_gimp',  obj.Data.ElevAirGimp,...
                'ind_overlap',    obj.Data.IndOverlap,...
                'lat',            obj.Data.Latitude,...
                'lon',            obj.Data.Longitude,...
                'num_sample',     obj.Data.NumSamples,...
                'num_trace',      obj.Data.NumTraces,...
                'time',           obj.Data.Time,...
                'twtt',           obj.Data.Twtt,...
                'twtt_bed',       obj.Data.TwttBed,...
                'twtt_surf',      obj.Data.TwttSurf,...
                'x',              obj.Data.X,...
                'y',              obj.Data.Y...
                );
                
            filename = sprintf('pcomp_output_files/%s_v%d',obj.Data.Filename,obj.Version);
                save(filename,'block');
        end
        
    end
    
end


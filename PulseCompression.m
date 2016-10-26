classdef PulseCompression < handle
    %PULSECOMPRESSION applies a pulse compression algorithm to the
    %amplitude data from the Data class. It does this by transforming the
    %data to the frequency domain with a Fourier transform, multiplying by
    %the frequency spectrum of the reference transmitted chirp, applying a
    %Hamming window to reduce sidelobes, and then converting back to the
    %time domain.
    %   The inputs for this class are the "Data" and "ReferenceChirp"
    %   classes. See pulsecomp_runscript for an example of how to use 
    %   these classes.
    %
    %       Created by Cassie Stuurman, March 2016
    
 
    
    properties
        Data %input data class
        ReferenceChirp %input reference chirp class
        Frequency %frequency counterpart to input time vector [Hz]
        FreqData %the amplitude data in the frequency domain
        MultData %the frequency domain data multiplied by the reference chirp
        CompData %pulse compressed data
    end
    
    methods
        function obj = PulseCompression(data,reference_chirp)
            obj.Data = data;
            obj.ReferenceChirp = reference_chirp;
            obj.fourierTransform;     %apply the Fourier transform
            obj.referenceConvolution; %multiply by reference chirp in fq domain
            %obj.hammingWindow;       %apply the Hamming window [removed]
            obj.inverseFourier;       %flip back to the time domain
           
        end
        
        function fourierTransform(obj)
            
            n = 5; %trace number
            max_t = obj.Data.NumSamples*obj.Data.SampleRate; %max time [s]
            Fs = 1/obj.Data.SampleRate; %sampling frequency [Hz]
            time = linspace(0,max_t,obj.Data.NumSamples); %for some reason the number of samples is one greater than the columns of actual data
            data = (obj.Data.Amplitude)'; %turn columnwise
            
            %lets see what it looks like for now ****[REMOVE LATER]****
            plot(time,data);
            xlabel('Time,(s)');
            ylabel('Amplitude');
            
            %Now take its Fourier transform
            obj.FreqData = fft(data);
            
            %normalizing the spectrum 
            %twosided_normalized = abs(bsxfun(@rdivide,obj.FreqData,max(obj.FreqData))); %divide each column by its maximum value
            %obj.FreqData = twosided_normalized;
            
            %creating the frequency vector (x-axis for Fourier transform)
            obj.Frequency = Fs*(0:(obj.Data.NumSamples-1))/obj.Data.NumSamples;
            figure(2)
            subplot(4,1,1)
            plot(obj.Frequency,(obj.FreqData).^2);
            title('power spectrum of all individual traces');
            ylabel('power');
            xlabel('Frequency (Hz)');

        end
        
        function referenceConvolution(obj)
            %Here, I multiply the frequency spectrum of the reference chirp
            %by the frequency spectrum of the radar track
            
            %take the Fourier transform of the reference chirp
            chirpdata = ((obj.ReferenceChirp.RefAverage))'; %rotate, fft takes columnwise transform
            freq_refdata = fft(chirpdata,obj.Data.NumSamples);

            %normalizing the spectrum
            %freq_refdata = abs(freq_refdata/max(freq_refdata)); %two-sided normalized spectrum
            
            %multiplying the reference chirp frequency spectrum by the
            %trace frequency spectrum
            spectrum_length = floor(length(obj.FreqData)/2);
            
            obj.MultData = bsxfun(@times,obj.FreqData(1:spectrum_length,:),conj(freq_refdata(1:spectrum_length,:)));
            
%             for k =1:length(obj.Data.NumTraces)
%                 obj.MultData = obj.FreqData)
%             end
            
            %show plots of data (for debugging)
            figure(1)
            subplot(2,1,1)
            imagesc(obj.Data.Amplitude');
            colormap(gray);
            title('Original Data');
            xlabel('Trace');
            
            figure(2)
            subplot(4,1,2)
            chirp_x = linspace(0,obj.Data.SampleRate*length(chirpdata),length(chirpdata));%x-axis for reference chirp
            plot(chirp_x,chirpdata);
            title('Reference Chirp');
            xlabel('Time');
            ylabel('Amplitude');
            
            figure(2)
            subplot(4,1,3);
            plot(obj.Frequency(1:spectrum_length),freq_refdata(1:spectrum_length,:));
            title('Frequency spectrum of reference chirp');
            xlabel('Frequency, Hz');
            ylabel('Amplitude');
            
            figure(2)
            subplot(4,1,4)
            plot(obj.MultData);
            title('Data frequency spectra multiplied by ref chirp frequency spectrum');
            
            %show plots of individual trace processing
            figure(3)
            subplot(3,1,1)
            amp=obj.Data.Amplitude';
            trace_450 = amp(:,450);
            plot(trace_450);
            title('Trace 450 original');
            
            subplot(3,1,2)
            fq_trace_450 = obj.FreqData(:,450);
            plot(obj.Frequency,fq_trace_450);
            title('Frequency spectrum of trace 450');
            
            
        end
        
        
        function inverseFourier(obj)
            %This method inverts the modified frequency spectrum of the
            %received data.
            
            obj.CompData = abs(ifft(obj.MultData,obj.Data.NumSamples*2));
            figure(1)
            subplot(2,1,2)
            imagesc(obj.CompData(1:obj.Data.NumSamples,:));
            colormap(gray);
            title('Pulse Compressed Data');
            
            figure(3)
            subplot(3,1,3);
            plot(obj.CompData(:,450));
            title('Inverse transform of trace 450');
        end
        
    end
    
end
    



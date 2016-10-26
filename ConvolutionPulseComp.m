classdef ConvolutionPulseComp < handle
    %CONVULUTIONPULSECOMP applies a pulse compression algorithm to the
    %amplitude data from the Data class. It does this by convolving the
    %amplitude data with the input reference chirp.
    %   Detailed explanation goes here
    %
    %       Created by Cassie Stuurman, May 2016
    
    properties
        Data %input data class
        ReferenceChirp %input reference chirp class
        Frequency %frequency counterpart to input time vector [Hz]
        FreqData %the amplitude data in the frequency domain
        MultData %the frequency domain data multiplied by the reference chirp
        CompData %pulse compressed data
    end
    
    methods
        function obj = ConvolutionPulseComp(data,reference_chirp)
            obj.Data = data;
            obj.ReferenceChirp = reference_chirp;
            obj.referenceConvolution; %apply convolution
        end
        
        function referenceConvolution(obj)
            chirpdata = ((obj.ReferenceChirp.RefAverage))';
            
            %apply a hamming window to the chirp data
            %y1 = fft(chirpdata,length(chirpdata));
            %win1 = hamming(length(chirpdata));
            %xw1 = win1.*y1;
            %chirpdata=abs(ifft(xw1,length(chirpdata)));
            
            %cropping the length (i.e. NumSamples) of each trace
            amp = obj.Data.Amplitude';
            start_crop = 1500;
            end_crop = 2100;%length(convolution);
            n_samples_crop = end_crop - start_crop;
            
        
            ampcrop = amp(start_crop:end_crop,:);
            
            %take the convolution of the reference chirp with the data
            convolution = [];
            for k =1:obj.Data.NumTraces
                convolution(:,k)=conv(chirpdata,ampcrop(:,k));
            end
            %convolution = conv2(chirpdata,ampcrop);
            obj.CompData = convolution;
            %end_crop = 2100%length(convolution);  
            
            %% plotting the individual trace results
            figure
            time_vector = (start_crop:obj.Data.NumSamples)*obj.Data.SampleRate;
            
            %plot the original data
            subplot(4,1,1)
            plot(ampcrop(:,obj.ReferenceChirp.Traces));
            title('Pre-compression, original data');
            %xlabel('Time, s');
            ylabel('Amplitude');
            
            subplot(4,1,2)
            plot(chirpdata);
            title('Reference chirp');
            
            %plot the convoled data
            subplot(4,1,3)
            plot(convolution(:,obj.ReferenceChirp.Traces));
            title('Post-convolution, no reference chirp detrending');
            xlabel('element');
            ylabel('Amplitude');
            
            
            %correlation between convolved and original data
            reference_corr=xcorr(ampcrop(:,obj.ReferenceChirp.Traces),chirpdata);
            subplot(4,1,4)
            plot(reference_corr);
            title_text = sprintf('Correlation of reference chirp and original data, trace %d',obj.ReferenceChirp.Traces);
            title(title_text);
            
            %% plotting the image results
            
            %plot the original data
            figure
            subplot(3,1,1)
            imagesc(ampcrop);
            title('Pre-compression, original data');
            
            %plot the convoled data
            subplot(3,1,2)
            imagesc(convolution(1:n_samples_crop,:));
            colormap(gray)
            title('Data convolved with reference chirp, no detrending');
            
            %%computing time-domain correlation for each column
            correlated = [];
            for k=1:obj.Data.NumTraces
                correlated(:,k) = xcorr(chirpdata,ampcrop(:,k));
            end
            
            %correlation between refchirp and original data
            subplot(3,1,3);
            imagesc(correlated)
            colormap(gray)
            xlabel('Trace')
            title('Correlation of reference chirp and original data');
            
            %% try convolving reference chirp trace on its own
            figure
            conv_reftrace = conv(chirpdata,ampcrop(:,obj.ReferenceChirp.Traces));
            plot(conv_reftrace);
            title_text=sprintf('convolution of trace %d on its own',obj.ReferenceChirp.Traces);
            title(title_text);
            
            %% try correlating reference chirp in time-domain with radargrams in time domain
            for k=1:obj.Data.NumTraces
                correlated_2(:,k) = xcorr(chirpdata,ampcrop(:,k));
            end
            figure
            image(correlated_2)
            title('XCorr of reference chirp with data, time domain');
            colormap(gray)
        end
        
        
        
        
    end
    
end


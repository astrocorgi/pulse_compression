classdef ReferenceChirp < handle
    %REFERENCECHIRP is a class that packages useful information for the
    %reference chirp together. It is a required input for the
    %PULSECOMPRESSION class. The input is an excel file that contains the 
    %track file path/name, the trace with the reference chirp of choice,
    %and the beginning and end locations of the reference chirp [in x].
    %   To find the start/end x-indices, plot a single track of data that
    %contains the reference chirp (i.e. a track that includes a reflection
    %off the surface of water) and use the MATLAB cursor to extract the
    %x-index at the beginning and end of the chirp. This class will average
    %as many reference chirps as there are input files.
    
    properties
        ParseFile   %file created in excel that contains ref chirp info. See "refpulse_info.xlsx" for example.
        Tracks      %input track files [n,1] where n is # of input files
        Trace      %The trace in the track that contains the ref chirp
        X1          %input start values, [n,1]
        X2          %input end values, [n,1]
        Duration   %The length of each reference chirp in seconds [s]
        ChirpLength %Length of chirp in x. NOT THE SAME AS DURATION.
        ChirpData   %Matrix of amplitude data for each reference chirp used
        RefAverage  %the final, averaged chirp
    end
    
    methods
        function obj = ReferenceChirp(chirp_file)
            %constructor method
            chirp_info = readtable(chirp_file,'Delimiter',',','Format','%s %d %d %d %f');
            obj.Tracks = table2array(chirp_info(:,1));
            obj.Trace = table2array(chirp_info(:,2));
            obj.X1 = table2array(chirp_info(:,3));
            obj.X2 = table2array(chirp_info(:,4));
            obj.Duration = table2array(chirp_info(:,5)); %length in seconds
            obj.ChirpLength = obj.X2 - obj.X1; %length in X
            obj.makeTraceMatrix;
            obj.averageChirps;
        end
        
        function obj = makeTraceMatrix(obj)
            %this is a bit awkward, it would make more sense to have the
            %class files as an input. I wrote it this way so I wouldn't
            %have to run a xlsread function twice. Regardless, this method 
            %converts the strings of reference chirp file names into Data
            %classes, selects only the trace of interest, and stores it in
            %a matrix for clipping and averaging below.
            
            %preallocating memory
            trace_matrix = zeros(length(obj.Tracks),max(obj.ChirpLength));
            obj.ChirpData = []; %preallocate memory for chirp matrix
            
            for k = 1:length(obj.Tracks); %for loop cop-out. consider vectorizing later
                data = Data(obj.Tracks{k}); %create radar data object
                low_gain_matrix = data.Amplitude; %amplitude matrix for track
                trace_of_interest = low_gain_matrix(obj.Trace(k),:); %trace with reference chirp
                
                %isolate chirp
                ref_chirp = trace_of_interest(:,obj.X1(k):obj.X2(k));
                
                
                %fit chirp to longest chirp
                [max_val,index] = max(obj.ChirpLength); %the maximum value and index
                chirp_stretched = imresize(ref_chirp,[1,max_val],'nearest');
                obj.ChirpData = [obj.ChirpData; chirp_stretched];
            end
        end
        
        function obj = averageChirps(obj)
              obj.RefAverage = mean(obj.ChirpData,1);
        end
    end
    
end


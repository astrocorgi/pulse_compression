classdef Data < handle
    %RADARDATA translates the .struct file containing the radar data to a
    %class object. It reads the data and assigns an appropriate property to
    %each component. It is useful to parse the data this way because it
    %enables each property to be independently passed between classes. 
    %See http://www.mathworks.com/help/matlab/matlab_oop/why-use-object-oriented-design.html
    %   This class was created for the Pulse Compression algorithm. One
    %   Data object represents one track.
    %   
    %       Created by Cassie Stuurman, March 2016
    
    properties
        NumSamples %number of samples within each trace
        NumTraces  %number of traces contained in data structure
        Latitude   %latitude of each trace [deg]
        Longitude  %longitude of each trace [deg]
        Elevation  %elevation of each trace [m]
        Time       %time vector, [s]
        SampleRate %sampling rate for trace data [s]
        Amplitude  %amplitude measurements
        Clutter    %clutter data
        Dist       %distance
        Dist_Lin   
        ElevAirGimp
        IndOverlap
        Twtt
        TwttBed
        TwttSurf
        X
        Y
        Filename
    end
    
    methods
        function obj = Data(import_data)
            %Constructor; parses data in import_data struct file.
            load(import_data);
            obj.NumSamples = block.num_sample;
            obj.NumTraces = block.num_trace;
            obj.Latitude = block.lat;
            obj.Longitude = block.lon;
            obj.Elevation = block.elev_air;
            obj.Time = block.time;
            obj.SampleRate = block.dt;
            obj.Amplitude = block.ch0'; %NOT power, actually amplitude
            
            %the following property definitions are not used in the pcomp
            %code until outputting the new block files at the very end
            obj.Clutter = block.clutter;
            obj.Dist = block.dist;
            obj.Dist_Lin = block.dist_lin;
            obj.ElevAirGimp = block.elev_air_gimp;
            obj.IndOverlap = block.ind_overlap;
            obj.Twtt = block.twtt;
            obj.TwttBed = block.twtt_bed;
            obj.TwttSurf = block.twtt_surf;
            obj.X = block.x;
            obj.Y = block.y;
            %parsing the input filename
            og_name = import_data;
            split = strsplit(import_data,'/');
            split = strsplit(split{2},'.');
            obj.Filename = split{1};
        end
        
        
    end
    
end


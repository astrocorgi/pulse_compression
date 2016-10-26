%get all the subdirectory names

directories = dir;
dirflags = [directories.isdir]
directories = directories(dirflags);
directories = directories(3:8,:);
for k=1:length(directories)

    %directory name
    path = sprintf('/Users/igadmin/Dropbox/Masters/pulsecompression/aug2015/%s',directories(k).name);
    
    %find .mat files in specific directory
    files=fuf(path,1); %extract all files from aug2015
    for j = 1:length(files)
        filename = files{j};
        path3 = sprintf('%s/%s',path,filename);
        load(path3)
        time=cellstr(datestr(datenum(rec.time)));
        trace = (1:length(rec.ele))';
        timetrace = [num2cell(trace) time];
        filename_noext = filename(1:(end-4)); %the filename of the trace with the .mat removed
        filename2 = sprintf('time_trace_%s.txt',filename_noext);

        save_name = sprintf('%s_%s',directories(k).name,filename2);
        
        
        fileID = fopen(save_name,'w');
        
        [nrows,ncols] = size(timetrace);
        for row = 1:nrows
          fprintf(fileID,'%d %s \n',timetrace{row,:});
        end
        
        fclose(fileID);
        path3 = [];
        filename = [];

    end
    

end

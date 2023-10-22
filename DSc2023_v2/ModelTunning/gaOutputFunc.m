function[state, options, optchanged]= gaOutputFunc(options,state,flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent history
persistent cost
optchanged = false;

Gen=[state.Population,state.Score];
 global logFilename

 fid=fopen(logFilename, 'a')
 for i=1:length(state.Score)
    %fprintf(fid, '%.5s %.5s %.5s %.5s %.5s %.5s %.5s %.5s - %.5s\n',Gen{i,1},Gen{i,2},Gen{i,3},Gen{i,4},Gen{i,5},Gen{i,6},Gen{i,7},Gen{i,8},Gen{i,9});
     fprintf(fid, '%s\n',mat2str(Gen(i,:)));
 end




switch flag
    case 'init'
        history(:,:,1) = state.Population;
        cost(:,1) = state.Score;
    case {'iter','interrupt'}
        ss = size(history,3);
        history(:,:,ss+1) = state.Population;
        cost(:,ss+1) = state.Score;
    case 'done'
        ss = size(history,3);
        history(:,:,ss+1) = state.Population;
        cost(:,ss+1) = state.Score;
        
        date = datestr(datetime('now')); 
        date=regexprep(date, '\s', '_');
        date=strrep(date,':','_');
        date=strrep(date,'-','_');
        date=strcat(date,'_');
        string1=strcat(date,'GA')


        folder1=strcat('D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\ModelTunning\Tuning_Feature',string1);

        save(folder1,'history', 'cost')

        save history.mat history cost
        %close all hidden


        
        
        %save history.mat history cost
end

%gaPlotFunc(state.Generation,cost)



end
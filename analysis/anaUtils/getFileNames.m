function [fileNames, dateNums] = getFileNames(dataDir)
% Get a list of files in a directory as a cell array
%
% fileNames = getFileNames(dataDir)
%
%

f = dir(dataDir);
c = 0;
for ii = 1:length(f)
    if ~strcmp(f(ii).name,'.') && ~strcmp(f(ii).name,'..')
        c = c+1;
        fileNames{c} = f(ii).name;
        dateNums{c} = f{ii}.datenum;
    end
end


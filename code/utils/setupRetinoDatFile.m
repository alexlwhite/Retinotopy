function datFile = setupRetinoDatFile(scanNum,scanType,subj,dFolder)

%decide what folder to put data in
thedate=date;
folderdate=[subj thedate(4:6) thedate(1:2)];
sFolder = fullfile(dFolder,subj,folderdate);

if ~isdir(sFolder)
    mkdir(sFolder);
end

% Decide what this data file should be called
thedate = [datestr(now,'yy') datestr(now,'mm') datestr(now,'dd')];
filename = sprintf('%s_%s_%02i_%s',subj,thedate,scanNum,scanType);

% make sure we don't have an existing file in the directory
% that would get overwritten
bn = 0; goodname = false;

while ~goodname
    bn = bn+1;
    if bn>1
        datFile = fullfile(sFolder, sprintf('%s_%02i',filename, bn));
    else %don't add another number if not necessary
        datFile = fullfile(sFolder, filename);
    end
    goodname = ~(isfile(sprintf('%s.mat',datFile)) || isfile(sprintf('%s.txt',datFile)) || isfile(sprintf('%s.edf',datFile)));
end


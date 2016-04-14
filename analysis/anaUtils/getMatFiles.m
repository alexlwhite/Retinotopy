function [matFs, dirs, dirIs] = getMatFiles(sdir)

fnames = sort(getFileNames(sdir));
dirs = {}; matFs = {}; dirIs = [];
nDir = 1; nMat = 0;
dirs{1} = sdir;
for fi = 1:numel(fnames)
    thisf = fullfile(sdir,fnames{fi});
    %if this is itself a subfolder
    if exist(thisf)==7
        [newMats, newDirs, newIs] = getMatFiles(thisf);
        matFs = cat(2,matFs,newMats);
        dirs = cat(2,dirs,newDirs);
        dirIs = [dirIs newIs+nDir]; %-1?
        nMat = numel(matFs);
        nDir = nDir+1;
    else
        ftype = thisf((end-2):end);
        if strcmp(ftype,'mat')
            nMat = nMat+1;
            matFs{nMat} = thisf;
            dirIs(nMat) = nDir;
        end
    end
end

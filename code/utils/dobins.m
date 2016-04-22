
function [binned_mat nnbinned_mat N] = dobins(mat,bins,myfun,se)

%
% stats in bins
%
% [bmat nbmat n] = dobins(mat,bins[,myfun,se])
% --- input
% mat: 1D vector (behaves as hist) or [nx2] matrix (takes myfun of mat(:,2) in bins according to mat(:,1))
% bins: [nx2] matrix bins(:,1)=leftedges bins(:,2)=rightedges (permits discontinuous bins)
% myfun: function handle e.g. @mean
% se: 1=computes standard error in bin, 2=binomial, 0:just nsamples
% --- output
% bmat: [nx3] myfun(x),myfun(y),se(y) or myfun(x),myfun(y),N
% nbmat: cell{n} = input mat divided by bins
% N: numerosity of datapoints in each bin
%
% pb 2014/01

if nargin<1
    help dobins
    return
end

% check input matrix dimensions
if sum(size(mat)>1)==1 % 1D vector
    mat(:,1) = mat; 
    mat(:,2) = mat; 
    dohist = 1;
    se = 0;
elseif sum(size(mat)>1)==2 % matrix
    dohist = 0;
    if ~size(mat,2)==2, error('matrix must be 2cols (x,y) and nrows');
    end
end

if nargin<4 
    se = 0; 
end

if nargin<3
    myfun = @mean;
end

% make 2 column bins (left and right edges) if a 1D vector is input (used as left edges)
if sum(size(bins)>1)==1 && any(size(bins) > 2)
    tmp = bins; clear bins
    bins(:,1) = reshape(tmp,[max(size(tmp)),1]);
    bins(:,2) = bins + (bins(2)-bins(1));
end

% initialize and bin
binned_mat = NaN(size(bins,1),3);
N = NaN(size(bins,1),1);
for i = 1:size(bins,1)
    
    tmp = mat(mat(:,1) >= bins(i,1) & mat(:,1) < bins(i,2), :);
    n = sum(~isnan(tmp(:,end)));
    N(i) = n;
    binned_mat(i,1:2) = myfun(tmp,1);
    
    if se == 1
        binned_mat(i,3) = nanstd(tmp(:,2))/sqrt(n-1);
    elseif se == 2
        p = binned_mat(i,2);
        binned_mat(i,3) = sqrt((2 * p * (1-p))/n);
    else
        binned_mat(i,3) = n;
    end
    
    if nargout > 1
        nnbinned_mat{i} = tmp;
    end
end



function r = exprndFree(mu,varargin)
%EXPRND Random arrays from exponential distribution.
%   R = EXPRND(MU) returns an array of random numbers chosen from the
%   exponential distribution with mean parameter MU.  The size of R is
%   the size of MU.
%
%   R = EXPRND(MU,M,N,...) or R = EXPRND(MU,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also EXPCDF, EXPFIT, EXPINV, EXPLIKE, EXPPDF, EXPSTAT, RANDOM.

%   EXPRND uses the inversion method.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2009 The MathWorks, Inc. 

%   Edited by Alex White to avoid using the mex file statsizechk


if nargin < 1
    error(message('stats:exprnd:TooFewInputs'));
end

%determine size of output 
if nargin == 1
    sizeOut = size(mu);
elseif nargin == 2
    sizeOut = varargin{1};
elseif nargin > 2
    for v = 1:(nargin-1)
        try
            sizeOut(v) = varargin{v};
        catch
            keyboard
        end
    end
else
    error(message('(exprndAW): Input size mismatch')); 
end

% Return NaN for elements corresponding to illegal parameter values.
mu(mu < 0) = NaN;

% Generate uniform random values, and apply the exponential inverse CDF.
r = -mu .* log(rand(sizeOut)); % == expinv(u, mu)


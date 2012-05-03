%% bic_ienv
% Select the dimension of the inner envelope subspace using Bayesian
% information criterion.

%% Usage
% u=bic_ienv(X,Y,opts)
%
% Input
%
% * X: Predictors. An n by p matrix, p is the number of predictors and n 
% is the number of observations. The predictors can be univariate or 
% multivariate, discrete or continuous.
% * Y: Multivariate responses. An n by r matrix, r is the number of
% responses. The responses must be continuous variables.
% * opts: The optional input parameter. If one or several (even all) 
% fields are not defined, the default settings (see make_opts documentation) 
% are used.
%
% Output
%
% * u: Dimension of the inner envelope. An integer between 0 and p or equal
% to r.

%% Description
% This function implements the Bayesian information criteria (BIC) to select
% the dimension of the inner envelope subspace. 

%% Example
%
% load irisf.mat
% u=bic_ienv(X,Y)

function u=bic_ienv(X,Y,opts)

if (nargin < 2)
    error('Inputs: X, Y should be specified!');
elseif (nargin==2)
    opts=[];
end

[n r]=size(Y);
p=size(X,2);
    
stat=env(X,Y,r,opts);
ic=-2*stat.l+log(n)*stat.np;
u=r;


for i=0:p
%     i
        stat=ienv(X,Y,i,opts);
        temp=-2*stat.l+log(n)*stat.np;
        if (temp<ic)
           u=i;
           ic=temp;
        end
end

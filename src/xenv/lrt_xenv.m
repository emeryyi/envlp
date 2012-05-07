%% lrt_xenv
% 
% Use likelihood ratio testing to select the dimension of the envelope
% subspace for the reduction on X.

%% Syntax
% u=lrt_xenv(X,Y,alpha)
% u=lrt_xenv(X,Y,alpha,opts)
%
% Input
%
% * X: Predictors. An n by p matrix, p is the number of predictors. The
% predictors can be univariate or multivariate, discrete or continuous.
% * Y: Multivariate responses. An n by r matrix, r is the number of
% responses and n is number of observations. The responses must be 
% continuous variables.
% * alpha: Significance level for testing.  A real number between 0 and 1,
% often taken at 0.05 or 0.01.
% * opts: A list containing the optional input parameter. If one or several (even all) 
% fields are not defined, the default settings (see make_opts documentation) 
% are used.
%
% Output
%
% * u: Dimension of the envelope. An integer between 0 and p.

%% Description
% This function implements the likelihood ratio testing procedure to select
% the dimension of the envelope subspace for the reduction on X, with
% prespecified significance level $$\alpha$. 

%% Example
%
% load wheatprotein.txt
% X=wheatprotein(:,1:6);
% Y=wheatprotein(:,7);
% u=lrt_xenv(X,Y,0.01)

function u=lrt_xenv(X,Y,alpha,opts)

if (nargin < 3)
    error('Inputs: X, Y and alpha should be specified!');
elseif (nargin==3)
    opts=[];
end

[n p]=size(X);

ModelOutput0=xenv(X,Y,p,opts);


for i=0:p-1

        ModelOutput=xenv(X,Y,i,opts);
        chisq = -2*(ModelOutput.l-ModelOutput0.l);
        df=ModelOutput0.np-ModelOutput.np;
        
        if (chi2cdf(chisq,df) < (1-alpha))
            u=i;
            break;
        end
        
end

if (i== p-1) && chi2cdf(chisq,df) > (1-alpha)
    u=p;
end
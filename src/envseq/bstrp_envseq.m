%% bstrp_envseq
% Compute bootstrap standard errors of the envelope model using a
% sequential algorithm.

%% Syntax
%         bootse = bstrp_envseq(X, Y, u, B)
%         bootse = bstrp_envseq(X, Y, u, B, Opts)
%
%% Input
%
% *X*: Predictors. An n by p matrix, p is the number of predictors. The
% predictors can be univariate or multivariate, discrete or continuous.
% 
% *Y*: Multivariate responses. An n by r matrix, r is the number of
% responses and n is number of observations. The responses must be 
% continuous variables.
% 
% *u*: Dimension of the envelope subspace.  A positive integer between 0
% and p.
% 
% *B*: Number of bootstrap samples.  A positive integer.
% 
% *Opts*: A list containing the optional input parameters. If one or
% several (even all) fields are not defined, the default settings are used.
% 
% * Opts.verbose: Flag for print out the number of bootstrap samples, 
% logical 0 or 1. Default value: 0.
%
%% Output
%
% *bootse*: The standard error for elements in $$\beta$ computed by
% bootstrap.  An r by p matrix.

%% Description
% This function computes the bootstrap standard errors for the regression
% coefficients in the envelope model by bootstrapping the residuals. The
% envelope model is applied for the reduction on X, using a
% sequential algorithm.

%% Example
% 
%         load Rohwer  
%         X = Rohwer(:, 4 : 5); 
%         Y = Rohwer(:, 1 : 3);
%         m = 5;
%         u = mfoldcv_envseq(X, Y, m)
%         B = 100;        
%         bootse = bstrp_envseq(X, Y, u, B)


function bootse = bstrp_envseq(X, Y, u, B, Opts)

if nargin < 4
    error('Inputs: X, Y, B and u should be specified!');
elseif nargin == 4
    Opts = [];
end

Opts = make_opts(Opts);
printFlag = Opts.verbose;
Opts.verbose = 0;

X = double(X);
Y = double(Y);

[n, r] = size(Y);
p = size(X, 2);

ModelOutput = envseq(X, Y, u);

Yfit = ones(n, 1) * ModelOutput.alpha' + X * ModelOutput.beta';
resi = Y - Yfit;

bootBeta = zeros(B, r * p);

for i = 1 : B
    
    if printFlag == 1
        fprintf(['Current number of bootstrap sample ' int2str(i) '\n']);
    end
    
    bootresi = resi(randsample(1 : n, n, true), :);
    Yboot = Yfit + bootresi;
    temp = envseq(X, Yboot, u);
    bootBeta(i, :) = reshape(temp.beta, 1, r * p);

end

bootse = reshape(sqrt(diag(cov(bootBeta, 1))), r, p);
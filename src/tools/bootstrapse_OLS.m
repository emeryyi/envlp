%% bootstrapse_OLS
% Compute bootstrap standard error for ordinary least squares. 

%% Syntax
%         bootse = bootstrapse_OLS(X, Y, B)
%
%% Input
%
% *X*: Predictors, an n by p matrix, p is the number of predictors.  The predictors can be univariate or multivariate, discrete or continuous.
% 
% *Y*: Multivariate responses, an n by r matrix, r is the number of
% responses and n is number of observations.  The responses must be continuous variables.
% 
% *B*: Number of bootstrap samples.  A positive integer.
%
% *Opts*: A list containing the optional input parameters. If not
% defined, the default setting is used.
% 
% * Opts.verbose: Flag for print out the number of bootstrap samples, 
% logical 0 or 1. Default value: 0.

%% Output
%
% *bootse*: The standard error for elements in $$\beta$ computed by
% bootstrap.  An r by p matrix.

%% Description
% This function computes the bootstrap standard errors for the regression
% coefficients in ordinary least squares by bootstrapping the residuals.  

%% Example
%
%         load wheatprotein.txt
%         X = wheatprotein(:, 8);
%         Y = wheatprotein(:, 1 : 6);
%         bootse = bootstrapse_OLS(X, Y, 200)

function bootse = bootstrapse_OLS(X, Y, B, Opts)

if nargin < 3
    error('Inputs: X, Y and B should be specified!');
elseif nargin == 3
    Opts = [];
end

Opts = make_opts(Opts);
printFlag = Opts.verbose;
Opts.verbose = 0;

ModelOutput = fit_OLS(X, Y);
[n, p] = size(X);
r = size(Y, 2);
mY = mean(Y)';
XC = center(X);
betaOLS = ModelOutput.betaOLS;

Yfit = ones(n, 1) * mY' + XC * betaOLS';
resi = Y - Yfit;

bootBeta = zeros(B, r * p);

for i = 1 : B
    
    if printFlag == 1
        fprintf(['Current number of bootstrap sample ' int2str(i) '\n']);
    end
    
    bootresi = resi(randsample(1 : n, n, true), :);
    Yboot = Yfit + bootresi;
    statBoot = fit_OLS(X, Yboot);
    bootBeta(i,:) = reshape(statBoot.betaOLS, 1, r * p);
    
end

bootse = reshape(sqrt(diag(cov(bootBeta, 1))), r, p);

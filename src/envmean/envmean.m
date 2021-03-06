%% envmean
% Provide envelope estimator for the multivariate mean.

%% Syntax
%         ModelOutput = envmean(Y, u)
%         ModelOutput = envmean(Y, u, Opts)

%% Input
%
% *Y*: Data matrix. An n by p matrix, p is the dimension of the variable
% and n is number of observations. 
%
% *u*: Dimension of the envelope. An integer between 0 and p.
% 
% *Opts*: A list containing the optional input parameters, to control the
% iterations in sg_min. If one or several (even all) fields are not
% defined, the default settings are used.
% 
% * Opts.maxIter: Maximum number of iterations.  Default value: 300.
% * Opts.ftol: Tolerance parameter for F.  Default value: 1e-10. 
% * Opts.gradtol: Tolerance parameter for dF.  Default value: 1e-7.
% * Opts.verbose: Flag for print out Grassmann manifold optimization 
% process, logical 0 or 1. Default value: 0.
% * Opts.init: The initial value for the envelope subspace. A p by u matrix. Default
% value is the one generated by function get_Init4envmean. 
%
%% Output
% 
% *ModelOutput*: A list that contains the maximum likelihood estimators and some
% statistics.
% 
% * ModelOutput.mu: The envelope estimator of the multivariate mean $$\mu$. 
% A p dimensional column vector.
% * ModelOutput.Sigma: The envelope estimator of the error covariance matrix.  A p by
% p matrix.
% * ModelOutput.Gamma: The orthogonal basis of the envelope subspace. A p by u
% semi-orthogonal matrix.
% * ModelOutput.Gamma0: The orthogonal basis of the complement of the envelope
% subspace.  An p by p-u semi-orthogonal matrix.
% * ModelOutput.eta: The coordinates of $$\mu$ with respect to Gamma. A u
% dimensional column vector. 
% * ModelOutput.Omega: The coordinates of Sigma with respect to Gamma. A u by u
% matrix.
% * ModelOutput.Omega0: The coordinates of Sigma with respect to Gamma0. A p-u by p-u
% matrix.
% * ModelOutput.l: The maximized log likelihood function.  A real number.
% * ModelOutput.covMatrix: The asymptotic covariance of $$\mu$.  A p by
% p matrix.  The covariance matrix returned are asymptotic.  For the
% actual standard errors, multiply by 1/n.
% * ModelOutput.asySE: The asymptotic standard error for elements in $$\mu$ under
% the envelope model.  A p dimensional column vector.  The standard errors returned are
% asymptotic, for actual standard errors, multiply by 1/sqrt(n).
% * ModelOutput.ratio: The asymptotic standard error ratio of the standard multivariate 
% linear regression estimator over the envelope estimator, for each element 
% in $$\mu$.  A p dimensional column vector.
% * ModelOutput.paramNum: The number of parameters in the envelope model.  A positive
% integer.
% * ModelOutput.n: The number of observations in the data.  A positive
% integer.


%% Description
% This function provides an envelope estimator for the multivariate mean, 
% with a given dimension of the envelope subspace u. The estimator is
% obtained using the maximum likelihood estimation.  When the dimension is
% p, then the envelope model degenerates to the standard sample mean.  When
% the dimension is 0, it means that Y has mean 0. 

%% References
% 
% The Grassmann manifold optimization step calls the package sg_min 2.4.3
% by Ross Lippert (http://web.mit.edu/~ripper/www.sgmin.html).

%% Example
%
%         load Adopted
%         Y = Adopted(:, 1 : 6);
%         u = bic_envmean(Y)
%         ModelOutput = envmean(Y, u)
%         ModelOutput.mu
%         ModelOutput.Sigma

function ModelOutput = envmean(Y, u, Opts)

if nargin < 2
    error('Inputs: Y and u should be specified!');
elseif nargin == 2
    Opts = [];
end

Y = double(Y);

[n, p] = size(Y);

u = floor(u);
if u < 0 || u > p
    error('u should be an integer between [0, p]!');
end

Opts = make_opts(Opts);

if isfield(Opts, 'init')
    [p2, u2] = size(Opts.init);
    if p ~= p2 || u ~= u2
        error('The size of the initial value should be r by u!');
    end
    if rank(Opts.init) < u2
        error('The initial value should be full rank!');
    end
end


sY = Y' * Y / n;
mY = mean(Y)';
sigY = cov(Y, 1);
eigtemY = eig(sY);
logDetSY = sum(log(eigtemY(eigtemY > 0)));
invsY = inv(sY);

if u > 0 && u < p

    DataParameter.n = n;
    DataParameter.p = p;
    DataParameter.sY = sY;
    DataParameter.sigY = sigY;
    DataParameter.logDetSY = logDetSY;
    DataParameter.invsY = invsY;
    
    F = make_F(@F4envmean, DataParameter);
    dF = make_dF(@dF4envmean, DataParameter);

    maxIter = Opts.maxIter;
	ftol = Opts.ftol;
	gradtol = Opts.gradtol;
	if Opts.verbose == 0 
        verbose = 'quiet';
    else
        verbose = 'verbose';
    end
    if ~isfield(Opts, 'init') 
        init = get_Init4envmean(F, u, DataParameter);
    else
        init = Opts.init;
    end
    
    %---Compute \Gamma using sg_min---

    [l, Gamma] = sg_min(F, dF, init, maxIter, 'prcg', verbose, ftol, gradtol);

    %---Compute the rest of the parameters based on \Gamma---
    Gamma0 = grams(nulbasis(Gamma'));
    eta = Gamma' * mY;
    mu = Gamma * eta;
    Omega = Gamma' * sigY * Gamma;
    Omega0 = Gamma0' * sY * Gamma0;
    Sigma = Gamma * Omega * Gamma' + Gamma0 * Omega0 * Gamma0';

    %---compute asymptotic variance and get the ratios---
    asyFm = sqrt(diag(sigY));
    temp = kron(eta * eta', inv(Omega0)) + kron(Omega, inv(Omega0))... 
        + kron(inv(Omega), Omega0) - 2 * kron(eye(u), eye(p - u));  
    covMatrix = Gamma * Omega * Gamma' + kron(eta', Gamma0) / temp * kron(eta, Gamma0');
    asySE = sqrt(diag(covMatrix));

    ModelOutput.mu = mu;
    ModelOutput.Sigma = Sigma;
    ModelOutput.Gamma = Gamma;
    ModelOutput.Gamma0 = Gamma0;
    ModelOutput.eta = eta;
    ModelOutput.Omega = Omega;
    ModelOutput.Omega0 = Omega0;
    ModelOutput.l = - 0.5 * l;
    ModelOutput.covMatrix = covMatrix;
    ModelOutput.asySE = asySE;
    ModelOutput.ratio = asyFm./asySE;
    ModelOutput.paramNum = u + p * (p + 1) / 2;
    ModelOutput.n = n;
    
elseif u == 0
    
    ModelOutput.mu = zeros(p, 1);
    ModelOutput.Sigma = sY;
    ModelOutput.Gamma = [];
    ModelOutput.Gamma0 = eye(p);
    ModelOutput.eta = [];
    ModelOutput.Omega = [];
    ModelOutput.Omega0 = sY;
    ModelOutput.l = - n * p / 2 * (1 + log(2 * pi)) - n / 2 * logDetSY;
    ModelOutput.covMatrix = [];
    ModelOutput.asySE = [];
    ModelOutput.ratio = ones(p, 1);
    ModelOutput.paramNum = u + p * (p + 1) / 2;
    ModelOutput.n = n;  
    
elseif u == p
    
    eigtem = eig(sigY);
    logDetSigY = sum(log(eigtem(eigtem > 0)));
    
    ModelOutput.mu = mY;
    ModelOutput.Sigma = sigY;
    ModelOutput.Gamma = eye(p);
    ModelOutput.Gamma0 = [];
    ModelOutput.eta = mY;
    ModelOutput.Omega = sigY;
    ModelOutput.Omega0 = [];
    ModelOutput.l = - n * p / 2 * (1 + log(2 * pi)) - n / 2 * logDetSigY;
    ModelOutput.covMatrix = sigY;
    ModelOutput.asySE = sqrt(diag(sigY));
    ModelOutput.ratio = ones(p, 1);
    ModelOutput.paramNum = u + p * (p + 1) / 2;
    ModelOutput.n = n; 
    
end
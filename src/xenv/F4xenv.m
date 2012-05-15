%% F4xenv
% Objective function for computing the envelope subspace for the reduction
% on X.

%% Syntax
%         f = F4xenv(R, DataParameter)
% 
%% Input
%
% *R*: A p by u semi orthogonal matrix, 0 < u <= p.
% 
% *DataParameter*: A structure that contains the statistics calculated from
% the data.
%
%% Output
%
% *f*: A scalar containing the value of the objective function evaluated at R.

%% Description
%
% The objective function is derived in Section 4.5.1 of Cook et al. (2012)
%  using maximum likelihood estimation. The columns of the semi-orthogonal 
% matrix that minimizes this function span the estimated envelope subspace.

function f = F4xenv(R, DataParameter)

sigXcY = DataParameter.sigXcY;
sigX = DataParameter.sigX;
invSigX = DataParameter.invSigX;

eigtem = eig(R' * sigXcY * R);
a = log(prod(eigtem(eigtem>0)));

eigtem0 = eig(R' * invSigX * R);
b = log(prod(eigtem0(eigtem0 > 0)));

f = a + b;
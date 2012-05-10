%% F4senv
% Objective funtion for computing the envelope subspace in scaled envelope
% model.

%% Syntax
% f = F4senv(R, DataParameter)
% 
%% Input
%
% * R: An r by u semi orthogonal matrix, 0 < u < r.
% * DataParameter: A structure that contains the statistics calculated from
% the data.
%
%% Output
%
% * f: A scalar containing the value of the objective function evaluated at
% R.

%% Description
%
% The objective function is derived in Section 4.1 in Cook and Su (2012) 
% using maximum likelihood estimation. The columns of the semi-orthogonal 
% matrix that minimizes this function span the estimated envelope subspace.


function f = F4senv(R, DataParameter)

sigRes = DataParameter.sigRes;
sigY = DataParameter.sigY;
Lambda = DataParameter.Lambda;


eigtem = eig(R' * inv(Lambda) * sigRes * inv(Lambda) * R);
a = log(prod(eigtem(eigtem > 0)));

eigtem0 = eig(R' * Lambda * inv(sigY) * Lambda * R);
b = log(prod(eigtem0(eigtem0 > 0)));

f = a + b;
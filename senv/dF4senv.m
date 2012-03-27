%% dF4senv
% First derivative of the objective funtion for computing the envelope
% subspace in the scaled envelope model.

%% Usage
% f = dF4senv(R,dataParameter)
% 
% Input
%
% * R: An r by u semi-orthogonal matrix, 0<u<=p.
% * dataParameter: A structure that contains the statistics calculated form
% the data.
%
% Output
%
% * dF: The first derivative of the objective function for computing the
%  envelope subspace.  An r by u matrix.

%% Description
%
% This first derivative of F4senv obtained by matrix calculus calculations.

function df = dF4senv(R,dataParameter)

sigRes=dataParameter.sigRes;
sigY=dataParameter.sigY;
Lambda=dataParameter.Lambda;

a=2*inv(Lambda)*sigRes*inv(Lambda)*R*inv(R'*inv(Lambda)*sigRes*inv(Lambda)*R);

temp=inv(sigY);

b=2*Lambda*temp*Lambda*R*inv(R'*Lambda*temp*Lambda*R);

df=a+b;
function [ Z, E ] = low_rank( X, lambda, maxIter )
% solve min ||J||_* + \lambda ||E||_2,1 s.t. X=XZ+E, Z=J

% TODO: acc as LRR
P=orth(X'); % nxr
r=size(P,2);
A=X*P; % 3xr

% fprintf(1,'r is %d\n',r);


% solve min ||J||_* + \lambda ||E||_2,1 s.t. X=AZ+E, Z=J
% A 3xr
% X 3xn
% Z rxn


d=size(X,1);
n=size(X,2);

Z=zeros(r,n);
J=Z;

E=zeros(d,n);
Y1=zeros(d,n);
Y2=zeros(r,n);

mu=1e-6;
max_mu=10^10;
rho=1.9;
epsilon=1e-8;

ata=A'*A;
atx=A'*X;
inv_a=inv(ata+eye(r));

MAX_ITER=maxIter;
iter=0;

while true
    if iter>MAX_ITER
        % fprintf(1,'max iter num reached!\n');
        break;
    end
    % 1. update J
    % tic
    Y=Z+Y2/mu;
    tau=1/mu;
    J=singular_value_shrinkage(Y,tau);
    % toc
    % J=max(J,0);
    % 2. update Z
    Z=inv_a*(atx-A'*E+J+(A'*Y1-Y2)/mu);
    % Z=max(Z,0);
    % 3. update E
    tlambda=lambda/mu;
    Q=X-A*Z+Y1/mu;
    E=l21(Q,tlambda);
    % 4. update Y1, Y2
    xz=X-A*Z;
    zj=Z-J;
    leq1=xz-E;
    leq2=zj;
    Y1=Y1+mu*(leq1);
    Y2=Y2+mu*(leq2);
    % 5. update mu
    mu=min(rho*mu,max_mu);
    % 6. check the convergence
    if max(max(abs(leq1)))<epsilon && max(max(abs(leq2)))<epsilon
        % fprintf(1,'iter %d, convergenced\n', iter);
        break;
    end
    iter=iter+1;
end

Z=P*Z;


function u=bic_penv(X1,X2,Y)

[n r]=size(Y);
    
stat=penv(X1,X2,Y,r);
ic=-2*stat.l+log(n)*stat.np;
u=r;


for i=0:r-1
%     i
        stat=penv(X1,X2,Y,i);
        temp=-2*stat.l+log(n)*stat.np;
        if (temp<ic)
           u=i;
           ic=temp;
        end
end
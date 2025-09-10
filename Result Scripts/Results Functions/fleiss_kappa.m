function [k, ci, agreement] = fleiss_kappa(x,varargin)

p = inputParser;
addRequired(p,'x',@(x) validateattributes(x,{'numeric'},{'nonempty','integer','real','finite','nonnan','nonnegative'}));
addOptional(p,'alpha',0.05, @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','nonnan','>',0,'<',1}));
parse(p,x,varargin{:});
x=p.Results.x; alpha=p.Results.alpha;
clear p
n=size(x,1); %subjects

%chech if the raters are the same for each rows
r=sum(x,2);
if any(r-max(r))
    error('The raters are not the same for each rows')
end

m=sum(x(1,:)); %raters
a=n*m;
pj=(sum(x)./(a)); %overall proportion of ratings in category j
b=pj.*(1-pj);
c=a*(m-1);
d=sum(b);
kj=1-(sum((x.*(m-x)))./(c.*b)); %the value of kappa for the j-th category
sekj=realsqrt(2/c); %kj standar error
zkj=kj./sekj;
pkj=(1-0.5*erfc(-abs(zkj)/realsqrt(2)))*2;
k=sum(b.*kj)/d; %Fleiss'es (overall) kappa
sek=realsqrt(2*(d^2-sum(b.*(1-2.*pj))))/sum(b.*realsqrt(c)); %kappa standard error
ci=k+([-1 1].*(abs(0.5*erfc(-alpha/2/realsqrt(2)))*sek)); %k confidence interval
z=k/sek; %normalized kappa
p=(1-0.5*erfc(-abs(z)/realsqrt(2)))*2;

%display results

if k<0
    agreement={'None'};
elseif k>=0 && k<=0.2
    agreement={'None'};
elseif k>0.2 && k<0.4
    agreement={'Minimal'};
elseif k>=0.4 && k<0.6
    agreement={'Weak'};
elseif k>=0.6 && k<0.8
    agreement={'Moderate'};
elseif k>=0.8 && k<=0.9
    agreement={'Strong'};
elseif k>0.9
    agreement={'Almost Perfect'};
end


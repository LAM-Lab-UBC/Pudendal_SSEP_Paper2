function [k, ci, agreement] = Cohen_kappa(x,varargin)
p = inputParser;
addRequired(p,'x',@(x) validateattributes(x,{'numeric'},{'square','nonempty','integer','real','finite','nonnan','nonnegative'}));
addOptional(p,'w',0, @(x) isnumeric(x) && isreal(x) && isfinite(x) && isscalar(x) && ismember(x,[0 1 2]));
addOptional(p,'alpha',0.05, @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','nonnan','>',0,'<',1}));
parse(p,x,varargin{:});
x=p.Results.x; w=p.Results.w; alpha=p.Results.alpha;
clear p default* validation*

m=size(x,1);
tr=repmat('-',1,80);
switch w
    case 0
        f=diag(ones(1,m)); %unweighted
        %disp('UNWEIGHTED COHEN''S KAPPA')
        %disp(tr)
        kcomp;
        %disp(' ')
    case 1
        J=repmat((1:1:m),m,1);
        I=flipud(rot90(J));
        f=1-abs(I-J)./(m-1); %linear weight
        %disp('LINEAR WEIGHTED COHEN''S KAPPA')
        %disp(tr)
        kcomp;
        %disp(' ')
    case 2
        J=repmat((1:1:m),m,1);
        I=flipud(rot90(J));
        f=1-((I-J)./(m-1)).^2; %quadratic weight
        %disp('QUADRATIC WEIGHTED COHEN''S KAPPA')
        %disp(tr)
        kcomp;
end

    function kcomp
        n=sum(x(:)); %Sum of Matrix elements
        x=x./n; %proportion
        r=sum(x,2); %rows sum
        s=sum(x); %columns sum
        Ex=r*s; %expected proportion for random agree
        po=sum(sum(x.*f)); %proportion observed
        pe=sum(sum(Ex.*f)); %proportion expected
        k=(po-pe)/(1-pe); %Cohen's kappa
        pom=sum(min([r';s])); %maximum proportion observable
        km=(pom-pe)/(1-pe); %maximum possible kappa, given the observed marginal frequencies
        ratio=k/km; %observed as proportion of maximum possible
        sek=sqrt((po*(1-po))/(n*(1-pe)^2)); %kappa standard error for confidence interval
        ci=k+([-1 1].*(abs(-realsqrt(2)*erfcinv(alpha))*sek)); %k confidence interval
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

    end
end
function [BestScore,BestPos,Curve] = PSO(N,MaxIter,lb,ub,dim,fobj)

if numel(lb)==1
    lb = lb*ones(1,dim);
    ub = ub*ones(1,dim);
end

w = 0.9;
wdamp = 0.99;

c1 = 2;
c2 = 2;

vmax = 0.2*(ub-lb);
vmin = -vmax;

X = rand(N,dim).*(ub-lb)+lb;
V = zeros(N,dim);

Pbest = X;
PbestScore = inf(N,1);

BestScore = inf;
BestPos = zeros(1,dim);

for i = 1:N

    fit = fobj(X(i,:));

    PbestScore(i) = fit;

    if fit < BestScore
        BestScore = fit;
        BestPos = X(i,:);
    end

end

Curve = zeros(MaxIter,1);

for t = 1:MaxIter

    for i = 1:N

        r1 = rand(1,dim);
        r2 = rand(1,dim);

        V(i,:) = w*V(i,:) ...
            + c1*r1.*(Pbest(i,:)-X(i,:)) ...
            + c2*r2.*(BestPos-X(i,:));

        V(i,:) = max(V(i,:),vmin);
        V(i,:) = min(V(i,:),vmax);

        X(i,:) = X(i,:) + V(i,:);

        X(i,:) = max(X(i,:),lb);
        X(i,:) = min(X(i,:),ub);

        fit = fobj(X(i,:));

        if fit < PbestScore(i)

            Pbest(i,:) = X(i,:);
            PbestScore(i) = fit;

        end

        if fit < BestScore

            BestScore = fit;
            BestPos = X(i,:);

        end

    end

    Curve(t) = BestScore;

    w = w*wdamp;

end

end
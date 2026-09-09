function [BestScore,BestPos,Curve] = ACO(N,MaxIter,lb,ub,dim,fobj)

if numel(lb)==1
    lb = lb*ones(1,dim);
    ub = ub*ones(1,dim);
end

nArchive = 2*N;
q = 0.2;
zeta = 0.2;

Archive = rand(nArchive,dim).*(ub-lb)+lb;
Fitness = zeros(nArchive,1);

for i = 1:nArchive
    Fitness(i) = fobj(Archive(i,:));
end

[Fitness,idx] = sort(Fitness);
Archive = Archive(idx,:);

BestScore = Fitness(1);
BestPos = Archive(1,:);

Curve = zeros(MaxIter,1);

for t = 1:MaxIter

    p = zeros(nArchive,1);

    for i = 1:nArchive

        p(i) = (1/(q*nArchive*sqrt(2*pi))) * ...
            exp(-(i-1)^2/(2*(q*nArchive)^2));

    end

    p = p/sum(p);

    NewPop = zeros(N,dim);
    NewFit = zeros(N,1);

    for k = 1:N

        idx = RouletteWheel(p);

        for j = 1:dim

            sigma = 0;

            for r = 1:nArchive
                sigma = sigma + ...
                    abs(Archive(r,j)-Archive(idx,j));
            end

            sigma = zeta*sigma/(nArchive-1);

            NewPop(k,j) = ...
                Archive(idx,j) + sigma*randn();

        end

        NewPop(k,:) = max(NewPop(k,:),lb);
        NewPop(k,:) = min(NewPop(k,:),ub);

        NewFit(k) = fobj(NewPop(k,:));

    end

    Archive = [Archive;NewPop];
    Fitness = [Fitness;NewFit];

    [Fitness,idx] = sort(Fitness);
    Archive = Archive(idx,:);

    Archive = Archive(1:nArchive,:);
    Fitness = Fitness(1:nArchive);

    if Fitness(1) < BestScore

        BestScore = Fitness(1);
        BestPos = Archive(1,:);

    end

    Curve(t) = BestScore;

end

end

function idx = RouletteWheel(P)

r = rand();
C = cumsum(P);

idx = find(r <= C,1,'first');

if isempty(idx)
    idx = numel(P);
end

end
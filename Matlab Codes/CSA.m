function [BestScore,BestPos,Curve] = CSA(N,MaxIter,lb,ub,dim,fobj)

%% Boundary Expansion (Matching ACO & PSO format)
if numel(lb)==1
    lb = lb*ones(1,dim);
    ub = ub*ones(1,dim);
end

%% CSA Parameters (As detailed in the reference paper)
pa = 0.25;      % Discovery probability of alien eggs/nests
beta = 1.5;     % Levy flight exponent (1 < beta <= 2)

% Calculate sigma for Mantegna's Levy flight generation
sigma = (gamma(1+beta) * sin(pi*beta/2) / ...
        (gamma((1+beta)/2) * beta * 2^((beta-1)/2)))^(1/beta);

%% Population Initialization
Nest = rand(N,dim).*(ub-lb) + lb;
Fitness = zeros(N,1);

for i = 1:N
    Fitness(i) = fobj(Nest(i,:));
end

[BestScore, idx] = min(Fitness);
BestPos = Nest(idx,:);

Curve = zeros(MaxIter,1);

%% Main Optimization Loop
for t = 1:MaxIter

    % ----------------------------------------------------
    % 1. Generate New Solutions by Levy Flights
    % ----------------------------------------------------
    for i = 1:N
        s = Nest(i,:);

        % Mantegna's algorithm for Levy flight walk
        u = randn(1,dim) * sigma;
        v = randn(1,dim);
        step = u ./ (abs(v).^(1/beta));

        % Step size proportional to distance from the current best nest
        stepsize = 0.01 * step .* (s - BestPos);

        % Perform Levy flight jump
        s_new = s + stepsize .* randn(1,dim);

        % Boundary control
        s_new = max(s_new, lb);
        s_new = min(s_new, ub);

        % Greedy selection against the current nest
        fit_new = fobj(s_new);
        if fit_new < Fitness(i)
            Nest(i,:) = s_new;
            Fitness(i) = fit_new;
        end
    end

    % ----------------------------------------------------
    % 2. Discover and Abandon Alien Nests (Fraction pa)
    % ----------------------------------------------------
    % Nests discovered with probability pa are replaced via random walk
    K = rand(N,dim) < pa; 
    stepsize = rand() * (Nest(randperm(N),:) - Nest(randperm(N),:));
    NewNest = Nest + stepsize .* K;

    for i = 1:N
        % Boundary control
        NewNest(i,:) = max(NewNest(i,:), lb);
        NewNest(i,:) = min(NewNest(i,:), ub);

        % Greedy selection
        fit_new = fobj(NewNest(i,:));
        if fit_new < Fitness(i)
            Nest(i,:) = NewNest(i,:);
            Fitness(i) = fit_new;
        end
    end

    % ----------------------------------------------------
    % 3. Update Global Best and Convergence Curve
    % ----------------------------------------------------
    [current_best, idx] = min(Fitness);
    if current_best < BestScore
        BestScore = current_best;
        BestPos = Nest(idx,:);
    end

    Curve(t) = BestScore;

end

end
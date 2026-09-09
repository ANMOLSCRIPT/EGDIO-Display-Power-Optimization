function [Best_score,Best_pos,cg_curve] = ...
EGDIO(N,Max_iter,lb,ub,dim,fobj)

if numel(lb)==1
    lb=lb*ones(1,dim);
end

if numel(ub)==1
    ub=ub*ones(1,dim);
end

%% ====================================================
%% OBL INITIALIZATION
%% ====================================================

X = repmat(lb,N,1) + ...
    rand(N,dim).*repmat((ub-lb),N,1);

Xopp = repmat(lb+ub,N,1) - X;

Pop = [X;Xopp];

Fit = zeros(2*N,1);

for i=1:2*N
    Fit(i)=fobj(Pop(i,:));
end

[~,idx]=sort(Fit);

X=Pop(idx(1:N),:);

%% ====================================================
%% INITIAL FITNESS
%% ====================================================

Fitness=zeros(N,1);

for i=1:N
    Fitness(i)=fobj(X(i,:));
end

[Fitness,idx]=sort(Fitness);

X=X(idx,:);

Alpha_pos=X(1,:);
Beta_pos=X(2,:);
Delta_pos=X(3,:);

Best_score=Fitness(1);
Best_pos=Alpha_pos;

cg_curve=zeros(1,Max_iter);

%% ====================================================
%% MAIN LOOP
%% ====================================================

for t=1:Max_iter

    %% ==========================================
    %% NONLINEAR DECAY
    %% ==========================================

    a = 2*(1-(t/Max_iter)^2);

    %% ==========================================
    %% ADAPTIVE STEP SIZE
    %% ==========================================

    lambda = 1 - (t/Max_iter);

    MeanPos = mean(X);

    for i=1:N

        %% ======================================
        %% DIO COMPONENT
        %% ======================================

        r = rand;

        B = a*(2*r-1);

        C = 1+r;

        D_lead = abs(C*Alpha_pos-X(i,:));

        X_dio = Alpha_pos - B.*D_lead;

        X_pack = MeanPos - ...
            r.*abs(MeanPos-X(i,:));

        X_dio = 0.7*X_dio + 0.3*X_pack;

        %% ======================================
        %% GWO COMPONENT
        %% ======================================

        r1=rand(1,dim);
        r2=rand(1,dim);

        A1=2*a*r1-a;
        C1=2*r2;

        D_alpha=abs(C1.*Alpha_pos-X(i,:));

        X1=Alpha_pos-A1.*D_alpha;

        r1=rand(1,dim);
        r2=rand(1,dim);

        A2=2*a*r1-a;
        C2=2*r2;

        D_beta=abs(C2.*Beta_pos-X(i,:));

        X2=Beta_pos-A2.*D_beta;

        r1=rand(1,dim);
        r2=rand(1,dim);

        A3=2*a*r1-a;
        C3=2*r2;

        D_delta=abs(C3.*Delta_pos-X(i,:));

        X3=Delta_pos-A3.*D_delta;

        X_gwo=(X1+X2+X3)/3;

        %% ======================================
        %% ADAPTIVE HYBRID WEIGHT
        %% ======================================

        w = t/Max_iter;

        HybridPos = ...
            (1-w)*X_dio + ...
             w*X_gwo;

        %% ======================================
        %% ADAPTIVE STEP CONTROL
        %% ======================================

        X_new = ...
            X(i,:) + ...
            lambda*(HybridPos-X(i,:));

        %% ======================================
        %% BOUNDARY CONTROL
        %% ======================================

        X_new=max(X_new,lb);
        X_new=min(X_new,ub);

        X(i,:)=X_new;

    end

    %% ==========================================
    %% FITNESS UPDATE
    %% ==========================================

    for i=1:N

        Fitness(i)=fobj(X(i,:));

    end

    [Fitness,idx]=sort(Fitness);

    X=X(idx,:);

    Alpha_pos=X(1,:);
    Beta_pos=X(2,:);
    Delta_pos=X(3,:);

    if Fitness(1)<Best_score

        Best_score=Fitness(1);

        Best_pos=Alpha_pos;

    end

    cg_curve(t)=Best_score;

end

end
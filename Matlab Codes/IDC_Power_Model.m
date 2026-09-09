%% =========================================================================
%  INDIA DISPLAY CONFERENCE (IDC) 2026 - EXPERIMENTAL TESTBENCH
%  Project: Power Optimization in Emissive Displays (OLED / MicroLED)
%  Algorithms: EGDIO, PSO, ACO, CSA
% =========================================================================
clear; clc; close all;

if isempty(gcp('nocreate'))
    parpool;
end

%% 1. DIRECTORY AND PATH CONFIGURATION
dataset_dir = fullfile(pwd, 'Datasets');
results_dir = fullfile(pwd, 'Results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end
% Supported image formats
img_files = [dir(fullfile(dataset_dir, '*.png')); ...
             dir(fullfile(dataset_dir, '*.jpg')); ...
             dir(fullfile(dataset_dir, '*.bmp')); ...
             dir(fullfile(dataset_dir, '*.tif'))];

if isempty(img_files)
    warning('No images found in Datasets folder. Creating sample test image...');
    if ~exist(dataset_dir, 'dir'), mkdir(dataset_dir); end
    synthetic_img = uint8(255 * rand(256, 256, 3));
    imwrite(synthetic_img, fullfile(dataset_dir, 'sample_test.png'));
    img_files = dir(fullfile(dataset_dir, 'sample_test.png'));
end
%% 2. HARDWARE AND MODEL CONSTANTS (From Dong & Zhong / Pandey et al.)
% Dynamic power weights: Blue draws highest current, followed by Green and Red
w_R = 0.28;       % Relative Red weight (194 mA baseline)
w_G = 0.31;       % Relative Green weight (212 mA baseline)
w_B = 0.41;       % Relative Blue weight (286 mA baseline)
weights = [w_R, w_G, w_B];
gamma_val = 2.2;  % Standard display gamma
C = 0.05;         % Normalized static hardware constant (display controller)
SSIM_target = 0.95; % Accepted constraint threshold

%% 3. ALGORITHM CONFIGURATION
% 5 Search Dimensions: [Alpha, Brightness, Scale_Red, Scale_Green, Scale_Blue]
dim = 5;
lb  = [0.20, 0.20, 0.20, 0.20, 0.20]; % Lower bounds
ub  = [1.00, 1.00, 1.00, 1.00, 1.00]; % Upper bounds
N       = 20;  % Population size (swarm/pack size)
MaxIter = 50;  % Maximum iterations

% Algorithm function handles
alg_names = {'EGDIO', 'PSO', 'ACO', 'CSA'};
alg_funcs = {@EGDIO, @PSO, @ACO, @CSA};

%% 4. RESULTS TABLE PREALLOCATION
num_images = length(img_files);
par_results = cell(num_images, 1);
fprintf('\n========================================================================\n');
fprintf('  STARTING SIMULATION RUN: SUB-PIXEL DISPLAY POWER OPTIMIZATION\n');
fprintf('========================================================================\n\n');
%% 5. BATCH EXECUTION LOOP ACROSS DATASETS
parfor img_idx = 1:num_images
    
    img_name = img_files(img_idx).name;
    img_path = fullfile(dataset_dir, img_name);
    
    % Read and normalize image
    I_orig = im2double(imread(img_path));
    if size(I_orig, 3) == 1
        I_orig = repmat(I_orig, [1, 1, 3]); % Convert grayscale to 3-channel
    end
    
    % Resize large images during optimization loop for faster CPU evaluation
    I_eval = imresize(I_orig, [256, 256]);
    
    % Compute unoptimized baseline power (Alpha=1, Brightness=1, sR=1, sG=1, sB=1)
    base_R = I_eval(:,:,1).^gamma_val;
    base_G = I_eval(:,:,2).^gamma_val;
    base_B = I_eval(:,:,3).^gamma_val;
    P_base = C + mean(w_R * base_R(:) + w_G * base_G(:) + w_B * base_B(:));
    
    fprintf('Processing Image [%d/%d]: %s (Baseline Power: %.4f)\n', ...
        img_idx, num_images, img_name, P_base);
    fprintf('------------------------------------------------------------------------\n');
    
    % Objective function handle with strict SSIM penalty
    fobj = @(X) objective_function(X, I_eval, weights, gamma_val, C, SSIM_target);
    
    local_results = [];
    
    % Run each metaheuristic on the current image
    for alg_i = 1:length(alg_funcs)
        
        alg_name = alg_names{alg_i};
        func = alg_funcs{alg_i};
        
        tic;
        [best_score, best_pos, conv_curve] = func(N, MaxIter, lb, ub, dim, fobj);
        runtime = toc;
        
        % Evaluate final metrics on full original resolution
        alpha_opt = best_pos(1);
        br_opt    = best_pos(2);
        sR_opt    = best_pos(3);
        sG_opt    = best_pos(4);
        sB_opt    = best_pos(5);
        
        I_opt = zeros(size(I_orig));
        I_opt(:,:,1) = min(max(alpha_opt * br_opt * sR_opt * I_orig(:,:,1), 0), 1);
        I_opt(:,:,2) = min(max(alpha_opt * br_opt * sG_opt * I_orig(:,:,2), 0), 1);
        I_opt(:,:,3) = min(max(alpha_opt * br_opt * sB_opt * I_orig(:,:,3), 0), 1);
        
        % Calculate final full-resolution metrics
        final_ssim = ssim(I_opt, I_orig);
        
        opt_R = I_opt(:,:,1).^gamma_val;
        opt_G = I_opt(:,:,2).^gamma_val;
        opt_B = I_opt(:,:,3).^gamma_val;
        P_opt = C + mean(w_R * opt_R(:) + w_G * opt_G(:) + w_B * opt_B(:));
        
        power_saved_pct = ((P_base - P_opt) / P_base) * 100;
        
        % Store to summary structure
       
        entry = struct(); 
        entry.ImageName      = string(img_name);
        entry.Algorithm      = string(alg_name);
        entry.BaselinePower  = P_base;
        entry.OptimizedPower = P_opt;
        entry.PowerSaved_Pct = power_saved_pct;
        entry.SSIM           = final_ssim;
        entry.Runtime_Sec    = runtime;
        
        local_results = [local_results; entry]; 
        
        fprintf('  %-7s -> Power Saved: %6.2f%% | SSIM: %.4f | Runtime: %5.2fs\n', ...
            alg_name, power_saved_pct, final_ssim, runtime);
    end
    par_results{img_idx} = local_results;
    fprintf('\n');
end
%% 6. DISPLAY AND SAVE TABULAR RESULTS
results_summary = vertcat(par_results{:});
ResultsTable = struct2table(results_summary);
disp('============================= COMPARATIVE RESULTS =============================');
disp(ResultsTable);
% Export results to CSV for your conference paper
writetable(ResultsTable, fullfile(results_dir, 'display_power_optimization_results.csv'));
fprintf('\nComplete tabular results successfully saved to: Results/display_power_optimization_results.csv\n');
%% =========================================================================
%% 7. MATHEMATICAL MODEL & OBJECTIVE FUNCTION WITH SSIM PENALTY
%% =========================================================================
function cost = objective_function(X, I_orig, weights, gamma_val, C, SSIM_target)
    
    alpha = X(1);
    Br    = X(2);
    sR    = X(3);
    sG    = X(4);
    sB    = X(5);
    
    % Apply sub-pixel scaling and regional dimming parameters
    I_mod = zeros(size(I_orig));
    I_mod(:,:,1) = min(max(alpha * Br * sR * I_orig(:,:,1), 0), 1);
    I_mod(:,:,2) = min(max(alpha * Br * sG * I_orig(:,:,2), 0), 1);
    I_mod(:,:,3) = min(max(alpha * Br * sB * I_orig(:,:,3), 0), 1);
    
    % Sub-pixel level dynamic power computation
    R_p = I_mod(:,:,1).^gamma_val;
    G_p = I_mod(:,:,2).^gamma_val;
    B_p = I_mod(:,:,3).^gamma_val;
    
    P_dynamic = mean(weights(1)*R_p(:) + weights(2)*G_p(:) + weights(3)*B_p(:));
    P_total   = C + P_dynamic;
    
    % Image Quality Metric: Structural Similarity Index Measure (SSIM)
    current_ssim = ssim(I_mod, I_orig);
    
    % Penalty method: heavily penalize solutions that violate SSIM >= 0.95
    penalty_weight = 1e4;
    ssim_violation = max(0, SSIM_target - current_ssim);
    
    % Total cost to be minimized by the metaheuristics
    cost = P_total + (penalty_weight * ssim_violation);
end
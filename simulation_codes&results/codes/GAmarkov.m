clc;
clear;
close all;


%% 遗传算法参数设置
nind = 100;            % 种群大小
maxgen = 500;         % 最大代数
preci = 20;           % 每个个体的基因长度（控制矩阵精度）
ggap = 0.9;          % 代沟
px = 0.8;             % 交叉概率
pm = 0.01;            % 变异概率
trace = zeros(17, maxgen);  % 记录最优解
avg_fitness = zeros(1,maxgen); %记录平均适应度

% 初始化种群
fieldd = [repmat(preci, 1, 16); ...
          repmat(0, 1, 16); ...
          repmat(1, 1, 16); ...
          ones(1, 16); ...
          zeros(1, 16); ...
          ones(1, 16); ...
          ones(1, 16)];
chrom = crtbp(nind, preci * 16);  % 随机生成初始种群
tic %开始计时
%% 适应度函数初始化
fitness = zeros(nind, 1);  % 存放每个个体的适应度值

for i = 1:nind
    % 解码并 reshape 为 6x6 矩阵
    X = bs2rv(chrom(i, :), fieldd);
    markovMatrix = reshape(X, [4, 4]);
    
    % 确保每行和为 1
    sumRows = sum(markovMatrix, 2);
    zeroRows = (sumRows == 0);
    markovMatrix(zeroRows, :) = 1 / size(markovMatrix, 2);
    markovMatrix = markovMatrix ./ sum(markovMatrix, 2);
    
    % 计算 FoM 和 RMSE
    [FoM, RMSE] = CA2(markovMatrix);
     
    
    % 适应度函数
    fitness(i) = 0.5 * FoM + 0.5 * (1-RMSE);
end

%% 遗传算法主循环
gen = 0;  % 代数计数器
while gen < maxgen
    % 检查是否收敛
    if gen > 300 && max(trace(17, gen-50:gen)) - min(trace(17, gen-50:gen)) < 0.001
        fprintf('模型收敛\n');
        break;
    end
    % 增加变异强度
    if gen < maxgen / 5
       pm = 0.05; % 前期变异概率提高
    else
       pm = 0.01; % 后期降低变异概率
    end

    gen = gen + 1;
    
    
    % 适应度排序并选择父代
    fitnv = ranking(-fitness);                   % 适应度排序（注意负号表示求最小值）
    selch = select('sus', chrom, fitnv, ggap);   % 选择操作

    % 交叉和变异
    selch = recombin('xovsp', selch, px);        % 交叉操作
    selch = mut(selch, pm);                      % 变异操作

    % 将子代转为实际解并计算适应度
    newChrom = bs2rv(selch, fieldd);
    for i = 1:size(newChrom, 1)
        X = newChrom(i, :);
        markovMatrix = reshape(X, [4, 4]);
        
        % 确保每行和为 1
        sumRows = sum(markovMatrix, 2);
        zeroRows = (sumRows == 0);
        markovMatrix(zeroRows, :) = 1 / size(markovMatrix, 2);
        markovMatrix = markovMatrix ./ sum(markovMatrix, 2);

        % 计算 FoM 和 RMSE
        [FoM, RMSE]  = CA2(markovMatrix);
         
        
        % 更新适应度
        fitness_new(i) = 0.5 * FoM + 0.5 * (1-RMSE);
    end
   
    % 确保 fitness 和 fitness_new 是列向量
    fitness = fitness(:);
    fitness_new = fitness_new(:);
    
    % 精英保留策略：将最优个体保留到下一代并替换掉最差个体
    [~, idx_best] = max(fitness);  % 当前代适应度最优个体索引
    [~, idx_worst] = min(fitness);  % 当前代适应度最差个体索引
    
    % 将最优个体替换掉最差个体
    chrom(idx_worst, :) = chrom(idx_best, :);  % 替换最差个体
    fitness(idx_worst) = fitness(idx_best);  % 更新适应度
   
    % 重插入操作
    [chrom, fitness] = reins(chrom, selch, 1, 1, fitness, fitness_new);
    
   
    % 更新最优解
    [maxFitness, j] = max(fitness);  % 适应度最大值
    trace(1:16, gen) = reshape(bs2rv(chrom(j, :), fieldd), [16, 1]);
    trace(17, gen) = maxFitness;  % 记录适应度最大值
    avg_fitness(gen) = mean(fitness); %记录平均适应度
end

%% 绘制进化过程
figure;
plot(1:gen, trace(17, 1:gen), 'b-*', 'DisplayName', 'Best Fitness');
hold on;
plot(1:gen, avg_fitness(1:gen), 'r-o', 'DisplayName', 'Average Fitness');
xlabel('Generation');
ylabel('Fitness');
title('Evolution of Fitness');
legend('Location', 'best');
grid on;

%% 输出最优解
bestMatrix = trace(1:16, gen);
fprintf('Best Markov Matrix (4x4):\n');
disp(bestMatrix);
fprintf('Best Fitness: %f\n', trace(17, gen));
markovMatrixt = reshape(bestMatrix, [4, 4]);
markovMatrixt = markovMatrixt ./ sum(markovMatrixt, 2);
elapsed_time = toc;
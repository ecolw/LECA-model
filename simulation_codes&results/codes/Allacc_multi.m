function Aresult = Allacc_multi(startdata, enddata, simudata)
    % 实际中分类的元胞数目
    a1 = sum(sum(enddata == 1)); % 红树林
    a2 = sum(sum(enddata == 2)); % 盐沼
    a3 = sum(sum(enddata == 3)); % 滩涂
    a4 = sum(sum(enddata == 4)); % 水体

    n = a1 + a2 + a3 + a4;

    % 模拟中分类的元胞数目
    b1 = sum(sum(simudata == 1)); % 红树林
    b2 = sum(sum(simudata == 2)); % 盐沼
    b3 = sum(sum(simudata == 3)); % 滩涂
    b4 = sum(sum(simudata == 4)); % 水体

    % 计算Pe值
    Pe = (a1 * b1 + a2 * b2 + a3 * b3 + a4 * b4) / (n * n);

    % 计算分类正确的元胞数目
    right = sum(sum(enddata == 1 & simudata == 1)) + ...
            sum(sum(enddata == 2 & simudata == 2)) + ...
            sum(sum(enddata == 3 & simudata == 3)) + ...
            sum(sum(enddata == 4 & simudata == 4));

    % 总体精度OA
    Aresult.OA = right / n;

    % Kappa系数
    Aresult.Kappa = (Aresult.OA - Pe) / (1 - Pe);

    % 计算FoM所需的各项指标
    % 实际发生变化但预测为不变
    A = sum(sum(startdata == simudata & startdata ~= enddata));

    % 实际发生变化且预测为变化（正确）
    B = sum(sum(startdata ~= enddata & enddata == simudata));

    % 实际发生变化但预测错误类别
    C = sum(sum(startdata ~= enddata & startdata ~= simudata & enddata ~= simudata));

    % 实际未变化但预测为变化
    D = sum(sum(startdata == enddata & startdata ~= simudata));

    % 计算FoM、PA和UA
    Aresult.FoM = B / (A + B + C + D); % 模型契合度
    Aresult.PA = B / (A + B + C);      % 生产者精度
    Aresult.UA = B / (B + C + D);      % 用户精度
end

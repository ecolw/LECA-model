%%%计算景观指标
function [NP, PD, Area_MN, TE, LPI, LSI, SHAPE_MN, AI, ED, ENN_MN, SHDI] = landscape(result_mat)
    
    %tiffpath = 'E:\model\CAGA\LuoyangCA\land_use_data&spatial_driving_factors\';   %指定文件路径
    %startdata_name=[tiffpath 'L2018.tif']; %%%初期数据的文件名
    %enddata_name=[tiffpath 'L2020.tif'];
    %ref_filename='L2018.tif';
    %[~,ref]=readgeoraster([tiffpath ref_filename]);
    %info=geotiffinfo([tiffpath ref_filename]);    %此处的ref为空间参考的对象（判断其为地理坐标系还是投影坐标系）；info是具体的空间参考信息（具体的地理坐标系或投影坐标系信息）。
    %startdata=double(imread(startdata_name));
    %enddata=double(imread(enddata_name));
    %result_mat = startdata;
    %real_map = enddata;

    cellsize = 30; % 元胞代表的矩阵大小
    categories = unique(result_mat(result_mat ~= 255)); % 动态获取类别
    non_null_cells = sum(result_mat(:) ~= 255); % 非空值区域的像元个数
    non_null_area = non_null_cells * (cellsize^2); % 非空值区域的总面积
    
    % 初始化指标
    num_categories = numel(categories);
    NP = zeros(1, num_categories);
    PD = zeros(1, num_categories);
    Area_MN = zeros(1, num_categories);
    TE = zeros(1, num_categories);
    LPI = zeros(1, num_categories);
    LSI = zeros(1, num_categories);
    SHAPE_MN = zeros(1, num_categories);
    AI = zeros(1, num_categories);
    ED = zeros(1, num_categories);
    ENN_MN = zeros(1, num_categories);
    area_proportions = zeros(1, num_categories); % 用于计算SHDI  
        
    for i = 1:4
        % 获取当前类别的二值图像
        ur_mat = result_mat;
        ur_mat(ur_mat ~= i) = 0; % 将非当前类别的区域设为0
        ur_mat(ur_mat == i) = 1; % 当前类别区域设为1

        % 计算城市区域面积
        urban_cells = sum(ur_mat(:) == 1); % 当前类别区域的像元个数
        urbanarea = urban_cells * (cellsize^2); % 当前类别区域的面积

        % 计算非空值区域面积
        non_null_cells = sum(result_mat(:) ~= 255); % 非空值区域的像元个数
        non_null_area = non_null_cells * (cellsize^2); % 非空值区域的总面积

        % 计算NP
        [L, nP] = bwlabel(ur_mat, 8); % 8连通
        NP(i) = nP; % 存储当前类别的NP

        % 计算每个连通域的面积和周长
        A = regionprops(L, 'Area');
        A = [A.Area]' * (cellsize^2); % 各连通域的面积
        P = regionprops(L, 'Perimeter');
        P = [P.Perimeter]' * cellsize; % 各连通域的周长

        % 计算PD
        PD(i) = (NP(i) / non_null_area) * 10000 * 100;

        % 计算Area_MN
        Area_MN(i) = urbanarea / NP(i);

        % 计算TE
        TE(i) = sum(P);

        % 计算LPI
        LP = max(A); % 最大面积
        LPI(i) = LP / non_null_area;

        % 计算LSI
        LSI(i) = 0.25 * TE(i) / (urbanarea^0.5);

        % 计算SHAPE_MN
        SHAPE_MN(i) = sum((0.25 * P) ./ (A.^0.5)) / NP(i);

        % 计算AI
        % g_i 是同类像元的邻接对数，通过灰度共生矩阵计算
        g_i = sum(sum(graycomatrix(ur_mat, 'Offset', [0 1], 'Symmetric', true)));
        G_i = (urban_cells * 4 - 2 * TE(i) / cellsize) / 2; % 理论邻接像元对数
        AI(i) = (g_i / G_i) * 100;

        % 计算ED
        ED(i) = TE(i) / non_null_area;

        % 计算ENN_MN
        % 获取斑块质心，计算最近邻距离
        centroids = regionprops(L, 'Centroid');
        centroids = cat(1, centroids.Centroid);
        if size(centroids, 1) > 1
            dist_matrix = squareform(pdist(centroids)); % 欧几里得距离矩阵
            dist_matrix(dist_matrix == 0) = Inf; % 排除自身
            ENN_MN(i) = mean(min(dist_matrix, [], 2)) * cellsize; % 最近邻均值
        else
            ENN_MN(i) = NaN; % 单个斑块无法计算最近邻
        end

        % 保存类别面积占比，用于SHDI计算
        area_proportions(i) = urbanarea / non_null_area;
    end
    % 计算SHDI (Shannon Diversity Index)
    area_proportions(area_proportions > 0) = area_proportions(area_proportions > 0); % 去除零值
    SHDI = -sum(area_proportions .* log(area_proportions));
end
function [error_metrics] = landscapecompare(simulated_map, real_map)
    % 计算模拟图与真实图的景观指数
   
   
    %tiffpath = 'E:\model\CAGA\LuoyangCA\land_use_data&spatial_driving_factors\';   %指定文件路径
    %startdata_name=[tiffpath 'L2018.tif']; %%%初期数据的文件名
    %enddata_name=[tiffpath 'L2020.tif'];
    %ref_filename='L2018.tif';
    %[~,ref]=readgeoraster([tiffpath ref_filename]);
    %info=geotiffinfo([tiffpath ref_filename]);    %此处的ref为空间参考的对象（判断其为地理坐标系还是投影坐标系）；info是具体的空间参考信息（具体的地理坐标系或投影坐标系信息）。
    %startdata=double(imread(startdata_name));
    %enddata=double(imread(enddata_name));
    %simulated_map = startdata;
    %real_map = enddata;
    
    
    [NP_sim, PD_sim, Area_MN_sim, TE_sim, LPI_sim, LSI_sim, SHAPE_MN_sim, AI_sim, ED_sim, ENN_MN_sim, SHDI_sim] = landscape(simulated_map);
    [NP_real, PD_real, Area_MN_real, TE_real, LPI_real, LSI_real, SHAPE_MN_real, AI_real, ED_real, ENN_MN_real, SHDI_real] = landscape(real_map);
    
    % 初始化误差结果
    error_metrics = struct();
    
    % 计算每个景观指数的误差
    error_metrics.NP_error = abs(NP_sim - NP_real);
    error_metrics.PD_error = abs(PD_sim - PD_real);
    error_metrics.Area_MN_error = abs(Area_MN_sim - Area_MN_real);
    error_metrics.TE_error = abs(TE_sim - TE_real);
    error_metrics.LPI_error = abs(LPI_sim - LPI_real);
    error_metrics.LSI_error = abs(LSI_sim - LSI_real);
    error_metrics.SHAPE_MN_error = abs(SHAPE_MN_sim - SHAPE_MN_real);
    error_metrics.AI_error = abs(AI_sim - AI_real);
    error_metrics.ED_error = abs(ED_sim - ED_real);
    error_metrics.ENN_MN_error = abs(ENN_MN_sim - ENN_MN_real);
    error_metrics.SHDI_error = abs(SHDI_sim - SHDI_real);

    % 计算误差的相对百分比
    error_metrics.NP_re_error = (error_metrics.NP_error ./ NP_real) * 100;
    error_metrics.PD_re_error = (error_metrics.PD_error ./ PD_real) * 100;
    error_metrics.Area_MN_re_error = (error_metrics.Area_MN_error ./ Area_MN_real) * 100;
    error_metrics.TE_re_error = (error_metrics.TE_error ./ TE_real) * 100;
    error_metrics.LPI_re_error = (error_metrics.LPI_error ./ LPI_real) * 100;
    error_metrics.LSI_re_error = (error_metrics.LSI_error ./ LSI_real) * 100;
    error_metrics.SHAPE_MN_re_error = (error_metrics.SHAPE_MN_error ./ SHAPE_MN_real) * 100;
    error_metrics.AI_re_error = (error_metrics.AI_error ./ AI_real) * 100;
    error_metrics.ED_re_error = (error_metrics.ED_error ./ ED_real) * 100;
    error_metrics.ENN_MN_re_error = (error_metrics.ENN_MN_error ./ ENN_MN_real) * 100;
    error_metrics.SHDI_re_error = (error_metrics.SHDI_error ./ SHDI_real) * 100;

    % 计算均方根误差（RMSE）
        
    %error_metrics.RMSE = sqrt(mean([error_metrics.PD_re_error.^2, ...
                                    %error_metrics.Area_MN_re_error.^2, ...
                                    %error_metrics.TE_re_error.^2, ...
                                    %error_metrics.LPI_re_error.^2, ...
                                    %error_metrics.LSI_re_error.^2, ...
                                    %error_metrics.SHAPE_MN_re_error.^2, ...
                                    %error_metrics.AI_re_error.^2, ...
                                    %error_metrics.ED_re_error.^2, ...
                                    %error_metrics.ENN_MN_re_error.^2, ...
                                    %error_metrics.SHDI_re_error.^2])) / 100;

error_metrics.RMSE = sqrt(mean([error_metrics.PD_re_error.^2, ...
                                    error_metrics.Area_MN_re_error.^2, ...
                                    error_metrics.LPI_re_error.^2, ...
                                    error_metrics.LSI_re_error.^2, ...
                                    error_metrics.ED_re_error.^2])) / 100;

    % 所有相对误差的加总
    %error_metrics.total_error = sum([error_metrics.PD_re_error, ...
     %                           error_metrics.Area_MN_re_error, ...
      %                          error_metrics.TE_re_error, ...
       %                         error_metrics.LPI_re_error, ...
        %                        error_metrics.LSI_re_error, ...
         %                       error_metrics.SHAPE_MN_re_error]);
   
     error_metrics.total_error = sum([error_metrics.PD_re_error, ...
                                     error_metrics.Area_MN_re_error, ...
                                     error_metrics.TE_re_error, ...
                                     error_metrics.LPI_re_error, ...
                                     error_metrics.LSI_re_error, ...
                                     error_metrics.SHAPE_MN_re_error, ...
                                     error_metrics.AI_re_error, ...
                                     error_metrics.ED_re_error, ...
                                     error_metrics.ENN_MN_re_error, ...
                                     error_metrics.SHDI_re_error]);
    
    error_metrics.PDtotalre_error = sum([error_metrics.PD_re_error
                                         ])/100;

    error_metrics.AREAMNtotalre_error = sum([error_metrics.Area_MN_re_error
                                         ])/100;

    error_metrics.LPItotalre_error = sum([error_metrics.LPI_re_error
                                         ])/100;

    error_metrics.LSItotalre_error = sum([error_metrics.LSI_re_error, ...
                                         ])/100;

    error_metrics.EDtotalre_error = sum([error_metrics.ED_re_error, ...
                                         ])/100;

    error_metrics.AItotalre_error = sum([error_metrics.AI_re_error, ...
                                         ])/100;

    error_metrics.SHDItotalre_error = sum([error_metrics.SHDI_re_error, ...
                                         ])/100;

    error_metrics.ENNMNtotalre_error = sum([error_metrics.ENN_MN_re_error, ...
                                         ])/100;

    error_metrics.TEtotalre_error = sum([error_metrics.TE_re_error, ...
                                         ])/100;

    n = 4;
    error_metrics.normalized_error = error_metrics.total_error / (10 * n);
    % 计算每个类别的均方误差（MSE）
    %error_metrics.MSE_per_category = struct();
    %for i = 1:6
        %error_metrics.MSE_per_category(i).NP = mean((NP_sim(i) - NP_real(i))^2);
        %error_metrics.MSE_per_category(i).PD = mean((PD_sim(i) - PD_real(i))^2);
        %error_metrics.MSE_per_category(i).Area_MN = mean((Area_MN_sim(i) - Area_MN_real(i))^2);
        %error_metrics.MSE_per_category(i).TE = mean((TE_sim(i) - TE_real(i))^2);
        %error_metrics.MSE_per_category(i).LPI = mean((LPI_sim(i) - LPI_real(i))^2);
        %error_metrics.MSE_per_category(i).LSI = mean((LSI_sim(i) - LSI_real(i))^2);
        %error_metrics.MSE_per_category(i).SHAPE_MN = mean((SHAPE_MN_sim(i) - SHAPE_MN_real(i))^2);
    %end
    
    % 可视化误差
    %figure;
    %subplot(2, 2, 1);
    %bar([NP_sim; NP_real]', 'grouped');
    %title('NP Comparison');
    
    %subplot(2, 2, 2);
    %bar([PD_sim; PD_real]', 'grouped');
    %title('PD Comparison');
    
    %subplot(2, 2, 3);
    %bar([Area_MN_sim; Area_MN_real]', 'grouped');
    %title('Area_MN Comparison');
    
    %subplot(2, 2, 4);
    %bar([LPI_sim; LPI_real]', 'grouped');
    %title('LPI Comparison');
end

function [FoM, RMSE]=CA2(markovMatrix)

tic
iters=10;           %迭代次数为40次
circle=5; repi=1;%,大循环2次
tiffpath = 'E:\model\CAGA\LuoyangCA\land_use_data&spatial_driving_factors\';   %指定文件路径
startdata_name=[tiffpath 'L2018.tif']; %%%初期数据的文件名
enddata_name=[tiffpath 'L2020.tif'];
ref_filename='L2018.tif';
[~,ref]=readgeoraster([tiffpath ref_filename]);
info=geotiffinfo([tiffpath ref_filename]);    %此处的ref为空间参考的对象（判断其为地理坐标系还是投影坐标系）；info是具体的空间参考信息（具体的地理坐标系或投影坐标系信息）。
posname1 = [tiffpath 'LYJclass1.tif'];    
posname2 = [tiffpath 'LYJclass2.tif']; 
posname3 = [tiffpath 'LYJclass3.tif']; 
posname4 = [tiffpath 'LYJclass4.tif']; %%%林地适宜性数据的文件名
%posname5 = [tiffpath 'WHclass5.tif']; %%%林地适宜性数据的文件名
%posname6 = [tiffpath 'WHclass6.tif']; %%%未利用地适宜性数据的文件名
%resultdata_name=[tiffpath 'PRD2020index'];     %tiffpath与后面的字符串中间为空格或逗号都行，表示连接
startdata=double(imread(startdata_name));
enddata=double(imread(enddata_name));
pos1 = double(imread(posname1));%不透水面开发适宜性
pos2 = double(imread(posname2));%耕地土地开发适宜性
pos3 = double(imread(posname3));
pos4 = double(imread(posname4));%不透水面开发适宜性
%pos5 = double(imread(posname5));%耕地土地开发适宜性
%pos6 = double(imread(posname6));
simudata = startdata;
water=enddata;
water(water==255 | water==4  | water==15)=0;   water(water==1 | water==2 | water==3)=1;
water2=enddata;
water2(enddata==255 |enddata==-128)=0; water2(enddata==1 |enddata==2 | enddata==3 |enddata==4)=1;
transitionMatrix = markovMatrix;
%transitionMatrix = [0.3956, 0.0187, 0.0027, 0.5830;
 %                   0.0106, 0.4809, 0.0020, 0.5065;
   %                 0.0021, 0.0872, 0.4060, 0.5048;
     %               0.5248, 0.1300, 0.1311, 0.2141;]; %优化后Markov矩阵

%transitionMatrix = [0.9757, 0.0201, 0.0041, 0.0001;
 %                   0.1045, 0.7634, 0.1319, 0.0001;
  %                  0.0011, 0.2667, 0.7287, 0.0033;
   %                 0.0001, 0.0075, 0.4258, 0.5665;]; %2018-2020原始Markov矩阵

for clcc=1:circle
    if clcc==1
        start=sum(sum(startdata == 1));
    elseif clcc>1
        start=sum(sum(startdata1 == 1));
    end
    endda=sum(sum(enddata == 1));
    num_growp=endda-start;    iter_grow=round(num_growp/iters);  %(末期城市元胞数-基期)/迭代次数=每次迭代增长的元胞数，round为四舍五入到最近的整数。
    if num_growp >=0
       % for repi = 1:rep 
            iteration = 1;
            if clcc==1
                simudata = startdata;    %每次都要重置simudata，否则是重复对同一张startdata进行迭代，会导致城市元胞数量溢出。
            elseif clcc>1
                simudata=startdata1;
            end
            nsize=3;
            markov = applyMarkovModel(transitionMatrix,simudata,1);
            while iteration < iters
                iteration = iteration+1;
                neighmat = ORNE1(simudata,nsize,1);    %用中心元素为0，其余元素为1的7×7核与模拟起始数据进行卷积（相当于滤波），代替"遍历邻域”的循环操作，得到邻域影响
                suit = simudata; suit(suit==1) = 0;
                suit(suit~=0) = 1;
                %P = neighmat.*pos1.*suit.*water2.*markov;
                P = neighmat.*pos1.*suit.*water.*markov;%.*jinzhi_E;%.*final_layer1;   %  ".*"为矩阵元素对应相乘，"*"为矩阵相乘
                simudata=SHOLD(P,iter_grow,simudata,1);
                if iteration == iters        %最后一次迭代
                    neighmat = ORNE1(simudata,nsize,1);
                    suit = simudata;suit(suit~=1) = 1; suit(suit==1) = 0;
                   % P = neighmat.*pos1.*suit.*water2.*markov;
                    P = neighmat.*pos1.*suit.*water.*markov;
                     if sum(sum(endda == 1)) > sum(sum(simudata ==1))
                    simudata=SHOLD1(P,endda,simudata,1);
                     end
                end
            end
    end
    startdata1=simudata;
    start=sum(sum(startdata1 == 2));
    endda=sum(sum(enddata == 2));
    num_growl=endda-start;     iter_grow=round(num_growl/iters);  %(末期元胞数-基期)/迭代次数=每次迭代增长的元胞数，round为四舍五入到最近的整数。 
    if num_growl>=0
        nsize=3;
            iteration = 1;  simudata = startdata1;    %每次都要重置simudata，否则是重复对同一张startdata进行迭代，会导致城市元胞数量溢出。
            markov = applyMarkovModel(transitionMatrix,simudata,2);
            while iteration < iters
                iteration = iteration+1;
                neighmat = ORNE1(simudata,nsize,2);    %用中心元素为0，其余元素为1的7×7核与模拟起始数据进行卷积（相当于滤波），代替"遍历邻域”的循环操作，得到邻域影响
                suit = simudata; suit(suit~=2) = 1;suit(suit==2) = 0;
               % P = neighmat.*pos2.*suit.*water2.*markov;
                P = neighmat.*pos2.*suit.*water.*markov;%.*  %  ".*"为矩阵元素对应相乘，"*"为矩阵相乘
                simudata=SHOLD(P,iter_grow,simudata,2);
                if iteration == iters        %最后一次迭代
                    neighmat = ORNE1(simudata,nsize,2);
                    suit = simudata;suit(suit~=2) = 1;suit(suit==2) = 0;
                   % P = neighmat.*pos2.*suit.*water2.*markov;
                    P = neighmat.*pos2.*suit.*water.*markov;%.*jinzhi.*yunxu;%.*final_layer4;
                     if sum(sum(endda == 2)) > sum(sum(simudata ==2))
                    simudata=SHOLD1(P,endda,simudata,2);
                     end
                end
            end
            
    end
    startdata1=simudata;
    start=sum(sum(startdata1 == 3));
    endda=sum(sum(enddata == 3));
    num_growe=endda-start;    iter_grow=round(num_growe/iters);  %(末期城市元胞数-基期)/迭代次数=每次迭代增长的元胞数，round为四舍五入到最近的整数。
    
    if num_growe >=0
            iteration = 1;  simudata = startdata1;    %每次都要重置simudata，否则是重复对同一张startdata进行迭代，会导致城市元胞数量溢出。
            nsize=3;
            markov = applyMarkovModel(transitionMatrix,simudata,3);
            while iteration < iters
                %disp(['总迭代次数为： ',num2str(iters),'次','；现在是第 ',num2str(iteration),' 次']);
                iteration = iteration+1;
                neighmat = ORNE1(simudata,nsize,3);    %用中心元素为0，其余元素为1的7×7核与模拟起始数据进行卷积（相当于滤波），代替"遍历邻域”的循环操作，得到邻域影响
                suit = simudata; suit(suit~=3) = 1;suit(suit==3) = 0;
                %P = neighmat.*pos3.*suit.*water2.*markov;
                P = neighmat.*pos3.*suit.*water.*markov;
                simudata=SHOLD(P,iter_grow,simudata,3);
                if iteration == iters        %最后一次迭代
                    neighmat = ORNE1(simudata,nsize,3);
                    suit = simudata;suit(suit~=3) = 1;suit(suit==3) = 0;
                    %P = neighmat.*pos3.*suit.*water2.*markov;
                    P = neighmat.*pos3.*suit.*water.*markov;%.*jinzhi_E;%.*final_layer4;
                    if sum(sum(endda == 3)) > sum(sum(simudata ==3))
                    simudata=SHOLD1(P,endda,simudata,3);
                    end
                end
            end
    end
    startdata1=simudata;
    start=sum(sum(startdata1 == 4));
    endda=sum(sum(enddata == 4));
    num_growl=endda-start;     iter_grow=round(num_growl/iters);  %(末期元胞数-基期)/迭代次数=每次迭代增长的元胞数，round为四舍五入到最近的整数。 
    if num_growl>=0
        nsize=3;
            iteration = 1;  simudata = startdata1;    %每次都要重置simudata，否则是重复对同一张startdata进行迭代，会导致城市元胞数量溢出。
            markov = applyMarkovModel2(transitionMatrix,simudata,4);
            while iteration < iters
                iteration = iteration+1;
                neighmat = ORNE1(simudata,nsize,4);    %用中心元素为0，其余元素为1的7×7核与模拟起始数据进行卷积（相当于滤波），代替"遍历邻域”的循环操作，得到邻域影响
                suit = simudata; suit(suit~=4) = 1;suit(suit==4) = 0;
                %P = neighmat.*pos4.*suit.*water2.*markov;
                P = neighmat.*pos4.*suit.*water2.*markov;
                simudata=SHOLD(P,iter_grow,simudata,4);
                if iteration == iters        %最后一次迭代
                    neighmat = ORNE1(simudata,nsize,4);
                    suit = simudata;  suit(suit~=4) = 1;suit(suit==4) = 0;
                    %P = neighmat.*pos4.*suit.*water2.*markov;
                    P = neighmat.*pos4.*suit.*water2.*markov;
                     if sum(sum(endda == 4)) > sum(sum(simudata ==4))
                    simudata=SHOLD1(P,endda,simudata,4);
                     end
                end
            end
    end
    

        disp(['The time for CA：',num2str(toc),' s.']);
end
Aresult = Allacc_multi(startdata,enddata,simudata);
FoM=Aresult.FoM;
error_metrics = landscapecompare(simudata, enddata);
RMSE = error_metrics.RMSE;

% 保存模拟结果为TIF文件
resultdata_name = 'E:\model\CAGA\LuoyangCA\simulation_codes&results\results\CA_result_'; % 自定义结果文件名
output_filename = [resultdata_name '2022testLEsimudata_iter' num2str(clcc) '.tif'];  % 保存文件名
geotiffwrite(output_filename, simudata, ref, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
disp(['GeoTIFF result saved at: ', output_filename]);

end
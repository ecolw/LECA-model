%%  制作土地利用变化图层并输出
%！！！注意！！！该处的末期数据应是：模拟基期和模拟末期两期土地利用数据中的城市用地取并集得到的末期数据（因为城市扩展CA的基本假设条件即城市用地无法转换为其他地类，不存在城市收缩情况,如用实际分类图，会影响Allacc代码中的FoM精度计算结果）
tic;
clc;clear;
%254是水，130是建设用地，191为其他，255为背景值。（图像以二维矩阵形式存储，缺值的地方即为背景值）
tiffpath = 'G:\CLCD_final\';    %指定文件的路径，用字符串的形式存储。字符串'a'、'b'的连接可以直接[a b]或[a,b]；中括号中间空格或逗号均可。
ref_filename='crop2015.tif';     %以基期数据为参照（一般所有用于输入的数据都会统一空间参考，所以选其一即可），获取其空间参考信息，用于图像输出。
[~,ref]=readgeoraster([tiffpath ref_filename]);    info=geotiffinfo([tiffpath ref_filename]); %此处的ref为空间参考的对象（判断其为地理坐标系还是投影坐标系）；info是具体的空间参考信息（具体的地理坐标系或投影坐标系信息）。

data1=imread([tiffpath 'water2015.tif']);  %double为把数组向外扩，避免索引超限。
data2=imread([tiffpath 'water2020.tif']);

%数据导入也可以用下列方式进行：
%data1=importdata('C:\Users\li\Desktop\logitdata\bj2000.txt');
%data2=importdata('C:\Users\li\Desktop\logitdata\bj2020.txt');
%txt数据输入和导出没有直接对图像操作快捷。且数据输出txt格式时需要for循环，效率较低；输出后，还要加上原始栅格数据导出为txt文件后的表头，否则在arcgis中进行ASCII转栅格时，会出现无法识别添加数据的问题。

    %data1(data1==1)=1;
   % data1(data1==0)=0;
    data2(data2==1)=10;
    data2(data2==0)=8;
    change=data2-data1;  %制作土地利用变化图层；
    change(change==10)=3; change(change==8 | change==9)=2; change(change==7)=1; change(change==0)=254;     %3表示新增，2表示不变，1表示减少，背景值设为255
    %change(change==17 | change==18 | change==19)=3;       %水体设为3
    %change(change==27 | change==28 | change==29)=0;       %非城市区域设为0
disp(['制作土地利用变化图层用时为：',num2str(toc),' s.']);

%输出：
%geotiffwrite([tiffpath 'change.tif'],change,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag); %GeoKeyDirectoryTag由指定 GeoTIFF 坐标参考系和元信息的结构组成。即info中的最核心部分，只需指定该部分即可。


%%  随机采样并输出带标记的样本点
tic;
grow_sample_num=5000;   orther_sample_num=5000;% decrea_sample_num=0;      %指定新增城市区域和其他不变区域的总采样数量(包括训练集和测试集)

[m1,n1]=find(change==3);    %找出新增城市元胞的行列号；
growthnum=numel(m1);       %计算新增城市元胞的数量；(行号数量=列号数量=元胞数量)
    randnum1=randperm(growthnum,grow_sample_num);    %在新增城市元胞数量范围内，采样多少就生成多少个随机数，随机数中没有重复值
    growsample_row_col=[m1(randnum1),n1(randnum1)];   %以随机数为行列号，抽取新增城市区域样本；此时growsample_row_col中存储的是样本点在change图中的行列号。
    
%   [m2,n2]=find(change==1);
%     decreathnum=numel(m2);
%      randnum2=randperm(decreathnum,decrea_sample_num);
%     decreasample_row_col=[m2(randnum2),n2(randnum2)];
    
    
[m3,n3]=find(change==2);
nochangenum=numel(m3);
    randnum3=randperm(nochangenum,orther_sample_num);
    orthersample_row_col=[m3(randnum3),n3(randnum3)];   %抽取非新增城市区域样本的行列号

growth_idx=sub2ind(size(change),growsample_row_col(:,1),growsample_row_col(:,2));  %在change矩阵中指定growsample_row_col中所存储的两列数值（即样本点的行列号）分别行下标和列下标，并将下标转换为线性索引。
change(growth_idx)=101;     %使用线性索引在change图中找到新增城市元胞样本点的具体位置。（此处将其修改为特殊值101,以标记样本点所在位置，便于后面在此基础上划分训练集和测试集）
orther_idx=sub2ind(size(change),orthersample_row_col(:,1),orthersample_row_col(:,2));
change(orther_idx)=100;
% decrea_idx=sub2ind(size(change),decreasample_row_col(:,1),decreasample_row_col(:,2));
% change(decrea_idx)=99;
disp(['随机采样用时为：',num2str(toc),' s.']);
%txt_asc_output('change_sample',change);




%  把样本集划分为训练集和测试集
%test_growsample_num=1;   test_orthersample_num=1; % test_decreasample_num=0; %测试集样本数量设为1000，为样本总数的20%
    %test_randnum1=randperm(grow_sample_num,test_growsample_num);   %在新增城市元胞总样本数量范围内生成测试集数量个随机数
    growsample_row=growsample_row_col(:,1); growsample_col=growsample_row_col(:,2);
    %test_growsample_row_col=[growsample_row(test_randnum1),growsample_col(test_randnum1)];  %以随机数为行列号，抽取新增城市区域测试集样本；此时test_growsample_row_col中存储的是测试集样本点在change图中的行列号。
    %test_growsample_idx=sub2ind(size(change),test_growsample_row_col(:,1),test_growsample_row_col(:,2));
    %change(test_growsample_idx)=1001;   %把总新增城市元胞样本点中的测试集样本点的值标注为1001，那么剩余的101值就是新增城市元胞训练集样本点。
    
    %test_randnum2=randperm(orther_sample_num,test_orthersample_num);
    orthersample_row=orthersample_row_col(:,1); orthersample_col=orthersample_row_col(:,2);
    %test_orthersample_row_col=[orthersample_row(test_randnum2),orthersample_col(test_randnum2)];
    %test_orthersample_idx=sub2ind(size(change),test_orthersample_row_col(:,1),test_orthersample_row_col(:,2));
    %change(test_orthersample_idx)=1000; %把总其他不变区域元胞样本点中的测试集样本点的值标注为1000，那么剩余的100值就是其他不变区域元胞训练集样本点。
    
%     test_randnum3=randperm(decrea_sample_num,test_decreasample_num);
%     decreasample_row=decreasample_row_col(:,1); decreasample_col=decreasample_row_col(:,2);
%     test_decreasample_row_col=[decreasample_row(test_randnum3),decreasample_col(test_randnum3)];
%     test_decreasample_idx=sub2ind(size(change),test_decreasample_row_col(:,1),test_decreasample_row_col(:,2));
%     change(test_decreasample_idx)=999; %把总减少区域元胞样本点中的测试集样本点的值标注为999，那么剩余的99值就是其他不变区域元胞训练集样本点。
%     
[train_growsample_m,train_growsample_n]=find(change==101);  train_growsample_row_col=[train_growsample_m,train_growsample_n];   %找出新增城市元胞训练集样本点在change图中的行列号
[train_orthersample_m,train_orthersample_n]=find(change==100);  train_orthersample_row_col=[train_orthersample_m,train_orthersample_n]; %找出其他不变区域元胞训练集样本点在change图中的行列号
%[train_decreasample_m,train_decreasample_n]=find(change==99);  train_decreasample_row_col=[train_decreasample_m,train_decreasample_n]; %找出减少区域元胞训练集样本点在change图中的行列号
%%  把驱动因子信息提取至采样点并输出
tic;
total_num_factor =8 ;      %驱动因子总数为12,根据驱动因子数量来改，命名规则需要统一
factorname=string(zeros(1,total_num_factor));    %创建字符串数组，存放驱动因子的路径
    for i=1:total_num_factor
        factorname(i)=tiffpath+"fac"+i+".tif";
    end
[fac_row,fac_col]=size(imread(factorname(1)));      %获取驱动因子图大小
factor=zeros(fac_row,fac_col);   %预分配内存
    for i=1:total_num_factor
        factor(:,:,i)=imread(factorname(i)); %创建三维数组，存放驱动因子信息。一、二维度是驱动因子栅格图值所对应的行列号，第三维度是驱动因子编号。double为把数组向外扩，避免索引超限（一般读取tif要进行此操作）。
    end
%   --------------------------------------------------------------------------------------------
%   前面是提取所有位置的驱动因子信息，下面开始提取样本点的驱动因子信息(分训练集和测试集分别提取)
%   --------------------------------------------------------------------------------------------
train_growth_factor_num=numel(train_growsample_row_col(:,1));    %统计所抽取的新增城市元胞区域的训练集样本数量，对于驱动因子三维数组来说，建立多维索引需要对第三维（即索引除了一、二维指定行列号外，还要第三维指定页码）进行页码限定。
train_growth_factor=ones(train_growth_factor_num,total_num_factor+3);       %创建15列值为1的数组存放行列号、12个驱动因子信息和1个因变量（值为1，代表新增城市元胞）信息。预分配内存。
train_growth_factor(:,1)=train_growsample_row_col(:,1); train_growth_factor(:,2)=train_growsample_row_col(:,2); %把行列号提取至样本点的第一二列，便于后期在概率图中找到对应的预测概率值与真实标签(因变量)比较，计算精度
train_page_growth=zeros(train_growth_factor_num,total_num_factor);
    for i=1:total_num_factor
        train_page_growth(:,i)=i;      %建立一个行数为样本数量，列数为12（驱动因子数量）的数组；每一列的值都相等，等于列的编号。（1-12表示分别从12张驱动因子图中指定页码，选出位于训练集样本位置的点；换句话说，每个样本点拥有12个驱动因子信息）。
        train_growth_factor_idx=sub2ind(size(factor),train_growsample_row_col(:,1),train_growsample_row_col(:,2),train_page_growth(:,i));  %建立三维索引
        train_growth_factor(:,i+2)=factor(train_growth_factor_idx);   %建立二维数组按列存放训练集样本点的驱动因子信息,共（train_growth_factor_num×12）个值，前两列为行列号，第三列的值为第一个驱动因子信息，第四列为第二个驱动因子信息，以此类推。
    end
    
train_orther_factor_num=numel(train_orthersample_row_col(:,1));       %train_orthersample_row_col(:,1)表示其他区域训练集样本行列号数组的第一列，即行号；又因为列号数量与行号数量相同，因此只取其一。
train_orther_factor=zeros(train_orther_factor_num,total_num_factor+3);      %创建15列值为0的数组存放行列号、12个驱动因子信息和1个因变量（值为0，代表没有转换为城市用地的元胞）信息。预分配内存。
train_orther_factor(:,1)=train_orthersample_row_col(:,1); train_orther_factor(:,2)=train_orthersample_row_col(:,2); %把行列号提取至样本点的第一二列，便于后期在概率图中找到对应的预测概率值与真实标签(因变量)比较，计算精度
train_page_orther=zeros(train_orther_factor_num,total_num_factor);
    for i=1:total_num_factor
        train_page_orther(:,i)=i;      %建立一个行数为样本数量，列数为12（驱动因子数量）的数组；每一列的值都相等，等于列的编号。（1-12表示分别从12张驱动因子图中指定页码，选出位于训练集样本位置的点；换句话说，每个样本点拥有12个驱动因子信息）。
        train_orther_factor_idx=sub2ind(size(factor),train_orthersample_row_col(:,1),train_orthersample_row_col(:,2),train_page_orther(:,i));
        train_orther_factor(:,i+2)=factor(train_orther_factor_idx);    %建立二维数组按列存放训练集样本点的驱动因子信息,共（train_orther_factor_num×12）个值，前两列为行列号，第三列的值为第一个驱动因子信息，第四列为第二个驱动因子信息，以此类推。
    end
    
%     train_decrea_factor_num=numel(train_decreasample_row_col(:,1));       %train_decreasample_row_col(:,1)表示其他区域训练集样本行列号数组的第一列，即行号；又因为列号数量与行号数量相同，因此只取其一。
% train_decrea_factor=ones(train_decrea_factor_num,total_num_factor+3)*(0.5);      %创建15列值为0的数组存放行列号、12个驱动因子信息和1个因变量（值为0，代表没有转换为城市用地的元胞）信息。预分配内存。
% train_decrea_factor(:,1)=train_decreasample_row_col(:,1); train_decrea_factor(:,2)=train_decreasample_row_col(:,2); %把行列号提取至样本点的第一二列，便于后期在概率图中找到对应的预测概率值与真实标签(因变量)比较，计算精度
% train_page_decrea=zeros(train_decrea_factor_num,total_num_factor);
%     for i=1:total_num_factor
%         train_page_decrea(:,i)=i;      %建立一个行数为样本数量，列数为12（驱动因子数量）的数组；每一列的值都相等，等于列的编号。（1-12表示分别从12张驱动因子图中指定页码，选出位于训练集样本位置的点；换句话说，每个样本点拥有12个驱动因子信息）。
%         train_decrea_factor_idx=sub2ind(size(factor),train_decreasample_row_col(:,1),train_decreasample_row_col(:,2),train_page_decrea(:,i));
%         train_decrea_factor(:,i+2)=factor(train_decrea_factor_idx);    %建立二维数组按列存放训练集样本点的驱动因子信息,共（train_orther_factor_num×12）个值，前两列为行列号，第三列的值为第一个驱动因子信息，第四列为第二个驱动因子信息，以此类推。
%     end
    
%下面是测试集样本点的驱动因子信息提取
% test_growth_factor_num=numel(test_growsample_row_col(:,1));
% test_growth_factor=ones(test_growth_factor_num,total_num_factor+3);
% test_growth_factor(:,1)=test_growsample_row_col(:,1); test_growth_factor(:,2)=test_growsample_row_col(:,2);
% test_page_growth=zeros(test_growth_factor_num,total_num_factor);
%     for i=1:total_num_factor
%         test_page_growth(:,i)=i;
%         test_growth_factor_idx=sub2ind(size(factor),test_growsample_row_col(:,1),test_growsample_row_col(:,2),test_page_growth(:,i));
%         test_growth_factor(:,i+2)=factor(test_growth_factor_idx);
%     end
%     
% test_orther_factor_num=numel(test_orthersample_row_col(:,1));
% test_orther_factor=zeros(test_orther_factor_num,total_num_factor+3);
% test_orther_factor(:,1)=test_orthersample_row_col(:,1); test_orther_factor(:,2)=test_orthersample_row_col(:,2);
% test_page_orther=zeros(test_orther_factor_num,total_num_factor);
%     for i=1:total_num_factor
%         test_page_orther(:,i)=i;
%         test_orther_factor_idx=sub2ind(size(factor),test_orthersample_row_col(:,1),test_orthersample_row_col(:,2),test_page_orther(:,i));
%         test_orther_factor(:,i+2)=factor(test_orther_factor_idx);
%     end
    
%   test_decrea_factor_num=numel(test_decreasample_row_col(:,1));
% test_decrea_factor=ones(test_decrea_factor_num,total_num_factor+3)*(0.5);
% test_decrea_factor(:,1)=test_decreasample_row_col(:,1); test_decrea_factor(:,2)=test_decreasample_row_col(:,2);
% test_page_decrea=zeros(test_decrea_factor_num,total_num_factor);
%     for i=1:total_num_factor
%         test_page_decrea(:,i)=i;
%         test_decrea_factor_idx=sub2ind(size(factor),test_decreasample_row_col(:,1),test_decreasample_row_col(:,2),test_page_decrea(:,i));
%         test_decrea_factor(:,i+2)=factor(test_decrea_factor_idx);
%     end  

trainset=[train_growth_factor;train_orther_factor];     %将新增城市元胞训练集样本矩阵和其他训练集样本矩阵上下合并为一个训练样本大矩阵。(逗号[ , ]为左右合并，分号[ ; ]为上下合并)
%testset=[test_growth_factor;test_orther_factor];        %将测试集矩阵也合并
writematrix(trainset,[tiffpath 'trainset(water.xlsx']);    %将训练集矩阵写入输出文件
%writematrix(testset,[tiffpath 'testset(crop).xlsx']);    %将测试集矩阵写入输出文件
%all_set=[train_growth_factor;test_growth_factor;train_orther_factor;test_orther_factor]
%如果不划分训练集和测试集，则可以合并整体输出为一个大的训练集all_set
%save change    %把所有数据存为.mat格式(当前目录下)，以便后期调用，避免反复重新采样而导致的样本不一致问题。但由于factor变量超出了2GB，无法保存，后续需要使用则还要重新引入
disp(['把驱动因子信息提取至采样点用时为：',num2str(toc),' s.']);

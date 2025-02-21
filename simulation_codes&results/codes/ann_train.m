clc;clear;
time=datestr(now,31); disp(time); rep=10; count = 1000;
tiffpath = 'H:\new\CLCD_final\';
ref_filename='fac1.tif';     %以基期数据为参照（一般所有用于输入的数据都会统一空间参考，所以选其一即可），获取其空间参考信息，用于图像输出。
[~,ref]=readgeoraster([tiffpath ref_filename]);   
info=geotiffinfo([tiffpath ref_filename]);    %此处的ref为空间参考的对象（判断其为地理坐标系还是投影坐标系）；info是具体的空间参考信息（具体的地理坐标系或投影坐标系信息）。
total_num_factor = 8;      %驱动因子总数为8
trainset = readmatrix([tiffpath 'trainset(water).xlsx']);  %从文件中读取矩阵元素
train_y=trainset(:,total_num_factor+3);   train_x=trainset(:,3:total_num_factor+2);     %采样点肯定不含背景值元胞，因此可直接转置后用于网络训练

%% 提取所有驱动因子，并把元胞平铺，行号为元胞的编号，列号为驱动因子编号
factorname=string(zeros(1,total_num_factor));    %创建字符串数组，存放驱动因子的路径
    for i=1:total_num_factor
        factorname(i)=tiffpath+"fac"+i+".tif";
    end
[fac_row,fac_col]=size(imread(factorname(1)));      %获取驱动因子图大小
factor=zeros(fac_row,fac_col);
feature_all=zeros(fac_row*fac_col,total_num_factor);      %把m×n个元胞(12张图)按照其元素编号，拉成m×n行，12列的数组，每一列存放一个驱动因子信息。以便后续有序地导入训练好的神经网络中计算预测值(因为训练网络时，是以样本点及其驱动因子信息训练的)
    for i=1:total_num_factor
        factor(:,:,i)=double(imread(factorname(i)));       %创建三维数组，存放驱动因子信息。一、二维度是驱动因子栅格图值所对应的行列号，第三维度是驱动因子编号。double为把数组向外扩，避免索引超限（一般读取tif要进行此操作）。
        feature_all(:,i) = reshape(factor(:,:,i),fac_row * fac_col,1);      %matlab对元素的编号是竖向的，从上到下，从左到右，因此把m×n矩阵拉成一列时，是把第n+1列放到第n列的末尾(得到m×n行，1列的数组)才不会改变元素的编号顺序，而reshape函数即可实现.此时feature_all含背景值255
    end
datasize = size(feature_all);   num = datasize(1);   every_count = round(num/count);   feature_input = feature_all';
clear factor factorname fac_row fac_col feature_all datasize num

%% ANN Cycle Preparation
t1=clock; overall_ANNRMSEMatrix=[]; val_ANNRMSEMatrix=[]; test_ANNRMSEMatrix=[];
relativeImp = zeros(total_num_factor,rep);  %total_num_factor个驱动因子，所以有total_num_factor行；训练rep次，得到rep列相对重要性值（相对权重），对每一行求平均即可得到平均相对重要性。此时预分配内存。
for repi=1:rep
    %% ANN define      Param在相应的函数帮助文档中查找说明，如trainParam在trainlm里有说明
    feature=train_x';    %把驱动因子矩阵转置，行号为驱动因子名称，列号为元胞编号
    label=train_y';      %把驱动因子矩阵转置，只有一行，用于判断是否为城市元胞，值为1或者0，列号为元胞编号
    trainFcn='trainlm';  %训练函数为'trainlm',输入命令help nntrain即可查看函数选择
    hiddenLayerSize = [20,20,20]; %行向量，隐藏层有三层，大小都是十五个神经元
    ANNnet=fitnet(hiddenLayerSize,trainFcn); %函数拟合神经网络
    ANNnet.input.processFcns={'removeconstantrows'}; %定义输入值在进入网络之前的处理函数，'removeconstantrows'为删除带有常数值的矩阵行,如果有一行值是相同的，那么该驱动因子的所有元胞值相同，没有训练意义。(其实默认输入输出处理函数即为removeconstantrows，不用特别指定)
    ANNnet.output.processFcns={'removeconstantrows'}; %定义层输出值在作为网络输出值返回之前，所要经历的处理函数，'removeconstantrows'为删除带有常数值的矩阵行。输入help nnprocess命令即可查看处理函数选择
    ANNnet.divideFcn='dividerand'; %使用随机索引将目标分成三个集合:训练，验证和测试。
    ANNnet.divideMode='sample';  %定义当调用数据划分函数时要划分的目标数据维度。对于静态网络，其默认值为 'sample'
    ANNnet.divideParam.trainRatio=0.7; %设置训练比例，相当于练习题（用于学习）    输入help nnParam命令即可查看所有参数
    ANNnet.divideParam.valRatio=0.15; %设置验证比例，相当于测验题（用于调整学习参数，超参数）
    ANNnet.divideParam.testRatio=0.15; %设置测试比例，相当于考试题（用于验证学习效果）
    ANNnet.performFcn='mse';  %定义用于度量网络性能的函数。每当调用 train 时，都会在训练过程中使用性能函数来计算网络性能
    ANNnet.trainParam.epochs=5000; %最大训练（迭代）次数,当达到goal（收敛）时，即停止，所以有可能训练次数小于5000；亦即当达不到goal（不收敛）时，则最多容许5000次训练（注意：epoch设置要在trainFcn之后，否则会产生副作用，即因更新训练函数而更新trainParam，使得epoch被设为默认值1000）
    %ANNnet.trainParam.max_fail=6;  %（最大验证失败次数）的默认值为6，因此无需特别指定。其意义是：在训练时，用training训练，每训练一次，系统自动会将validation set中的样本数据输入神经网络进行验证，在validation set输入后会得出一个误差，连续6次验证检验均不能使其validation误差下降，说明建的网络是能力不能提高了，则训练终止。
    ANNnet.trainParam.goal=0.01; %训练要求精度，全局最小误差（均方差），即所设计的神经网络采用阈值为0.01的均方误差(MSE)作为训练目标。达到训练目标即终止训练。
    ANNnet.plotFcns={'plotperform','plottrainstate','ploterrhist','plotregression','plotfit'};  %输入help nnplot命令即可查看有哪些绘图选择
    %% ANN training
    [ANNnet,tr] = train(ANNnet,feature,label);
    %% ANN train accuracy
    overall_yhat = ANNnet(feature);
    overall_ANNRMSE=sqrt(sum(sum((overall_yhat'-train_y).^2))/size(train_y,1));
    overall_ANNRMSEMatrix=[overall_ANNRMSEMatrix,overall_ANNRMSE];    %训练集的RMSE
    val_yhat = ANNnet(feature(:,tr.valInd));    %tr是用于训练记录的结构数组,valInd为验证集的索引，testInd为测试集的索引，在全体训练数据中使用索引即可找到各个集合的具体值
    val_minus = val_yhat-label(:,tr.valInd);    %因为索引valInd、testInd都为行向量，因此要使用行向量label，而不能用train_y，否则索引超限
    val_ANNRMSE=sqrt(sum(sum((val_minus').^2))/size(val_minus',1));
    val_ANNRMSEMatrix=[val_ANNRMSEMatrix,val_ANNRMSE];   %验证集的RMSE
    test_yhat = ANNnet(feature(:,tr.testInd));
    test_minus = test_yhat-label(:,tr.testInd);
    test_ANNRMSE=sqrt(sum(sum((test_minus').^2))/size(test_minus',1));
    test_ANNRMSEMatrix=[test_ANNRMSEMatrix,test_ANNRMSE];   %测试集的RMSE
    %%  Garson's weight
    input_weight = ANNnet.iw{1,1}';     %获取输入层和隐藏层的连接权值(由于本网络有一个输入层，三个隐藏层，一个输出层，因此输入层到第一个隐藏层的连接权值即第一层(第一隐藏层)对第一层(输入层)的权值，即{1,1}。"iw"表示input weight。输入层与其他层分开表示，其他层表示为lw，重新编号，所以其他层对输入层的权值表示为{n,1}，后面的1表示输入层，n为其他层的位置(n=1表示第一隐藏层，2表示第二隐藏层，...，n表示输出层，一般只看1，后面为空数组)。
    relativeCon = zeros(size(input_weight));
    for c = 1:size(input_weight,2)%size()获取input_wighht的列数,遍历每一列，第二个维度为列。
            for r=1:size(input_weight,1)%size()获取input_weight的行数，遍历每一行,第一个维度为行。
              relativeCon(r,c) = abs(input_weight(r,c))/sum(abs(input_weight(:,c))); %(s,d)对应的权重绝对值/第d列所有权重总和绝对值
            end
    end
          output_weight = ANNnet.lw{4,3};%隐藏层到输出层的连接权值(由于本网络有一个输入层，三个隐藏层，一个输出层，因此隐藏层到输出层的连接权值即第四层（输出层）对第三层（第三隐藏层）的权值，即{4,3}。"lw"表示layer weight，为除去输入层，重新编号的层间权值)
          contribution_in2out = abs(relativeCon.*output_weight(1,:));%relativeCon（s,d）*output_weight第一行
          result = sum(contribution_in2out,2);%result=将contribution_in2out的每一行求和，得到列向量。sum(…,2) 是包含每一行总和的列向量,sum(…,1)是包含每一列总和的行向量
          relativeImp(:,repi) = result./sum(result); % ./表示数组点除。12个驱动因子，所以有12行；训练rep次，得到rep列相对重要性值（相对权重）；训练之后对每一行relativeImp求平均即可得到平均相对重要性。
    %% ANN Model Storage
    saveresultname=[tiffpath,'watersult',num2str(repi),'.mat'];
    eval(['save ',saveresultname,' ANNnet']);
end
%% Train time
timeANNtrain=etime(clock,t1); timeANNtrain=timeANNtrain/rep;
disp(['Time used for ANN training is ',num2str(timeANNtrain),' s.']);
%% Probability map
clear feature
areadata=imread([tiffpath,'water2015.tif']); [m,n]=size(areadata);
t2=clock; predict_yhat=zeros(1,m*n); temppredict_yhat=zeros(1,m*n);
for i = 1:rep
    disp(['正在引用第 ',num2str(i),'个网络...']);
    load([tiffpath,'watersult',num2str(i),'.mat']);
    for j = 1:(count-1)     %分批次放入数据集以得到预测值，避免内存不足的问题
        temppredict=sim(ANNnet,feature_input(:,((j-1)*every_count+1):j*every_count));  %此处temppredict_yhat=sim(ANNnet,feature_all') 与 temppredict_yhat=ANNnet(feature_all') 效果相同，可以使用sim函数
        temppredict_yhat(1,((j-1)*every_count+1):j*every_count) = temppredict;
    end
    temppredict_yhat(1,((count-1)*every_count+1):end) = sim(ANNnet,feature_input(:,((count-1)*every_count+1):end));
%为了保证元胞的相对位置正确，此时的feature_input中包含背景值元胞，即所有驱动因子信息都为255的元胞。后面需要将这部分背景值元胞预测得到的转换概率值重新设置为255
    %temppredict_yhat=sim(ANNnet,feature_input);    %这步是将数据集一下子全放入进行预测(与前五行做替换对比)，一下子全放的效率还没有分批放的效率高
    predict_yhat = predict_yhat + temppredict_yhat;
    %clear ANNnet
end
timeANNproject=etime(clock,t2)/rep; disp(['Time used for ANN projecting is ',num2str(timeANNproject),' s.']);
predict_yhat=predict_yhat/10;
promap=reshape(predict_yhat,m,n);       %把求得的转换概率行向量重新按元素编号顺序转换为m×n的矩阵，此m×n矩阵与原始土地利用数据元胞的位置一一对应
temppro=promap(areadata~=1); minv=min(min(temppro)); maxv=max(max(temppro)); clear temppro
promap=(promap-minv)/(maxv-minv); promap(areadata==1)=1;        %标准化转换概率，并按照原始土地利用数据中背景值元胞所在的位置，在转换概率图中将这部分背景值元胞的转换概率值重新赋值为255
geotiffwrite([tiffpath 'classsw.tif'],promap,ref,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%% Time record
timeANNtrain_project=timeANNtrain + timeANNproject;
disp(['Time used for ANN training and projecting is ',num2str(timeANNtrain_project),' s.']);
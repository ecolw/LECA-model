function   simudata=SHOLD(P,iter_grow,simudata,landuse)

Ptemp = P(P > 0);   %选出概率乘积大于0的部分，此时数组已变为了一列
if sum(sum(Ptemp))<(iter_grow+1)
    P=P+0.1;
Ptemp = P(P>0);
end
        sorting = sort(Ptemp,'descend'); 
        threshold = sorting(iter_grow+1,1);  %降序排列概率值，取每次迭代增长的元胞数的后一个元胞的概率为阈值。
        [threshold_m,threshold_n]=find(sorting==threshold);    num_threshold=numel(threshold_m);    %找出阈值在数组中的个数
        if num_threshold~=1           %如果阈值不唯一，说明：“转换概率=阈值”的元胞有多个，需要进一步分析
            k = numel(simudata(P > threshold));      %计算“转换概率>阈值”的元胞数量
            if k < iter_grow                        %如果“转换概率>阈值”的元胞数量<每次迭代增长的元胞数，说明降序排列时，假设每次迭代500个元胞，可能第400个到第501个元胞的转换概率相同，取第501个元胞作为阈值，会使得实际转换数量只有399个，小于迭代所需数量
                simudata(P > threshold) = landuse;     %此时先把“转换概率>阈值”的元胞数量变为城市元胞
                minus = iter_grow - k;           %然后计算单次迭代数量与“转换概率>阈值”的元胞数量的差值
                random_grow = randperm(num_threshold,minus);      %差minus个，就从所有“转换概率=阈值”的元胞中随机抽取minus个作为新增元胞，补齐单次迭代数量
                [Psame_m,Psame_n] = find(P == threshold);   %从模拟的基期数据中找出所有“转换概率=阈值”的元胞的行列号。simudata(P == threshold)中，"P==threshold"返回的是包含行列号信息的逻辑数组，因此当P与simudata的数组大小相同(元素一一对应)时，可将该行列号信息用作索引条件，找出simudata中相应的值。
                random_grow_row_col = [Psame_m(random_grow),Psame_n(random_grow)];  %从所有“转换概率=阈值”的元胞的行列号选出随机数所指定的行列号
                random_grow_idx = sub2ind(size(simudata),random_grow_row_col(:,1),random_grow_row_col(:,2));       %把行列号转换为索引
                simudata(random_grow_idx) = landuse;                             %修改对应的元胞值为城市元胞
            else
                simudata(P > threshold) = landuse;      %其他情况：即“转换概率>阈值”的元胞数量=每次迭代增长的元胞数，说明阈值不唯一是降序向下的不唯一，不影响转换元胞数
            end
        else
            simudata(P > threshold) = landuse; %如果阈值唯一，那么大于阈值的个数满足单次迭代元胞数量要求，直接将概率大于阈值的元胞设为新增城市元胞
       end
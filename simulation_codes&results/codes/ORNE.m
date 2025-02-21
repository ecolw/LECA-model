function neighmat=ORNE(landmat,ornsize,landuse)
    landmat(landmat~=landuse)=0; landmat(landmat==landuse)=1;     %非城镇值设为0，城镇元胞值为1
    kernelmat=ones(ornsize,ornsize); kernelmat((ornsize+1)/2,(ornsize+1)/2)=0;   %构建中心元素为0，其余元素为1的ornsize×ornsize大小的核
   
    neighmat=conv2(double(landmat),double(kernelmat),'same');     %卷积操作，此处+1是为了模拟飞地，否则邻域中没有城市元胞则概率为0，但不+1精度更高neighmat=1+conv2(double(landmat),double(kernelmat),'same');
    neighmat=neighmat / (ornsize * ornsize - 1);       %计算邻域概率
end

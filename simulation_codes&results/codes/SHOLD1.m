function simudata=SHOLD1(P,endda,simudata,landuse)
Ptemp = P(P > 0);
            yet_grow = sum(sum(simudata == landuse)); last_grow = endda-yet_grow;       %此时simudata == 5返回的是索引，sum索引得到的是个数、数量；若sum(simudata(simudata==5))，则意义完全不同，是对simudata中所有等于5的值进行求和。simudata(simudata==5)返回的是值
            sorting = sort(Ptemp,'descend'); threshold = sorting(last_grow+1,1);
            [threshold_m,threshold_n]=find(sorting==threshold);    num_threshold=numel(threshold_m);
            if num_threshold~=1
                k = numel(simudata(P > threshold));
                if k < last_grow
                    simudata(P > threshold) = landuse;
                    minus = last_grow - k;
                    random_grow = randperm(num_threshold,minus);
                    [Psame_m,Psame_n] = find(P == threshold);
                    random_grow_row_col = [Psame_m(random_grow),Psame_n(random_grow)];
                    random_grow_idx = sub2ind(size(simudata),random_grow_row_col(:,1),random_grow_row_col(:,2));
                    simudata(random_grow_idx) = landuse;
                else
                    simudata(P > threshold) = landuse;
                end   
            else
                simudata(P > threshold) = landuse;
            end
function transition_probabilities = applyMarkovModel2(Markov_matrix, simudata, localtype)
    % 计算每个元胞的转移概率，基于当前的土地利用状态
    [rows, cols] = size(simudata);
    transition_probabilities = zeros(rows, cols);
    
    for i = 1:rows
        for j = 1:cols
            land_type = simudata(i, j);
            if land_type == 255 || land_type == -128
               transition_probabilities(i,j) = 1;
            else
               transition_probabilities(i, j) = Markov_matrix(land_type, localtype);  % 转移到相同类别的概率
            end
        end
    end
end
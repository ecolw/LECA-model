function Aresult = Allacc_multi(startdata, enddata, simudata)
    % ʵ���з����Ԫ����Ŀ
    a1 = sum(sum(enddata == 1)); % ������
    a2 = sum(sum(enddata == 2)); % ����
    a3 = sum(sum(enddata == 3)); % ̲Ϳ
    a4 = sum(sum(enddata == 4)); % ˮ��

    n = a1 + a2 + a3 + a4;

    % ģ���з����Ԫ����Ŀ
    b1 = sum(sum(simudata == 1)); % ������
    b2 = sum(sum(simudata == 2)); % ����
    b3 = sum(sum(simudata == 3)); % ̲Ϳ
    b4 = sum(sum(simudata == 4)); % ˮ��

    % ����Peֵ
    Pe = (a1 * b1 + a2 * b2 + a3 * b3 + a4 * b4) / (n * n);

    % ���������ȷ��Ԫ����Ŀ
    right = sum(sum(enddata == 1 & simudata == 1)) + ...
            sum(sum(enddata == 2 & simudata == 2)) + ...
            sum(sum(enddata == 3 & simudata == 3)) + ...
            sum(sum(enddata == 4 & simudata == 4));

    % ���徫��OA
    Aresult.OA = right / n;

    % Kappaϵ��
    Aresult.Kappa = (Aresult.OA - Pe) / (1 - Pe);

    % ����FoM����ĸ���ָ��
    % ʵ�ʷ����仯��Ԥ��Ϊ����
    A = sum(sum(startdata == simudata & startdata ~= enddata));

    % ʵ�ʷ����仯��Ԥ��Ϊ�仯����ȷ��
    B = sum(sum(startdata ~= enddata & enddata == simudata));

    % ʵ�ʷ����仯��Ԥ��������
    C = sum(sum(startdata ~= enddata & startdata ~= simudata & enddata ~= simudata));

    % ʵ��δ�仯��Ԥ��Ϊ�仯
    D = sum(sum(startdata == enddata & startdata ~= simudata));

    % ����FoM��PA��UA
    Aresult.FoM = B / (A + B + C + D); % ģ�����϶�
    Aresult.PA = B / (A + B + C);      % �����߾���
    Aresult.UA = B / (B + C + D);      % �û�����
end

% 1. Построить математическую модель 3-х звенного манипулятора в представлении
% Денавита-Хартенберга по приведенной графической схеме.

% 2. Добиться повышения точности позиционирования (калибровки) манипулятора путем постановки 
%и последующего решения соответствующей задачи оптимизации на основе предоставленных данных (.zip архив). 
%Провести сравнение точности откалиброванных, номинальных и фактических (указанных в предоставленном файле) 
%параметров геометрии манипулятора. Описать ход работы.

clear
data = load('calib.mat');
q = data.calib.Q; 
T_fact = data.calib.T;

eps =   [0,    0,   0 ];
d =     [300,  0,   0 ]; 
alpha = [pi/2, 0,   0 ]; 
a =     [ 0,  400, 500]; 

X0 = [0,    0,    0, ...
      300,  0,    0, ...
      pi/2, 0,    0, ...
      0,    400, 500];

lb = [-0.01,         -0.01,   -0.01, ...
      d(1)-10,       -10,     -10, ...
      alpha(1)-0.01, -0.01,   -0.01, ...
      -10,           a(2)-10, a(3)-10];
  
ub = [0.01,          0.01,    0.01,...
      d(1)+10,       10,      10,...
      alpha(1)+0.01, 0.01,    0.01,...
      10,            a(2)+10, a(3)+10];

T_nom = kinematics(X0,q);

options = optimoptions('fmincon', 'Display', 'iter');
[DH_calibr, fval] = fmincon(@(X0) fun(T_fact, X0, q), X0, [],[],[],[],lb,ub,[],options);

eps_calib = DH_calibr(1:3)
d_calib = DH_calibr(4:6)
alpha_calib = DH_calibr(7:9)
a_calib = DH_calibr(10:12)

T_calibr = kinematics(DH_calibr, q);

disp('h до калибровки:');
disp(fun(T_fact,X0,q));
disp('h после калибровки:');
disp(fun(T_fact,DH_calibr,q));

function h = fun(T_fact,X,q)
    T = kinematics(X,q);
    h = 0;
    for i = 1:40
        h = h + (norm(T_fact(1:3,4,i) - T{i}(1:3,4)));
    end
end

function T = kinematics(DH, q)

    eps = DH(1:3);
    d = DH(4:6);
    alpha = DH(7:9);
    a = DH(10:12);

    RotZ = cell(1, 3);
    RotX = cell(1, 3);
    TranZ = cell(1, 3);
    TranX = cell(1, 3);
    Ti = cell(1, 3);
    T = cell(1, 40);
    
    for j = 1:40 
        teta = [q(j,1)+eps(1), q(j,2)+eps(2), q(j,3)+eps(3)];

        for i = 1:3
            RotZ{i} = [[cos(teta(i)), -sin(teta(i)), 0,0];
                       [sin(teta(i)),  cos(teta(i)), 0,0];
                       [     0,            0,        1,0];
                       [     0,            0,        0,1]];

            RotX{i} = [[1,      0,             0,        0];
                       [0, cos(alpha(i)), -sin(alpha(i)),0];
                       [0, sin(alpha(i)), cos(alpha(i)), 0];
                       [0,      0,             0,        1]];

            TranZ{i} = [[1,0,0,0];
                        [0,1,0,0];
                        [0,0,1,d(i)];
                        [0,0,0,1]];

            TranX{i} = [[1,0,0,a(i)];
                        [0,1,0,0];
                        [0,0,1,0];
                        [0,0,0,1]];

            Ti{i} = RotZ{i}*TranZ{i}*RotX{i}*TranX{i}; 
        end
        T{j} = Ti{1}*Ti{2}*Ti{3}; 
    end
end
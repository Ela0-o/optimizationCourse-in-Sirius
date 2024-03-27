% Задача 1

% Построить два набора случайных точек на плоскости, используя параметрическую формулу
% x = Xc + ar*cos(ф)cos(a) - br*sin(ф)sin(a)
% y = Yc + ar*cos(ф)sin(a) + br*sin(ф)cos(a), 
% где a, b, α, Хc, Ус - заданные параметры, ф, a  - случайные величины, ф равномерно распределена на интервале [0, 2π],
% r равномеро распределена на интервале [0, 1]. В каждом наборе по 500 точек. 
% Для первого набора использовать параметры a = 3, b = 1, α = 0, Xс = -2, Yc = 1, 
% для второго a = 4, b = 1, α = п/4, Хc = 2, Yс = -1.
% Расчитать и изобразить на рисунке множества и прямую, разделяющую эти множества.
clear

a1 = 3;
b1 = 1;
alpha1 = 0;
xc1 = -2;
yc1 = 1;

a2 = 4;
b2 = 1;
alpha2 = pi/4;
xc2 = 2;
yc2 = -1;

phi = unifrnd(0,pi*2,500,1);
r = unifrnd(0,1,500,1);

x1 = [];
x2 = [];
y1 = [];
y2 = [];

for i = 1:500
    x1 = [x1; xc1 + a1*r(i).*cos(phi(i)).*cos(alpha1) - b1*r(i).*sin(phi(i)).*sin(alpha1)];
    y1 = [y1; yc1 + a1*r(i).*cos(phi(i)).*sin(alpha1) + b1*r(i).*sin(phi(i)).*cos(alpha1)];

    x2 = [x2; xc2 + a2*r(i).*cos(phi(i)).*cos(alpha2) - b2*r(i).*sin(phi(i)).*sin(alpha2)];
    y2 = [y2;yc2 + a2*r(i).*cos(phi(i)).*sin(alpha2) + b2*r(i).*sin(phi(i)).*cos(alpha2)];
end

A1 = [];
A2 = [];
B1 = [];
B2 = [];

for i = 1:500
    A1 = [A1; [ 1, x1(i), y1(i)]];
    A2 = [A2; [ 1, x2(i), y2(i)]];
    B1 = [B1; 1];
    B2 = [B2; -1];
end

lin = sdpvar(3,1);
F = [A1*lin>=B1, A2*lin<=B2];
% h = 0.5* norm(A1+A2);
% optimize(F,h);
optimize(F);
Lin = value(lin);

X1 = -5:0.1:5;
Y1 = -Lin(2)*X1/Lin(3)-Lin(1)/Lin(3);

figure
hold on
grid on
plot(x1,y1,'bo',x2,y2, 'go')
plot(X1,Y1,'red')
title("Полностью разделимые множества")

% Задача 2

% Используя те же формулы построить два множества, отличающиеся параметрами а и b. 
% Для первого множества взять a = 3, b = 2.5, для второго а = 4, b = 2. 
% Расчитать и изобразить на рисунке множества и прямую, примерно разделяющую полученные множества.
clear
a12 = 3;
b12 = 2.5;
alpha12 = 0;
xc12 = -2;
yc12 = 1;

a22 = 4;
b22 = 2;
alpha22 = pi/4;
xc22 = 2;
yc22 = -1;

phi = unifrnd(0,pi*2,500,1);
r = unifrnd(0,1,500,1);

x12 = [];
x22 = [];
y12 = [];
y22 = [];

for i = 1:500
    x12 = [x12; xc12 + a12*r(i).*cos(phi(i)).*cos(alpha12) - b12*r(i).*sin(phi(i)).*sin(alpha12)];
    y12 = [y12; yc12 + a12*r(i).*cos(phi(i)).*sin(alpha12) + b12*r(i).*sin(phi(i)).*cos(alpha12)];

    x22 = [x22; xc22 + a22*r(i).*cos(phi(i)).*cos(alpha22) - b22*r(i).*sin(phi(i)).*sin(alpha22)];
    y22 = [y22; yc22 + a22*r(i).*cos(phi(i)).*sin(alpha22) + b22*r(i).*sin(phi(i)).*cos(alpha22)];
end

A12 = [];
A22 = [];
B12 = [];
B22 = [];
lin2 = sdpvar(3,1);

for i = 1:500
    A12 = [A12; [ 1, x12(i), y12(i)]];
    A22 = [A22; [ 1, x22(i), y22(i)]];
    B12 = [B12; 1];
    B22 = [B22; -1];
end

lin2 = sdpvar(1003,1);
solve = lin2(1:3);
u = lin2(4:503);
v = lin2(504:1003);
F2 = [A12*solve>=B12-u, A22*solve<=B22+v, u>=0, v>=0];
h2 = sum(u)+sum(v);
optimize(F2,h2);
Lin2 = value(lin2);

X2 = -5:0.1:5;
Y2 = -Lin2(2)*X2/Lin2(3)-Lin2(1)/Lin2(3);
Lin2(1);
Lin2(2);
Lin2(3);

figure
hold on
grid on
plot(x12,y12,'bo',x22,y22,'go')
plot(X2,Y2,'red')
title("Оптимальная разделяющая прямая для неразделимых множеств")

% Задача 3

% В базе MNIST (будет выслана в виде mat-файла) выбрать изображения из обучающей выборки, 
% соответствующие двум различным цифрам (можно уменьшить количество изображений). 
% Описание структуры, содержащей символы базы MNIST дано в прилагаемом word файле. 
% Построить несколько изображений символов из базы. Построить гиперплоскость, примерно разделяющую множества изображений. 
% Проверить, как построенная гиперплоскость разделяет изображения из тестовой последовательности. 
% Найти процент ошибочных классификаций.
clear
data = load('mnist.mat');
train = data.training;
test = data.test;

% Для обучающего набора
X_train = train.images; % Обучающие изображения
y_train = train.labels; % Метки классов для обучающего набора

im1 = [];
im2 = [];
num1 = 0;
num2 = 0;

for i = 1:60000
    if y_train(i) == 4
        im1 = [im1, reshape(X_train(:,:,i),784,1)];
        num1 = num1+1;
    end
    if y_train(i) == 0
        im2 = [im2, reshape(X_train(:,:,i),784,1)];
        num2 = num2+1;
    end
end


figure
for i = 1:3
    subplot(2,3,i);
    imshow(reshape(im1((i-1)*784+1:i*784), 28, 28));
    title('Class 4');
    
    subplot(2,3,i+3);
    imshow(reshape(im2((i-1)*784+1:i*784), 28, 28));
    title('Class 0');
end

A_svm = sdpvar(784,1);
b_svm = sdpvar(1);
u_svm = sdpvar(1, num1);
v_svm = sdpvar(1, num2);

F_svm = [A_svm'*im1+b_svm>=1-u_svm, A_svm'*im2+b_svm<=-1+v_svm, u_svm>=0, v_svm>=0];
g = 10;
h_svm = norm(A_svm) + g*(sum(u_svm)+sum(v_svm));

optimize(F_svm, h_svm, sdpsettings('solver', 'sdpt3','debug',1))

A_SVM = value(A_svm);
B_SVM = value(b_svm);

% Для тестового набора
X_test = test.images; % Тестовые изображения
y_test = test.labels; % Метки классов для тестового набора


im1_test = [];
im2_test = [];
num1_test = 0;
num2_test = 0;

for i = 1:10000
    if y_test(i) == 4
        im1_test = [im1_test, reshape(X_test(:,:,i),784,1)];
        num1_test = num1_test+1;
    end
    if y_test(i) == 0
        im2_test = [im2_test, reshape(X_test(:,:,i),784,1)];
        num2_test = num2_test+1;
    end
end

error1 = 0;
error2 = 0;

for i=1:num1_test
    if A_SVM'*im1_test(:,i)+B_SVM>=0
        error1 = error1+1;
    end
end

for i=1:num2_test
    if A_SVM'*im2_test(:,i)+B_SVM<=1
        error2 = error2+1;
    end
end

err1 = 100-(error1/num1_test)*100
err2 = 100-(error2/num2_test)*100

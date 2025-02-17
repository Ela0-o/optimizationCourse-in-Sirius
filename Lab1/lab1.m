%1 задание

%Построить многочлен пятой степени у = p(x) (найти коэффициенты), который в точках yi = p(xi), 
%где xi =0.1i, i = 0, ..., 100, удовлетворяет неравенствам 0 ≤ yi < =5. 
%И, кроме того, удовлетворяет неравенствам: y0≤ 1, У30 ≥ 4, У70 ≤ 1, 2 ≤ У100≤ 3. 
%Построить график этого многочлена на интервале [0, 10].

A = [];
x = [];
b1 = [];
b2 = [];

for i = 1:101
    x = 0:0.1:10;
    A = [A; [1, x(i), x(i)^2, x(i)^3, x(i)^4, x(i)^5]];
    b1 = [b1;0];
    b2 = [b2;5];
end

b1(31) = 4;
b2(1) = 1;
b2(71) = 1;
b1(101) = 2;
b2(101) = 3;

a = sdpvar(6,1);
F = [A*a>=b1, A*a<=b2];
optimize(F);
b = value(a);

y = A*b;

figure
plot(x,A*b,'black')
hold on
grid on
title("График полинома")

%2 задание

%Построить зашумленные измерения значений этого многочлена по формуле Zi = yi + wi, i = 0,...,100, 
%где помеха w белый гауссовский шум со средним 0 и дисперсией 0.3. 
%Построить график истинных значений многочлена и зашумленных измеренных значений в точках xi

z1 = y + randn(101,1)*sqrt(0.3);

figure
hold on
grid on
plot(x,z1,'blue')
plot(x,y,'black')
title("График зашумленного полинома с помехой w")

%3 задание

%По зашумленным измерениям, оценить неизвестные значения коэффициентов многочлена, используя метод наименьших квадратов, 
%аппроксимацию Чебышева, минимизацию суммы модулей ошибок, минимизацию суммы значений штрафной функции ф(t) = √[t]. 
%На одном рисунке построить графики истинных значений многочлена, зашумленных измеренных значений в точках xi 
%и всех построенных аппроксимаций. Провести анализ точности различных методов и дать описание полученных результатов.

%МНК
h1 = norm(A*a - z1,2);
optimize(F,h1);
b_mnk = value(a);
z11 = A*b_mnk;

%Чебышев
h2 = max(abs(A*a - z1));
% h2 = norm(A*a - z1,inf);
optimize(F,h2);
b_cheb = value(a);
z12 = A*b_cheb;

%Минимизация суммы модулей ошибок
h3 = sum(abs(A*a - z1));
% h3 = norm(A*a - z1,1);
optimize(F,h3);
b_1 = value(a);
z13 = A*b_1;

%минимизацию суммы значений штрафной функции ф(t) = √[t]
% h4 = sum(sqrt(abs(A*a - z1)));
% optimize(F,h4);
% b_phi = value(a);
% z14 = A*b_phi;

figure
hold on
grid on
plot(x,z11)
plot(x,z12)
plot(x,z13)
% plot(x,z14)

plot(x,z1)
plot(x,y)

legend('mnk','cheb','first','with noise','without')
title("оценки")

max(abs(y-z11))
max(abs(y-z12))
max(abs(y-z13))
%4 задание

%Построить зашумленные измерения значений того же многочлена по формуле zi = yi + wi + vi, i = 0, ..., 100, 
%где помеха w та же, что и раньше, а vi случайная величина, принимающая значение 0 с вероятностью 0.9 
%и зачение лежащее в диапазоне 10 < |vi| ≤ 20, с вероятностью 0.1. 
%Построить график истинных значений многочлена и зашумленных измеренных значений в точках хi.

v = [];
for i = 1:101
    p = rand;
    if p < 0.9
        v = [v; 0];
    else 
        v = [v; sign(randn) * (10 + rand * 10)];
    end
end

z2 = z1 + v;

figure
hold on
grid on
plot(x,z2,'blue')
plot(x,y,'black')
title("График зашумленного полинома с помехами w и v")

%5 задание

%По новым зашумленным измерениям оценить коэффициенты многочлена, используя те же методы, что и в задаче 3. 
%На одном рисунке построить графики полученных аппроксимаций. 
%Провести анализ результатов, сравнить различные методы между собой и с результатами, полученными в задаче 3.


%МНК
h12 = norm(A*a - z2);
optimize(F,h12);
b_mnk2 = value(a);
z21 = A*b_mnk2;

%Чебышев
h22 = max(abs(A*a - z2));
% h2 = norm(A*a - z1,inf);
optimize(F,h22);
b_cheb2 = value(a);
z22 = A*b_cheb2;

%Минимизация суммы модулей ошибок
h32 = sum(abs(A*a - z2));
% h3 = norm(A*a - z1,1);
optimize(F,h32);
b_12 = value(a);
z23 = A*b_12;

%минимизацию суммы значений штрафной функции ф(t) = √[t]
% h42 = sum(sqrt(abs(A*a - z2)));
% optimize(F,h42);
% b_phi2 = value(a);
% z24 = A*b_phi2;

figure
hold on
grid on
plot(x,z21)
plot(x,z22)
plot(x,z23)
% plot(x,z24)

plot(x,z2)
plot(x,y)

legend('mnk','cheb','first','with noise','without')
title("другие оценки")

max(abs(y-z21))
max(abs(y-z22))
max(abs(y-z23))

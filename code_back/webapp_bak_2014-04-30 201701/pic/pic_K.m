clear all
clf
clc
grid on
hold on

pic_n = 1;
pic_name = strcat('wowfish+' , int2str(pic_n) , '.bmp');
fprintf('PIC: %s \n',pic_name);

I = imread( pic_name );
II = I;


[pic_h, pic_w, pic_n]=size(I);
y = 1 : 1 : pic_h;
x = 1 : 1 : pic_w;
[ X, Y ]=meshgrid(x,y);

cut_r = 40;
cut_g = 80;
cut_b = 80;

for th = 1:pic_h
    for tw = 1:pic_w
        t_r = I(th, tw, 1);
        t_g = I(th, tw, 2);
        t_b = I(th, tw, 3);
        if (t_r>cut_r) || (t_g>cut_g) || (t_b>cut_b)
            I(th, tw, 1) = 255;
        	I(th, tw, 2) = 255;
        	I(th, tw, 3) = 255;
        end
    end
end

R_I = I(:,:,1);
G_I = I(:,:,2);
B_I = I(:,:,3);



%%  *BOLD sub 1 *
subplot(2,2,1)

imshow(II);


%%  *BOLD sub 2 *
subplot(2,2,2)

imshow(I);

%%  *BOLD sub 3 *
subplot(2,2,3)
Z = G_I;

plot3(X,Y,Z);
axis equal
view(0, 0);


%%  *BOLD sub 4 *
subplot(2,2,4)
Z = B_I;

plot3(X,Y,Z);
axis equal
view(0, 0);




clear all
clf
clc
grid on
hold on

%%  read pic
pic_n = 2;
pic_name = strcat('wowfish+' , int2str(pic_n) , '.bmp');

fprintf('PIC: %s \n',pic_name);

pic_name = 'ccc.png'

I = imread( pic_name );
II = I;


[pic_h, pic_w, pic_n]=size(I);

%%  cut pic

cut_r = 140;
cut_g = 180;
cut_b = 80;

CX = [];
for th = 1:pic_h
    for tw = 1:pic_w
        t_r = I(th, tw, 1);
        t_g = I(th, tw, 2);
        t_b = I(th, tw, 3);
        if (t_r>cut_r) || (t_g>cut_g) || (t_b>cut_b)
            I(th, tw, 1) = 255;
        	I(th, tw, 2) = 255;
        	I(th, tw, 3) = 255;
        else
            CX = [CX ; [tw, pic_h - th]];
        end
    end
end

%%  *BOLD sub 1 *
subplot(2,2,1)

imshow(II);


%%  *BOLD sub 2 *
subplot(2,2,2)
imshow(I);
%%  *BOLD sub 3 *
subplot(2,2,3)

%%   
X = [randn(50,2)+ones(50,2);randn(50,2)-ones(50,2);randn(50,2)+[ones(50,1),-ones(50,1)]];

X = CX;
NK =7;

NX =3;

opts = statset('Display','final');

%����Kmeans����
%X N*P�����ݾ���
%Idx N*1������,�洢����ÿ����ľ�����
%Ctrs K*P�ľ���,�洢����K����������λ��
%SumD 1*K�ĺ�����,�洢����������е���������ĵ����֮��
%D N*K�ľ��󣬴洢����ÿ�������������ĵľ���;

[Idx,Ctrs,SumD,D] = kmeans(X,NK,'Replicates',NX,'Options',opts);

hold on
%��������Ϊ1�ĵ㡣X(Idx==1,1),Ϊ��һ��������ĵ�һ�����ꣻX(Idx==1,2)Ϊ�ڶ���������ĵڶ�������
for k=1:NK
    all_color = ['b','g','r','c','m','y']
    k_color = all_color( mod(k,6)+1 )
    plot(X(Idx==k,1), X(Idx==k,2), strcat(k_color,'.') ,'MarkerSize',14)
end
%����������ĵ�
plot(Ctrs(:,1),Ctrs(:,2),'kx','MarkerSize',14,'LineWidth',4)


legend('Cluster 1','Cluster 2','Cluster 3','Centroids','Location','NW')

axis equal

Ctrs
SumD
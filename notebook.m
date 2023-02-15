
if size(im,3)==3
    imGray = rgb2gray(im);
else
    imGray = im;
end
figure(1)
imshow(imGray)

figure(2)
%subplot(212)
piel=~im2bw(imGray,0.19);
imshow(piel);

piel=bwmorph(piel,'close');
figure(3)
imshow(piel);

piel=bwmorph(piel,'open');
figure(4)
imshow(piel);

piel=bwareaopen(piel,50);
figure(5)
imshow(piel);

piel=imfill(piel,'holes');
figure(6)
imshow(piel);

% Tagged objects in BW image
L=bwlabel(piel);
% Get areas and tracking rectangle
out_a=regionprops(L);
% Count the number of objects
N=size(out_a,1);
if N < 1 || isempty(out_a) % Returns if no object in the image
    solo_cara=[ ];
    %continue
end
% ---
% Select larger area
areas=[out_a.Area];
[area_max pam]=max(areas);
figure(7)
imshow(L==pam)
figure(8)
imshow(imGray);
colormap gray
hold on
rectangle('Position',out_a(pam).BoundingBox,'EdgeColor',[1 0 0],...
    'Curvature', [1,1],'LineWidth',2)
centro=round(out_a(pam).Centroid);
X=centro(1);
Y=centro(2);


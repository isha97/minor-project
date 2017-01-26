%======================================================================
%SLICO demo
% Copyright (C) 2015 Ecole Polytechnique Federale de Lausanne
% File created by Radhakrishna Achanta
% Please also read the copyright notice in the file slicmex.c 
%======================================================================
%Input:
%[1] 8 bit images (color or grayscale)
%[2] Number of required superpixels (optional, default is 200)
%
%Ouputs are:
%[1] labels (in raster scan order)
%[2] number of labels in the image (same as the number of returned
%superpixels
%
%NOTES:
%[1] number of returned superpixels may be different from the input
%number of superpixels.
%[2] you must compile the C file using mex slicmex.c before using the code
%below
%----------------------------------------------------------------------
% How is SLICO different from SLIC?
%----------------------------------------------------------------------
% 1. SLICO does not need compactness factor as input. It is calculated
% automatically
% 2. The automatic value adapts to the content of the superpixel. So,
% SLICO is better suited for texture and non-texture regions
% 3. The advantages 1 and 2 come at the cost of slightly poor boundary
% adherences to regions.
% 4. This is also a very small computational overhead (but speed remains
% almost as fast as SLIC.
% 5. There is a small memory overhead too w.r.t. SLIC.
% 6. Overall, the advantages are likely to outweigh the small disadvantages
% for most applications of superpixels.
%======================================================================
%img = imread('someimage.jpg');
img = imread('bee.jpg');
[rows,cols,dim] = size(img);
[labels, numlabels] = slicomex(img,500);%numlabels is the same as number of superpixels
%figure;
%imagesc(labels);
reshapelabel=transpose(reshape(labels,1,prod(size((labels)))));
rgb=reshape(img,prod(size(labels)),3);
lab_image=rgb2lab(img);
lab=reshape(lab_image,prod(size(labels)),3);
rgb=double(rgb);
featurevector=cat(2,rgb,lab);
segmented_img=cell(1,numlabels);
seg_label=repmat(labels,[1 1 3]);
black = zeros(1,numlabels);
for l=0:numlabels-1
    color = img;
    color(seg_label~=l) =0;
    segmented_img{l+1} = color;
end
%% counting pixel frequency
nonblack = zeros(1,numlabels);
for i=0:numlabels-1
    for j=2:rows-1
        for k=2:cols-1
            if(i==labels(j,k))
                nonblack(1,i+1)=nonblack(1,i+1)+1;
            end
        end
    end
end

%% final histogram for every super pixel
black= zeros(1,numlabels);
black(:,:)=(rows-2)*(cols-2);
black_final=black-nonblack;


hist = [];

for i=0:numlabels-1
    
    seg_gray=rgb2gray(segmented_img{i+1});
    temp_hist=lbp(seg_gray,1,8,mapping,'h');
    temp_hist(1,58)=temp_hist(1,58)-(black_final(1,i+1));
    hist=cat(1,hist,temp_hist);
end
training_data = cat(2,train,hist);
 function y = myMeanShiftSegmentation(vid,sp_sig,col_sig,time_sig,stopiter,numneighbour,lambda,windowsize,windowed,onlyy)
%Set XY coordinates
coordscale=255/max([size(vid,2),size(vid,1)]);
[row,col] = meshgrid(1:size(vid,2),1:size(vid,1));

featurespace = zeros(size(vid,4)*size(vid,2)*size(vid,1),6);
for time = 1:size(vid,4)
    for j = 1:size(vid,2)
        for i = 1:size(vid,1)
            %featurespace(((time-1)*size(vid,2)+(j-1))*size(vid,1)+i,:)=[row(i,j),col(i,j),vid(i,j,1,time),vid(i,j,2,time),vid(i,j,3,time),timevec(time)];
            featurespace(((time-1)*size(vid,2)+(j-1))*size(vid,1)+i,:)=[coordscale*row(i,j)/sp_sig,coordscale*col(i,j)/sp_sig,vid(i,j,1,time)/col_sig,vid(i,j,2,time)/col_sig,vid(i,j,3,time)/col_sig,time*255/(time_sig*size(vid,4))];
            %indextoloc(((time-1)*size(vid,2)+(j-1))*size(vid,1)+i,:)=[max(time-windowsize/2,1),min(time+windowsize/2,size(vid,4)),max(j-windowsize/2,1),min(j+windowsize/2,size(vid,2)),max(i-windowsize/2,1),min(i+windowsize/2,size(vid,1))];
        end
    end
end
fprintf('done creating feature vector \n');
if onlyy ==1
    reducedfeaturespace = featurespace(:,1:4);
end
if onlyy ==0
    reducedfeaturespace = featurespace(:,1:6);
end
%a represents 1-learning rate (=lambda)
a=1-lambda;
%iterate over the image, each time moving via gradient ascent

grad=zeros(size(featurespace));
if windowed==0
    for it = 1:stopiter
       if onlyy ==1
           reducedfeaturespace = featurespace(:,1:4);
       end
       if onlyy ==0
           reducedfeaturespace = featurespace(:,1:6);
       end
        
       disp(it/stopiter*100)
       [idx,D]=knnsearch(reducedfeaturespace,reducedfeaturespace,'k',numneighbour); %do k nearest neighbour search for each pixel
       %Calculate gradient at each pixel
       for val = 1:size(featurespace,1) 
          coef=exp(-(D(val,:).^2)/2); 
          coef = coef'./sum(coef);
          grad(val,:)=sum(featurespace(idx(val,:),:).*[coef coef coef coef coef coef]);
       end
       %update featurespace
       featurespace=a*featurespace+lambda*grad;
    end
end

if windowed ==1
    for it = 1:stopiter
       for pixel = 1:size(featurespace,1)
           if mod(pixel,size(vid,2)*size(vid,1)) ==0
               fprintf('frame number  = %.3f \n',(pixel/size(vid,2)*size(vid,1)));
               fprintf('iteration  = %.3f\n',it);
           end
           val = indextoloc(pixel,:);
           %pixelsearchgrouploc = sub2ind([size(vid,1),size(vid,2),size(vid,4)],val(5):val(6),val(3):val(4),val(1):val(2));
           %ispread=val(5):val(6);
           %jspread = val(3):val(4);
           %tspread=val(1):val(2);
           [iloc,jloc,timeloc]=meshgrid(val(5):val(6),val(3):val(4),val(1):val(2));
           iloc=reshape(iloc,[],1);
           jloc=reshape(jloc,[],1);
           timeloc=reshape(timeloc,[],1);
           searchindices=sub2ind([size(vid,1),size(vid,2),size(vid,4)],iloc,jloc,timeloc);
           %searchtable=featurespace(searchindices,:);
           %searchval=featurespace(pixel,:);
           [idx,D]=knnsearch(reducedfeaturespace(searchindices,:),reducedfeaturespace(pixel,:),'k',numneighbour); %do k nearest neighbour search for each pixel
           coef=exp(-(D.^2)/2); 
           coef = coef'./sum(coef);
           %temp1=featurespace(idx);
           %temp=sum(featurespace(idx)'.*[coef coef coef coef coef coef]);
           grad(pixel,:)=sum(featurespace(idx)'.*[coef coef coef coef coef coef]);
           %Calculate gradient at each pixel
           %for val = 1:size(featurespace,1) 
           %   coef=exp(-(D(val,:).^2)/2); 
           %   coef = coef'./sum(coef);
           %   grad(val,:)=sum(featurespace(idx(val,:),:).*[coef coef coef coef coef coef]);
           %end
           %update featurespace
           %featurespace()=a*featurespace+lambda*grad;
       end
       featurespace=a*featurespace+lambda*grad;
    end
end


%Reshape and scale colour features back to original image size
curr=zeros(size(vid));
for time = 1:size(vid,4)
    for j = 1:size(vid,2)
        for i = 1:size(vid,1)
            curr(i,j,:,time)=featurespace(((time-1)*size(vid,2)+(j-1))*size(vid,1)+i,3:5)*col_sig;
        end
    end
end
y = curr;



% 

% UNUSED CODE
%row=row*coordscale/sp_sig;
%col=coordscale*col/sp_sig;

%NEW STUFF
% colour1=vid(:,:,1,:)/col_sig;
% colour2=vid(:,:,2,:)/col_sig;
% colour3=vid(:,:,3,:)/col_sig;
% colour1=reshape(colour1,[],1);
% colour2=reshape(colour2,[],1);
% colour3=reshape(colour3,[],1);
%Scale XY coordinates to same dimensions as image colour intensities

%Create Featurespace with 5 columns and heightxwidth rows (formatted this way for knnsearch)
%Features are weighted by their gaussian variance, effectively creating a
%5D feature space where all features are equivalent
% [icoord,jcoord,tcoord] = meshgrid(1:size(vid,1),1:size(vid,2),1:size(vid,4));
% icoord=reshape(icoord,[],1);%*coordscale/sp_sig;
% jcoord=reshape(jcoord,[],1);%*coordscale/sp_sig;
% tcoord=reshape(tcoord,[],1);%/(time_sig*size(vid,4));
% 
% colour1=vid(:,:,1,:)/col_sig;
% colour1=reshape(colour1,[],1);
% colour2=vid(:,:,2,:)/col_sig;
% colour2=reshape(colour2,[],1);
% colour3=vid(:,:,3,:)/col_sig;
% colour3=reshape(colour3,[],1);
% colour1=vid(icoord,jcoord,1,tcoord)/col_sig;
% colour2=vid(icoord,jcoord,2,tcoord)/col_sig;
% colour3=vid(icoord,jcoord,3,tcoord)/col_sig;
% colour1=reshape(colour1,[],1);
% colour2=reshape(colour2,[],1);
% colour3=reshape(colour3,[],1);

%indices=sub2ind([size(vid,1),size(vid,2),size(vid,4)],icoord,jcoord,tcoord);
%timevec =1:size(vid,4);
%timevec=timevec/(time_sig*size(vid,4));
%featurespace = [icoord*coordscale/sp_sig,jcoord*coordscale/sp_sig,colour1,colour2,colour3,tcoord*255/(time_sig*size(vid,4))];
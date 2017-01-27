% VBFA regularized covariance matrix
% HT Attias, Golden Metallic 1/8/05


function [b,lam,sig,yc,cy,bet,weight,mlike,ubar]=nut_reg_vbfa(y,nl,nem,plotflag);


nk=size(y,1);nt=size(y,2);

% y(nk,nt) = data
% b(nk,nl) = mixing matrix
% lam(nk,1) = sensor noise precision
% bet(nl,1) = hyperparamaeters
% sig(nk,nk) = data covariance matrix = b*b'+1/lam (approx)
% nk = data dimensionality
% nl  = factor dimensionality (try 5)
% nt = number of time points
% nem = number of EM iterations  (try 50)
% plot = flag for plotting

% experiment with nl,nem using the plots generated by the code: 
% set nem such that the likelihood converges (top plot)
% set nl such that some hyperparameters bet approach infinity, i.e. some 
% 1/bet vanish (middle plot)
 

%===============================


ryy=y*y';
[p d]=svd(ryy/nt);
d=diag(d);
b=p*diag(sqrt(d));
b=b(:,1:nl);
lam=1./diag(ryy/nt);

bet=ones(nl,1); %diff from VBFA

likeli=zeros(nem,1);
rbb=eye(nl)/nt;

for iem=1:nem
   dbet=diag(bet);ldbet=sum(log(bet));
   dlam=diag(lam);ldlam=sum(log(lam));

   gam=b'*dlam*b+eye(nl)+nk*rbb*0; %diff from VBFA
   igam=inv(gam);   
   ubar=igam*b'*dlam*y;
   ryu=y*ubar';
   ruu=ubar*ubar'+nt*igam;

   [p d q]=svd(gam);ldgam=sum(log(diag(d)));
   temp1=-.5*ldgam*ones(1,nt)+.5*sum(ubar.*(gam*ubar),1);
   temp2=.5*ldlam*ones(1,nt)-.5*lam'*(y.^2);
   f=temp1+temp2;	
   f3=.5*nl*ldlam+.5*nk*ldbet-.5*trace(b'*dlam*b*dbet); %diff
   likeli(iem)=mean(f)+f3/nt; 
							   
   betbar=ruu+dbet;
   ibetbar=inv(betbar);
   b=ryu*ibetbar;

   ilam=diag(ryy-b*ryu')/(nt+nl); % diff
   lam=1./ilam;
   dlam=diag(lam);
       					
   bet=1./(diag(b'*dlam*b)/nk+diag(ibetbar));
    if plotflag
       figure(6)
       hsub=subplot(3,3,1);plot((1:iem)',likeli(1:iem));title('likelihood')
       hsub=subplot(3,3,4);plot((1:nl)',sqrt([mean(b.^2,1)' 1./bet]));title('1/bet');
       hsub=subplot(3,3,7);plot(1./lam);title('1/lam');
       drawnow;
    end

   rbb=ibetbar;
end

weight=b*igam*b'*dlam;
sig=b*b'+diag(1./lam);
yc=b*ubar;
cy=b*ruu*b'+diag(ilam*trace(ruu*ibetbar));
mlike=likeli(iem);

if plotflag
    subplot(3,3,2);imagesc(ryy/nt);title('ryy/nt');colorbar;
    subplot(3,3,3);imagesc(cy/nt);title('cy/nt');colorbar;
    subplot(3,3,5);imagesc((ryy-cy)/nt);title('(ryy-cy)/nt');colorbar;
    subplot(3,3,6);imagesc(b*b');title('b*bT');colorbar;
    subplot(3,3,8);imagesc(sig);title('sig');colorbar;
end

return


%===============================



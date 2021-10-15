% analyze photobleaching.. 
function [] = analyze_bleaching_quartiles(fname, transp)
load(fname); 
if transp
	Dalign = permute(Dalign, [2 1 3]); 
end
sx = sort(Dalign(:));
l = length(sx);
Dmin = sx(floor(l* 0.01));
Dmax = sx(floor(l* 0.99));
Dalign_scl = (Dalign - Dmin) / (Dmax - Dmin);

Dalign_mean = mean(Dalign, 3);
N = size(Dalign, 3);


Dmeansort = sort(Dalign_mean(:)); 
l = length(Dmeansort); 
q1 = Dmeansort(floor(l * 0.25)); 
q2 = Dmeansort(floor(l * 0.5)); 
q3 = Dmeansort(floor(l * 0.75)); 
mask1 = Dalign_mean < q1; 
mask2 = (Dalign_mean >= q1) .* (Dalign_mean < q2); 
mask3 = (Dalign_mean >= q2) .* (Dalign_mean < q3); 
mask4 = Dalign_mean >= q3; 

figure; 
subplot(2, 1, 1);
masks = mask2 * 0.33 + mask3 * 0.66 + mask4; 
lo = min(Dalign_mean(:));
hi = max(Dalign_mean(:));
masks = (masks*(hi-lo))+lo; 
imagesc([Dalign_mean; masks]); 
title(fname); 
colormap gray; 
axis image; 

bleach1 = sum(reshape(Dalign .* repmat(mask1, 1, 1, N), 128*512, N), 1) / sum(sum(mask1)); 
bleach2 = sum(reshape(Dalign .* repmat(mask2, 1, 1, N), 128*512, N), 1) / sum(sum(mask2)); 
bleach3 = sum(reshape(Dalign .* repmat(mask3, 1, 1, N), 128*512, N), 1) / sum(sum(mask3)); 
bleach4 = sum(reshape(Dalign .* repmat(mask4, 1, 1, N), 128*512, N), 1) / sum(sum(mask4)); 

subplot(2,1,2);
time = (1:N)/156.0; 
plot(time, [bleach1' bleach2' bleach3' bleach4'])
hold on; 
plot(time, bleach4 - bleach1, 'k', 'Linewidth', 2)
title('mean pixel intensities vs time, by quartile')
legend('Q1', 'Q2', 'Q3', 'Q4', 'Q4-Q1')
xlabel('time, sec'); 
ylabel('average pixel photon count'); 

print([fname(1:end-3) 'pdf'], '-dpdf', '-fillpage'); 

save([fname(1:end-4) '_qtrace.mat'], 'bleach*', 'Dalign_mean', 'mask*', 'time'); 
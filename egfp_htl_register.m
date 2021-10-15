cd /media/tlh24/Samsung_X5/data/2021/050621/
fname = 'mouse_481524_jRGECO_00003.tif';
if 1
	obj = ScanImageTiffReader(fname);
	D = single(obj.data());
	meta = obj.metadata();
end
D = permute(D, [2 1 3]); 
% NoRMCorreSetParams doesn't work, needs ~ 200 frames to get a good
% template. 
% try matlab Suite2p instead. 
out = single(zeros(512, 512, 200)); 
for k = 1:20:size(D, 3)-1
	dreg = suite2p_rigid_registration(D(:,:,k:k+19)); 
	out(:,:,(k-1)/20+1) = squeeze(mean(dreg, 3)); 
	fprintf('done with %d\n', k); 
end

fname_reg = [fname(1:end-4) '_registered.tif']; 
write_tiff_stack(dreg, fname_reg); 
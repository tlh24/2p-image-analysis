list = dir('*.tif');

for fileN = 1:length(list)
   filename = list(fileN).name
	obj = ScanImageTiffReader(filename);
	D = single(obj.data());
	meta = obj.metadata();
	
	if(size(D, 3) >= 24000 )
		D2 = reshape(D, size(D,1), size(D,2), 2, floor(size(D,3)/2)); 
		D = squeeze(sum(D2, 3));
	end

	options = NoRMCorreSetParms('grid_size', [64,64], ...
		'd1',size(D,1),'d2',size(D,2), 'bin_width',200,'max_shift',65,...
		'iter',2,'correct_bidir',false, 'upd_template', false);
	[~,shifts,A.template,~] = normcorre_batch(D, options);
	Dalign = apply_shifts(D,shifts,options);
	savename = join([filename(1:end-4) '_registered.mat']);
% 	save(savename,'Dalign','meta','-v7.3');
	savename = join([filename(1:end-4) '_registered.tif']);
	Dalign = permute(Dalign, [2 1 3]);
	write_tiff_stack(Dalign, savename); 
end

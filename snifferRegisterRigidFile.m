function [] = snifferRegisterRigidFile(...
	filename, planes, binsize, spacing)

obj = ScanImageTiffReader(filename);
D = single(obj.data());
meta = obj.metadata();
D = permute(D, [2 1 3]); % transpose into matlab order
if(size(D, 3) > 1) % no single-frame tifs
	% needs to fit into a 4GB Tiff file.  float32 samples.
	if 4*size(D,1)*size(D,2)*size(D,3)/spacing > 4e9
		n = floor((1e9*spacing) / (size(D,1)*size(D,2)*planes))*planes; 
		D = D(:,:,1:n); 
	end

	if(size(D, 1) == 256) %85.5 FPS
		% binsize = 5; % this is good for glsnfr
		binsize = 15; % this is good for jrgeco
		spacing = 2; 
	end
	K = floor((size(D, 3)/planes-binsize)/spacing); 
	out = single(zeros(size(D,1), size(D,2), planes, K));

	dreg = suite2p_rigid_registration(D, planes); 
	dreg = reshape(dreg, size(D,1), size(D,2), planes, ...
		size(D,3)/planes); 
	for j = 1:planes
		for h = 1:K
			indx = (h-1)*spacing+1; 
			out(:,:,j,h) = sum(dreg(:,:,j,indx:indx+binsize), 4); 
		end
	end
	out = squeeze(reshape(out, size(D,1), size(D,2), K*planes)); 
	savename = join([filename(1:end-4) '_regifiltered.tif']);
	write_tiff_stack(out, savename); 
end
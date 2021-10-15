function [dreg] = suite2p_rigid_registration(IMG, numPlanes)
% uses the matlab version of Suite2p's rigid registration, with kringing,
% to align one plane in an image stack.  
% sketchily cribbed from Suite2p's reg2p.m
% I'm not sure how multi-plane registration works in suite2p -- 
% hence here am adopting the strategy of summing red and green channels, 
% getting the offsets, and shifting both red and green accordingly, 
% and outputting the same format as was given.
[Ly, Lx, ~, ~] = size(IMG);
ops.Ly = Ly;
ops.Lx = Lx;
ops.nplanes = 1; 
ops.dobidi = 1; 
ops.planesToProcess = 1;
ops = buildRegOps(ops);
[xFOVs, yFOVs] = get_xyFOVs(ops);
if ops.dobidi
	ops.BiDiPhase = BiDiPhaseOffsets(IMG);
end
BiDiPhase = ops.BiDiPhase;
% fprintf('bi-directional scanning offset = %d pixels\n', BiDiPhase);
if abs(BiDiPhase) > 0
	IMG = ShiftBiDi(BiDiPhase, IMG, Ly, Lx);
end
ops.useGPU = 0;

if(numPlanes > 1)
	IMG2 = reshape(IMG, size(IMG,1), size(IMG,2), numPlanes, ...
		floor(size(IMG,3)/numPlanes)); 
	IMG2 = squeeze(sum(IMG2, 3)); 
else
	IMG2 = IMG;
end

for l = 1:size(xFOVs,2)
	ops1{1,l} = alignIterative(single(...
		squeeze(IMG2(yFOVs(:,l),xFOVs(:,l),:))), ops);
end

red_mean = 0;
red_align = 0;
for j = 1:size(xFOVs,2)
	ops1{1,j}.DS          = [];
	ops1{1,j}.CorrFrame   = [];
	ops1{1,j}.mimg1       = zeros(ops1{1,j}.Ly, ops1{1,j}.Lx);
end

for i = 1:numel(ops1)
	ops1{i}.Nframes(1)     = 0;
end

[dsall, ops1] = rigidOffsets(IMG2, 1, 1, 1, ops, ops1);

dreg = zeros(size(IMG, 1), size(IMG,2), size(IMG,3)); 
for i = 1:numPlanes
	dreg1 = rigidMovie(squeeze(IMG(:,:,i:numPlanes:end)), ...
		ops1, dsall, yFOVs, xFOVs);
	dreg(:,:,i:numPlanes:end) = dreg1; 
end
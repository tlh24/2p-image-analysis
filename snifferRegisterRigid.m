planes = 1; 
binsize = 8; % good default, glusnfr = 10; jrgeco = 15
spacing = 2; % good default = 2

list = dir('*.tif');
for fileN = 1:length(list)
   filename = list(fileN).name
	if(numel(regexp(filename, 'regifiltered')) == 0 && ...
			numel(regexp(filename, 'SUM')) == 0)
		savename = join([filename(1:end-4) '_regifiltered.tif']);
		if(~isfile(savename))
			snifferRegisterRigidFile(...
				filename, planes, binsize, spacing);
		end
	end
end

function [] = write_tiff_stack(out_stack, fname)
% write a single (float) resolution tiff stack, suitable for imageJ to
% read.
t = Tiff(fname,'w');
for i = 1:size(out_stack, 3)
	tagstruct.ImageLength     = size(out_stack,1);
	tagstruct.ImageWidth      = size(out_stack,2);
	tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
	tagstruct.BitsPerSample   = 32;
	tagstruct.SamplesPerPixel = 1;
	tagstruct.RowsPerStrip    = 16;
	tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
	tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
	tagstruct.Software        = 'MATLAB';
	t.setTag(tagstruct);
	t.write(out_stack(:,:,i))
	t.writeDirectory(); 
end
t.close()
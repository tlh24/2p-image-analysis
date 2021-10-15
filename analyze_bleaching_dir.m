% for 042721 awake glusnfr recordings. 
cd /media/tlh24/Samsung_X5/data/2021/042721/
cd /media/tlh24/Samsung_X5/data/2021/042321/
cd /media/tlh24/Samsung_X5/data/2021/042121/
list = dir('*.mat');
basename = '4_glsnfr__'; 
basename = 'mouse_482374_glsnfr__'; 

if 1
	for fileN = 1:length(list)
		fname = list(fileN).name;
		if numel(regexp(fname, 'qtrace')) == 0
			analyze_bleaching_quartiles(fname, 1); 
		end
	end
end

if 0 % 042721
	new_no = [4, 5, 6, 7, 8]; % only use the 15k traces.
	wt_no = [9, 10, 11, 12];
end

if 1
	new_no = [1 2 3 4 5 6];
	wt_no = [9 10 11]; 
end

new_traces = []; 
wt_traces = []; 
figure;

for n = 1:length(new_no)
	new = new_no(n); 
	fno = regexprep(sprintf('%5.0d', new), ' ', '0'); 
	fname = [basename fno '_registered_qtrace.mat']; 
	load(fname); 
	bb = double(squeeze(bleach4' - bleach1')); 
	bb = bb / mean(bb(1:15)); 
	new_traces = [new_traces bb]; 
	hold on; 
	plot(time, sgolayfilt(bb, 5, 61), 'b', 'Linewidth', 1); 
end

for n = 1:length(wt_no)
	wt = wt_no(n); 
	fno = regexprep(sprintf('%5.0d', wt), ' ', '0'); 
	fname = [basename fno '_registered_qtrace.mat']; 
	load(fname); 
	bb = double(squeeze(bleach4' - bleach1')); 
	bb = bb / mean(bb(1:15)); 
	wt_traces = [wt_traces bb]; 
	plot(time, sgolayfilt(bb, 5, 61), 'k', 'Linewidth', 1); 
end

title('Bleaching curves');
xlabel('time, sec');
ylabel('mean pixel photon counts'); 
text(80, 20, '857 variant', 'FontSize', 20, 'Color', 'b'); 
text(80, 19, 'WT variant', 'FontSize', 20); 

print('Normalized_bleaching_curves.pdf', '-dpdf', '-fillpage'); 
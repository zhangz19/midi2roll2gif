% MATLAB toolkit to convert MIDI file to GIF animation figures. This 
% function is based on the MATLAB MIDI toolbox. The output file will
% be '1.gif' under the same directory.

function [] = roll2gif()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Parameter field: to be adjust for your MIDI file           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the input MIDI file name.
midifilename = './littlefugue.mid'; 

% ratio of the size of GIF file versus the size of your screen 
width = .44; height = .34; 

% the title of your GIF file
% If the title contains two lines £¬let titles = {'line1';'line2'}; 
titles = 'BWV 578, Little Fugue in g minor, by J.S.Bach';

% delaytime between frames. The larger, more slowly the frame moves
delaytime = 0.3; 
% range of frame. The larger, the more you have pianorolls for single frame
steps = 20;

% The frames rate adjudgement. The smaller, the larger frame rate.
by = 2; 

% the colors of each chanel. you can modify it.
cols = ['r', 'b', 'y', 'g', 'c', 'm']; 

% subtle adjustment for the range of Y axis, to include the X axis.
ua = 1; la = 1.1;

% background color. You can modify it by setting [a b c] where a,b,c are 
% recommanded to be small numbers. default if black.
whitebg([0 0 0]) 
%%%%%%%%%%%%%%%%%%%% parameter fields end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%   function field %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addpath('./miditoolbox_Windows/miditoolbox')

tmp = midi2nmat(midifilename); % replace readmidi function

chs = unique(tmp(:,3)); c1 = chs(1); chs = (c1~=1)*(chs+1-c1)+(c1==1)*chs;
tmp(:,3) = (c1~=1)*(tmp(:,3)+1-c1)+(c1==1)*tmp(:,3);
J = length(chs); ch = cell(1,J);
for i = 1:J
    ch{i} = tmp(tmp(:,3)==chs(i),:);
end
Len = max(tmp(:,1));
ub = max(tmp(:,4))+ua; lb = min(tmp(:,4))-la;

scrsz = get(0,'ScreenSize'); 
for j = 1:J
    h = figure(2);
    set(h,'outerPosition',[1 scrsz(4)/5 scrsz(3)*width scrsz(4)*height]);
    index = round(min(ch{j}(:,1))); tmp2 = ch{j}(1:(1+steps),:); 
    tmp2(:,1) = tmp2(:,1)+ 2 - index; 
    pianoroll(tmp2,'name','beat',cols(j),'hold'); 
    axis([0 steps lb ub]); grid off; 
end
f = getframe(h); [junk,map] = rgb2ind(f.cdata,512,'nodither'); close all

p = 1; 
for i = -steps:by:round(Len)
    h = figure(1); 
    set(h,'outerPosition',[1 scrsz(4)/5 scrsz(3)*width scrsz(4)*height]); 
    for j = 1:J
        index = find(ch{j}(:,1)<i+steps & ch{j}(:,1)>i);
        tmp2 = ch{j}(index,:); pianoroll(tmp2,'name','beat',cols(j),'hold');
    end
    axis([i i+steps lb ub]); grid off;
    title(titles,'Fontname','courier'); 
    xlabel('');ylabel('') 
    f = getframe(h); 
    im(:,:,1,p) = rgb2ind(f.cdata,map,'nodither'); p = p+1;
end
im(:,:,1,p) = 0;
imwrite(im,map,'1.gif','DelayTime',delaytime,'LoopCount',inf);

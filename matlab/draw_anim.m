o = zeros(320, 240);
o(1:2:end,1:2:end) = 1;
ds_fixed = [[1:76800]'; 76800+find(o)];

cm = [0.5000    0.5000    1.0000
      0.5161    0.5161    1.0000
      0.5323    0.5323    1.0000
      0.5484    0.5484    1.0000
      0.5645    0.5645    1.0000
      0.5806    0.5806    1.0000
      0.5968    0.5968    1.0000
      0.6129    0.6129    1.0000
      0.6290    0.6290    1.0000
      0.6452    0.6452    1.0000
      0.6613    0.6613    1.0000
      0.6774    0.6774    1.0000
      0.6935    0.6935    1.0000
      0.7097    0.7097    1.0000
      0.7258    0.7258    1.0000
      0.7419    0.7419    1.0000
      0.7581    0.7581    1.0000
      0.7742    0.7742    1.0000
      0.7903    0.7903    1.0000
      0.8065    0.8065    1.0000
      0.8226    0.8226    1.0000
      0.8387    0.8387    1.0000
      0.8548    0.8548    1.0000
      0.8710    0.8710    1.0000
      0.8871    0.8871    1.0000
      0.9032    0.9032    1.0000
      0.9194    0.9194    1.0000
      0.9355    0.9355    1.0000
      0.9516    0.9516    1.0000
      0.9677    0.9677    1.0000
      0.9839    0.9839    1.0000
      1.0000    1.0000    1.0000
      0.9688    0.9688    1.0000
      0.9375    0.9375    1.0000
      0.9062    0.9062    1.0000
      0.8750    0.8750    1.0000
      0.8438    0.8438    1.0000
      0.8125    0.8125    1.0000
      0.7812    0.7812    1.0000
      0.7500    0.7500    1.0000
      0.7188    0.7188    1.0000
      0.6875    0.6875    1.0000
      0.6562    0.6562    1.0000
      0.6250    0.6250    1.0000
      0.5938    0.5938    1.0000
      0.5625    0.5625    1.0000
      0.5312    0.5312    1.0000
      0.5000    0.5000    1.0000
      0.4688    0.4688    1.0000
      0.4375    0.4375    1.0000
      0.4062    0.4062    1.0000
      0.3750    0.3750    1.0000
      0.3438    0.3438    1.0000
      0.3125    0.3125    1.0000
      0.2812    0.2812    1.0000
      0.2500    0.2500    1.0000
      0.2188    0.2188    1.0000
      0.1875    0.1875    1.0000
      0.1562    0.1562    1.0000
      0.1250    0.1250    1.0000
      0.0938    0.0938    1.0000
      0.0625    0.0625    1.0000
      0.0312    0.0312    1.0000
           0         0    1.0000];

xlim = [min(min(anim.clouds(:,1,:))) max(max(anim.clouds(:,1,:)))];
ylim = [min(min(anim.clouds(:,2,:))) max(max(anim.clouds(:,2,:)))];
zlim = [min(min(anim.clouds(:,3,:))) max(max(anim.clouds(:,3,:)))];

p = pcplayer(zlim, xlim, ylim);
p.Axes.View = [-126.7900  -15.2217];
for i=1:size(anim.clouds, 3)
  view(p, anim.clouds(ds_fixed,[3 1 2],i), anim.clouds(ds_fixed,4:6,i));
  imagesc(anim.zfields(:,:,i)');
  daspect([1 1 1]);
  if i==2
    colormap(cm);
    input('Press ENTER')
  end
  pause(0.02);
end
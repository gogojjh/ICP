function [tf, iter, matched] = mycp(ref, src, params)
  global beta gamma
  w = 640;
  h = 480;
  beta = 4.0;
  gamma = 2.0;
  icp;

  dt_thresh = 0.01;
  dth_thresh = 0.001;
  scale_thresh = 0.001;

  % we'll work with homogenous coords
  n_ref = size(ref, 1);
  n_src = size(src, 1);
  assert(size(ref, 2) == 4);
  assert(size(src, 2) == 4);

  % build kdtree
  if params.verbose
    disp('Building kdtree');
  end
  kdtree = KDTreeSearcher(ref);

  tf = params.t_init;

  % apply initial transform
  src = (params.t_init * src')';

  all_matches = cell(0);
  matches = 0;
  for iter=1:params.iter_max
    [idx, dist] = knnsearch(kdtree, src);

    init = -1*ones(w, h);
    if matches==0
      init(find(dist < prctile(dist, 90))) = 1;
    else
      init(matches(:,1)) = 1;
    end
    matches = find_matches(ref, src, idx, dist, init);
    all_matches{iter} = matches;

    % calculate transformation
    Tmat = localize(ref(matches(:,2),:), src(matches(:,1),:), params.do_scale);
    tf = Tmat * tf;

    % apply to source cloud
    src = (Tmat * src')';

    % stopping criteria
    scale = norm(Tmat(1:3,1));
    dt = norm(Tmat(1:3,4));
    dth = acos((trace(Tmat(1:3,1:3))/scale - 1)/2);

    if params.verbose
      disp(sprintf('Iter %d; scale %f, translation %f, rotation %f', iter, scale, dt, dth));
    end

    if dt < dt_thresh && dth < dth_thresh && abs(scale-1) < scale_thresh
      break;
    end
  end
  assignin('base', 'matches_mycp', all_matches);
  matched = matches;
end

function [matches] = find_matches(ref, src, idx, dist, init)
  global beta gamma
  assert(all(size(init)==[640 480]))
  [h w] = size(init);
  y = reshape(dist, [h w]);
  z = init;

  if sum(z(:)==1) > 2
    in_mean = mean(reshape(y(z==1), 1, []), 'omitnan');
    in_std = std(reshape(y(z==1), 1, []), 'omitnan');
  else
    % handle bad initialization (all outliers)--shouldn't happen
    in_mean = min(y(:));
    in_std = std(y(:), 'omitnan');
  end

  if sum(z(:)==-1) > 2
    out_mean = mean(reshape(y(z==-1), 1, []), 'omitnan');
    out_std = std(reshape(y(z==-1), 1, []), 'omitnan');
  else
    % handle bad initialization (all inliers)--shouldn't happen
    out_mean = max(y(:));
    out_std = std(y(:), 'omitnan');
  end
  assert(~isnan(in_mean));
  assert(~isnan(in_std));
  assert(~isnan(out_mean));
  assert(~isnan(out_std));

  for i=1:10
    % E-step
    last_z = z;
    mean_field = [z(2:end,:); zeros(1, w)] + [zeros(1, w); z(1:end-1,:)] + [z(:,2:end) zeros(h, 1)] + [zeros(h, 1) z(:,1:end-1)];
    r_in = beta*mean_field - log(in_std) - (y - in_mean).^2/(2*in_std.^2) + gamma;
    r_out = -beta*mean_field - log(out_std) - (y - out_mean).^2/(2*out_std.^2) - gamma;
    z = 2*exp(r_in) ./ (exp(r_out) + exp(r_in)) - 1;
    % M-step
    in_mean = sum((1+z(:))/2.*y(:), 'omitnan')...
      /sum((1+z(:))/2, 'omitnan');
    in_std = sqrt(sum((1+z(:))/2.*y(:).^2, 'omitnan')...
      /sum((1+z(:))/2, 'omitnan') - in_mean.^2);
    out_mean = sum((1-z(:))/2.*y(:), 'omitnan')...
      /sum((1-z(:))/2, 'omitnan');
    out_std = sqrt(sum((1-z(:))/2.*y(:).^2, 'omitnan')...
      /sum((1-z(:))/2, 'omitnan') - out_mean.^2);
    if in_mean >= out_mean && params.debug
      dbob.w = w;
      dbob.h = h;
      dbob.r_in = r_in;
      dbob.r_out = r_out;
      dbob.z = z;
      dbob.last_z = last_z;
      dbob.y = y;
      dbob.in_mean = in_mean;
      dbob.out_mean = out_mean;
      dbob.in_std = in_std;
      dbob.out_std = out_std;
      assignin('base', 'mycp_debug', dbob);
    end
    assert(in_mean < out_mean);
    assert(~any(isnan([in_mean, in_std, out_mean, out_std])));
    if ~any(z(:) .* last_z(:) < 0)
      break
    end
  end
  matches = [find(z > 0) idx(find(z>0))];
end

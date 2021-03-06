if strcmp('kitti', dataset)
  if 0 == exist('kitti_sequence')
    kitti_sequence = 0;
  end
  poses = dlmread(sprintf('../data/dataset/poses/%02d.txt', kitti_sequence));
  tr = dlmread(sprintf('../data/dataset/sequences/%02d/tr.txt', ...
      kitti_sequence));
  tr = [reshape(tr, [4 3])'; 0 0 0 1];
  pmats = mat2cell(poses, ones(1, size(poses, 1)));
  pmats = cellfun(@(p) inv(tr)*[reshape(p, [4 3])'; 0 0 0 1]*tr, pmats, 'UniformOutput', false);
else
  switch dataset
  case 'desk'
    pose_file = '../data/freiburg1_desk.poses';
    ts_file = '../data/freiburg1_desk_depth_timestamps.csv';
  case 'room'
    pose_file = '../data/freiburg1_room.poses';
    ts_file = '../data/freiburg1_room_depth_timestamps.csv';
  case 'shark'
    pose_file = '../data/shark_bot_01.poses';
  end

  if strcmp(dataset, 'shark')
    poses = csvread(pose_file);
  else
    raw_poses = dlmread(pose_file, ' ', 3, 0);
    ts_file = fopen(ts_file);
    timestamps = textscan(ts_file, '%f %s', 'CommentStyle', '#');
    fclose(ts_file);
    timestamps = timestamps{1};
    n_poses = size(timestamps, 1);
    poses = zeros(size(timestamps, 1), 7);
    next_pose_i = zeros(n_poses, 1);

    % interpolate
    for i=1:n_poses
      next_pose_i(i) = find(raw_poses(:,1) > timestamps(i), 1);
    end

    delta_t = raw_poses(next_pose_i, 1) - raw_poses(next_pose_i-1, 1);
    c = abs(raw_poses(next_pose_i, 1) - timestamps)./delta_t;
    poses = c.*raw_poses(next_pose_i-1, 2:end) + ...
            (1-c).*raw_poses(next_pose_i, 2:end);
    poses = [poses(:,4:7) poses(:,1:3)];
    poses(:,1:4) = poses(:, 1:4) ./ sqrt(sum(poses(:, 1:4).^2, 2));
  end

  pmats = arrayfun(@(i) pos2mat(poses(i,:)), [1:size(poses, 1)], 'UniformOutput', false);
  clear raw_poses pose_file ts_file next_pose_i delta_t c
  clear timestamps n_poses i ans poses
end

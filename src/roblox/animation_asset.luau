local easing_enum_map = require("./easing_enum_map")

export type PoseNode = {
	position: vector,
	quat_vector: vector,
	quat_scalar: number,
	easing_function: (alpha: number) -> number,
}

type KeyframeNode = {
	time: number,
	poses: { [string]: PoseNode },
}

export type Poses = { [string]: PoseNode }

export type Identity = {
	keyframe_times: { number },
	keyframe_poses: { Poses },
	length: number,
}

local function recursive_tree_from_pose(
	keyframe: Keyframe,
	poses: { [string]: PoseNode },
	root_pose: Pose
)
	local sub_poses = root_pose:GetSubPoses() :: { Pose }

	for _, sub_pose in sub_poses do
		recursive_tree_from_pose(keyframe, poses, sub_pose)
	end

	local cframe = root_pose.CFrame
	local axis, angle = cframe:ToAxisAngle()

	local half_angle = angle / 2
	local position = cframe.Position
	local quat_vector = axis * math.sin(half_angle)
	local quat_scalar = math.cos(half_angle)

	poses[root_pose.Name] = {
		position = position,
		quat_vector = quat_vector,
		quat_scalar = quat_scalar,
		easing_function = easing_enum_map[root_pose.EasingStyle][root_pose.EasingDirection],
	}
end

local animation_asset = {}

function animation_asset.load_keyframe_sequence(keyframe_sequence: KeyframeSequence): Identity
	local keyframes = keyframe_sequence:GetKeyframes() :: { Keyframe }

	local markers = {}
	local keyframe_nodes: { KeyframeNode } = {}

	for keyframe_index, keyframe in keyframes do
		for _, marker in keyframe:GetMarkers() :: { KeyframeMarker } do
			markers[marker.Name] = keyframe_index
		end

		local poses: { [string]: PoseNode } = {}
		for _, pose_instance in keyframe:GetPoses() do
			recursive_tree_from_pose(keyframe, poses, pose_instance :: Pose)
		end

		table.insert(keyframe_nodes, {
			time = keyframe.Time,
			poses = poses,
		})
	end

	table.sort(keyframe_nodes, function(left, right)
		return left.time < right.time
	end)

	local length = keyframe_nodes[#keyframe_nodes].time
	local keyframe_times = {}
	local keyframe_poses = {}

	for index, keyframe_node in keyframe_nodes do
		keyframe_times[index] = keyframe_node.time
		keyframe_poses[index] = keyframe_node.poses
	end

	return {
		keyframe_times = keyframe_times,
		keyframe_poses = keyframe_poses,
		length = length,
	}
end

return animation_asset

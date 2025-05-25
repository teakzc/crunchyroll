--!optimize 2

local animation_asset = require("./roblox/animation_asset")
local create_rig = require("./rig")

export type AnimationTrack = {
	-- 0-1
	alpha: number,

	-- 0-1
	start_fade_time: number,
	stop_fade_time: number,
	weight: number,

	-- arbitrary number
	priority: number,
}

local function vector_lerp(a: vector, b: vector, t: number): vector
	return a + (b - a) * t
end

local function quat_nlerp(a_vector: vector, a_scalar: number, b_vector: vector, b_scalar, t: number)
	local quat_vector = vector_lerp(a_vector, b_vector, t)
	local quat_scalar = math.lerp(a_scalar, b_scalar, t)

	--stylua: ignore
	local magnitude = math.sqrt(quat_vector.X^2 + quat_vector.Y^2 + quat_vector.Z^2 + quat_scalar^2)
	return quat_vector / magnitude, quat_scalar / magnitude
end

local function solve_fade_time_influence(
	real_time: number,
	animation_length: number,
	start_fade_time: number,
	stop_fade_time: number
): number
	if real_time <= start_fade_time then
		return math.min(1 - ((start_fade_time - real_time) / start_fade_time), 1)
	elseif real_time >= (animation_length + stop_fade_time) then
		return math.min(
			1 - ((real_time - (animation_length - stop_fade_time)) / stop_fade_time),
			1
		)
	else
		return 1
	end
end

local function animation_solver(
	rig: create_rig.Identity,
	tracks: {
		[animation_asset.Identity]: AnimationTrack,
	},
	root: CFrame
)
	local limb_array: { create_rig.Limb } = rig._topologically_sorted_limbs
	for _, limb in limb_array do
		limb.priority = -1
	end

	local total_weight = 0
	for _, track in tracks do
		total_weight += track.weight
	end

	for animation, playback in tracks do
		local priority = playback.priority
		local real_time = animation.length * playback.alpha
		local influence = (playback.weight / total_weight)
			* solve_fade_time_influence(
				real_time,
				animation.length,
				playback.start_fade_time,
				playback.stop_fade_time
			)

		-- Figure out which keyframes to interpolate between
		local time_after: number?
		local time_before: number?
		local poses_after: animation_asset.Poses?
		local poses_before: animation_asset.Poses?

		for index, keyframe_time in animation.keyframe_times do
			if keyframe_time >= real_time then
				time_after = keyframe_time
				poses_after = animation.keyframe_poses[index]

				time_before = animation.keyframe_times[index - 1]
				poses_before = animation.keyframe_poses[index - 1]

				break
			end
		end

		-- Solve limb transforms
		for _, node in limb_array do
			if node.priority > priority then
				continue
			end

			local left_pose: animation_asset.PoseNode? = poses_before and poses_before[node.name]
			local right_pose: animation_asset.PoseNode? = poses_after and poses_after[node.name]
			local left_or_right = left_pose or right_pose

			--stylua: ignore start
			if left_pose and right_pose then
				local alpha = left_pose.easing_function((real_time - (time_before :: number)) / ((time_after :: number) - (time_before :: number)))
				local position = vector_lerp(left_pose.position, right_pose.position, alpha)
				local quat_vector, quat_scalar = quat_nlerp(
					left_pose.quat_vector, left_pose.quat_scalar, 
					right_pose.quat_vector, right_pose.quat_scalar, 
					alpha
				)

				node.position = vector_lerp(node.position, position, influence)
				node.quat_vector, node.quat_scalar = quat_nlerp(
					node.quat_vector, node.quat_scalar, 
					quat_vector, quat_scalar, 
					influence
				)
				node.priority = priority
			elseif left_or_right then
				node.position = vector_lerp(node.position, left_or_right.position, influence)
				node.quat_vector, node.quat_scalar = quat_nlerp(
					node.quat_vector, node.quat_scalar, 
					left_or_right.quat_vector, left_or_right.quat_scalar, influence
				)
				node.priority = priority
			end
			--stylua: ignore end
		end
	end

	local result_coordinate_frames: { [string]: CFrame } = rig.result_coordinate_frames
	result_coordinate_frames["root"] = root

	for _, limb in limb_array do
		local position = limb.position
		local quat_vector = limb.quat_vector

		--stylua: ignore
		local transform = CFrame.new(
			position.X, position.Y, position.Z,
			quat_vector.X, quat_vector.Y, quat_vector.Z, limb.quat_scalar
		)

		result_coordinate_frames[limb.name] = result_coordinate_frames[limb.depends_on]
			* limb.c0
			* transform
			* limb.c1
	end
end

return animation_solver

local animation_asset = require("./roblox/animation_asset")
local create_rig = require("./rig")

export type AnimationPlayback = {
	-- 0-1
	alpha: number,

	-- 0-1
	influence: number,

	-- arbitrary number
	priority: number,
}

local function get_keyframe_before(
	keyframe_array: { animation_asset.KeyframeNode },
	real_time: number
): animation_asset.KeyframeNode?
	local closest_keyframe: animation_asset.KeyframeNode? = nil
	local closest_distance: number = math.huge

	for _, keyframe_node in keyframe_array do
		local distance = keyframe_node.time - real_time
		local absoluteDistance = math.abs(distance)

		if distance <= 0 and (absoluteDistance < closest_distance) then
			closest_keyframe = keyframe_node
			closest_distance = absoluteDistance
		end
	end

	return closest_keyframe
end

local function get_keyframe_after(
	keyframeArray: { animation_asset.KeyframeNode },
	real_time: number
): animation_asset.KeyframeNode?
	local closestKeyframe: animation_asset.KeyframeNode? = nil
	local closestDistance: number = math.huge

	for _, keyframe in keyframeArray do
		local distance = keyframe.time - real_time
		local absoluteDistance = math.abs(distance)

		if distance >= 0 and (absoluteDistance < closestDistance) then
			closestKeyframe = keyframe
			closestDistance = absoluteDistance
		end
	end

	return closestKeyframe
end

local function animation_solver(
	rig: create_rig.Identity,
	anim_playbacks: { [animation_asset.Identity]: AnimationPlayback },
	root: CFrame
)
	local limb_array = rig._topologically_sorted_limbs
	for _, limb in limb_array do
		limb.priority = -1
	end

	for animation, playback in anim_playbacks do
		local real_time = animation.length * playback.alpha
		local before_keyframe, after_keyframe =
			get_keyframe_before(animation.keyframes, real_time),
			get_keyframe_after(animation.keyframes, real_time)

		for _, node in limb_array do
			if node.priority > playback.priority then
				continue
			end

			local left_pose, right_pose =
				before_keyframe and before_keyframe.poses[node.name],
				after_keyframe and after_keyframe.poses[node.name]

			if left_pose and right_pose then
				node.priority = playback.priority
				local calculated_transform = left_pose.coordinate_frame:Lerp(
					right_pose.coordinate_frame,
					left_pose.easing_function(
						(real_time - left_pose.time) / (right_pose.time - left_pose.time)
					)
				)

				node.transform = node.transform:Lerp(calculated_transform, playback.influence)
			elseif left_pose or right_pose then
				node.priority = playback.priority
				local calculated_transform = (
					(left_pose or right_pose) :: animation_asset.PoseNode
				).coordinate_frame

				node.transform = node.transform:Lerp(calculated_transform, playback.influence)
			end
		end
	end

	rig.result_coordinate_frames["root"] = root
	for _, limb in rig._topologically_sorted_limbs do
		rig.result_coordinate_frames[limb.name] = rig.result_coordinate_frames[limb.depends_on]
			* limb.c0
			* limb.transform
			* limb.c1
	end
end

return animation_solver

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

local function animation_solver(
	rig: create_rig.Identity,
	anim_playbacks: {
		[animation_asset.Identity]: AnimationPlayback,
	},
	root: CFrame
)
	local limb_array = rig._topologically_sorted_limbs
	for _, limb in limb_array do
		limb.priority = -1
	end

	for animation, playback in anim_playbacks do
		local real_time = animation.length * playback.alpha
		local keyframe_after: animation_asset.KeyframeNode?, closest_distance_after: number, keyframe_before: animation_asset.KeyframeNode?, closest_distance_before: number =
			nil, math.huge, nil, math.huge

		for _, keyframe in animation.keyframes do
			local distance = keyframe.time - real_time
			local absolute_distance = math.abs(distance)

			if distance >= 0 and (absolute_distance < closest_distance_after) then
				keyframe_after, closest_distance_after = keyframe, absolute_distance
			elseif distance <= 0 and (absolute_distance < closest_distance_before) then
				keyframe_before, closest_distance_before = keyframe, absolute_distance
			end
		end

		for _, node in limb_array do
			if node.priority > playback.priority then
				continue
			end

			local left_pose, right_pose =
				keyframe_before and keyframe_before.poses[node.name],
				keyframe_after and keyframe_after.poses[node.name]

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

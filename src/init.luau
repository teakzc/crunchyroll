local animation_asset = require("@self/roblox/animation_asset")
local animation_solver = require("@self/animation_solver")
local rig = require("@self/rig")

export type LimbInfo = rig.LimbInfo
export type Rig = rig.Identity

export type AnimationPlayback = animation_solver.AnimationPlayback
export type AnimationAsset = animation_asset.Identity

return {
	load_keyframe_sequence = animation_asset.load_keyframe_sequence,
	create_rig = rig.create_rig,

	solve_animation = animation_solver,
}

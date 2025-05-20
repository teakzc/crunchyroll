local animation_asset = require("./roblox/animation_asset")
local animation_solver = require("./animation_solver")

export type AnimationTrack = {
	asset: animation_asset.Identity,

	alpha: number,

	-- not clamped between 0 and 1
	weight: number,

	priority: number,

	start_fade_time: number,
	stop_fade_time: number,

	playback_speed: number,

	looped: boolean,
}

local function solve_fade_time(
	alpha: number,
	animation_length: number,
	start_fade_time: number,
	stop_fade_time: number
): number
	local time_into_anim = alpha * animation_length

	if time_into_anim <= start_fade_time then
		local influence = 1 - ((start_fade_time - time_into_anim) / start_fade_time)

		return math.min(influence, 1)
	elseif time_into_anim >= (animation_length + stop_fade_time) then
		local influence = 1
			- ((time_into_anim - (animation_length - stop_fade_time)) / stop_fade_time)

		return math.min(influence, 1)
	end

	return 1
end

local function solve_tracks(
	tracks: { [animation_asset.Identity]: AnimationTrack }
): { [animation_asset.Identity]: animation_solver.AnimationPlayback }
	local track_weights = {}
	local total_weight = 0

	for _, track in tracks do
		total_weight += track.weight
	end

	for i, track in tracks do
		track_weights[i] = track.weight / total_weight
	end

	local playbacks: { [animation_asset.Identity]: animation_solver.AnimationPlayback } = {}

	for asset, track in tracks do
		local influence = solve_fade_time(
			track.alpha,
			track.asset.length,
			track.start_fade_time,
			track.stop_fade_time
		)

		-- TODO: fix type error
		track_weights[asset] *= influence :: any

		playbacks[asset] = {
			asset = track.asset,
			alpha = track.alpha,
			influence = track_weights[asset],
			priority = track.priority,
		}
	end

	return playbacks
end

return {
	solve_tracks = solve_tracks,
	solve_fade_time = solve_fade_time,
}

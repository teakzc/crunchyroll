local ReplicatedStorage = game:GetService("ReplicatedStorage")

local create_bench = require(ReplicatedStorage.benches.create_bench)
local crunchyroll = require(ReplicatedStorage.crunchyroll)
local mirror_crunchyroll = require(ReplicatedStorage.benches.mirrors.crunchyroll)
local rig_template = require(ReplicatedStorage.client.rig) :: any

local rig = crunchyroll.create_rig(rig_template)
local mirror_rig = mirror_crunchyroll.create_rig(rig_template)

local animation = crunchyroll.load_keyframe_sequence(ReplicatedStorage.assets.animation, rig)
local mirror_animation =
	mirror_crunchyroll.load_keyframe_sequence(ReplicatedStorage.assets.animation)

return create_bench(function() end, {
	["new"] = function()
		for i = 1, 500 do
			crunchyroll.solve_animation(rig, {
				[animation] = {
					priority = 1,

					start_fade_time = 0,
					stop_fade_time = 0,
					weight = 1,

					alpha = 0.5,
				},
			}, CFrame.identity)
		end
	end,

	["mirror"] = function()
		for i = 1, 500 do
			mirror_crunchyroll.solve_animation(mirror_rig, {
				[mirror_animation] = {
					priority = 1,

					start_fade_time = 0,
					stop_fade_time = 0,
					weight = 1,

					alpha = 0.5,
				},
			}, CFrame.identity)
		end
	end,
})

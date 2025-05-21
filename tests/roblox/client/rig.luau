local ReplicatedStorage = game:GetService("ReplicatedStorage")

local crunchyroll = require(ReplicatedStorage.crunchyroll)

local rig = crunchyroll.create_rig({
	root_name = "Torso",

	coordinate_frame0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	coordinate_frame1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),

	children = {
		["Head"] = {
			coordinate_frame0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
			coordinate_frame1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),

			children = {},
		},
		["Left Leg"] = {
			coordinate_frame0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
			coordinate_frame1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),

			children = {},
		},
		["Right Leg"] = {
			coordinate_frame0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
			coordinate_frame1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),

			children = {},
		},
		["Left Arm"] = {
			coordinate_frame0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
			coordinate_frame1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),

			children = {},
		},
		["Right Arm"] = {
			coordinate_frame0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
			coordinate_frame1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),

			children = {},
		},
	},
} :: crunchyroll.RigRootNode)

return rig

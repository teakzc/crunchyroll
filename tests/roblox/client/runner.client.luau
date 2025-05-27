local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local crunchyroll = require(ReplicatedStorage.crunchyroll)
local rig_template = require("./rig") :: any

local rig = crunchyroll.create_rig(rig_template)

local TEST_TRANSFORM = CFrame.new(10, 0, -0) * CFrame.fromEulerAnglesYXZ(0, math.rad(90), 0)

local keyframe_sequence = ReplicatedStorage.assets.animation
local character_template = ReplicatedStorage.assets.character

local function spawn_character()
	local spawned_rig = character_template:Clone()

	for _, child in spawned_rig:GetChildren() do
		if child:IsA("BasePart") then
			child.Anchored = true
		end
	end

	spawned_rig:PivotTo(TEST_TRANSFORM)

	-- strict datamodel types, lol.
	spawned_rig.Parent = workspace :: any

	return spawned_rig
end

local animation = crunchyroll.load_keyframe_sequence(keyframe_sequence, rig)
local alpha = 0
local character = spawn_character()

RunService.RenderStepped:Connect(function(delta_time)
	-- loop the animation
	alpha += delta_time / animation.length
	alpha %= 1

	-- HumanoidRootPart.CFrame for the root CFrame
	crunchyroll.solve_animation(rig, {
		[animation] = {
			priority = 1,

			start_fade_time = 0,
			stop_fade_time = 0,
			weight = 1,

			alpha = alpha,
		},
	}, character.HumanoidRootPart.CFrame)

	character["Left Arm"].CFrame = rig.result_coordinate_frames["Left Arm"]
	character["Right Arm"].CFrame = rig.result_coordinate_frames["Right Arm"]

	character["Left Leg"].CFrame = rig.result_coordinate_frames["Left Leg"]
	character["Right Leg"].CFrame = rig.result_coordinate_frames["Right Leg"]

	character["Torso"].CFrame = rig.result_coordinate_frames["Torso"]
	character["Head"].CFrame = rig.result_coordinate_frames["Head"]
end)

local Enum = Enum or (require("@lune/roblox").Enum :: any) :: typeof(Enum)

local easings = require("../easings")

return {
	[Enum.PoseEasingStyle.Linear] = {
		[Enum.PoseEasingDirection.In] = easings.linear,
		[Enum.PoseEasingDirection.Out] = easings.linear,
		[Enum.PoseEasingDirection.InOut] = easings.linear,
	},

	[Enum.PoseEasingStyle.Cubic] = {
		[Enum.PoseEasingDirection.In] = easings.cubic_in,
		[Enum.PoseEasingDirection.Out] = easings.cubic_out,
		[Enum.PoseEasingDirection.InOut] = easings.cubic_in_out,
	},

	[Enum.PoseEasingStyle.Bounce] = {
		[Enum.PoseEasingDirection.In] = easings.bounce_in,
		[Enum.PoseEasingDirection.Out] = easings.bounce_out,
		[Enum.PoseEasingDirection.InOut] = easings.bounce_in_out,
	},

	[Enum.PoseEasingStyle.Elastic] = {
		[Enum.PoseEasingDirection.In] = easings.elastic_in,
		[Enum.PoseEasingDirection.Out] = easings.elastic_out,
		[Enum.PoseEasingDirection.InOut] = easings.elastic_in_out,
	},
}

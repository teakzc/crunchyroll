--!native
local Enum = Enum or ((require("@lune/roblox") :: any).Enum) :: typeof(Enum)

local Easing = {
	[Enum.PoseEasingStyle.Linear] = {
		[Enum.PoseEasingDirection.In] = function(Value: number): number
			return Value
		end,

		[Enum.PoseEasingDirection.Out] = function(Value: number): number
			return Value
		end,

		[Enum.PoseEasingDirection.InOut] = function(Value: number): number
			return Value
		end,
	},

	[Enum.PoseEasingStyle.Cubic] = {
		[Enum.PoseEasingDirection.In] = function(Value: number): number
			return Value ^ 3
		end,

		[Enum.PoseEasingDirection.Out] = function(Value: number): number
			return 1 - ((1 - Value) ^ 3)
		end,

		[Enum.PoseEasingDirection.InOut] = function(Value: number): number
			if Value < 0.5 then
				return 4 * (Value ^ 3)
			end

			local Base = -2 * Value + 2
			return 1 - (Base ^ 3) * 0.5
		end,
	},

	[Enum.PoseEasingStyle.Bounce] = {
		[Enum.PoseEasingDirection.In] = function(Value: number): number
			local Compliment = 1 - Value

			if Compliment < 0.36363636363636365 then
				return 1 - 7.5625 * Compliment * Compliment
			end

			if Compliment < 0.7272727272727273 then
				local Base = Compliment - 0.5454545454545454
				return 1 - 7.5625 * Base * Base + 0.75
			end

			if Compliment < 0.9090909090909091 then
				local Base = Compliment - 0.9090909090909091
				return 1 - 7.5625 * Base * Base + 0.9375
			end

			local Base = Compliment - 0.9545454545454546
			return 1 - 7.5625 * Base * Base + 0.984375
		end,

		[Enum.PoseEasingDirection.Out] = function(Value: number): number
			if Value < 0.36363636363636365 then
				return 7.5625 * Value * Value
			end

			if Value < 0.7272727272727273 then
				local Base = Value - 0.5454545454545454
				return 7.5625 * Base * Base + 0.75
			end

			if Value < 0.9090909090909091 then
				local Base = Value - 0.9090909090909091
				return 7.5625 * Base * Base + 0.9375
			end

			local Base = Value - 0.9545454545454546
			return 7.5625 * Base * Base + 0.984375
		end,

		[Enum.PoseEasingDirection.InOut] = function(Value: number): number
			if Value < 0.5 then
				local Compliment = 1 - 2 * Value

				if Compliment < 0.36363636363636365 then
					return (1 - 7.5625 * Compliment * Compliment) * 0.5
				end

				if Compliment < 0.7272727272727273 then
					local Base = Compliment - 0.5454545454545454
					return (1 - 7.5625 * Base * Base + 0.75) * 0.5
				end

				if Compliment < 0.9090909090909091 then
					local Base = Compliment - 0.9090909090909091
					return (1 - 7.5625 * Base * Base + 0.9375) * 0.5
				end

				local Base = Compliment - 0.9545454545454546
				return (1 - 7.5625 * Base * Base + 0.984375) * 0.5
			end

			local Compliment = 2 * Value - 1

			if Compliment < 0.36363636363636365 then
				return (1 + 7.5625 * Compliment * Compliment) * 0.5
			end

			if Compliment < 0.7272727272727273 then
				local Base = Compliment - 0.5454545454545454
				return (1 + 7.5625 * Base * Base + 0.75) * 0.5
			end

			if Compliment < 0.9090909090909091 then
				local Base = Compliment - 0.9090909090909091
				return (1 + 7.5625 * Base * Base + 0.9375) * 0.5
			end

			local Base = Compliment - 0.9545454545454546
			return (1 + 7.5625 * Base * Base + 0.984375) * 0.5
		end,
	},

	[Enum.PoseEasingStyle.Elastic] = {
		[Enum.PoseEasingDirection.In] = function(Value: number): number
			return -2 ^ (10 * Value - 10) * math.sin((Value * 10 - 10.75) * 2.0943951023931953)
		end,

		[Enum.PoseEasingDirection.Out] = function(Value: number): number
			return 2 ^ (-10 * Value) * math.sin((Value * 10 - 0.75) * 2.0943951023931953) + 1
		end,

		[Enum.PoseEasingDirection.InOut] = function(Value: number): number
			if Value < 0.5 then
				return -2 ^ (20 * Value - 10)
					* math.sin((20 * Value - 11.125) * 1.3962634015954636)
					* 0.5
			end

			return 2 ^ -20 * Value
				+ 10 * math.sin(20 * Value - 11.125 * 1.3962634015954636) * 0.5
				+ 1
		end,
	},
}

return Easing

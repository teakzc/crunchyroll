local TEST, CASE, CHECK, FINISH = require("@vendor/testkit").test()

local animation_track_solver = require("@src/animation_track_solver")

TEST("animation track solver", function()
	CASE("fadetime alpha")
	do
		local weight = animation_track_solver.solve_fade_time(0.5, 5, 2, 2)

		CHECK(weight == 1)
	end
end)

FINISH()

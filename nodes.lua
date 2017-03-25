local tmr = 0
minetest.register_node("lua_computer:monitor_off", {
	description = "Lua Computer Monitor",
	tiles = {
		"case.png",
		"monitor_bottom.png",
		"case.png",
		"case.png",
		"monitor_screen.png",
		"case.png",
	},
	groups = {cracky=3},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		terminal_form(player)
		local timer = minetest.get_node_timer(pos):start(0.2)
	end,
	on_timer = function(pos, elapsed)
		if minetest.get_node_timer(pos):get_elapsed() == 2 then
			minetest.set_node(pos, {name="lua_computer:monitor_on"})
		end
	end
})

minetest.register_node("lua_computer:monitor_on", {
	description = "Lua Computer Monitor On",
	tiles = {
		"case.png",
		"monitor_bottom.png",
		"case.png",
		"case.png",
		"monitor_screen_on.png",
		"case.png",
	},
	groups = {cracky=3, not_in_creative_inventory=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		terminal_form(player)
		local timer = minetest.get_node_timer(pos):start(0.2)
	end,
	on_timer = function(pos, elapsed)
		if minetest.get_node_timer(pos):get_elapsed() == 2 then
			minetest.set_node(pos, {name="lua_computer:monitor_off"})
		end
	end
})

minetest.register_node("lua_computer:tower", {
	description = "Lua Computer Tower",
	tiles = {
		"case.png",
		"monitor_bottom.png",
		"case.png",
		"case.png",
		"tower_front.png",
		"case.png",
	},
	groups = {cracky=3}
})

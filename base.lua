function terminal_form(player)
	local output = minetest.serialize(cprompt)
	local end_out = output:gsub("{", ""):gsub("}", ""):gsub("return", ""):gsub("\"", ""):gsub(",", ""):gsub("\\", "")
	minetest.show_formspec(player:get_player_name(), "lua_computer:terminal",
		"size[10,10]" ..
		"background[0,0;10,10;monitor_screen.png;true]" ..
		"textarea[.8,.5;8.84,9.37;terminal;;>" .. minetest.formspec_escape(end_out) .. "]" ..
		"button[1,9.5;2,1;submit;]")
end

-- If there isn't a file, make one.
local f, err = io.open(minetest.get_worldpath() .. "/email_information.db", "r")
if f == nil then
	local f, err = io.open(minetest.get_worldpath() .. "/email_information.db", "w")
     	f:write(minetest.serialize(email))
     	f:close()
end

-- Saves changes to player's account.
function save_email()
     	local data = email
     	local f, err = io.open(minetest.get_worldpath() .. "/email_information.db", "w")
     	if err then
        	return err
     	end
     	f:write(minetest.serialize(data))
     	f:close()
end

-- Reads changes from player's account.
function read_email()
     	local f, err = io.open(minetest.get_worldpath() .. "/email_information.db", "r")
     	local data = minetest.deserialize(f:read("*a"))
     	f:close()
          	return data
end

command_list = {}
refined_commands = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "lua_computer:terminal" then
		if fields.submit then
			if fields.terminal ~= nil then
				local s = minetest.serialize(cprompt)
				local s_fin = s:gsub("{", ""):gsub("}", ""):gsub("return", ""):gsub("\"", "")
				if string.match(fields.terminal, ">help") then
					table.insert(cprompt, "help\n\nLua_Computer OS v0.1\n" ..
					"You can view all commands by typing: command -list.\n>")
					terminal_form(player)
				end
				if string.match(fields.terminal, ">command %-list") then
					command_list = minetest.get_dir_list(minetest.get_modpath("lua_computer") ..
					"/commands", false)
					refined_commands = minetest.serialize(command_list):gsub("base_commands.lua", "")
					:gsub(".lua", ""):gsub(",", "\n"):gsub(" ", "")
					table.insert(cprompt, "command -list\n" .. refined_commands ..
					" \nclose               open\ndelete              restart\n" ..
					"help                 save\nip                    shutdown\nnew               " ..
					"  time\n>")
					terminal_form(player)
				end
			end
		end
	end
end)

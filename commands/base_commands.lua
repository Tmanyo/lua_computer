fname = {}
close_question = {}
do_nothing = {}
total = 1
email = {}
email_current_body = {}
email_current_subject = {}
recipient = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "lua_computer:terminal" then
		if fields.submit then
			if string.match(fields.terminal, ">ip") then
				local playername = player:get_player_name()
				table.insert(cprompt, "ip\n\n" .. minetest.get_player_ip(playername) .. "\n>")
				terminal_form(player)
			end
			if string.match(fields.terminal, ">new %-name .+") then
				fname = string.match(fields.terminal, ">new %-name .+"):gsub(">new %-name ", "")
				command_list = minetest.get_dir_list(minetest.get_modpath("lua_computer") ..
				"/commands", false)
				refined_commands = minetest.serialize(command_list):gsub("base_commands.lua", "")
				:gsub(".lua", ""):gsub(",", "\n"):gsub(" ", "")
				if string.match(refined_commands, fname) then
					table.insert(cprompt, "new -name " .. fname .. " \n\nFile already exists.\n>")
				else
					cprompt = " "
				end
				terminal_form(player)
			end
			if string.match(fields.terminal, ">save") then
				if fname == "" or fname == nil then
					table.insert(cprompt, "save\n\nNo file is currently being edited.\n>")
					terminal_form(player)
				else
					local f, err = io.open(minetest.get_modpath("lua_computer") .. "/commands/" ..
					fname .. ".lua", "r")
					if f == nil then
						local f, err = io.open(minetest.get_modpath("lua_computer") ..
						"/commands/" .. fname .. ".lua", "w")
						local code = fields.terminal:gsub(">", ""):gsub("save", "")
						f:write(code)
						f:close()
					else
						local f, err = io.open(minetest.get_modpath("lua_computer") ..
						"/commands/" .. fname .. ".lua", "w")
						local code = fields.terminal:gsub(">", ""):gsub("save", "")
						f:write(code)
						f:close()
					end
					cprompt = {}
					fname = ""
					terminal_form(player)
				end
			end
			if string.match(fields.terminal, ">open .+") then
				local command_raw = string.match(fields.terminal, ">open .+")
				local file_to_edit = command_raw:gsub(">open ", "")
				local f, err = io.open(minetest.get_modpath("lua_computer") .. "/commands/" ..
				file_to_edit, "r")
				local code_to_edit = f:read("*a")
				f:close()
				cprompt = {}
				table.insert(cprompt, code_to_edit)
				fname = file_to_edit:gsub(".lua", "")
				terminal_form(player)
			end
			if string.match(fields.terminal, ">close\n\n.+") then
				do_nothing = 1
			elseif string.match(fields.terminal, ">close") then
				if fname == nil then
					table.insert(cprompt, ">close\n\nNo file is currently being edited.\n>")
					terminal_form(player)
				else
					if close_question == 0 then
						terminal_form(player)
					else
						table.insert(cprompt, ">close\n\nAre you sure you want to close? [Y/N]\n>")
						terminal_form(player)
						close_question = 1
					end
				end
			end
			if string.match(fields.terminal, ">y.+") then
				do_nothing = 1
			elseif string.match(fields.terminal, ">n.+") then
				do_nothing = 1
			elseif string.match(fields.terminal, ">y") then
				if close_question == 1 then
					cprompt = {}
					fname = ""
					terminal_form(player)
					close_question = 0
				else
					table.insert(cprompt, "y\n\nNo action currently requires your approval.\n>")
					terminal_form(player)
				end
			end
			if string.match(fields.terminal, ">n") then
				if close_question == 1 then
					terminal_form(player)
					close_question = 0
					fname = ""
				else
					table.insert(cprompt, "n\n\nNo action currently requires your approval.\n>")
					terminal_form(player)
				end
			end
			if string.match(fields.terminal, ">delete .+") then
				local command_raw1 = string.match(fields.terminal, ">delete .+")
				local file_to_delete = command_raw1:gsub(">delete ", "")
				os.remove(minetest.get_modpath("lua_computer") .. "/commands/" .. file_to_delete)
				table.insert(cprompt, "delete " .. file_to_delete .. " \n\nFile successfully deleted.\n>")
				terminal_form(player)
			end
			if string.match(fields.terminal, ">restart") then
				cprompt = {}
				fname = ""
				terminal_form(player)
			end
			if string.match(fields.terminal, ">shutdown") then
				cprompt = {}
				fname = ""
				minetest.close_formspec(player:get_player_name(), "lua_computer:terminal")
			end
			if string.match(fields.terminal, ">time") then
				table.insert(cprompt, "time\n\n" .. os.date("%c", os.time()) .. " \n>")
				terminal_form(player)
			end
			if string.match(fields.terminal, ">email %-compose .+") then
				recipient = string.match(fields.terminal, ">email %-compose .+"):
				gsub(">email", ""):gsub("compose", ""):gsub(" ", ""):gsub("-", "")
				if not email[total][recipient] then
					email[total][recipient] = {}
				else
					total = #email[recipient] + 1
					email[total][recipient] = {}
				end
				table.insert(email[total][recipient],1,{sender=player:get_player_name()})
				cprompt = {}
				table.insert(cprompt, "Subject:")
				terminal_form(player)
				email_current_subject = 1
				email_current_body = 1
				save_email()
			end
			if string.match(fields.terminal, "> Subject: .+") then
				if email_current_subject ~= 1 then
					do_nothing = 1
				else
					if fields.terminal:sub(12, fields.terminal:len()) == nil then
						table.insert(email[total][recipient],1,{subject="(No Subject)"})
					else
						table.insert(email[total][recipient],1,{subject=fields.terminal:
						sub(12, fields.terminal:len())})
					end
					email_current_subject = 0
					save_email()
					cprompt = {}
					table.insert(cprompt, "Body:")
					terminal_form(player)
				end
			end
			if string.match(fields.terminal, "> Body: .+") then
				if email_current_body ~= 1 then
					do_nothing = 1
				elseif email_current_body == 1 then
					table.insert(email[total][recipient],1,{body=fields.terminal:sub(9, fields.terminal:
					len())})
					email_current_body = 0
					save_email()
					cprompt = {}
					table.insert(cprompt, "Email Successfully sent!")
					terminal_form(player)
				end
			end
		end
	end
end)

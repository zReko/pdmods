local button
local mpath=ModPath
local debug_instant=false

function do_pause(rem)
	if rem and rem>0 and not m_paused then
		managers.chat:send_message(1, nil, managers.localization:text("m_pause_timer", {
			time=tostring(rem)
			}))
		DelayedCalls:Add("Delayed:PauseCd", 1, function()
			do_pause(rem-1)
			end)
	else
		button:set_enabled(true)
		m_paused=not m_paused
		if m_paused then
			managers.time_speed:play_effect("pause", {
				speed=0,
				fade_in=1,
				fade_out=1,
				sustain=3600,
				timer="pausable",
				affect_timer={"player", "game", "game_animation"}
				})
			for peer_id, peer in pairs(managers.network._session._peers) do
				peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0, 1, 3600, 1)
				end
		else
			managers.time_speed:stop_effect("pause", 1)
			for peer_id, peer in pairs(managers.network._session._peers) do
				peer:send("stop_timespeed_effect", "pause", 1)
				end
			end
		end
	end

function MenuCallbackHandler:m_pause()
	if Network:is_server() and button:enabled() then
		button:set_enabled(false)
		button._parameters.text_id=m_paused and "m_pause" or "m_unpause"
		button._parameters.help_id=m_paused and "m_pause_desc" or "m_unpause_desc"
		do_pause(debug_instant and 0 or 5)
		end
	end

function MenuCallbackHandler:m_pause_visible()
	return not Global.game_settings.single_player and Network:is_server()
	end

Hooks:Add("MenuManagerBuildCustomMenus", "MenManBuildMenu:mpasu", function(menu_manager, nodes)
	if nodes.pause and MenuCallbackHandler:m_pause_visible() then
		button=nodes.pause:create_item(nil, {
			name="m_pause",
			text_id="m_pause",
			help_id="m_pause_desc",
			callback="m_pause"
			})
		nodes.pause:insert_item(button, 2)
		end
	end)

Hooks:Add("LocalizationManagerPostInit", "LocManInit:mpasu", function(loc)
	local lang, path=SystemInfo and SystemInfo:language(), "loc.en.txt"
	if lang==Idstring("french") then
		path="loc.fr.txt"
	elseif lang==Idstring("italian") then
		path="loc.it.txt"
		end
	loc:load_localization_file(mpath..path)
	end)
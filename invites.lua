script_name('InviteCounter')
script_author('Dominic Miracles')
script_version('1.3.0')
script_version_number(13)

require "lib.moonloader"
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local dlstatus = require('moonloader').download_status
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 2
local script_vers_text = "2.00"

local update_url = "https://raw.githubusercontent.com/thedqrkway-lua/scripts/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/thedqrkway-lua/scripts/blob/main/imguitest.luac?raw=true"
local script_path = thisScript().path

local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)

local main_color = 0xFFA500
local main_color_text = "{FFA500}"
local white_color = 0xFFFFFF
local white_color_text = "{FFFFFF}"
local success_color = 0x00FF00
local success_color_text = "{00FF00}"
local tag = "{FFA500}[InviteCounter]:{FFFFFF} "
local name_script = u8"InviteCounter для Trinity от Dominic Miracles."

local themes = import "resource/imgui_themes.lua"

local mainIni = inicfg.load({
config =
    {
        invite = 0,
        day = os.date('%a'),
                all = 0
    }
}, "invite.ini")
if not doesFileExist('moonloader/config/invite.ini') then inicfg.save(mainIni, 'invite.ini') end

function main()
    wait(2500)
    sampAddChatMessage(tag ..'{FFFFFF}Скрипт успешно загружен, автор Dominic Miracles. Активация - /invites.', 0x1E90FF)
    repeat wait(0) until isSampAvailable()
    while not isSampAvailable() do wait(0) end
		  apply_custom_style()
    sampRegisterChatCommand('invites', cmd_invites)

		_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    imgui.Process = false


    sampRegisterChatCommand('invite.day', function() sampAddChatMessage(tag ..'{FFFFFF}Инвайты за день -'..mainIni.config.invite) end)

    sampRegisterChatCommand('invite.all', function() sampAddChatMessage(tag ..'{FFFFFF}Инвайты за все время - '..mainIni.config.all, 0x1E90FF) end)

    sampRegisterChatCommand('invite.reset', function()
        sampAddChatMessage(tag ..'{FFFFFF}Инвайты сброшены.', 0x1E90FF)
        mainIni.config.invite = 0
        mainIni.config.all = 0
        inicfg.save(mainIni, 'invite.ini')
    end)

    sampRegisterChatCommand('invite.reset.day', function()
        sampAddChatMessage(tag ..'{FFFFFF}Инвайты за день сброшены.', 0x1E90FF)
        mainIni.config.invite = 0
        inicfg.save(mainIni, 'invite.ini')
    end)

    sampRegisterChatCommand('invite.reset.all', function()
        sampAddChatMessage(tag ..'{FFFFFF}Инвайты за все время сброшены.', 0x1E90FF)
        mainIni.config.all = 0
        inicfg.save(mainIni, 'invite.ini')
    end)

		sampRegisterChatCommand('invite.help', function()
			sampAddChatMessage(tag ..'{FFFFFF}Помощь по командам.')
				sampAddChatMessage(tag ..'{FFFFFF}/invite.day - {FFFFFF}получить инвайты за день.{FFFFFF}')
				sampAddChatMessage(tag ..'{FFFFFF}/invite.all - получить инвайты за все время.')
				sampAddChatMessage(tag ..'{FFFFFF}/invite.reset - сбросить инвайты.')
				sampAddChatMessage(tag ..'{FFFFFF}/invite.reset.day - сбросить инвайты за день.')
				sampAddChatMessage(tag ..'{FFFFFF}/invite.reset.all - сбросить инвайты за все время.')
				sampAddChatMessage(tag ..'{FFFFFF}/invites - удобное imgui окно со всеми функциями скрипта.')
		end)

		downloadUrlToFile(update_url, update_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						updateIni = inicfg.load(nil, update_path)
						if tonumber(updateIni.info.vers) > script_vers then
								sampAddChatMessage(tag .."{FFFFFF}Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
								update_state = true
						end
						os.remove(update_path)
				end

    while true do
        wait(0)

				if update_state then
						downloadUrlToFile(script_url, script_path, function(id, status)
								if status == dlstatus.STATUS_ENDDOWNLOADDATA then
										sampAddChatMessage("Скрипт успешно обновлен!", -1)
										thisScript():reload()
								end
						end)
						break
				end

if main_window_state.v == false then
	imgui.Process = false
end

        if mainIni.config.day ~= os.date("%a") then
            sampAddChatMessage(tag ..'{FFFFFF}Новый день, вчерашние инвайты автоматически сброшены.', -1)
            mainIni.config.invite = 0
            mainIni.config.day = os.date('%a')
            inicfg.save(mainIni, 'invite.ini')
        end
    end
end

function sampev.onServerMessage(color,text)
    if text:find('Игрок %{abcdef%}(%w+_?%w+)%{ffffff%} принял предложение вступить в ваш клуб.') or text:find('Игрок %{abcdef%}(%w+_?%w+)%{ffffff%} принял предложение вступить в вашу организацию.') or text:find('Игрок %{abcdef%}(%w+_?%w+)%{ffffff%} принял предложение вступить в вашу банду.') or text:find ('Игрок %{abcdef%}(%w+_?%w+)%{ffffff%} принял предложение вступить в вашу мафию.') then
        mainIni.config.invite = mainIni.config.invite + 1
        mainIni.config.all = mainIni.config.all + 1
        inicfg.save(mainIni, 'invite.ini')
    end
end

function cmd_invites(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end

function imgui.OnDrawFrame()
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(350, 250), imgui.Cond.FirstUseEver)
		imgui.Begin(name_script, main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Text(u8'Инвайты за день - ' .. mainIni.config.invite)

		imgui.Spacing()
		imgui.Spacing()

		if imgui.Button(u8'Очистить инвайты за день.') then
			mainIni.config.invite = 0
			inicfg.save(mainIni, 'invite.ini')
			sampAddChatMessage(tag .. "Инвайты за день успешно сброшены.")
			main_window_state.v = false
		end
		imgui.Spacing()
		imgui.Spacing()

		imgui.Text(u8'Инвайты за все время - ' .. mainIni.config.all)

		imgui.Spacing()
		imgui.Spacing()

		if imgui.Button(u8'Очистить инвайты за все время.') then
			mainIni.config.all = 0
			inicfg.save(mainIni, 'invite.ini')
			sampAddChatMessage(tag .. "Инвайты за все время успешно сброшены.")
			main_window_state.v = false
		end

				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()
				imgui.Spacing()

				 if imgui.Button(u8'Очистить инвайты за день и все время.') then
					 mainIni.config.invite = 0
					 mainIni.config.all = 0
					 inicfg.save(mainIni, 'invite.ini')
					 sampAddChatMessage(tag .. "Инвайты за день и все время успешно сброшены.")
					 main_window_state.v = false
				 end

				 	imgui.Spacing()
					imgui.Spacing()
					imgui.Spacing()
					imgui.Spacing()

				 if imgui.Button(u8'Report Bug [ВКонтакте]') then os.execute('explorer "https://vk.com/miraclesmods"') end
					imgui.End()
				end

function apply_custom_style()imgui.SwitchContext()local a=imgui.GetStyle()local b=a.Colors;local c=imgui.Col;local d=imgui.ImVec4;a.WindowRounding=0.0;a.WindowTitleAlign=imgui.ImVec2(0.5,0.5)a.ChildWindowRounding=0.0;a.FrameRounding=0.0;a.ItemSpacing=imgui.ImVec2(5.0,5.0)a.ScrollbarSize=13.0;a.ScrollbarRounding=0;a.GrabMinSize=8.0;a.GrabRounding=0.0;b[c.TitleBg]=d(0.60,0.20,0.80,1.00)b[c.TitleBgActive]=d(0.60,0.20,0.80,1.00)b[c.TitleBgCollapsed]=d(0.60,0.20,0.80,1.00)b[c.CheckMark]=d(0.60,0.20,0.80,1.00)b[c.Button]=d(0.60,0.20,0.80,0.31)b[c.ButtonHovered]=d(0.60,0.20,0.80,0.80)b[c.ButtonActive]=d(0.60,0.20,0.80,1.00)b[c.WindowBg]=d(0.13,0.13,0.13,1.00)b[c.Header]=d(0.60,0.20,0.80,0.31)b[c.HeaderHovered]=d(0.60,0.20,0.80,0.80)b[c.HeaderActive]=d(0.60,0.20,0.80,1.00)b[c.FrameBg]=d(0.60,0.20,0.80,0.31)b[c.FrameBgHovered]=d(0.60,0.20,0.80,0.80)b[c.FrameBgActive]=d(0.60,0.20,0.80,1.00)b[c.ScrollbarBg]=d(0.60,0.20,0.80,0.31)b[c.ScrollbarGrab]=d(0.60,0.20,0.80,0.31)b[c.ScrollbarGrabHovered]=d(0.60,0.20,0.80,0.80)b[c.ScrollbarGrabActive]=d(0.60,0.20,0.80,1.00)b[c.Text]=d(1.00,1.00,1.00,1.00)b[c.Border]=d(0.60,0.20,0.80,0.00)b[c.BorderShadow]=d(0.00,0.00,0.00,0.00)b[c.CloseButton]=d(0.60,0.20,0.80,0.31)b[c.CloseButtonHovered]=d(0.60,0.20,0.80,0.80)b[c.CloseButtonActive]=d(0.60,0.20,0.80,1.00)
end

function update(url)
  downloadUrlToFile(url, thisScript().path, function(_, status1, _, _)
    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
      thisScript():reload()
    end
  end)
end

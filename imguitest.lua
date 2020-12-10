require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local tag = "[My first imgui]:"
local label = 0
local main_color = 0xFFA500
local main_color_text = "{FFA500}"
local ic_chat = 0x34C924
local ic_chat_text = "{34C924}"
local white_color = "{FFFFFF}"

update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/thedqrkway-lua/scripts/main/update.ini"
local update_path = getWorkingDirectory() .. "/config/update.ini"

local script_url = "https://github.com/thechampguess/scripts/blob/master/autoupdate_lesson_16.luac?raw=true"
local script_path = thisScript().path

local themes = import "resource/imgui_themes.lua"

local main_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(256)

local checked_radio =imgui.ImInt(1)

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)
		sampRegisterChatCommand("imgui", cmd_imgui)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
			end)

imgui.Process = false

imgui.SwitchContext()
themes.SwitchColorTheme(8)


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

end
end

	if isKeyJustPressed(VK_F3) then
		sampAddChatMessage("Вы нажали клавишу {FFFFFF}F3. " .. main_color_text .. "Ваш ник: {FFFFFF}" .. nick .. ", " .. main_color_text .. "Ваш ID: {FFFFFF}" .. id, main_color)
	end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление v2.0", "{FFFFFF}Это урок по обновлению\n{FFF000}Новая версия", "Закрыть", "", 0)
end

function cmd_imgui(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end

function imgui.OnDrawFrame()
	if main_window_state.v == false then
		imgui.Process = false
	end
			local sw, sh = getScreenResolution()
ScreenX, ScreenY = getScreenResolution() -- получения расширения
imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
imgui.SetNextWindowSize(imgui.ImVec2(800, 400), imgui.Cond.FirstUseEver)
imgui.Begin(u8('Отправлялка',nil))
	imgui.InputText(u8'Впишите сюда ваше сообщение.', text_buffer)
	imgui.Text(u8'Отправить сообщение ' .. text_buffer.v .. '?')
	if imgui.Button(u8'Отправить') then
		sampSendChat(u8:decode(text_buffer.v))
	end
	if imgui.Button(u8'Вывести сообщение "' .. text_buffer.v .. u8'" визуально ?') then
   sampAddChatMessage(nick .. ' сказал: ' .. u8:decode(text_buffer.v), ic_chat)
end
imgui.RadioButton("IC", checked_radio, 2)
imgui.RadioButton("OOC", checked_radio, 3)
imgui.RadioButton("ME", checked_radio, 4)
if imgui.Button("button1") then

                if checked_radio.v == 2 then
                    sampAddChatMessage('qq', main_color)
                elseif checked_radio.v == 3 then
                    sampAddChatMessage('qqq', main_color)
                elseif checked_radio.v == 4 then
                    sampAddChatMessage('qqqq', main_color)
                end
end
    imgui.End()
end

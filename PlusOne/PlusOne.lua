local _, Plus = ...

Plus.One = LibStub("AceAddon-3.0"):NewAddon("PlusOne", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
Plus.buttonHeight = 18
Plus.visible = false
Plus.One.chatcount = 0
Plus.whisperDelay = 1

Plus.SRSortPO = false
Plus.MSSortPO = true
Plus.OSSortPO = false

-- One.db.profile.rollSR

local PlusOneLDB = LibStub("LibDataBroker-1.1"):NewDataObject("PlusOne", {
type = "data source",
text = "Settings",
icon = "Interface\\Icons\\5_capture",
OnClick = function(widget, button) 
	if button == "LeftButton" then
		Plus.One:MainWindow()
	elseif button == "RightButton" then
		InterfaceOptionsFrame_OpenToCategory(Plus.One.optionsFrame)
	end
end,})
local icon = LibStub("LibDBIcon-1.0")

-- toggle visibility of minimap button
function Plus.One:MinimapButton() 
	Plus.One.db.profile.minimap.hide = not Plus.One.db.profile.minimap.hide if Plus.One.db.profile.minimap.hide then 
	   icon:Hide("PlusOne") 
   else 
	   icon:Show("PlusOne") 
   end 
end

function Plus.One:OnInitialize()
	Plus.One.db = LibStub("AceDB-3.0"):New("SettingsDB", {
		profile = { 
			minimap = { hide = false, }, 
			rollDuration = 10,
			trackSR = false,
			rollSR = 200,
			rollMS = 100,
			trackOS = false,
			rollOS = 99,
			trackedPlayers = {},
			minquality = 4
		},
	}) 
	
	icon:Register("PlusOne", PlusOneLDB, self.db.profile.minimap) 
	LibStub("AceConfig-3.0"):RegisterOptionsTable("PlusOne", Plus.PlusOneOptions, {"poraopt"})
	Plus.One.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PlusOne", "PlusOne")
	Plus.One:RegisterChatCommand("pora", "MainWindow") 
	Plus.One:RegisterChatCommand("poramm", "MinimapButton") 
end

function Plus.One:MainWindow()
	if Plus.visible then
		Plus.visible = false
		Plus.GUIRoot:Release()
	else
		Plus.visible = true
		Plus.GUIRoot = Plus.AceGUI:Create("Frame")
		-- Add the frame as a global variable under the name `PlusOneRaidRolls`
		_G["PlusOneRaidRolls"] = Plus.GUIRoot
		-- Register the global variable `PlusOneRaidRolls` as a "special frame"
		-- so that it is closed when the escape key is pressed.
		tinsert(UISpecialFrames, "PlusOneRaidRolls")
		-- Create a container frame
		Plus.GUIRoot:SetCallback("OnClose",function(widget) Plus.AceGUI:Release(widget) Plus.visible = false end)
		Plus.GUIRoot:SetTitle("PlusOne")
		Plus.GUIRoot:SetWidth(800)
		Plus.GUIRoot:SetHeight(500)
		Plus.GUIRoot:SetStatusText("Status Bar -- test")
		Plus.GUIRoot:SetLayout("Flow")

		-- Create outer containers and add them to panel
		local pwrap = Plus.AceGUI:Create("InlineGroup")
		local iwrap = Plus.AceGUI:Create("InlineGroup")
		local rwrap = Plus.AceGUI:Create("InlineGroup")
		pwrap:SetTitle("Player")
		iwrap:SetTitle("Item")
		rwrap:SetTitle("Roll")
		pwrap:SetLayout("Fill")
		iwrap:SetLayout("Fill")
		rwrap:SetLayout("Fill")

		pwrap:SetFullHeight(true)
		iwrap:SetFullHeight(true)
		rwrap:SetFullHeight(true)

		pwrap:SetWidth(226)
		iwrap:SetWidth(288)
		rwrap:SetWidth(246)

		Plus.GUIRoot:AddChild(pwrap)
		Plus.GUIRoot:AddChild(iwrap)
		Plus.GUIRoot:AddChild(rwrap)

		Plus.playercontainer = Plus.AceGUI:Create("ScrollFrame")
		Plus.itemcontainer = Plus.AceGUI:Create("ScrollFrame")
		Plus.rollcontainer = Plus.AceGUI:Create("ScrollFrame")

		pwrap:AddChild(Plus.playercontainer)
		iwrap:AddChild(Plus.itemcontainer)
		rwrap:AddChild(Plus.rollcontainer)

		-- Create layout boxes
		Plus.playercontainer:SetLayout("List")
		Plus.itemcontainer:SetLayout("List")
		Plus.rollcontainer:SetLayout("List")
		
		Plus:InitParty()
		Plus:InitLoot()
	end
end

-- handle delayed whisper messages
function Plus.One:DelayChatWhisper(reply, playerName)
	Plus.One.chatcount = Plus.One.chatcount - Plus.whisperDelay
	SendChatMessage(reply, "WHISPER", GetDefaultLanguage(playerName), playerName)
end

-- keep track of who is in the raid group
function Plus.One:RAID_ROSTER_UPDATE(event, ...)
	local playernames = {}
	Plus.playerscore = {}
	for i=1,40 do 
		local name = GetUnitName("raid"..i)
		if name then
			playernames[#playernames + 1] = name
		end
	end
	for name=1, #playernames do
		if not Plus.One.db.profile.trackedPlayers[playernames[name]] then
			Plus.One.db.profile.trackedPlayers[playernames[name]] = 0
		end
	end
end

-- check for and handle requests for current score
function Plus.One:CHAT_MSG_WHISPER(event, text, playerName, ...)
	-- Plus.playerscore[name]:SetText(Plus.One.db.profile.trackedPlayers[name])
	if text:find("allpoints") then
		print("entered allpoints")
		local points = {}
		local vals = {}
		for name, _ in pairs(Plus.playerscore) do
			local score = Plus.One.db.profile.trackedPlayers[name]
			if points[score] == nil then
				points[score] = {}
				vals[#vals+1] = score
			end
			points[score][#points[score] + 1] = name
		end
		table.sort(vals)
		local reply = ""
		for _, v in ipairs(vals) do
			reply = "["..v.."]: "
		
			table.sort(points[v])
			for c, n in ipairs(points[v]) do
				if strlen(reply) + strlen(n) < 255 then
					if c > 1 then
						reply = reply..", "..n
					else
						reply = reply..n
					end
				else
					Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
					Plus.One:ScheduleTimer("DelayChatWhisper", Plus.One.chatcount, reply, playerName)
					reply = "["..v.."]: "..n
				end
			end
			if strlen(reply) > 0 then
				Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
				Plus.One:ScheduleTimer("DelayChatWhisper", Plus.One.chatcount, reply, playerName)
			end	
		end

	elseif text:find("points") then
		Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
		Plus.One:ScheduleTimer("DelayChatWhisper", Plus.One.chatcount, Plus.One.db.profile.trackedPlayers[playerName] or "No Points Found", playerName)
	end
end

local function filterWhisper(self, event, msg, author, ...)
	if event == "CHAT_MSG_WHISPER" and msg:find("points") then return true end
	if event == "CHAT_MSG_WHISPER_INFORM" and author == UnitName("player") and msg:find("%[%d+%]") then return true end
	return false
end

function Plus.One:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from 
	-- the game that wasn't available in OnInitialize

  	Plus.AceGUI = LibStub("AceGUI-3.0")
	Plus.One:RegisterEvent("RAID_ROSTER_UPDATE")
	Plus.One:RegisterEvent("CHAT_MSG_WHISPER")
--	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterWhisper)
--	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterWhisper)
end

function Plus.One:OnDisable()
	print("Disabled")
	Plus.One:UnregisterEvent("RAID_ROSTER_UPDATE")
	Plus.One:UnregisterEvent("CHAT_MSG_WHISPER")
--	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", filterWhisper)
--	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filterWhisper)
  -- Unhook, Unregister Events, Hide frames that you created.
  -- You would probably only use an OnDisable if you want to 
  -- build a "standby" mode, or be able to toggle modules on/off.
end

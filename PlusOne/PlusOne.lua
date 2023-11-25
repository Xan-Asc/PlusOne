local _, Plus = ...

Plus.One = LibStub("AceAddon-3.0"):NewAddon("PlusOne", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
Plus.buttonHeight = 18
Plus.visible = false
Plus.One.chatcount = 0
Plus.whisperDelay = 0.3

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
	if PO_blacklist == nil then PO_blacklist = {} end

	Plus.One.db = LibStub("AceDB-3.0"):New("PO_SettingsDB", {
		profile = { 
			minimap = { hide = false, }, 
			rollDuration = 10,
			trackSR = false,
			rollSR = 200,
			rollMS = 100,
			trackOS = false,
			rollOS = 99,
			trackedPlayers = {},
			minquality = 4,
			output = "RAID_WARNING",
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

		local announcepoints = Plus.AceGUI:Create("Button")
		announcepoints:SetText("Annouce Points")
		announcepoints:SetHeight(Plus.buttonHeight)
		announcepoints:SetWidth(183)
		announcepoints:SetCallback("OnClick", function(widget) 
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
			Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
			Plus.One:ScheduleTimer("DelayRaidOutput", Plus.One.chatcount, "Current PlusOne Point Standing:")
			local announce = ""
			for _, v in ipairs(vals) do
				announce = "["..v.."]: "
			
				table.sort(points[v])
				for c, n in ipairs(points[v]) do
					if strlen(announce) + strlen(n) < 255 then
						if c > 1 then
							announce = announce..", "..n
						else
							announce = announce..n
						end
					else
						Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
						Plus.One:ScheduleTimer("DelayRaidOutput", Plus.One.chatcount, announce)
						announce = "["..v.."]: "..n
					end
				end
				if strlen(announce) > 0 then
					Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
					Plus.One:ScheduleTimer("DelayRaidOutput", Plus.One.chatcount, announce)
				end	
			end
		end)

		local announcerules = Plus.AceGUI:Create("Button")
		announcerules:SetText("Annouce Rules")
		announcerules:SetHeight(Plus.buttonHeight)
		announcerules:SetWidth(248)
		announcerules:SetCallback("OnClick", function(widget) 
			local raidrules = {
				"Loot System: Uncontested Universal +1",
				"All items looted to the raid leader (or someone designated) and rolled at end of the raid (or as close to end of 2 hour trade window if sooner.)",
				"The raid leader MIGHT decide to roll items at each boss instead in the interest of time.",
				"You get 1 point for that raid session each time you win a contested item. The points stack infinitely and reset after the raiding period that day.",
				"You can only beat another player's rolls if you are lower or equal in points to them.",
				"Tier pieces will always be rolled last.",
				"An item is only considered contested if the winner of the item had someone else roll on it. The following exceptions apply: All tier pieces will always give +1.",
				"Important Notes:",
				"Mounts will be free-rolled outside of the +1 system.",
				"Raid loot worldforged enchants will be rolled outside the +1 system as MS>OS.",
				"Some raid crafting materials may not be rolled off.",
				"Legendary items may or may not be rolled. They will be arbitrarily allocated by the guild oligarchy. If they are rolled, they will not be affected by the +1 system.",
			}

			for _, announce in ipairs(raidrules) do
				Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
				Plus.One:ScheduleTimer("DelayRaidOutput", Plus.One.chatcount, announce)
			end
		end)

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
		
		Plus.playercontainer:AddChild(announcepoints)
		Plus.itemcontainer:AddChild(announcerules)

		Plus:InitParty()
		Plus:InitLoot()
	end
end

-- SendChatMessage("Rolls have finished, no further rolls will be tracked.", Plus.One.db.profile.output)
-- handle delayed raid messages
function Plus.One:DelayRaidOutput(announce)
	if Plus.One.chatcount > Plus.whisperDelay then
		Plus.One.chatcount = Plus.One.chatcount - Plus.whisperDelay
	end
	SendChatMessage(announce, Plus.One.db.profile.output)
end

-- handle delayed whisper messages
function Plus.One:DelayChatWhisper(reply, playerName)
	if Plus.One.chatcount > Plus.whisperDelay then
		Plus.One.chatcount = Plus.One.chatcount - Plus.whisperDelay
	end
	SendChatMessage(reply, "WHISPER", GetDefaultLanguage(playerName), playerName)
end

-- keep track of who is in the raid group
function Plus.One:RAID_ROSTER_UPDATE(event, ...)
	local playernames = {}
	for i=1,40 do 
		local name = GetUnitName("raid"..i)
		if name then
			if not Plus.One.db.profile.trackedPlayers[name] then
				Plus.One.db.profile.trackedPlayers[name] = 0
			end
		end
	end
end

-- check for and handle requests for current score
function Plus.One:CHAT_MSG_WHISPER(event, text, playerName, ...)
	if Plus.One.db.profile.trackedPlayers[playerName] == nil then return end 
	if text:find("#allpoints") then
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

	elseif text:find("#points") then
		Plus.One.chatcount = Plus.One.chatcount + Plus.whisperDelay
		Plus.One:ScheduleTimer("DelayChatWhisper", Plus.One.chatcount, "Your +1 is: "..Plus.One.db.profile.trackedPlayers[playerName] or "No Points Found", playerName)
	end
end

local function filterWhisper(self, event, msg, author, ...)
	if event == "CHAT_MSG_WHISPER" and msg:find("points") then return true end
--	if event == "CHAT_MSG_WHISPER_INFORM" and author == UnitName("player") and msg:find("%[%d+%]") then return true end
	return false
end

function Plus.One:PO_SlashCommand(input)
	local _, _, command, extra = string.find(input, "(%a*)[ ]?(%d*)")
	if command == "bl" or command == "wl" then 
		local itemID
		if extra ~= "" then 
			itemID = tonumber(extra)
		else
			if GameTooltip:IsShown() then 
				local itemLink = select(2, GameTooltip:GetItem())
				itemID = tonumber(select(3, string.find(itemLink, "item:(%d+)")))
			end
		end

		if command == "bl" then
			DEFAULT_CHAT_FRAME:AddMessage("Pora: Ignoring "..itemID)
			PO_blacklist[itemID] = true
		else
			DEFAULT_CHAT_FRAME:AddMessage("Pora: Tracking "..itemID)
			PO_blacklist[itemID] = nil
		end
	elseif command == "list" then
		DEFAULT_CHAT_FRAME:AddMessage("Pora: Currently excluded items:")
		for id, _ in pairs(PO_blacklist) do
			DEFAULT_CHAT_FRAME:AddMessage("Pora: "..id..": "..select(2, GetItemInfo(id)))
		end
	else
		for _, s in ipairs({"List of valid commands",
							"bl (itemID, optional) -- adds either the supplied ID or mouseover item to exclude list",
							"wl (itemID, optional) -- removes item from exclude list",
							"list -- lists all currently excluded items"}) do
			DEFAULT_CHAT_FRAME:AddMessage("Pora: "..s)
		end
	end
end

function Plus.One:OnEnable()
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from 
	-- the game that wasn't available in OnInitialize

  	Plus.AceGUI = LibStub("AceGUI-3.0")
	Plus.One:RegisterEvent("RAID_ROSTER_UPDATE")
	Plus.One:RegisterEvent("CHAT_MSG_WHISPER")
	Plus.One:RegisterChatCommand("pora", "PO_SlashCommand")
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

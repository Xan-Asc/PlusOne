local _, Plus = ...

Plus.One = LibStub("AceAddon-3.0"):NewAddon("PlusOne", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
Plus.buttonHeight = 18
Plus.visible = false

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
		-- Create a container frame
		Plus.GUIRoot = Plus.AceGUI:Create("Frame")
		Plus.GUIRoot:SetCallback("OnClose",function(widget) Plus.AceGUI:Release(widget) Plus.visible = false end)
		Plus.GUIRoot:SetTitle("PlusOne")
		Plus.GUIRoot:SetWidth(640)
		Plus.GUIRoot:SetHeight(480)
		Plus.GUIRoot:SetStatusText("Status Bar")
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

		pwrap:SetRelativeWidth(0.33)
		iwrap:SetRelativeWidth(0.33)
		rwrap:SetRelativeWidth(0.33)

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

function Plus.One:OnEnable()
	Plus.isRaid = GetRealNumRaidMembers() > 0
	-- Do more initialization here, that really enables the use of your addon.
	-- Register Events, Hook functions, Create Frames, Get information from 
	-- the game that wasn't available in OnInitialize

  	Plus.AceGUI = LibStub("AceGUI-3.0")
end

function Plus.One:OnDisable()
	print("Disabled")
  -- Unhook, Unregister Events, Hide frames that you created.
  -- You would probably only use an OnDisable if you want to 
  -- build a "standby" mode, or be able to toggle modules on/off.
end

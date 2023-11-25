local _, Plus = ...

function Plus:AddPlayer(name)
	-- Add Player
	local player = Plus.AceGUI:Create("SimpleGroup")
	player:SetLayout("Flow")
	player:SetRelativeWidth(1)
	local pt = Plus.AceGUI:Create("Label")
	local pto = Plus.AceGUI:Create("Label")
	local pp = Plus.AceGUI:Create("Button")
	local pm = Plus.AceGUI:Create("Button")

	-- Set up button functionality
	pp:SetUserData("pto", pto)
	pp:SetUserData("name", name)
	pp:SetCallback("OnClick", function(widget) 
		Plus.One.db.profile.trackedPlayers[widget:GetUserData("name")] = Plus.One.db.profile.trackedPlayers[widget:GetUserData("name")] + 1
		(widget:GetUserData("pto")):SetText(Plus.One.db.profile.trackedPlayers[name])
	end)

	pm:SetUserData("pto", pto)
	pm:SetUserData("name", name)
	pm:SetCallback("OnClick", function(widget) 
		if Plus.One.db.profile.trackedPlayers[widget:GetUserData("name")] > 0 then
			Plus.One.db.profile.trackedPlayers[widget:GetUserData("name")] = Plus.One.db.profile.trackedPlayers[widget:GetUserData("name")] - 1
		end
		(widget:GetUserData("pto")):SetText(Plus.One.db.profile.trackedPlayers[name])
	end)

	-- Spacer
	local spacer = Plus.AceGUI:Create("Label")
	spacer:SetText(" ")
	spacer:SetWidth(2)
	player:AddChild(spacer)
	-- Add text
	pt:SetText(name)
	pto:SetText(Plus.One.db.profile.trackedPlayers[name])
	pp:SetText("+")
	pm:SetText("-")

	-- Set up spacing
	pt:SetWidth(80)
	pto:SetWidth(20)
	pp:SetWidth(40)
	pm:SetWidth(36)

	pp:SetHeight(Plus.buttonHeight)
	pm:SetHeight(Plus.buttonHeight)

	-- merge buttons in to parent
	player:AddChild(pt)
	player:AddChild(pto)
	player:AddChild(pp)
	player:AddChild(pm)

	Plus.playercontainer:AddChild(player)
	-- end throwaway portion
end

function Plus:InitParty()
	local playernames = {}
	if Plus.isRaid then
		for i=1,40 do 
			local name = GetUnitName("raid"..i)
			if name then
				playernames[#playernames + 1] = name
			end
		end
	else
		playernames[#playernames + 1] = GetUnitName("player")
		for i=1,4 do 
			local name = GetUnitName("party"..i)
			if name then
				playernames[#playernames + 1] = name
			end
		end
	end
	table.sort(playernames)
	for name=1, #playernames do
		if not Plus.One.db.profile.trackedPlayers[playernames[name]] then
			Plus.One.db.profile.trackedPlayers[playernames[name]] = 0
		end
		Plus:AddPlayer(playernames[name])
	end
end

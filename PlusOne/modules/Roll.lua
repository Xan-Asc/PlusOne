local _, Plus = ...

function Plus.One:LootRollTimer(remain)
	SendChatMessage(remain.." seconds remaining!", Plus.isRaid and "RAID_WARNING" or "PARTY")
end

function Plus.One:EndRollTimer(remain)
	Plus.One:UnregisterEvent("CHAT_MSG_SYSTEM")
	Plus.rolling = false
	SendChatMessage("Rolls have finished, no further rolls will be tracked.", Plus.isRaid and "RAID_WARNING" or "PARTY")
end

function Plus.One:CHAT_MSG_SYSTEM(...)
	local roll = select(2, ...)
	local name, val, minr, maxr = roll:match("(.*) rolls (.*) %((.*)-(.*)%)")
	if name then
		val = tonumber(val)
		minr = tonumber(minr)
		maxr = tonumber(maxr)
		if minr ~= 1 or Plus.rolled[name] ~= nil then return end
		Plus.rolled[name] = true
		if maxr == Plus.One.db.profile.rollSR and Plus.One.db.profile.trackSR then
			Plus:AddRoll(name, val, Plus.rollcontainer:GetUserData("sr"))
		elseif maxr == Plus.One.db.profile.rollMS then
			Plus:AddRoll(name, val, Plus.rollcontainer:GetUserData("ms"))
		elseif maxr == Plus.One.db.profile.rollOS and Plus.One.db.profile.trackOS then
			Plus:AddRoll(name, val, Plus.rollcontainer:GetUserData("os"))
		else
			Plus.rolled[name] = nil
		end
	end
end

local timer_rolls = {1, 2, 3, 4, 5, 10, 15, 20, 30}

function Plus:AddRoll(name, value, widget)
	local roll = Plus.AceGUI:Create("SimpleGroup")
	roll:SetLayout("Flow")
	roll:SetRelativeWidth(1)
	local pt = Plus.AceGUI:Create("Button")
	local pval = Plus.AceGUI:Create("Label")
	local pto = Plus.AceGUI:Create("Label")

	-- Add text
	pt:SetText(name)
	pt:SetUserData("player", name)
	pt:SetCallback("OnClick", function(widget) 
		InitiateTrade(widget:GetUserData("player"))
	end)
	pval:SetText("+"..Plus.One.db.profile.trackedPlayers[name])
	pto:SetText(value)

	-- Set up spacing
	pt:SetWidth(80)
	pt:SetHeight(Plus.buttonHeight)
	pval:SetWidth(36)
	pto:SetWidth(40)

	-- merge buttons in to parent
	roll:AddChild(pt)
	roll:AddChild(pval)
	roll:AddChild(pto)

	-- figure out where to insert the roll
	local wid = nil
	local rs, vs = 99, 0
	for v, w in pairs(widget:GetUserData("rollvals")) do
		local plus, rval = v:match("(.*)_(.*)")
		plus = tonumber(plus)
		rval = tonumber(rval)
		if (Plus.One.db.profile.trackedPlayers[name] < plus or (Plus.One.db.profile.trackedPlayers[name] == plus and value > rval)) and (rs > plus or (rs == plus and vs < rval)) then
			rs = plus
			vs = rval
			wid = w
		end
	end

	-- insert the roll
	if wid then
		widget:AddChild(roll, wid)
	else
		widget:AddChild(roll)
	end

	-- update tracked rolls
	if (widget:GetUserData("rollvals"))[Plus.One.db.profile.trackedPlayers[name].."_"..value] == nil then
		(widget:GetUserData("rollvals"))[Plus.One.db.profile.trackedPlayers[name].."_"..value] = roll
	end
	Plus.rollcontainer:DoLayout()
end

function Plus:InitRoll(widget)
	if Plus.rolling then
		print("Already rolling an item, please wait.")
		return
	end
	Plus.rolling = true
	-- reset list of people that have rolled
	Plus.rolled = {}

	Plus.One:RegisterEvent("CHAT_MSG_SYSTEM")
	Plus.rollcontainer:ReleaseChildren()

	if Plus.One.db.profile.trackSR then
		local srwrap = Plus.AceGUI:Create("InlineGroup")
		srwrap:SetTitle("Soft Res - "..Plus.One.db.profile.rollSR)
		srwrap:SetUserData("rollvals", {})
		Plus.rollcontainer:AddChild(srwrap)
		Plus.rollcontainer:SetUserData("sr", srwrap)
	end

	local mswrap = Plus.AceGUI:Create("InlineGroup")
	mswrap:SetTitle("Mainspec - "..Plus.One.db.profile.rollMS)
	mswrap:SetUserData("rollvals", {})
	Plus.rollcontainer:AddChild(mswrap)
	Plus.rollcontainer:SetUserData("ms", mswrap)

	if Plus.One.db.profile.trackOS then
		local oswrap = Plus.AceGUI:Create("InlineGroup")
		oswrap:SetTitle("Offspec - "..Plus.One.db.profile.rollOS)
		oswrap:SetUserData("rollvals", {})
		Plus.rollcontainer:AddChild(oswrap)
		Plus.rollcontainer:SetUserData("os", oswrap)
	end

	for i=1, 9 do
		if timer_rolls[i] < Plus.One.db.profile.rollDuration then
			Plus.One:ScheduleTimer("LootRollTimer", Plus.One.db.profile.rollDuration-timer_rolls[i], timer_rolls[i])
		else
			break
		end
	end
	Plus.One:ScheduleTimer("EndRollTimer", Plus.One.db.profile.rollDuration)
	SendChatMessage("Roll ("..widget:GetUserData("count").."x): "..widget:GetUserData("link").." ("..Plus.One.db.profile.rollDuration.." seconds)", Plus.isRaid and "RAID_WARNING" or "PARTY") 
end

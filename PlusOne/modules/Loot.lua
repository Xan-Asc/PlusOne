local _, Plus = ...

local function RGBtoHEX (r,g,b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255);
end

function Plus:AddItem(itemlink, count)
	local item = Plus.AceGUI:Create("SimpleGroup")
	item:SetLayout("Flow")
	item:SetRelativeWidth(1)
	local pi = Plus.AceGUI:Create("InteractiveLabel")
	pi:SetUserData("link", itemlink)
	pi:SetCallback("OnEnter", function(widget)
		if (widget:GetUserData("link")) then
		  GameTooltip:SetOwner(UIParent, "ANCHOR_TOP")
		  GameTooltip:SetHyperlink(widget:GetUserData("link"))
		  GameTooltip:Show()
		end
	  end)
	pi:SetCallback("OnLeave", function(widget) GameTooltip:Hide() end)
	local pc = Plus.AceGUI:Create("Label")
	local pr = Plus.AceGUI:Create("Button")
	pr:SetUserData("link", itemlink)
	pr:SetUserData("count", count)
	pr:SetCallback("OnClick", function(widget) 
		Plus:InitRoll(widget)
	end)

	-- Spacer
	local spacer = Plus.AceGUI:Create("Label")
	spacer:SetText(" ")
	spacer:SetWidth(2)
	item:AddChild(spacer)

	-- Add text
	local itemName, _, itemRarity = GetItemInfo(itemlink)
	local itemTextColor = ITEM_QUALITY_COLORS[itemRarity]
	local color = "|cff"..RGBtoHEX (itemTextColor[1], itemTextColor[2], itemTextColor[3])
	pi:SetText(color..itemName.."|r")
	pc:SetText(count)
	pr:SetText("Roll")

	-- Set up spacing
	pi:SetWidth(75)
	pc:SetWidth(20)
	pr:SetWidth(60)
	pr:SetHeight(Plus.buttonHeight)

	-- merge buttons in to parent
	item:AddChild(pi)
	item:AddChild(pc)
	item:AddChild(pr)

	Plus.itemcontainer:AddChild(item)
end

local function isTradable(bagID, slot)
	Plus.TT:ClearLines()  
	Plus.TT:SetBagItem(bagID, slot)
	local retval = true
	for i = 1,Plus.TT:NumLines() do
		local line = _G[Plus.TT:GetName() .. "TextLeft" .. i]:GetText()
		if line then
			if string.find(line, string.format(BIND_TRADE_TIME_REMAINING_REPLACEMENT, ".*")) then
				return true
			elseif line==ITEM_SOULBOUND or line==ITEM_ACCOUNTBOUND then
				retval = false
			end
		end
	end
	return retval
end

function Plus:InitLoot()
	if Plus.TT == nil then
		Plus.TT = CreateFrame("GameTooltip","Tooltip",nil,"GameTooltipTemplate")
		Plus.TT:SetOwner(UIParent, "ANCHOR_NONE")
	end
	local itemList = {}

	-- Check for an open loot window
	for i = 1, GetNumLootItems() do
		if (LootSlotIsItem(i)) then
			local _, _, itemCount, quality = GetLootSlotInfo(i)
			if quality >= Plus.One.db.profile.minquality then
				local itemLink = GetLootSlotLink(i);
				if itemList[itemLink] then
					itemList[itemLink] = itemList[itemLink] + itemCount
				else
					itemList[itemLink] = itemCount
				end
			end
		end
	end
	-- check bags for any unbound items
	for bagID=0, 4 do
		for slot=1, GetContainerNumSlots(bagID) do
			local _, itemCount, _, quality, _, _, itemLink = GetContainerItemInfo(bagID, slot)
			if itemLink and (quality >= Plus.One.db.profile.minquality or quality == -1) then
				if isTradable(bagID, slot) then
					if itemList[itemLink] then
						itemList[itemLink] = itemList[itemLink] + itemCount
					else
						itemList[itemLink] = itemCount
					end
				end
			end
		end
	end
	for k, v in pairs(itemList) do
		Plus:AddItem(k, v)
	end
end

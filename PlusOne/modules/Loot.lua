local _, Plus = ...

local next = next -- faster empty table check
Plus.corpseitemList = {}
Plus.itemList = {}

local function RGBtoHEX (r,g,b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255);
end

function Plus:AddItem(itemlink, count)
	local item = Plus.AceGUI:Create("SimpleGroup")
	item:SetLayout("Flow")
	item:SetWidth(248)
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
	local hide = Plus.AceGUI:Create("Button")
	hide:SetUserData("parent", item)
	hide:SetCallback("OnClick", function(widget) 
		item:SetWidth(1)
		item:SetHeight(1)
		item:ReleaseChildren()
		Plus.itemcontainer:DoLayout()
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
	hide:SetText("X")

	-- Set up spacing
	pi:SetWidth(118)
	pc:SetWidth(20)
	pr:SetWidth(55)
	pr:SetHeight(Plus.buttonHeight)
	hide:SetWidth(45)
	hide:SetHeight(Plus.buttonHeight)

	-- merge buttons in to parent
	item:AddChild(pi)
	item:AddChild(pc)
	item:AddChild(pr)
	item:AddChild(hide)

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

local function lootSort(a, b)
	return a[2] < b[2]
end

function Plus:InitLoot()
	if Plus.TT == nil then
		Plus.TT = CreateFrame("GameTooltip","Tooltip",nil,"GameTooltipTemplate")
		Plus.TT:SetOwner(UIParent, "ANCHOR_NONE")
	end

	-- Check for an open loot window
	Plus.corpseitemList = {}
	for i = 1, GetNumLootItems() do
		if (LootSlotIsItem(i)) then
			local _, _, itemCount, quality = GetLootSlotInfo(i)
			if quality >= Plus.One.db.profile.minquality then
				local itemLink = GetLootSlotLink(i);
				if Plus.corpseitemList[itemLink] then
					corpseitePlus.corpseitemListmList[itemLink] = Plus.corpseitemList[itemLink] + itemCount
				else
					Plus.corpseitemList[itemLink] = itemCount
				end
			end
		end
	end
	-- Add Spacer if loot window
	for k, v in pairs(Plus.corpseitemList) do
		Plus:AddItem(k, v)
	end
	if next(Plus.corpseitemList) ~= nil then
		local spacer = Plus.AceGUI:Create("Heading")
		spacer:SetText("^Loot Window^")
		spacer:SetWidth(165)
		Plus.itemcontainer:AddChild(spacer)
	end

	-- check bags for any unbound items
	Plus.itemList = {}
	local sortedItems = {}
	for bagID=0, 4 do
		for slot=1, GetContainerNumSlots(bagID) do
			local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagID, slot)			
			if itemLink then
				local name, _, iqual = GetItemInfo(itemLink)
				if iqual >= Plus.One.db.profile.minquality then
					if isTradable(bagID, slot) then

						if Plus.itemList[itemLink] then
							Plus.itemList[itemLink] = Plus.itemList[itemLink] + itemCount
						else
							sortedItems[#sortedItems + 1] = {itemLink, name}
							Plus.itemList[itemLink] = itemCount
						end
					end
				end
			end
		end
	end
	table.sort(sortedItems, lootSort)
	for _, n in ipairs(sortedItems) do
		Plus:AddItem(n[1], Plus.itemList[n[1]])
	end
end

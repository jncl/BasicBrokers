-- **********
-- DURABILITY
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local gender = _G.UnitSex("player")

BasicBrokers.itemSlot = {
	"Head",
	"Shoulder",
	"Chest",
	"Wrist",
	"Hands",
	"Waist",
	"Legs",
	"Feet",
	"MainHand",
	"SecondaryHand",
}

_G.StaticPopupDialogs["BASICBROKER_DURABILITY"] = {
  text = "Repair damaged equipment for %s? \n %s",
  button1 = "Repair",
  button2 = "Hide",
  OnAccept = function()
      _G.RepairAllItems();
  end,
  timeout = 0,
  whileDead = 0,
  hideOnEscape = 1,
}

function BasicBrokers.OnEvent.Durability(_, event)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.RegisterEvent("Durability", "MERCHANT_SHOW")
		BasicBrokers.RegisterEvent("Durability", "MERCHANT_CLOSED")
		BasicBrokers.RegisterEvent("Durability", "PLAYER_REGEN_ENABLED")
		BasicBrokers.RegisterEvent("Durability", "PLAYER_DEAD")
		BasicBrokers.RegisterEvent("Durability", "PLAYER_UNGHOST")
		BasicBrokers.RegisterEvent("Durability", "UPDATE_INVENTORY_ALERTS")
		if not BasicBrokers.isClsc then
			BasicBrokers.RegisterEvent("Durability", "EQUIPMENT_SWAP_FINISHED")
		end
		BasicBrokers.UnregisterEvent("Durability", "PLAYER_LOGIN")
	end

	if event == "MERCHANT_SHOW" then
		if _G.CanMerchantRepair() then
			local cost = _G.GetRepairAllCost()
			if cost > 0 then
				_G.StaticPopup_Show ("BASICBROKER_DURABILITY", BasicBrokers.GoldToText(cost), BasicBrokers.MerchantDiscount() )
			end
		end
	end
	if event == "MERCHANT_CLOSED" then
		_G.StaticPopup_Hide("BASICBROKER_DURABILITY")
	end

	BasicBrokers.UpdatePercent()

end

function BasicBrokers.MerchantDiscount()

	local hexcolor, standingText
	local itemName, item_cost
	local discount, total_cost = 0, 0
	local faction, standingID =  BasicBrokers.TargetFactionInfo()
	print("MerchantDiscount", faction, standingID)
	if standingID
	and _G.type(standingID) ~= "table"
	then
		if BasicBrokers.isClscERA then
			hexcolor = _G.PLAYER_FACTION_COLORS[_G.PLAYER_FACTION_GROUP[_G.UnitFactionGroup("player")]]:GenerateHexColorMarkup()
		else
			hexcolor = _G.FACTION_BAR_COLORS[standingID]:GenerateHexColorMarkup()
		end
		standingText = _G.GetText("FACTION_STANDING_LABEL" .. standingID, gender)
		-- print("MerchantDiscount#2", hexcolor, standingText)
		for k, _ in pairs(BasicBrokers.itemSlot) do
			itemName, item_cost = BasicBrokers.ItemData(k)
			if itemName then
				if item_cost > 0 then
					total_cost = total_cost + item_cost
				end
			end
		end
		total_cost = total_cost + BasicBrokers.BagItems()
		if standingID == 5 then -- Friendly
			discount = (total_cost / 0.95) - total_cost
		elseif standingID == 6 then -- Honored
			discount = (total_cost / 0.9) - total_cost
		elseif standingID == 7 then -- Revered
			discount = (total_cost / 0.85) - total_cost
		elseif standingID == 8 then -- Exalted
			discount = (total_cost / 0.8) - total_cost
		end
		return _G.strjoin(" ", hexcolor .. standingText .." Discount" .. colorEnd .. ": ", BasicBrokers.GoldToText(discount))
	end
	return ""
end

function BasicBrokers.TargetFactionInfo()

	local tiptext, j
	BasicBrokers.TT:SetOwner(_G.UIParent, "ANCHOR_NONE")
	BasicBrokers.TT:ClearLines()
	BasicBrokers.TT:SetUnit("target")

	for i = 1, BasicBrokers.TT:NumLines() do
	   tiptext = _G["BasicBrokerScanTipTextLeft" .. i]:GetText()
	   j = 1
	   -- rather not do-while but GetNumFactions() only returns active
	   while _G.GetFactionInfo(j) do
		local faction, _, standingID = _G.GetFactionInfo(j)
		if faction == tiptext then
			return faction, standingID
		end
		j = j +1
		if j > 250 then break end
	   end
	end

	return nil, nil

end

function BasicBrokers.OnTooltip.Durability(tip)

	if not BasicBrokers.Durability.tooltip then BasicBrokers.Durability.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "Durability")

	local total_repairs = 0
	for k, _ in pairs(BasicBrokers.itemSlot) do
		total_repairs = total_repairs + BasicBrokers.AddInventoryItem(k)
	end

	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "Weapons & Armor:" .. colorEnd .. " ", BasicBrokers.GoldToText(total_repairs))
	BasicBrokers.Durability.tooltip:AddLine(" ")

	total_repairs = total_repairs + BasicBrokers.BagItems()
	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "Total Repair Bill:" .. colorEnd .. " ", BasicBrokers.GoldToText(total_repairs))
	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "  Discount:" .. colorEnd .. " Friendly", BasicBrokers.GoldToText(total_repairs * 0.05))
	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "  Discount:" .. colorEnd .. " Honored", BasicBrokers.GoldToText(total_repairs * 0.1))
	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "  Discount:" .. colorEnd .. " Revered", BasicBrokers.GoldToText(total_repairs * 0.15))
	BasicBrokers.Durability.tooltip:AddDoubleLine(bbc.green .. "  Discount:" .. colorEnd .. " Exalted", BasicBrokers.GoldToText(total_repairs * 0.2))

end

function BasicBrokers.OnClick.Durability()
	-- if _G.IsAltKeyDown() then
	-- end
end

function BasicBrokers.UpdatePercent()
	local hasItem, value, max
	local percentage = 1
	local hexcolor = bbc.blue
	for k, _ in pairs(BasicBrokers.itemSlot) do
		hasItem, _, value, max = BasicBrokers.ItemData(k)
		if hasItem then
			if max > 0 then
				if (value / max) < percentage then
					percentage = (value / max)
				end
			end
		end
	end
	percentage = math.floor(percentage * 100)
	if  percentage == 0 then
		hexcolor = bbc.red
	elseif percentage < 30 then
		hexcolor = bbc.yellow
	end
	BasicBrokers.Text( "Durability",  hexcolor .. percentage .. "%" .. colorEnd)
end

function BasicBrokers.AddInventoryItem(index)
	local itemName, cost, value, max = BasicBrokers.ItemData(index)
	if itemName then
		if max > 0 then
			local percentage = _G.format("%.1f%%", (value / max) * 100)
			BasicBrokers.Durability.tooltip:AddDoubleLine("  " .. itemName, percentage)
			return cost
		end
	end
	return 0
end

local GetContainerItemLink = _G.C_Container and _G.C_Container.GetContainerItemLink or _G.GetContainerItemLink
local GetContainerItemInfo = _G.C_Container and _G.C_Container.GetContainerItemInfo or _G.GetContainerItemInfo
local GetContainerItemDurability = _G.C_Container and _G.C_Container.GetContainerItemDurability or _G.GetContainerItemDurability
local GetContainerNumSlots = _G.C_Container and _G.C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
function BasicBrokers.ItemData(index, bag)
	local itemLink, cost, value, max, hasItem, _
	if bag then
		itemLink = GetContainerItemLink(bag, index)
		hasItem = GetContainerItemInfo(bag, index)
		value, max = GetContainerItemDurability(bag, index)
		if _G.C_TooltipInfo and _G.C_TooltipInfo.GetBagItem then
			local tooltipData = _G.C_TooltipInfo.GetBagItem(bag, index)
			if tooltipData then
				_G.TooltipUtil.SurfaceArgs(tooltipData)
				cost = tooltipData.repairCost and tooltipData.repairCost or 0
			else
				cost = 0
			end
		else
			_, cost = BasicBrokers.TT:SetBagItem(bag, index)
		end
	else
		local slotName = BasicBrokers.itemSlot[index] .. "Slot"
		local id = _G.GetInventorySlotInfo(slotName)
		itemLink = _G.GetInventoryItemLink("player", id)
		value, max = _G.GetInventoryItemDurability(id)
		if _G.C_TooltipInfo and _G.C_TooltipInfo.GetInventoryItem then
			local tooltipData = _G.C_TooltipInfo.GetInventoryItem("player", id)
			if tooltipData then
				_G.TooltipUtil.SurfaceArgs(tooltipData)
				cost = tooltipData.repairCost and tooltipData.repairCost or 0
				hasItem = true
			else
				hasItem, cost = false, 0
			end
		else
			hasItem, _, cost = BasicBrokers.TT:SetInventoryItem("player", id)
		end

	end
	if hasItem and value then
		return itemLink, cost, value, max
	end
end

function BasicBrokers.ItemName(itemLink)
	local itemName, _, itemRarity = _G.GetItemInfo(itemLink)
	if itemName and (itemRarity or itemRarity == 0) then
		local _, _, _, itemColor = _G.GetItemQualityColor(itemRarity)
		itemName = itemColor .. itemName .. colorEnd
	end
	return itemName
end

function BasicBrokers.BagItems()
	local hasItem, cost, _
	local total_cost = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			hasItem, cost, _, _ = BasicBrokers.ItemData(slot, bag)
			if hasItem then
				total_cost = cost + total_cost
			end
		end
	end
	return total_cost
end

BasicBrokers.CreatePlugin("Durability","0%",[[Interface\Minimap\Tracking\Repair]])
BasicBrokers.RegisterEvent("Durability", "PLAYER_LOGIN")

-- **********
-- BASIC DURABILITY
 BasicBrokers.itemSlot = {
	"Head",
	"Shoulder", 
	"Chest", 
	"Waist", 
	"Legs", 
	"Feet", 
	"Wrist", 
	"Hands", 
	"MainHand", 
	"SecondaryHand", 
	"Ranged", 
	}
	
StaticPopupDialogs["BASICBROKER_DURABILITY"] = {
  text = "Repair damaged equipment for %s? \n %s",
  button1 = "Repair",
  button2 = "Hide",
  OnAccept = function()
      RepairAllItems();
  end,
  timeout = 0,
  whileDead = 0,
  hideOnEscape = 1,  
}
	
function BasicBrokers.OnEvent.Durability(_, event)
	if event == "MERCHANT_SHOW" then
		if CanMerchantRepair() then
			local cost = GetRepairAllCost()
			if cost > 0 then
				StaticPopup_Show ("BASICBROKER_DURABILITY", BasicBrokers.GoldToText(cost), BasicBrokers.MerchantDiscount() )
			end
		end
	elseif event == "MERCHANT_CLOSED" then
		StaticPopup_Hide("BASICBROKER_DURABILITY")
	end
	BasicBrokers.UpdatePercent()
end

function BasicBrokers.MerchantDiscount()
	local reputation, hexcolor
	local itemName, item_cost
	local discount, total_cost = 0, 0
	local faction, reaction =  BasicBrokers.TargetFactionInfo()	
	if faction and reaction then
		reputation, hexcolor = BasicBrokers.FactionLabel(reaction)
		for k,v in pairs(BasicBrokers.itemSlot) do
			itemName, item_cost = BasicBrokers.ItemData(k)
			if itemName then
				if item_cost > 0 then
					total_cost = total_cost + item_cost
				end
			end
		end
		total_cost = total_cost + BasicBrokers.BagItems()
		if reaction == 5 then
			discount = (total_cost / 0.95) - total_cost
		elseif reaction == 6 then
			discount = (total_cost / 0.9) - total_cost
		elseif reaction == 7 then
			discount = (total_cost / 0.85) - total_cost
		elseif reaction == 8 then
			discount = (total_cost / 0.8) - total_cost
		end
		return "  " .. hexcolor .. reputation .. " Discount|r:  " .. BasicBrokers.GoldToText(discount)	
	end
	return ""
end

function BasicBrokers.TargetFactionInfo()
	local tipline, tiptext
	BasicBrokers.TT:SetOwner(UIParent, "ANCHOR_NONE")
	BasicBrokers.TT:ClearLines()
	BasicBrokers.TT:SetUnit("target")
	for i = 1, BasicBrokers.TT:NumLines() do
	   local tipline = getglobal("BasicBrokerScanTipTextLeft" .. i)
	   local tiptext = tipline:GetText()
	   local j = 1
	   -- rather not do-while but GetNumFactions() only returns active
	   while GetFactionInfo(j) do
		faction, _, reaction = GetFactionInfo(j)
		if faction == tiptext then
			return faction, reaction
		end
		j = j +1
		if j > 200 then break end
	   end
	end
	return nil, nil
end


function BasicBrokers.OnTooltip.Durability(tip)
	if not BasicBrokers.Durability.tooltip then BasicBrokers.Durability.tooltip = tip end
	local total_repairs = 0
	BasicBrokers.Durability.tooltip:ClearLines()
	BasicBrokers.Durability.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffDurability|r")
	for k,v in pairs(BasicBrokers.itemSlot) do
		total_repairs = total_repairs + BasicBrokers.AddInventoryItem(k)
	end
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950Weapons & Armor:|r ",BasicBrokers.GoldToText(total_repairs))
	BasicBrokers.Durability.tooltip:AddLine(" ")
	total_repairs = total_repairs + BasicBrokers.BagItems()
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950Total Repair Bill:|r ",BasicBrokers.GoldToText(total_repairs))
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950  Discount:|r Friendly",BasicBrokers.GoldToText(total_repairs * 0.05))
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950  Discount:|r Honored",BasicBrokers.GoldToText(total_repairs * 0.1))
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950  Discount:|r Revered",BasicBrokers.GoldToText(total_repairs * 0.15))
	BasicBrokers.Durability.tooltip:AddDoubleLine("|cff69b950  Discount:|r Exalted",BasicBrokers.GoldToText(total_repairs * 0.2))	
end

function BasicBrokers.OnClick.Durability()
	if IsAltKeyDown() then
	end
end

function BasicBrokers.UpdatePercent()
	local hasItem, cost, value, max
	local percentage = 1
	local hexcolor = "|cff8888ee"
	for k,v in pairs(BasicBrokers.itemSlot) do
		hasItem, cost, value, max = BasicBrokers.ItemData(k)
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
		hexcolor = "|cFFFF0000" 
	elseif percentage < 30 then
		hexcolor = "|cFFFFFF00"	
	end
	BasicBrokers.Text( "Durability",  hexcolor..percentage.."%|r")
end

function BasicBrokers.AddInventoryItem(index)
	local itemName, cost, value, max = BasicBrokers.ItemData(index)
	if itemName then
		if max > 0 then
			local percentage = format("%.1f%%", (value / max) * 100)
			BasicBrokers.Durability.tooltip:AddDoubleLine("  " .. itemName, percentage)			
			return cost
		end
	end
	return 0
end

function BasicBrokers.ItemData(index, bag)
	local itemLink, cost, value, max, hasItem
	if bag then
		itemLink = GetContainerItemLink(bag, index)
		_,cost = BasicBrokers.TT:SetBagItem(bag, index)
		hasItem = GetContainerItemInfo(bag, index)
		value, max = GetContainerItemDurability(bag, index)	
	else
		local slotName = BasicBrokers.itemSlot[index] .. "Slot"
		local id = GetInventorySlotInfo(slotName)
		itemLink = GetInventoryItemLink("player",id)		
		hasItem,_,cost = BasicBrokers.TT:SetInventoryItem("player", id)
		value, max = GetInventoryItemDurability(id)
	end
	if hasItem and value then
		return BasicBrokers.ItemName(itemLink), cost, value, max
	end
end
	
function BasicBrokers.ItemName(itemLink)
	local itemName, _, itemRarity = GetItemInfo(itemLink)
	if itemName and (itemRarity or itemRarity == 0) then
		local _, _, _, itemColor = GetItemQualityColor(itemRarity)
		itemName = itemColor .. itemName .. "|r"
	end
	return itemName
end

function BasicBrokers.BagItems()
	local bag, slot, hasItem, cost, value, max
	local total_cost = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local hasItem, cost, value, max = BasicBrokers.ItemData(slot, bag)
			if hasItem then
				total_cost = cost + total_cost
			end
		end
	end
	return total_cost
end

BasicBrokers.CreatePlugin("Durability","0%","Interface\\Minimap\\Tracking\\Repair.blp")
BasicBrokers.RegisterEvent("Durability", "PLAYER_LOGIN")
--BasicBrokers.RegisterEvent("Durability", "MERCHANT_SHOW")
BasicBrokers.RegisterEvent("Durability", "MERCHANT_CLOSED")
BasicBrokers.RegisterEvent("Durability", "PLAYER_REGEN_ENABLED")
BasicBrokers.RegisterEvent("Durability", "PLAYER_DEAD")
BasicBrokers.RegisterEvent("Durability", "PLAYER_UNGHOST")
BasicBrokers.RegisterEvent("Durability", "UPDATE_INVENTORY_ALERTS")
BasicBrokers.RegisterEvent("Durability", "EQUIPMENT_SWAP_FINISHED")
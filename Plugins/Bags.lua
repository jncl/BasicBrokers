-- **********
-- BASIC BAGS
local _G = _G
local BasicBrokers = _G.BasicBrokers

function BasicBrokers.OnEvent.Bags(_, event, bag)
	local total, free, used_per, used = 0, 0, 0, 0
	for i = 0, 4 do
		if BasicBrokers.IsValidBag(i) then
			total = total + GetContainerNumSlots(i)
			free = free + GetContainerNumFreeSlots(i)
		end
	end
	used = total - free
	used_per = (free / total)
	local used_color = "|cFF00FF00"
	local total_color = "|cFF00FF00"
	if  used_per < .15 then
		used_color = "|cFFFF0000"
	elseif used_per < .35 then
		used_color = "|cFFFFFF00"
	end
	BasicBrokers.Text( "Bags",  used_color .. used .. "|r/" .. total_color .. total .. "|r")
end

function BasicBrokers.OnTooltip.Bags(tip)
	if not BasicBrokers.Bags.tooltip then BasicBrokers.Bags.tooltip = tip end
	BasicBrokers.Bags.tooltip:ClearLines()
	BasicBrokers.Bags.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffBags|r")
	for i = 0, 4 do
		if GetBagName(i) then
			BasicBrokers.Bags.tooltip:AddDoubleLine("|cff69b950  "..GetBagName(i)..":|r ", (GetContainerNumSlots(i)-GetContainerNumFreeSlots(i)).."/"..GetContainerNumSlots(i))
		end
	end
end

local function is_backpack_open()
	for bag = 1, NUM_CONTAINER_FRAMES do
		local check = _G["ContainerFrame"..bag]
		if check:GetID() == 0 and check:IsVisible() then return true end
	end
end

function BasicBrokers.OnClick.Bags(_, which)
	which = which == "RightButton"
	if which then
		return
	elseif is_backpack_open() then
		CloseAllBags()
	else
		OpenAllBags()
	end
end

BasicBrokers.CreatePlugin("Bags","0/0","Interface\\Minimap\\Tracking\\Banker.blp")
BasicBrokers.RegisterEvent("Bags", "PLAYER_LOGIN")
BasicBrokers.RegisterEvent("Bags", "BAG_UPDATE")

-- don't include counts of specialty bags
function BasicBrokers.IsValidBag(num)
	local bag = GetBagName(num)
	if not bag then return false end
	if BasicBrokers.NotBag[bag] then return false end
	return true
end

BasicBrokers.NotBag = {
	-- soul bags
	["Core Felcloth Bag"] = true,
	["Abyssal Bag"] = true,
	["Ebon Shadowbag"] = true,
	["Felcloth Bag"] = true,
	["Box of Souls"] = true,
	["Small Soul Pouch"] = true,
	["Soul Pouch"] = true,

	-- ammo pouches
	["Dragonscale Ammo Pouch"] = true,
	["Gnoll Skin Bandolier"] = true,
	["Netherscale Ammo Pouch"] = true,
	["Smuggler's Ammo Pouch"] = true,
	["Bandolier of the Night Watch"] = true,
	["Heavy Leather Ammo Pouch"] = true,
	["Knothide Ammo Pouch"] = true,
	["Ribbly's Bandolier"] = true,
	["Thick Leather Ammo Pouch"] = true,
	["Hunting Ammo Sack"] = true,
	["Medium Shot Pouch"] = true,
	["Small Ammo Pouch"] = true,
	["Small Leather Ammo Pouch"] = true,
	["Small Shot Pouch"] = true,

	-- quivers
	["Small Quiver"] = true,
	["Medium Quiver"] = true,
	["Light Quiver"] = true,
	["Light Leather Quiver"] = true,
	["Hunting Quiver"] = true,
	["Ribbly's Quiver"] = true,
	["Quiver of the Night Watch"] = true,
	["Quickdraw Quiver"] = true,
	["Knothide Quiver"] = true,
	["Heavy Quiver"] = true,
	["Worg Hide Quiver"] = true,
	["Quiver of a Thousand Feathers"] = true,
	["Nerubian Reinforced Quiver"] = true,
	["Harpy Hide Quiver"] = true,
	["Clefthoof Hide Quiver"] = true,
	["Ancient Sinew Wrapped Lamina"] = true,
}
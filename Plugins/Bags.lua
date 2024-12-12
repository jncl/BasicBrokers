-- **********
-- BAGS
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE

local GetBagName = _G.C_Container and _G.C_Container.GetBagName or _G.GetBagName
local GetContainerNumSlots = _G.C_Container and _G.C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerNumFreeSlots = _G.C_Container and _G.C_Container.GetContainerNumFreeSlots or _G.GetContainerNumFreeSlots

function BasicBrokers.OnEvent.Bags(_, event, _)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.RegisterEvent("Bags", "BAG_UPDATE")
		BasicBrokers.UnregisterEvent("Bags", "PLAYER_LOGIN")
	end

	local total, free, used_per, used = 0, 0
	for i = 0, _G.NUM_BAG_FRAMES do
		if BasicBrokers.IsValidBag(i) then
			total = total + GetContainerNumSlots(i)
			free = free + GetContainerNumFreeSlots(i)
		end
	end
	used = total - free
	used_per = (free / total)
	local used_color = bbc.light_green
	local total_color = bbc.light_green
	if  used_per < .15 then
		used_color = bbc.red
	elseif used_per < .35 then
		used_color = bbc.yellow
	end
	BasicBrokers.Text( "Bags",  used_color .. used .. colorEnd .. "/" .. total_color .. total .. colorEnd)

end

function BasicBrokers.OnTooltip.Bags(tip)

	if not BasicBrokers.Bags.tooltip then BasicBrokers.Bags.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "Bags")

	for i = 0, _G.NUM_BAG_FRAMES do
		if BasicBrokers.IsValidBag(i) then
			BasicBrokers.Bags.tooltip:AddDoubleLine(bbc.green .. "  " .. GetBagName(i).. ":" .. colorEnd, (GetContainerNumSlots(i) - GetContainerNumFreeSlots(i)) .. " / " .. GetContainerNumSlots(i))
		end
	end

end

local function is_backpack_open()
	for bag = 1, _G.NUM_CONTAINER_FRAMES do
		local check = _G["ContainerFrame"..bag]
		if check:GetID() == 0 and check:IsVisible() then return true end
	end
end

function BasicBrokers.OnClick.Bags(_, which)

	which = which == "RightButton"
	if which then
		return
	elseif is_backpack_open() then
		_G.CloseAllBags()
	else
		_G.OpenAllBags()
	end

end

BasicBrokers.CreatePlugin("Bags", "0/0", [[Interface\Minimap\Tracking\Banker]])
BasicBrokers.RegisterEvent("Bags", "PLAYER_LOGIN")

-- don't include counts of specialty bags
function BasicBrokers.IsValidBag(num)

	local bag = GetBagName(num)
	if not bag
	or BasicBrokers.NotBag[bag]
	then
		return false
	end
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

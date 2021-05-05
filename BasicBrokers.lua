-- BasicBrokers Core
local bbName, BasicBrokers = ...
local _G = _G
_G[bbName] = BasicBrokers

BasicBrokers.isClassic = _G.GetCVar("agentUID"):find("wow_classic") and true or false

BasicBrokers.OnEvent = {}
BasicBrokers.OnTooltip = {}
BasicBrokers.OnClick = {}
BasicBrokers.TT = _G.CreateFrame("GameTooltip", "BasicBrokerScanTip", nil, "GameTooltipTemplate")
BasicBrokers.TT:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
local ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")

BasicBrokers.inGarrison = _G.C_Garrison.IsPlayerInGarrison(_G.Enum.GarrisonType.Type_6_0)

function BasicBrokers.CreatePlugin(plugin, pluginText, pluginIcon, pluginType)
	BasicBrokers[plugin] = {
		label = "BasicBroker "..plugin,
		frame = _G.CreateFrame("frame"),

	}
	BasicBrokers[plugin].brokerobj = ldb:NewDataObject(BasicBrokers[plugin].label, {
		type = pluginType or "data source",
		text = pluginText,
		icon = pluginIcon,
		})
	BasicBrokers[plugin].frame:SetScript("OnEvent", BasicBrokers.OnEvent[plugin])
	BasicBrokers[plugin].brokerobj.OnTooltipShow = BasicBrokers.OnTooltip[plugin]
	BasicBrokers[plugin].brokerobj.OnClick = BasicBrokers.OnClick[plugin]
end

function BasicBrokers.RegisterEvent(plugin, event)
	BasicBrokers[plugin].frame:RegisterEvent(event)
end
function BasicBrokers.UnregisterEvent(plugin, event)
	BasicBrokers[plugin].frame:UnregisterEvent(event)
end

function BasicBrokers.Text(plugin, txt)
	BasicBrokers[plugin].brokerobj.text = txt
end

function BasicBrokers.CommaFormat(amount)
  local formatted, k = amount
  while true do
    formatted, k = _G.string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function BasicBrokers.DecimalFormat(amount, decimal)
  local famount, remain, formatted
  if not decimal then decimal = 2 end
  famount =_G.math.abs(_G.math.floor( (amount * 10^decimal) + 0.5) / (10^decimal))
  famount = _G.math.floor(famount)
  remain =  _G.math.floor( ((_G.math.abs(amount) - famount) * 10^decimal) + 0.5) / (10^decimal)
  formatted = BasicBrokers.CommaFormat(famount)
  if (decimal > 0) then
    remain = _G.string.sub(_G.tostring(remain),3)
    formatted = formatted .. "." .. remain .. _G.string.rep("0", decimal - _G.string.len(remain))
  end
  return formatted
end

function BasicBrokers.GoldToText(money)
	local gold, silver, copper
	if money > 0 then
		gold = _G.floor(money / 10000)
		silver = _G.floor((money - (gold * 10000)) / 100)
		copper = _G.mod(money, 100)
		return _G.format("|cffffffff%i|r|cffffd700%s|r |cffffffff%i|r|cffc7c7cf%s|r |cffffffff%i|r|cffeda55f%s|r", gold, "g", silver, "s", copper, "c")
	elseif money < 0 then
		money = (money * -1)
		gold = _G.floor(money / 10000)
		silver = _G.floor((money - (gold * 10000)) / 100)
		copper = _G.mod(money, 100)
		return _G.format("|cFFFF0000-%i|r|cffffd700%s|r |cFFFF0000%i|r|cffc7c7cf%s|r |cFFFF0000%i|r|cffeda55f%s|r", gold, "g", silver, "s", copper, "c")
	else
		return _G.format("|cffffffff%i|r|cffffd700%s|r |cffffffff%i|r|cffc7c7cf%s|r |cffffffff%i|r|cffeda55f%s|r", 0, "g", 0, "s", 0, "c")
	end
end

function BasicBrokers.FactionLabel(reaction)
	local name = _G.getglobal("FACTION_STANDING_LABEL" .. reaction)
	local r = _G.FACTION_BAR_COLORS[reaction].r * 255
	local g = _G.FACTION_BAR_COLORS[reaction].g * 255
	local b = _G.FACTION_BAR_COLORS[reaction].b * 255
	local cText = "|c%02X%02X%02X%02X"
	local hexcolor = _G.format(cText, 255, r, g, b)
	return name, hexcolor
end

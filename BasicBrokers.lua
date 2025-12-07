-- **********
-- Core
-- **********
local bbName, BasicBrokers = ...
local _G = _G

_G[bbName] = BasicBrokers

local agentUID = _G.C_CVar.GetCVar("agentUID")

BasicBrokers.isClsc       = agentUID == "wow_classic" and true or false
BasicBrokers.isClscPTR    = agentUID == "wow_classic_ptr" and true or false
BasicBrokers.isClscERA    = agentUID == "wow_classic_era" and true or false
BasicBrokers.isClscERAPTR = agentUID == "wow_classic_era_ptr" and true or false
BasicBrokers.isClsc       = BasicBrokers.isClsc or BasicBrokers.isClscPTR
BasicBrokers.isClscERA    = BasicBrokers.isClscERA or BasicBrokers.isClscERAPTR

BasicBrokers.isRtl        = agentUID == "wow" and true or false
BasicBrokers.isRtlPTR     = agentUID == "wow_ptr" and true or false
BasicBrokers.isRtlPTRX    = agentUID == "wow_ptr_x" and true or false
BasicBrokers.isRtlBeta    = agentUID == "wow_beta" and true or false
BasicBrokers.isRtl        = BasicBrokers.isRtl or BasicBrokers.isRtlPTR or BasicBrokers.isRtlPTRX or BasicBrokers.isRtlBeta

BasicBrokers.OnEvent   = {}
BasicBrokers.OnTooltip = {}
BasicBrokers.OnClick   = {}

BasicBrokers.TT = _G.CreateFrame("GameTooltip", "BasicBrokerScanTip", nil, "GameTooltipTemplate")
BasicBrokers.TT:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

local ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")

BasicBrokers.uCls = _G.select(2, _G.UnitClass("player"))

function BasicBrokers.CreatePlugin(plugin, pluginText, pluginIcon, pluginType)
	BasicBrokers[plugin] = {
		label = "BasicBroker " .. plugin,
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

function BasicBrokers.DestroyPlugin(plugin)
	ldb.attributestorage[BasicBrokers[plugin].brokerobj] = nil
	ldb.namestorage[BasicBrokers[plugin].brokerobj] = nil
	ldb.proxystorage[plugin] = nil
	BasicBrokers[plugin].brokerobj = nil
	BasicBrokers[plugin].frame = nil
	BasicBrokers[plugin] = nil
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
  local formatted, k = amount or 0
  while true do
    formatted, k = _G.string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if k == 0 then
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
  if decimal > 0 then
    remain = _G.string.sub(_G.tostring(remain),3)
    formatted = formatted .. "." .. remain .. _G.string.rep("0", decimal - _G.string.len(remain))
  end
  return formatted
end

local colorStart = "|cff"
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
BasicBrokers.hexColors = {
	blue        = colorStart .. "8888ee",
	copper      = colorStart .. "b87333",
	green       = colorStart .. "69b950",
	light_green = colorStart .. "00ff00",
	gold        = colorStart .. "ffd700",
	red         = colorStart .. "ff0000",
	silver      = colorStart .. "c0c0c0",
	yellow      = colorStart .. "ffff00",
	white       = colorStart .. "ffffff",
}
local bbc = BasicBrokers.hexColors
function BasicBrokers.GoldToText(money)
	local gold, silver, copper = 0, 0, 0
	if money < 0 then
		money = (money * -1)
	end
	if money ~= 0 then
		gold   = _G.floor(money / 10000)
		silver = _G.floor((money - (gold * 10000)) / 100)
		copper = _G.floor((money - (gold * 10000) - (silver * 100)), 100)
	end
	return bbc.white .. BasicBrokers.CommaFormat(gold) .. colorEnd .. bbc.gold .. "g " .. colorEnd .. bbc.white .. silver .. colorEnd .. bbc.silver .. "s " .. colorEnd .. bbc.white .. copper .. colorEnd .. bbc.copper .. "c" .. colorEnd
end

function BasicBrokers.SetupTooltip(tip, name)

	tip:ClearLines()
	tip:AddLine(bbc.blue .. "BasicBroker: " .. colorEnd .. bbc.white .. name .. colorEnd)

end

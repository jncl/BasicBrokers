-- BasicBrokers Core
BasicBrokers = { }
BasicBrokers.OnEvent = {}
BasicBrokers.OnTooltip = {}
BasicBrokers.OnClick = {}
BasicBrokers.TT = CreateFrame("GameTooltip", "BasicBrokerScanTip", nil, "GameTooltipTemplate")
BasicBrokers.TT:SetOwner(UIParent, "ANCHOR_NONE")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

function BasicBrokers.CreatePlugin(plugin,pluginText,pluginIcon, pluginType)
	BasicBrokers[plugin] = {
		label = "BasicBroker "..plugin,
		frame = CreateFrame("frame"),
		
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

function BasicBrokers.Text(plugin, txt)
	BasicBrokers[plugin].brokerobj.text = txt
end

function BasicBrokers.CommaFormat(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function BasicBrokers.DecimalFormat(amount, decimal)
  local famount, remain, formatted
  if not decimal then decimal = 2 end
  famount = math.abs(math.floor( (amount * 10^decimal) + 0.5) / (10^decimal))
  famount = math.floor(famount)
  remain =  math.floor( ((math.abs(amount) - famount) * 10^decimal) + 0.5) / (10^decimal)
  formatted = BasicBrokers.CommaFormat(famount)
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..string.rep("0", decimal - string.len(remain))
  end
  return formatted
end

function BasicBrokers.GoldToText(money)
	local gold, silver, copper
	if money > 0 then
		gold = floor(money / 10000)
		silver = floor((money - (gold * 10000)) / 100)
		copper = mod(money, 100)	
		return format("|cffffffff%i|r|cffffd700%s|r |cffffffff%i|r|cffc7c7cf%s|r |cffffffff%i|r|cffeda55f%s|r", gold, "g", silver, "s", copper, "c")
	elseif money < 0 then
		money = (money * -1)
		gold = floor(money / 10000)
		silver = floor((money - (gold * 10000)) / 100)
		copper = mod(money, 100)	
		return format("|cFFFF0000-%i|r|cffffd700%s|r |cFFFF0000%i|r|cffc7c7cf%s|r |cFFFF0000%i|r|cffeda55f%s|r", gold, "g", silver, "s", copper, "c")
	else
		return format("|cffffffff%i|r|cffffd700%s|r |cffffffff%i|r|cffc7c7cf%s|r |cffffffff%i|r|cffeda55f%s|r", 0, "g", 0, "s", 0, "c")
	end
end

function BasicBrokers.FactionLabel(reaction)
	local name = getglobal("FACTION_STANDING_LABEL"..reaction)
	local r = FACTION_BAR_COLORS[reaction].r * 255
	local g = FACTION_BAR_COLORS[reaction].g * 255
	local b = FACTION_BAR_COLORS[reaction].b * 255
	local cText = "|c%02X%02X%02X%02X"
	local hexcolor = format(cText, 255, r, g, b)	
	return name, hexcolor
end

--Interface\\Minimap\\Tracking\\
--
--Ammunition.blp
--Banker.blp
--Class.blp
--Food.blp
--Mailbox.blp
--OBJECTICONS.BLP
--Profession.blp
--Repair.blp
--TrivialQuests.blp
--StableMaster.blp
--Reagents.blp
--Poisons.blp
--Innkeeper.blp
--FlightMaster.blp
--BattleMaster.blp
--Auctioneer.blp
-- **********
-- XP
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "

function BasicBrokers.OnEvent.XP(_, event, unit)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.initialXP = _G.UnitXP("player")
		BasicBrokers.sessionTime_XP = _G.time()
		BasicBrokers.lastXP = BasicBrokers.initialXP
		BasicBrokers.killXP = 0
		BasicBrokers.RegisterEvent("XP", "PLAYER_XP_UPDATE")
		BasicBrokers.RegisterEvent("XP", "PLAYER_LEVEL_UP")
		BasicBrokers.UnregisterEvent("Faction", "PLAYER_LOGIN")
	end
	if event == "PLAYER_LEVEL_UP" then
		BasicBrokers.initialXP = 0
		BasicBrokers.sessionTime_XP = _G.time()
		BasicBrokers.lastXP = 0
		BasicBrokers.killXP = 0
	end
	if event == "PLAYER_XP_UPDATE" then
		BasicBrokers.killXP = _G.UnitXP("player") - BasicBrokers.lastXP
		BasicBrokers.lastXP = _G.UnitXP("player")
	end

	if (unit and unit == "player") or not unit then
		local xp = _G.format("%.1f%%", (_G.UnitXP("player") / _G.UnitXPMax("player") * 100))
		local rested = _G.GetXPExhaustion()
		if rested then
			rested = _G.format("%.1f%%", (rested / _G.UnitXPMax("player") * 100))
			BasicBrokers.Text("XP", xp .. "  (" .. rested .. ")")
		else
			BasicBrokers.Text("XP", xp)
		end
	end

end

function BasicBrokers.OnTooltip.XP(tip)

	if not BasicBrokers.XP.tooltip then BasicBrokers.XP.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "XP")

	local Session = _G.UnitXP("player") - BasicBrokers.initialXP
	local perHour, timeToLevel = 0, "N/A"
	local Rested = _G.GetXPExhaustion()
	if not Rested then Rested = 0 end
	local XP = _G.UnitXP("player")
	local MaxXP = _G.UnitXPMax("player")
	local Remaining = MaxXP - XP
	local perKill = "N/A"
	if Session > 0 then perHour = _G.floor(Session / (_G.time() - BasicBrokers.sessionTime_XP ) * 3600)	end
	if Remaining > 0 and BasicBrokers.killXP > 0 then perKill = _G.floor(Remaining / BasicBrokers.killXP ) end
	if perHour > 0 and Remaining > 0 then timeToLevel = BasicBrokers.DecimalFormat(Remaining / perHour, 2) .. " hrs" end
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Current XP:" .. colorEnd, BasicBrokers.CommaFormat(XP))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "XP to Level:" .. colorEnd, BasicBrokers.CommaFormat(MaxXP))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Remaining:" .. colorEnd, BasicBrokers.CommaFormat(Remaining))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Rested XP:" .. colorEnd, BasicBrokers.CommaFormat(Rested))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Session:" .. colorEnd, BasicBrokers.CommaFormat(Session))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "XP / Hour:" .. colorEnd, BasicBrokers.CommaFormat(perHour))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "XP / Kill:" .. colorEnd, BasicBrokers.CommaFormat(BasicBrokers.killXP))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Mobs to Level:" .. colorEnd, BasicBrokers.CommaFormat(perKill))
	BasicBrokers.XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Time to Level:" .. colorEnd, timeToLevel)
	BasicBrokers.XP.tooltip:AddLine(" ")
	BasicBrokers.XP.tooltip:AddLine("Alt-Click: Resets Session")

end

function BasicBrokers.OnClick.XP()

	if _G.IsAltKeyDown() then
		BasicBrokers.initialXP = _G.UnitXP("player")
		BasicBrokers.sessionTime_XP = _G.time()
		BasicBrokers.lastXP = BasicBrokers.initialXP
		BasicBrokers.killXP = 0
	end

end

-- check to see if this plugin should be loaded
if _G.UnitLevel("player") == _G.GetMaxPlayerLevel() then return end

BasicBrokers.CreatePlugin("XP", "0%", [[Interface\AddOns\BasicBrokers\Icons\xp]])
BasicBrokers.RegisterEvent("XP", "PLAYER_LOGIN")

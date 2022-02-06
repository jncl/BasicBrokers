-- **********
-- BASIC XP
-- **********
local _G = _G
local BasicBrokers = _G.BasicBrokers

function BasicBrokers.OnEvent.XP(_,event,unit)
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
	if event == "PLAYER_LOGIN" then
		BasicBrokers.initialXP = _G.UnitXP("player")
		BasicBrokers.sessionTime_XP = _G.time()
		BasicBrokers.lastXP = BasicBrokers.initialXP
		BasicBrokers.killXP = 0
	end
	if event == "PLAYER_LEVEL_UP" then
		BasicBrokers.initialXP = 0
		BasicBrokers.lastXP = 0
		BasicBrokers.killXP = 0
		BasicBrokers.sessionTime_XP = _G.time()
	end
	if event == "PLAYER_XP_UPDATE" then
		BasicBrokers.killXP = _G.UnitXP("player") - BasicBrokers.lastXP
		BasicBrokers.lastXP = _G.UnitXP("player")
	end
end

function BasicBrokers.OnTooltip.XP(tip)
	if not BasicBrokers.XP.tooltip then BasicBrokers.XP.tooltip = tip end
	local Session = _G.UnitXP("player") - BasicBrokers.initialXP
	local perHour, timeToLevel = 0, "N/A"
	local Rested = _G.GetXPExhaustion()
	if not Rested then Rested = 0 end
	local XP = _G.UnitXP("player")
	local MaxXP = _G.UnitXPMax("player")
	local Remaining = MaxXP - XP
	local perKill = "N/A"
	if Session > 0 then perHour =  _G.floor(Session / (_G.time() - BasicBrokers.sessionTime_XP ) * 3600) 	end
	if Remaining > 0  and BasicBrokers.killXP > 0 then perKill = _G.floor(Remaining / BasicBrokers.killXP ) end
	if perHour > 0 and Remaining > 0 then timeToLevel = BasicBrokers.DecimalFormat(Remaining / perHour, 2).." hrs" end
	BasicBrokers.XP.tooltip:ClearLines()
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff8888eeBasicBroker:|r |cffffffffXP|r")
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Current XP:|r", BasicBrokers.CommaFormat(XP))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  XP to Level:|r", BasicBrokers.CommaFormat(MaxXP))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Remaining:|r", BasicBrokers.CommaFormat(Remaining))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Rested XP:|r", BasicBrokers.CommaFormat(Rested))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Session:|r", BasicBrokers.CommaFormat(Session))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  XP / Hour:|r", BasicBrokers.CommaFormat(perHour))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  XP / Kill:|r", BasicBrokers.CommaFormat(BasicBrokers.killXP))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Mobs to Level:|r", BasicBrokers.CommaFormat(perKill))
	BasicBrokers.XP.tooltip:AddDoubleLine("|cff69b950  Time to Level:|r", timeToLevel)
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
if _G.UnitLevel("player") == _G.MAX_PLAYER_LEVEL then return end

BasicBrokers.CreatePlugin("XP","0%","Interface\\AddOns\\BasicBrokers\\Icons\\xp.tga")
BasicBrokers.RegisterEvent("XP", "PLAYER_XP_UPDATE")
BasicBrokers.RegisterEvent("XP", "PLAYER_LOGIN")
BasicBrokers.RegisterEvent("XP", "PLAYER_LEVEL_UP")

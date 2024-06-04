-- **********
-- XP
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "

local xp, rested
local function showXP(unit)
	if unit
	and unit == "player"
	or not unit
	then
		xp = _G.format("%.1f%%", (_G.UnitXP("player") / _G.UnitXPMax("player") * 100))
		rested = _G.GetXPExhaustion()
		if rested then
			rested = _G.format("%.1f%%", (rested / _G.UnitXPMax("player") * 100))
			BasicBrokers.Text("XP", xp .. "  (" .. rested .. ")")
		else
			BasicBrokers.Text("XP", xp)
		end
	end
end
local Session
local function resetStats()
	-- _G.print("resetStats")
	BasicBrokers.initialXP = _G.UnitXP("player")
	BasicBrokers.sessionTime_XP = _G.time()
	BasicBrokers.lastXP = BasicBrokers.initialXP
	BasicBrokers.killXP = 0
	Session = 0
end
local function startup()
	BasicBrokers.CreatePlugin("XP", "0%", [[Interface\AddOns\BasicBrokers\Icons\xp]])
	BasicBrokers.RegisterEvent("XP", "PLAYER_XP_UPDATE")
	BasicBrokers.RegisterEvent("XP", "PLAYER_LEVEL_UP")
	resetStats()
	showXP()
end
function BasicBrokers.OnEvent.XP(_, event, unit)

	if event == "PLAYER_LEVEL_UP" then
		if _G.UnitLevel("player") == _G.GetMaxPlayerLevel() then
			BasicBrokers.UnregisterEvent("XP", "PLAYER_XP_UPDATE")
			BasicBrokers.UnregisterEvent("XP", "PLAYER_LEVEL_UP")
			BasicBrokers.DestroyPlugin("XP")
			return
		else
			BasicBrokers.lastXP = _G.UnitXP("player")
		end
	end
	if event == "PLAYER_XP_UPDATE" then
		BasicBrokers.killXP = _G.UnitXP("player") - BasicBrokers.lastXP
		BasicBrokers.lastXP = _G.UnitXP("player")
		Session = Session + BasicBrokers.killXP
	end

	showXP(unit)

end

local perHour, timeToLevel, Rested, XP, MaxXP, Remaining, perKill
function BasicBrokers.OnTooltip.XP(tip)

	if not BasicBrokers.XP.tooltip then BasicBrokers.XP.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "XP")

	XP = _G.UnitXP("player")
	MaxXP = _G.UnitXPMax("player")
	Remaining = MaxXP - XP

	if Session > 0 then
		perHour = _G.floor(Session / (_G.time() - BasicBrokers.sessionTime_XP ) * 3600)
	else
		perHour = 0
	end
	if Remaining > 0
	and BasicBrokers.killXP > 0
	then
		perKill = _G.floor(Remaining / BasicBrokers.killXP )
	else
		perKill = "N/A"
	end
	if perHour > 0
	and Remaining > 0
	then
		timeToLevel = BasicBrokers.DecimalFormat(Remaining / perHour, 2) .. " hrs"
	else
		timeToLevel = "N/A"
	end
	Rested = _G.GetXPExhaustion() or 0
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
		resetStats()
	end

end

-- wait for player level to be corrected for Classic SoD
_G.C_Timer.After(0.05, function()
	-- _G.print("BB XP", _G.UnitLevel("player"), _G.GetMaxPlayerLevel())
	-- check to see if this plugin should be loaded
	if _G.UnitLevel("player") == _G.GetMaxPlayerLevel() then return end
	startup()
end)

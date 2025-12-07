-- **********
-- Pet XP
-- **********
local _G = _G

local BasicBrokers = _G.BasicBrokers

-- check to see if this plugin should be loaded
if BasicBrokers.isRtl
or BasicBrokers.isClsc
or BasicBrokers.uCls ~= "HUNTER"
then
	return
end

local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "

local _, Session
local function resetStats()
	BasicBrokers.Pet_currLevel      = _G.UnitLevel("pet")
	BasicBrokers.Pet_initialXP, _   = _G.GetPetExperience()
	BasicBrokers.Pet_lastXP         = BasicBrokers.Pet_initialXP
	BasicBrokers.Pet_killXP         = 0
	BasicBrokers.Pet_sessionTime_XP = _G.time()
	Session                         = 0
end

local hasPetUI, happiness, petLoyalty, totalPoints, spent, availTPs, playerLevel, petLevel, currXP, nextXP
function BasicBrokers.OnEvent.Pet_XP(_, event, _)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.RegisterEvent("Pet_XP", "UNIT_HAPPINESS")
		BasicBrokers.RegisterEvent("Pet_XP", "UNIT_PET")
		BasicBrokers.RegisterEvent("Pet_XP", "UNIT_PET_EXPERIENCE")
		BasicBrokers.RegisterEvent("Pet_XP", "UNIT_PET_TRAINING_POINTS")
		BasicBrokers.RegisterEvent("Pet_XP", "PLAYER_LEVEL_UP")
		BasicBrokers.UnregisterEvent("Pet_XP", "PLAYER_LOGIN")
	end

	hasPetUI, _ = _G.HasPetUI()

	if not hasPetUI then
		BasicBrokers.Text("Pet_XP", "No Pet")
		return
	else
		happiness, _, _    = _G.GetPetHappiness()
		petLoyalty         = _G.GetPetLoyalty()
		totalPoints, spent = _G.GetPetTrainingPoints()
		availTPs           = (totalPoints - spent)
		playerLevel        = _G.UnitLevel("player")
		petLevel           = _G.UnitLevel("pet")
		currXP, nextXP     = _G.GetPetExperience()
		BasicBrokers.Text("Pet_XP", _G.format("%s : %s", availTPs, petLevel < playerLevel and _G.format("%.1f%%", (currXP / nextXP * 100)) or "--"))
	end

	if event == "UNIT_PET"
	and BasicBrokers.Pet_currLevel < petLevel
	then
		resetStats()
	end
	if event == "UNIT_PET_EXPERIENCE" then
		BasicBrokers.Pet_killXP = currXP - BasicBrokers.Pet_lastXP
		BasicBrokers.Pet_lastXP = currXP
		Session                 = Session + BasicBrokers.Pet_killXP
	end

end

local perHour, timeToLevel, Remaining, perKill
function BasicBrokers.OnTooltip.Pet_XP(tip)

	-- _G.print("OnTooltip Pet_XP", hasPetUI, happiness, petLoyalty, totalPoints, petLevel, currXP, nextXP)

	if not BasicBrokers.Pet_XP.tooltip then
		BasicBrokers.Pet_XP.tooltip = tip
	end
	BasicBrokers.SetupTooltip(tip, "Pet XP")

	if not hasPetUI then
		BasicBrokers.Pet_XP.tooltip:AddLine("No Pet Called")
	else
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Happiness:" .. colorEnd, BasicBrokers.CommaFormat(happiness))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Loyalty:" .. colorEnd, BasicBrokers.CommaFormat(petLoyalty))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Training Points:" .. colorEnd, BasicBrokers.CommaFormat(availTPs))

		if petLevel == playerLevel then
			return
		end

		BasicBrokers.Pet_XP.tooltip:AddLine(" ")
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Current XP:" .. colorEnd, BasicBrokers.CommaFormat(currXP))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Next XP:" .. colorEnd, BasicBrokers.CommaFormat(nextXP))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Remaining:" .. colorEnd, BasicBrokers.CommaFormat(nextXP - currXP))
		if Session > 0 then
			perHour = _G.floor(Session / (_G.time() - BasicBrokers.Pet_sessionTime_XP ) * 3600)
		else
			perHour = 0
		end
		Remaining = nextXP - currXP
		if Remaining > 0
		and BasicBrokers.Pet_killXP > 0
		then
			perKill = _G.floor(Remaining / BasicBrokers.Pet_killXP )
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
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Session:" .. colorEnd, BasicBrokers.CommaFormat(Session))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "XP / Hour:" .. colorEnd, BasicBrokers.CommaFormat(perHour))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "XP / Kill:" .. colorEnd, BasicBrokers.CommaFormat(BasicBrokers.Pet_killXP))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Mobs to Level:" .. colorEnd, BasicBrokers.CommaFormat(perKill))
		BasicBrokers.Pet_XP.tooltip:AddDoubleLine(bbc.green .. twoSpaces .. "Time to Level:" .. colorEnd, timeToLevel)
		BasicBrokers.Pet_XP.tooltip:AddLine(" ")
		BasicBrokers.Pet_XP.tooltip:AddLine("Alt-Click: Resets Session")
	end

end

function BasicBrokers.OnClick.Pet_XP()

	if _G.IsAltKeyDown() then
		resetStats()
	end

end

BasicBrokers.CreatePlugin("Pet_XP", "0: 0%", [[Interface\AddOns\BasicBrokers\Icons\xp]])
BasicBrokers.RegisterEvent("Pet_XP", "PLAYER_LOGIN")
resetStats()

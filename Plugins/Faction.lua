-- **********
-- BASIC FACTION
local _G = _G
local BasicBrokers = _G.BasicBrokers

local format, ipairs, pairs = _G.format, _G.ipairs, _G.pairs

function BasicBrokers.OnEvent.Faction()

	local name, standing, min, max, value = _G.GetWatchedFactionInfo()

	if name then
		local reputation, hexcolor = BasicBrokers.FactionLabel(standing)
		value = format("%.1fk", ((value - min) / 1000))
		max = format("%.1fk", ((max - min) / 1000))
		BasicBrokers.Text( "Faction", hexcolor .. reputation .. "|r: " .. value .. " / " .. max)
	else
		BasicBrokers.Text( "Faction", "Faction")
	end

end

local myFactions
local function getFactionInfo()

	myFactions = {}
	local topheaderIndex = 0
	local factionIndex = 0
	local childIndex = 0
	local childFactionIndex = 0
	local name, standingID, barMin, barMax, barValue, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID

	-- get and organize factions into myFactions
	for i = 1, _G.GetNumFactions() do
		if not _G.IsFactionInactive(i) then
			-- local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex);
			name, _, standingID, barMin, barMax, barValue, _, _, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, _, _ = _G.GetFactionInfo(i)


			-- print("BB GetFactionInfo", name, standingID, barMin, barMax, barValue, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, topheaderIndex, factionIndex, childIndex)

			--Normalize Values
			barMax = barMax - barMin
			barValue = barValue - barMin
			barMin = 0

			if not isCollapsed then
				if isHeader
				and not isChild
				then
					topheaderIndex = topheaderIndex + 1
					factionIndex = 0
					childIndex = 0
					myFactions[topheaderIndex] = { name = name, displayHeader = true, factions = {}, children = {} }
				elseif isHeader
				and isChild
				then
					myFactions[topheaderIndex].hasChildHeader = true
					childIndex = childIndex + 1
					myFactions[topheaderIndex].children[childIndex] = { name = name, displayHeader = true, factions = {} }
					childFactionIndex = 0
				elseif isChild then
					childFactionIndex = childFactionIndex + 1
					myFactions[topheaderIndex].children[childIndex].factions[childFactionIndex] = { name = name, standing = standingID, value = barValue, maxvalue = barMax, isWatched = isWatched, faction = factionID }
				else
					factionIndex = factionIndex + 1
					myFactions[topheaderIndex].factions[factionIndex] = { name = name, standing = standingID, value = barValue, maxvalue = barMax, isWatched = isWatched, faction = factionID }
				end
			end
		end
	end

end
function BasicBrokers.OnTooltip.Faction(tip)

	if not BasicBrokers.Faction.tooltip then BasicBrokers.Faction.tooltip = tip end

	BasicBrokers.Faction.tooltip:ClearLines()
	BasicBrokers.Faction.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffFaction|r")

	getFactionInfo()

	-- _G.Spew("BB Factions", myFactions[0])

	-- display factions
	for k, v in ipairs(myFactions) do
		-- _G.Spew("BB myFactions", v)
		if v.displayHeader then
			BasicBrokers.Faction.tooltip:AddLine("|cff69b950" .. v.name .. "|r")
			for j, h in ipairs(v.factions) do
				-- _G.Spew("BB Factions#1", h)
				BasicBrokers.AddFaction(h, false)
			end
			if v.hasChildHeader then
				for j, h in ipairs(v.children) do
					if h.displayHeader then
						if h.faction then
							-- _G.Spew("BB Factions#2", h)
							BasicBrokers.AddFaction(h, true)
						else
							BasicBrokers.Faction.tooltip:AddLine("|cff69b950  " .. h.name .. "|r")
						end
						for e, d in ipairs(h.factions) do
							-- _G.Spew("BB Factions#3", d)
							BasicBrokers.AddFaction(d, false)
						end
					end
				end
			end
		end
	end

end

function BasicBrokers.AddFaction(factionInfo, isHeader)

	-- _G.Spew("faction", factionInfo)

	local reputation, hexcolor = BasicBrokers.FactionLabel(factionInfo.standing)
	if factionInfo.isWatched then
		factionInfo.name = factionInfo.name .. " (w)"
		hexcolor = "|cffffffff"
	elseif isHeader then
		factionInfo.name = "|cff69b950" .. factionInfo.name .. "|r"
	end
	if not isHeader then factionInfo.name = "  " .. factionInfo.name end

	local repMod, repCnt = 0, 0
	-- Paragon Faction (Legion & BfA)
	-- print("BB-F#1", factionInfo.standing, factionInfo.faction, factionInfo.value, factionInfo.maxvalue)
	if factionInfo.standing == 8
	and _G.C_Reputation.IsFactionParagon(factionInfo.faction)
	then
		local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = _G.C_Reputation.GetFactionParagonInfo(factionInfo.faction)
		-- print("BB-F#2", _G.C_Reputation.IsFactionParagon(factionInfo.faction), currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon)
		if hasRewardPending then
			BasicBrokers.Faction.tooltip:AddDoubleLine("  ".. hexcolor .. factionInfo.name .. "|r", hexcolor .. reputation .. ": |r Reward Pending")
		else
			repMod = ((currentValue / threshold) %1)
			repCnt = (currentValue / threshold) - repMod
			BasicBrokers.Faction.tooltip:AddDoubleLine("  ".. hexcolor .. factionInfo.name .. "|r", hexcolor .. reputation .. ": " .. _G.math.floor((repMod * threshold) + 0.5) .. "|r / " .. hexcolor .. threshold .. "|r (" .. repCnt .. ")")
		end
	else
		if factionInfo.maxvalue > 0 then
			repMod = ((factionInfo.value / factionInfo.maxvalue) %1)
			repCnt = (factionInfo.value / factionInfo.maxvalue) - repMod
		else
			repMod, repCnt = 0, 0
		end
		BasicBrokers.Faction.tooltip:AddDoubleLine("  ".. hexcolor .. factionInfo.name .. "|r", hexcolor .. reputation .. ": " .. _G.math.floor((repMod * factionInfo.maxvalue) + 0.5) .. "|r / " .. hexcolor .. factionInfo.maxvalue .. "|r")
	end

	repMod, repCnt = nil, nil

end

function BasicBrokers.OnClick.Faction()

	_G.ToggleCharacter("ReputationFrame")

end

BasicBrokers.CreatePlugin("Faction","Faction","Interface\\Minimap\\Tracking\\BattleMaster.blp")
BasicBrokers.RegisterEvent("Faction", "PLAYER_LOGIN")
BasicBrokers.RegisterEvent("Faction", "UPDATE_FACTION")

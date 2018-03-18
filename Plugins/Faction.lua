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

function BasicBrokers.OnTooltip.Faction(tip)

	local topheaderIndex = 0
	local childIndex = 0
	local faction, _, reputationID, botValue, curValue, topValue, maxValue, earnedValue, isHeader, hasRep, watched, isChild, factionID
	local currentValue, threshold, rewardQuestID, hasRewardPending
	local myFactions = {}
	if not BasicBrokers.Faction.tooltip then BasicBrokers.Faction.tooltip = tip end

	BasicBrokers.Faction.tooltip:ClearLines()
	BasicBrokers.Faction.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffFaction|r")

	-- get and organize factions into myFactions
	for i = 1, _G.GetNumFactions() do
		if not _G.IsFactionInactive(i) then
			faction, _, reputationID, botValue, topValue, earnedValue , _, _, isHeader, _, hasRep, watched, isChild, factionID = _G.GetFactionInfo(i)
			curValue = earnedValue - botValue
			maxValue = topValue - botValue
			if faction ~= nil then
				if isHeader and not isChild then
					childIndex = 0
					topheaderIndex = topheaderIndex + 1
					myFactions[topheaderIndex] = { hasChildHeader = false, name = faction, displayHeader = false, children = {}, factions = {} }
				elseif isHeader and isChild then
					childIndex = childIndex + 1
					myFactions[topheaderIndex].hasChildHeader = true
					myFactions[topheaderIndex].children[childIndex] = { name = faction, isFaction = false, displayHeader = false, factions = {} }
					if hasRep then
						myFactions[topheaderIndex].children[childIndex].isFaction = true
						myFactions[topheaderIndex].children[childIndex].reaction = reputationID
						myFactions[topheaderIndex].children[childIndex].value = curValue
						myFactions[topheaderIndex].children[childIndex].maxvalue = maxValue
						myFactions[topheaderIndex].children[childIndex].isWatched = watched
					end
				-- Legion Paragon Rep
				elseif reputationID > 3 then
					if _G.C_Reputation.IsFactionParagon(factionID) then
						currentValue, threshold, rewardQuestID, hasRewardPending =  _G.C_Reputation.GetFactionParagonInfo(factionID)
						-- print("BB Faction Paragon:", currentValue, threshold, rewardQuestID, hasRewardPending)
						curValue = currentValue
						-- curValue = currentValue > threshold and currentValue - threshold or currentValue
						maxValue = threshold
					end
					if myFactions[topheaderIndex].hasChildHeader then
						myFactions[topheaderIndex].displayHeader = true
						myFactions[topheaderIndex].children[childIndex].displayHeader = true
						_G.table.insert(myFactions[topheaderIndex].children[childIndex].factions, { name = faction, reaction = reputationID, isWatched = watched, value = curValue, maxvalue = maxValue, paragonReward = hasRewardPending or false })
					else
						myFactions[topheaderIndex].displayHeader = true
						_G.table.insert(myFactions[topheaderIndex].factions, { name = faction, reaction = reputationID, isWatched = watched, value = curValue, maxvalue = maxValue, paragonReward = hasRewardPending or false })
					end
				end
			end
		end
	end

	-- display factions
	for k, v in ipairs(myFactions) do
		if v.displayHeader then
			BasicBrokers.Faction.tooltip:AddLine("|cff69b950" .. v.name .. "|r")
			for j, h in ipairs(v.factions) do
				BasicBrokers.AddFaction(h, false)
			end
			if v.hasChildHeader then
				for j, h in ipairs(v.children) do
					if h.displayHeader then
						if h.isFaction then
							BasicBrokers.AddFaction(h, true)
						else
							BasicBrokers.Faction.tooltip:AddLine("|cff69b950  " .. h.name .. "|r")
						end
						for e, d in ipairs(h.factions) do
							BasicBrokers.AddFaction(d, false)
						end
					end
				end
			end
		end
	end

end

function BasicBrokers.AddFaction(faction, isHeader)

	-- Spew("faction", faction)
	local reputation, hexcolor = BasicBrokers.FactionLabel(faction.reaction)
	if faction.isWatched then
		faction.name = faction.name .. " (w)"
		hexcolor = "|cffffffff"
	elseif isHeader then
		faction.name = "|cff69b950" .. faction.name .. "|r"
	end
	if not isHeader then faction.name = "  " .. faction.name end

	if faction.reaction == 8
	and faction.paragonReward
	then
		BasicBrokers.Faction.tooltip:AddDoubleLine("  ".. hexcolor .. faction.name .. "|r", hexcolor .. reputation .. ": |r Reward Pending")
	else
		-- Rep values increase, so remove multiples of maxvalue
		local repMod = ((faction.value / faction.maxvalue) %1)
		local repCnt = (faction.value / faction.maxvalue) - repMod
		-- print("BB AddFaction:", faction.value, faction.maxvalue, repMod, repCnt)

		BasicBrokers.Faction.tooltip:AddDoubleLine("  ".. hexcolor .. faction.name .. "|r", hexcolor .. reputation .. ": " .. _G.math.floor((repMod * faction.maxvalue) + 0.5) .. "|r / " .. hexcolor .. faction.maxvalue .. "|r (" .. repCnt .. ")")
		repMod, repCnt = nil, nil
	end

end

function BasicBrokers.OnClick.Faction()

	_G.ToggleCharacter("ReputationFrame")

end

BasicBrokers.CreatePlugin("Faction","Faction","Interface\\Minimap\\Tracking\\BattleMaster.blp")
BasicBrokers.RegisterEvent("Faction", "PLAYER_LOGIN")
BasicBrokers.RegisterEvent("Faction", "UPDATE_FACTION")

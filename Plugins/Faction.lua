-- **********
-- FACTION
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local colorStart = "|cff"
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "
local cText = colorStart .. "%02X%02X%02X"

local format, ipairs = _G.format, _G.ipairs
local myFactions
local name, standingID, barMin, barMax, barValue, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, factionColor, factionType, standingText

local function unpackInfoEntry(factionInfo)

	name               = factionInfo[1]
	-- description     = factionInfo[2]
	standingID         = factionInfo[3]
	barMin             = factionInfo[4]
	barMax             = factionInfo[5]
	barValue           = factionInfo[6]
	-- atWarWith       = factionInfo[7]
	-- canToggleAtWar  = factionInfo[8]
	isHeader           = factionInfo[9]
	isCollapsed        = factionInfo[10]
	hasRep             = factionInfo[11]
	isWatched          = factionInfo[12]
	isChild            = factionInfo[13]
	factionID          = factionInfo[14]
	-- hasBonusRepGain = factionInfo[15]
	-- canBeLFGBonus   = factionInfo[16]
	factionColor       = factionInfo[17]
	factionType        = factionInfo[18]
	standingText       = factionInfo[19]

end
local function packInfoEntry(factionInfo)

	-- --@debug@
	-- _G.Spew("packInfoEntry #1", factionInfo)
	-- --@end-debug@

	factionInfo[3]  = standingID
	factionInfo[4]  = barMin
	factionInfo[5]  = barMax
	factionInfo[6]  = barValue
	factionInfo[17] = factionColor
	factionInfo[18] = factionType
	factionInfo[19] = standingText

	-- --@debug@
	-- _G.Spew("packInfoEntry #2", factionInfo)
	-- --@end-debug@

end
local function getFactionInfo(idx)
	local factionInfo
	-- _G.print("getFactionInfo", idx)
	if idx == 0 then
		return {}
	elseif idx < 250 then
		factionInfo = {_G.GetFactionInfo(idx)}
	else
		factionInfo = {_G.GetFactionInfoByID(idx)}
	end
	--@debug@
	-- _G.Spew("getFactionInfo #1", factionInfo)
	--@end-debug@

	-- name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus

	unpackInfoEntry(factionInfo)

	factionColor = _G.FACTION_BAR_COLORS[standingID]
	factionType  = _G.FACTION_STANDING_LABEL or ""
	standingText = _G.GetText("FACTION_STANDING_LABEL" .. standingID, _G.UnitSex("player")) or ""

	if BasicBrokers.isRtl then
		local isMajorFaction = factionID and _G.C_Reputation.IsMajorFaction(factionID)
		local repInfo = factionID and _G.C_GossipInfo.GetFriendshipReputation(factionID)
		if repInfo and repInfo.friendshipFactionID > 0 then
			-- --@debug@
			-- _G.Spew("repInfo" .. idx, repInfo)
			-- --@end-debug@
			standingID = repInfo.reaction
			standingText = repInfo.reaction
			if repInfo.nextThreshold then
				barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
			else
				-- max rank, make it look like a full bar
				barMin, barMax, barValue = 0, 1, 1
			end
			factionType = "rep"
		elseif isMajorFaction then
			local majorFactionData = _G.C_MajorFactions.GetMajorFactionData(factionID)
			-- --@debug@
			-- _G.Spew("majorFaction" .. idx, majorFactionData)
			-- --@end-debug@
			barMin, barMax = 0, majorFactionData.renownLevelThreshold
			barValue = _G.C_MajorFactions.HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
			standingID = majorFactionData.renownLevel
			factionColor = _G.BLUE_FONT_COLOR
			factionType = _G.RENOWN_LEVEL_LABEL
			standingText = _G.RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel
		end
	end

	packInfoEntry(factionInfo)

	--@debug@
	-- _G.Spew("getFactionInfo #2", factionInfo)
	--@end-debug@

	return factionInfo

end
local function getAllFactionInfo()
	-- print("getAllFactionInfo")

	local factionInfo
	myFactions = {}
	local topheaderIndex = 0
	local factionIndex = 0
	local childIndex = 0
	local childFactionIndex = 0

	-- get and organize factions into myFactions
	for i = 1, _G.GetNumFactions() do
		if not _G.IsFactionInactive(i) then
			factionInfo = getFactionInfo(i)

			-- --@debug@
			-- _G.Spew("getAllFactionInfo", factionInfo)
			-- --@end-debug@

			unpackInfoEntry(factionInfo)

			--Normalize Values
			barMax = barMax - barMin
			barValue = barValue - barMin

			if not isCollapsed then
				if isHeader then
					if not isChild then
						topheaderIndex = topheaderIndex + 1
						factionIndex = 0
						childIndex = 0
						myFactions[topheaderIndex] = { name = name, displayHeader = true, faction = factionID, factions = {}, standing = standingID, children = {}, type = factionType, text = standingText, color = not BasicBrokers.isClsc and _G.FACTION_YELLOW_COLOR or {r = 1.0, g = 0.82, b = 0}}
					else
						myFactions[topheaderIndex].hasChildHeader = true
						childIndex = childIndex + 1
						childFactionIndex = 0
						if hasRep then
							myFactions[topheaderIndex].children[childIndex] = { name = name, displayHeader = true, factions = {}, standing = standingID, value = barValue, maxvalue = barMax, isWatched = isWatched, faction = factionID, type = factionType, text = standingText, color = factionColor}
						else
							myFactions[topheaderIndex].children[childIndex] = { name = name, displayHeader = true, factions = {}, type = factionType, text = standingText, color = factionColor}
						end
					end
				elseif isChild then
					childFactionIndex = childFactionIndex + 1
					myFactions[topheaderIndex].children[childIndex].factions[childFactionIndex] = { name = name, standing = standingID, value = barValue, maxvalue = barMax, isWatched = isWatched, faction = factionID, type = factionType, text = standingText, color = factionColor}
				else
					factionIndex = factionIndex + 1
					myFactions[topheaderIndex].factions[factionIndex] = { name = name, standing = standingID, value = barValue, maxvalue = barMax, isWatched = isWatched, faction = factionID, type = factionType, text = standingText, color = factionColor}
				end
			end
		end
	end

end
local function getHexColor(color)
	return _G.format(cText, _G.Round(color.r * 255), _G.Round(color.g * 255), _G.Round(color.b * 255))
end

function BasicBrokers.OnEvent.Faction(_, event, _)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.RegisterEvent("Faction", "UPDATE_FACTION")
		BasicBrokers.UnregisterEvent("Faction", "PLAYER_LOGIN")
	end

	factionID = _G.select(6, _G.GetWatchedFactionInfo())
	-- _G.print("OnEvent", event, factionID)

	local min, max, value
	if factionID > 0 then
		name, standingID, min, max, value, factionID = _G.GetWatchedFactionInfo()
		value = format("%.1fk", ((value - min) / 1000))
		max = format("%.1fk", ((max - min) / 1000))
		if not BasicBrokers.isClsc then
			BasicBrokers.Text( "Faction", _G.FACTION_BAR_COLORS[standingID] .. "_CODE" .. name .. colorEnd .. ": " .. value .. " / " .. max)
		else
			BasicBrokers.Text( "Faction", getHexColor(_G.FACTION_BAR_COLORS[standingID]) .. name .. colorEnd .. ": " .. value .. " / " .. max)
		end
	else
		BasicBrokers.Text( "Faction", "Factions")
	end

end

function BasicBrokers.OnTooltip.Faction(tip)

	if not BasicBrokers.Faction.tooltip then BasicBrokers.Faction.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "Factions")

	getAllFactionInfo()

	-- _G.Spew("BB Factions", myFactions)

	-- display factions
	for _, v in ipairs(myFactions) do
		--@debug@
		-- _G.Spew("BB myFactions", v)
		--@end-debug@
		if v.displayHeader
		and #v.factions > 0
		then
			if not BasicBrokers.isClsc then
				BasicBrokers.Faction.tooltip:AddLine(v.color:GenerateHexColorMarkup() .. v.name .. colorEnd)
			else
				BasicBrokers.Faction.tooltip:AddLine(getHexColor(v.color) .. v.name .. colorEnd)
			end
			for _, h in ipairs(v.factions) do
				--@debug@
				-- _G.Spew("BB Factions#1", h)
				--@end-debug@
				BasicBrokers.AddFaction(h)
			end
			if v.hasChildHeader then
				for _, h in ipairs(v.children) do
					--@debug@
					-- _G.Spew("BB Factions#2", h)
					--@end-debug@
					if h.displayHeader then
						if h.faction then
							BasicBrokers.AddFaction(h)
						else
							if not BasicBrokers.isClsc then
								BasicBrokers.Faction.tooltip:AddLine(twoSpaces .. h.color:GenerateHexColorMarkup() .. h.name .. colorEnd)
							else
								BasicBrokers.Faction.tooltip:AddLine(twoSpaces .. getHexColor(h.color) .. h.name .. colorEnd)
							end
						end
						for _, d in ipairs(h.factions) do
							--@debug@
							-- _G.Spew("BB Factions#3", d)
							--@end-debug@
							BasicBrokers.AddFaction(d, true)
						end
					end
				end
			end
		end
	end

end

function BasicBrokers.AddFaction(factionInfo, isIndent2)

	local hexcolor
	if factionInfo.color.GenerateHexColorMarkup then
		hexcolor = factionInfo.color:GenerateHexColorMarkup()
	else
		hexcolor = getHexColor(factionInfo.color)
	end

	if factionInfo.isWatched then
		factionInfo.name = factionInfo.name .. " (w)"
	end
	if isIndent2 then
		factionInfo.name = twoSpaces .. factionInfo.name
	end

	local repMod, repCnt
	-- Paragon Faction (Legion & BfA)
	-- print("BB-F#1", factionInfo.standing, factionInfo.faction, factionInfo.value, factionInfo.maxvalue, _G.C_Reputation.IsFactionParagon(factionInfo.faction), standingID == 8)
	if factionInfo.standing == 8
	and _G.C_Reputation.IsFactionParagon(factionInfo.faction)
	then
		-- currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon
		local currentValue, threshold, _, hasRewardPending, _ = _G.C_Reputation.GetFactionParagonInfo(factionInfo.faction)
		-- print("BB-F#2", currentValue, threshold)
		if hasRewardPending then
			BasicBrokers.Faction.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionInfo.name .. colorEnd, hexcolor .. factionInfo.text .. ":" .. colorEnd .. " Reward Pending")
		else
			repMod = ((currentValue / threshold) %1)
			repCnt = (currentValue / threshold) - repMod
			BasicBrokers.Faction.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionInfo.name .. colorEnd, hexcolor .. factionInfo.text .. ": " .. _G.math.floor((repMod * threshold) + 0.5) .. colorEnd .. " / " .. hexcolor .. threshold .. colorEnd .. " (" .. repCnt .. ")")
		end
	else
		if factionInfo.maxvalue > 0 then
			repMod = ((factionInfo.value / factionInfo.maxvalue) %1)
		else
			repMod = 0
		end
		BasicBrokers.Faction.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionInfo.name .. colorEnd, hexcolor .. factionInfo.text .. ": " .. _G.math.floor((repMod * factionInfo.maxvalue) + 0.5) .. colorEnd .. " / " .. hexcolor .. factionInfo.maxvalue .. colorEnd)
	end

end

function BasicBrokers.OnClick.Faction()

	_G.ToggleCharacter("ReputationFrame")

end

BasicBrokers.CreatePlugin("Faction", "Factions", [[Interface\Minimap\Tracking\BattleMaster]])
BasicBrokers.RegisterEvent("Faction", "PLAYER_LOGIN")

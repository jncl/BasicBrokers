-- Non-Retail versions use Faction.lua
if not _G.BasicBrokers.isRtl then
	return
end

-- **********
-- REPUTATION
-- **********
local _G = _G

local gender = _G.UnitSex("player")

local BasicBrokers = _G.BasicBrokers
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "

local factionColor, standingText
local function addFaction(factionData, indent)

	local minValue, maxValue, currentValue
	-- Friendship reputation
	local friendshipData = _G.C_GossipInfo.GetFriendshipReputation(factionData.factionID)
	if friendshipData and friendshipData.friendshipFactionID > 0 then
		factionColor = _G.FACTION_BAR_COLORS[5] -- always colour friendships green
		standingText = friendshipData.reaction
		local isMaxRank = friendshipData.nextThreshold == nil
		if isMaxRank then
			-- Max rank, make it look like a full bar
			minValue, maxValue, currentValue = 0, 1, 1
		else
			minValue, maxValue, currentValue = friendshipData.reactionThreshold, friendshipData.nextThreshold, friendshipData.standing
		end
	-- MajorFaction reputation
	elseif _G.C_Reputation.IsMajorFaction(factionData.factionID) then
		local majorFactionData = _G.C_MajorFactions.GetMajorFactionData(factionData.factionID)
		factionColor = _G.BLUE_FONT_COLOR -- always colour majorFaction blue
		standingText = _G.RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel
		local isMaxRenown = _G.C_MajorFactions.HasMaximumRenown(factionData.factionID)
		if isMaxRenown then
			-- Max renown, make it look like a full bar
			minValue, maxValue, currentValue = 0, 1, 1
			standingText = _G.MAJOR_FACTION_MAX_RENOWN_REACHED
		else
			minValue, maxValue, currentValue = 0, majorFactionData.renownLevelThreshold, majorFactionData.renownReputationEarned
		end
	-- Standard reputation
	else
		factionColor = _G.FACTION_BAR_COLORS[factionData.reaction]
		standingText = _G.GetText("FACTION_STANDING_LABEL" .. factionData.reaction, gender)
		local isCapped = factionData.reaction == _G.MAX_REPUTATION_REACTION
		if isCapped then
			-- Max rank, make it look like a full bar
			minValue, maxValue, currentValue = 0, 1, 1
		else
			minValue, maxValue, currentValue = factionData.currentReactionThreshold, factionData.nextReactionThreshold, factionData.currentStanding
		end
	end

	-- Normalize bar values
	maxValue     = maxValue - minValue
	currentValue = currentValue - minValue
	minValue     = 0

	local hexcolor = factionColor:GenerateHexColorMarkup()

	if factionData.isWatched then
		BasicBrokers.Text( "Reputation", hexcolor .. factionData.name .. colorEnd .. ": " .. currentValue .. " / " .. maxValue)
		factionData.name = factionData.name .. " (w)"
	end

	if indent == 2 then
		factionData.name = twoSpaces .. factionData.name
	elseif indent == 4 then
		factionData.name = twoSpaces .. twoSpaces .. factionData.name
	end

	-- Paragon Faction
	local repMod, repCnt
	if _G.C_Reputation.IsFactionParagon(factionData.factionID) then
		local curValue, threshold, _, hasRewardPending, _ = _G.C_Reputation.GetFactionParagonInfo(factionData.factionID)
		-- print("BB-F#2", currentValue, threshold)
		if hasRewardPending then
			BasicBrokers.Reputation.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionData.name .. colorEnd, hexcolor .. standingText .. ":" .. colorEnd .. " Reward Pending")
		else
			repMod = ((curValue / threshold) %1)
			repCnt = (curValue / threshold) - repMod
			BasicBrokers.Reputation.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionData.name .. colorEnd, hexcolor .. standingText .. ": " .. _G.BreakUpLargeNumbers(_G.math.floor((repMod * threshold) + 0.5)) .. colorEnd .. " / " .. hexcolor .. _G.BreakUpLargeNumbers(threshold) .. colorEnd .. " (" .. repCnt .. ")")
		end
	else
		if maxValue > 0 then
			repMod = ((currentValue / maxValue) %1)
		else
			repMod = 0
		end
		BasicBrokers.Reputation.tooltip:AddDoubleLine(twoSpaces .. hexcolor .. factionData.name .. colorEnd, hexcolor .. standingText .. ": " .. _G.BreakUpLargeNumbers(_G.math.floor((repMod * maxValue) + 0.5)) .. colorEnd .. " / " .. hexcolor .. _G.BreakUpLargeNumbers(maxValue) .. colorEnd)
	end
end
local factionList, factionData = {}
local function buildFactionList()
	_G.wipe(factionList)
	for index = 1, _G.C_Reputation.GetNumFactions() do
		factionData = _G.C_Reputation.GetFactionDataByIndex(index)
		if factionData then
			factionData.factionIndex = index
			_G.tinsert(factionList, factionData)
		end
	end

	for _, v in _G.ipairs(factionList) do
		if v.isHeader and not v.isChild then
			BasicBrokers.Reputation.tooltip:AddLine(v.name)
		elseif v.isHeader and v.isChild then
			addFaction(v, 2)
		elseif not v.isHeader and v.isChild then
			addFaction(v, 4)
		else
			addFaction(v, 2)
		end
	end
end

function BasicBrokers.OnEvent.Reputation(_, event, _)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.UnregisterEvent("Reputation", "PLAYER_LOGIN")
		BasicBrokers.RegisterEvent("Reputation", "UPDATE_FACTION")
	end

	-- Update the Broker Text to include the watched Reputation info
	local watchedFactionData = _G.C_Reputation.GetWatchedFactionData()

	if watchedFactionData
	and watchedFactionData.factionID > 0
	then
		buildFactionList()
	else
		BasicBrokers.Text( "Reputation", "Reputation")
	end

end

function BasicBrokers.OnTooltip.Reputation(tip)

	BasicBrokers.SetupTooltip(tip, "Reputation")

	buildFactionList()

end

function BasicBrokers.OnClick.Reputation()

	_G.ToggleCharacter("ReputationFrame")

end

BasicBrokers.CreatePlugin("Reputation", "Reputation", [[Interface\Minimap\Tracking\BattleMaster]])
BasicBrokers.RegisterEvent("Reputation", "PLAYER_LOGIN")
BasicBrokers.Reputation.tooltip = _G.GameTooltip

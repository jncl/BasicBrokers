-- **********
-- BASIC BfA Mission Followers
local _G = _G
local aObj

local BasicBrokers = _G.BasicBrokers

if BasicBrokers.isClassic then return end

local hexClose = _G.FONT_COLOR_CODE_CLOSE
local hexBlu = "|cff00ff00"
local hexBlue  = "|cff8888ee"
local hexLightBlue = _G.RGBToColorCode(0.683, 0.941, 1)
local hexWhite = "|cffffffff"
local indent4 = "    "
local indent8 = indent4 .. indent4
-- local followerType = 0
local garrisonType = _G.Enum.GarrisonType.Type_8_0 -- BfA Missions
local followerType = _G.Enum.GarrisonFollowerType.FollowerType_8_0 -- BfA Missions
local troops = {}
local catLimit = 4 -- can be 6 if researched
local classID = _G.select(3, _G.UnitClass("player"))
local factionID = _G.UnitFactionGroup("player") == "Horde" and 1 or 2

local function getTalentTree()

	local talentTreeIDs = _G.C_Garrison.GetTalentTreeIDsByClassID(garrisonType, classID)
	local completeTalentID = _G.C_Garrison.GetCompleteTalent(garrisonType)
	if talentTreeIDs
	and talentTreeIDs[factionID]
	then
		local talentInfo = _G.C_Garrison.GetTalentTreeInfo(talentTreeIDs[factionID])
		for _, talent in _G.ipairs(talentInfo.talents) do
			-- if _G.Spew then _G.Spew("tt", talent) end

			if talent.id == 549 -- Barracks talent (Horde)
			or talent.id == 553 -- Barracks talent (Alliance)
			and talent.selected == true
			and talent.isBeingResearched == false
			then
				catLimit = 6
			end
		end
	end

end

local followers = {}
local function getFollowerInfo()

	aObj.numActiveFollowers = _G.C_Garrison.GetNumActiveFollowers(followerType) or 0 -- upto 7
	followers = _G.C_Garrison.GetFollowers(followerType) or {}
	aObj.numFollowers = _G.C_Garrison.GetNumFollowers(followerType) -- upto 14

	-- _G.print("BB BfAF:", aObj.numActiveFollowers, #followers, aObj.numFollowers)

	aObj.followersList = {}
	aObj.numActive = 0
	aObj.numTroops = 0
	aObj.numInactive = 0
	aObj.numUncollected = 0
	for i = 1, #followers do
		_G.tinsert(aObj.followersList, i) -- used for sorting followers
		if not followers[i].isCollected then
			aObj.numUncollected = aObj.numUncollected + 1
		elseif followers[i].isTroop then
			aObj.numTroops = aObj.numTroops + 1
		elseif followers[i].status == _G.GARRISON_FOLLOWER_INACTIVE then
			aObj.numInactive = aObj.numInactive + 1
		else
			aObj.numActive = aObj.numActive + 1
		end
	end
	-- _G.print("BB BfAF nums:", aObj.numActive, aObj.numTroops, aObj.numInactive, aObj.numUncollected)

end
local function showBrokerInfo()

	-- show follower counts including any uncollected if required
	BasicBrokers.Text("BfAFollowers",  hexBlu .. aObj.numFollowers .. hexClose .. "/" .. hexBlu .. aObj.numActiveFollowers +  aObj.numUncollected + catLimit .. hexClose .. (aObj.numUncollected > 0 and "/" .. hexBlu .. aObj.numUncollected .. hexClose or ""))

end
local function getAndShow()

	getFollowerInfo()
	showBrokerInfo()

end

local delay, tmrActive = 1.0, false
function BasicBrokers.OnEvent.BfAFollowers(_, event, ...)
	-- _G.print("BB BfAMF event:", event, ...)

	if (event == "GARRISON_TALENT_COMPLETE"
	or event == "GARRISON_TALENT_UPDATE"
	or event == "UNIT_PHASE") then
		-- RequestClassSpecCategory Info
		_G.C_Garrison.RequestClassSpecCategoryInfo(followerType)
		aObj.updSpecInfo = true
		getTalentTree()
	end

	if event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" then
		aObj.updSpecInfo = true
	end

	if not tmrActive then
		_G.C_Timer.After(delay, function()
			getAndShow()
			tmrActive =false
		end)
		tmrActive = true
	end

end

local function sortFollowers(self) -- copied from GarrisonFollowerList_SortFollowers

	local function comparison(index1, index2)

		local follower1 = followers[index1]
		local follower2 = followers[index2]
		local follower1Active = follower1.status ~= _G.GARRISON_FOLLOWER_INACTIVE
		local follower2Active = follower2.status ~= _G.GARRISON_FOLLOWER_INACTIVE

		-- collected > troops > inactive is always the primary sort order; the category names rely on this.
		if follower1.isCollected ~= follower2.isCollected then
			return follower1.isCollected
		end
		if follower1Active ~= follower2Active then
			return follower1Active
		end
		if follower1.isTroop ~= follower2.isTroop then
			return follower2.isTroop
		end

		-- last resort; all else being equal sort by name, and then followerID
		local strCmpResult = strcmputf8i(follower1.name, follower2.name)
		if strCmpResult ~= 0 then
			return strCmpResult < 0
		end

		return follower1.followerID < follower2.followerID

	end

	_G.table.sort(self.followersList, comparison)

end
function BasicBrokers.OnTooltip.BfAFollowers(tip)

	if not aObj.tooltip then aObj.tooltip = tip end
	aObj.tooltip:ClearLines()
	aObj.tooltip:AddLine(hexBlue .. "BasicBroker: " .. hexClose .. hexWhite .. "BfA Followers" .. hexClose)
	aObj.hdgCnt = 1

	if aObj.numFollowers == 0 then
		aObj.tooltip:AddLine("No Champions, yet ;)")
		return
	end

	-- sort followers List, collected > troops > inactive > uncollected
	sortFollowers(aObj)

	for _, i in _G.pairs(aObj.followersList) do
		BasicBrokers.BfAFollowerLine(followers[i])
	end

end

function BasicBrokers.BfAFollowerLine(flwr)

	-- _G.print("BfAFollowerLine", flwr.name, flwr.isTroop, flwr.status, flwr.isCollected or nil)
	-- _G.Spew("follower", flwr)

	-- Add Headings as required
	if aObj.hdgCnt == 1 then
		aObj.tooltip:AddLine(indent4 .. "Champions: " .. aObj.numActiveFollowers  .. "/" .. aObj.numActiveFollowers +  aObj.numUncollected)
		aObj.hdgCnt = 2
	elseif aObj.hdgCnt == 2 and flwr.isTroop then
		aObj.tooltip:AddLine(indent4 .. "Troops: " .. aObj.numTroops .. "/" .. catLimit)
		if #troops > 0 then
			-- _G.print("BB BfAFollowers", #troops)
			aObj.tooltip:AddDoubleLine(indent8 .. troops[1], troops[2])
			if #troops > 3 then
				aObj.tooltip:AddDoubleLine(indent8 .. troops[3] or "", troops[4] or "")
			end
			if #troops == 5 then
				aObj.tooltip:AddLine(indent8 .. troops[5] or "")
			end
		end
		aObj.hdgCnt = 4
	elseif aObj.hdgCnt == 4 and flwr.status == _G.GARRISON_FOLLOWER_INACTIVE then
		aObj.tooltip:AddLine(indent4 .. "Inactive: " .. aObj.numInactive)
		aObj.hdgCnt = 8
	elseif aObj.hdgCnt ~= 16 and not flwr.isCollected then
		aObj.tooltip:AddLine(indent4 .. "Uncollected: " .. aObj.numUncollected)
		aObj.hdgCnt = 16
	end

	-- colour name with quality
	local followerInfo = indent8 .. _G.FOLLOWER_QUALITY_COLORS[flwr.quality].hex .. flwr.name .. " [" .. flwr.iLevel .. "] " .. hexClose .. hexLightBlue .. " [" .. (flwr.status or flwr.isCollected and "Idle" or "Dormant") .. "]" .. hexClose

	if not flwr.isCollected or flwr.levelXP == 0 then -- Uncollected or no more experience available (maxxed out)
		aObj.tooltip:AddLine(followerInfo)
	elseif flwr.isTroop then
		aObj.tooltip:AddDoubleLine(followerInfo, hexBlue .. flwr.durability .. "/" .. flwr.maxDurability .. " Durability" .. hexClose)
	else
		aObj.tooltip:AddDoubleLine(followerInfo, hexBlue .. flwr.levelXP - flwr.xp .. " XP to next upgrade" .. hexClose)
	end

	followerName, status = nil, nil

end

local function initialize()

	-- wait for garrison info to become available (>= 5 secs)
	if not _G.C_Garrison.HasGarrison(garrisonType) then
		_G.C_Timer.After(0.5, function()
			initialize()
		end)
		return
	end

	-- if not eligible for BfA Missions then do nothing
	if not _G.C_Garrison.HasGarrison(garrisonType) then return end

	-- create plugin
	_G.BasicBrokers.CreatePlugin("BfAFollowers", "0/9", "Interface\\Icons\\Spell_Holy_ChampionsGrace.blp")

	aObj = _G.BasicBrokers.BfAFollowers

	-- Register Events
	-- _G.BasicBrokers.RegisterEvent("BfAFollowers", "ZONE_CHANGED_NEW_AREA") -- login
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "PLAYER_ENTERING_WORLD") -- needed for reloadUI
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_LIST_UPDATE")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_ADDED")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_REMOVED")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_UPGRADED")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_XP_CHANGED")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_DURABILITY_CHANGED")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_FOLLOWER_CATEGORIES_UPDATED")

	-- these are for ClassSpecCategory
	_G.C_Garrison.RequestClassSpecCategoryInfo(followerType)
	aObj.updSpecInfo = true
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_TALENT_COMPLETE")
	_G.BasicBrokers.RegisterEvent("BfAFollowers", "GARRISON_TALENT_UPDATE")
	aObj.frame:RegisterUnitEvent("UNIT_PHASE", "player")


	getTalentTree()

end

do

	if _G.UnitLevel("player") < 50
	or _G.UnitLevel("player") > 55
	or not garrisonType
	then
		return
	end

	initialize()

end

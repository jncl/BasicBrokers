-- **********
-- Shadowlands Adventurers
local _G = _G
local aObj

local BasicBrokers = _G.BasicBrokers

if BasicBrokers.isClassic then return end

local hexClose = _G.FONT_COLOR_CODE_CLOSE
local hexGreen = "|cff00ff00"
local hexBlue  = "|cff8888ee"
local hexLightBlue = _G.RGBToColorCode(0.683, 0.941, 1)
local hexWhite = "|cffffffff"
local indent4 = "    "
local indent8 = indent4 .. indent4
local garrisonType = _G.Enum.GarrisonType.Type_9_0
local followerType = _G.Enum.GarrisonFollowerType.FollowerType_9_0
local maxCompanions = 10
local followers = {}
local function getFollowerInfo()

	aObj.numActiveFollowers = _G.C_Garrison.GetNumActiveFollowers(followerType) or 0
	followers = _G.C_Garrison.GetFollowers(followerType) or {}
	aObj.numFollowers = _G.C_Garrison.GetNumFollowers(followerType)

	-- _G.print("BB Adventurers:", aObj.numActiveFollowers, #followers, aObj.numFollowers)

	aObj.followersList = {}
	aObj.numActive = 0
	aObj.numInactive = 0
	for idx, companion in _G.pairs(followers) do
		-- _G.Spew("", companion)
		_G.tinsert(aObj.followersList, idx) -- used for sorting followers
		if companion.status == _G.GARRISON_FOLLOWER_INACTIVE then
			aObj.numInactive = aObj.numInactive + 1
		else
			aObj.numActive = aObj.numActive + 1
		end
	end
	-- _G.print("BB Adventurers nums:", aObj.numActive, aObj.numInactive)

end
local function showBrokerInfo()

	-- show follower counts
	BasicBrokers.Text("Adventurers",  hexGreen .. aObj.numFollowers .. "/" .. maxCompanions .. hexClose)

end
local function getAndShow()

	getFollowerInfo()
	showBrokerInfo()

end

local delay, tmrActive = 1.0, false
function BasicBrokers.OnEvent.Adventurers(_, event, ...)
	-- _G.print("BB Adventurers event:", event, ...)

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

		if follower1.isCollected ~= follower2.isCollected then
			return follower1.isCollected
		end
		if follower1Active ~= follower2Active then
			return follower1Active
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
function BasicBrokers.OnTooltip.Adventurers(tip)

	if not aObj.tooltip then aObj.tooltip = tip end
	aObj.tooltip:ClearLines()
	aObj.tooltip:AddLine(hexBlue .. "BasicBroker: " .. hexClose .. hexWhite .. "Adventurers" .. hexClose)
	aObj.hdgCnt = 1

	if aObj.numFollowers == 0 then
		aObj.tooltip:AddLine("No Adventurers, yet ;)")
		return
	end

	sortFollowers(aObj)

	for _, i in _G.pairs(aObj.followersList) do
		BasicBrokers.AdventurerLine(followers[i])
	end

end

function BasicBrokers.AdventurerLine(flwr)

	-- _G.print("AdventurerLine", flwr.name, flwr.isTroop, flwr.status, flwr.isCollected or nil)
	-- _G.Spew("follower", flwr)

	-- Add Headings as required
	if aObj.hdgCnt == 1 then
		aObj.tooltip:AddLine(indent4 .. "Adventurers: " .. aObj.numActiveFollowers .. "/" .. maxCompanions)
		aObj.hdgCnt = 2
	end

	-- colour name with quality
	local followerInfo = indent8 .. _G.FOLLOWER_QUALITY_COLORS[flwr.quality].hex .. flwr.name .. hexClose .. hexLightBlue .. " [" .. (flwr.status or flwr.isCollected and "Idle" or "Dormant") .. "]" .. hexClose

	if not flwr.isCollected
	or flwr.levelXP == 0
	then -- Uncollected or no more experience available (maxxed out)
		aObj.tooltip:AddLine(followerInfo)
	else
		aObj.tooltip:AddDoubleLine(followerInfo .. " (" .. flwr.level .. ")", hexBlue .. flwr.levelXP - flwr.xp .. " XP to next upgrade" .. hexClose)
	end

	followerName, status = nil, nil

end

local cnt = 0
local function initialize()

	-- wait for garrison info to become available (>= 5 secs)
	if not _G.C_Garrison.HasGarrison(garrisonType) then
		if cnt < 2 then
			_G.C_Timer.After(0.5, function()
				cnt = cnt + 1
				initialize()
			end)
			return
		else
			-- if not eligible for Adventurer Missions then do nothing
			return
		end
	end

	-- create plugin
	_G.BasicBrokers.CreatePlugin("Adventurers", "0", "Interface\\Icons\\Spell_Holy_ChampionsGrace.blp")

	aObj = _G.BasicBrokers.Adventurers

	-- Register Events
	_G.BasicBrokers.RegisterEvent("Adventurers", "PLAYER_ENTERING_WORLD") -- needed for reloadUI
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_LIST_UPDATE")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_ADDED")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_REMOVED")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_UPGRADED")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_XP_CHANGED")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_DURABILITY_CHANGED")
	_G.BasicBrokers.RegisterEvent("Adventurers", "GARRISON_FOLLOWER_CATEGORIES_UPDATED")

end

do

	if _G.UnitLevel("player") < 50
	or not garrisonType
	then
		return
	end

	initialize()

end

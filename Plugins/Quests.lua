-- **********
-- QUESTS
-- **********
local _G = _G
-- luacheck: ignore 631 (line is too long)

local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorStart = "|cff"
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "
local cText = colorStart .. "%02X%02X%02X"

local GetNumQuestLogEntries = _G.C_QuestLog and _G.C_QuestLog.GetNumQuestLogEntries or _G.GetNumQuestLogEntries

local function countQuests(numEntries)
	local qCnt = 0
	for i = 1, numEntries do
		local questInfo = _G.C_QuestLog.GetInfo(i)
		if not questInfo.isHeader
		and not questInfo.isHidden
		then
			qCnt = qCnt + 1
		end
	end
	return qCnt
end

function BasicBrokers.OnEvent.Quests(_, event, _)

	if event == "PLAYER_LOGIN" then
		BasicBrokers.RegisterEvent("Quests", "QUEST_LOG_UPDATE")
		BasicBrokers.RegisterEvent("Quests", "QUEST_WATCH_UPDATE")
		BasicBrokers.RegisterEvent("Quests", "UNIT_QUEST_LOG_CHANGED")
		BasicBrokers.UnregisterEvent("Quests", "PLAYER_LOGIN")
	end

	local numEntries, numQuests
	numEntries, numQuests = GetNumQuestLogEntries()
	if BasicBrokers.isRtl then
		numQuests = countQuests(numEntries)
	end
	-- print("Quests", numEntries, numQuests)
	BasicBrokers.Text("Quests",  bbc.light_green .. numQuests .. colorEnd .. "/" .. bbc.light_green .. _G.C_QuestLog.GetMaxNumQuestsCanAccept() .. colorEnd)

end

function BasicBrokers.OnTooltip.Quests(tip)

	if not BasicBrokers.Quests.tooltip then BasicBrokers.Quests.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "Quests")

	local numEntries = GetNumQuestLogEntries()
	if numEntries == 0 then
		BasicBrokers.Quests.tooltip:AddLine("No quests in the QuestLog")
	else
		for i = 1, numEntries do
			BasicBrokers.QuestLine(i)
		end
	end
	BasicBrokers.Quests.tooltip:AddLine(" ")
	BasicBrokers.Quests.tooltip:AddLine("Left-Click: Toggle QuestLog")
	if _G.QuestHelper then
		BasicBrokers.Quests.tooltip:AddLine("Right-Click: Open QuestHelper")
	end

end

local hLine, tLine
function BasicBrokers.QuestLine(questIndex)

	local _, title, level, isHeader, isComplete, frequency, isStory, isHidden
	if _G.GetQuestLogTitle then
		title, level, _, isHeader, _, isComplete, frequency, _, _, _, _, _, _, isStory = _G.GetQuestLogTitle(questIndex)
	else
		local questInfo = _G.C_QuestLog.GetInfo(questIndex)
		-- _G.Spew("", questInfo)
		title, level, isHeader, isStory, isHidden, frequency = questInfo.title, questInfo.level, questInfo.isHeader, questInfo.isStory, questInfo.isHidden, questInfo.frequency or 0
		isComplete = _G.C_QuestLog.IsComplete(questInfo.questID)
	end
	-- print("QuestLine", title, level, isHeader, isComplete, frequency, isStory, isHidden)
	-- ignore Missing header!/Weekly Quests/World Quests
	if title:find("Missing header")
	or title:find("Weekly")
	or isStory
	or isHidden
	then
		return
	end
	tLine = title
	local clr = _G.QuestDifficultyColors["header"]
	if not isHeader then
		tLine = twoSpaces .. "[" .. level .. "]" .. twoSpaces .. title
		clr = _G.GetQuestDifficultyColor(level)
	end
	local R, G, B = clr.r * 255, clr.g * 255, clr.b * 255
	if isComplete then
		R, G, B = 100, 150, 255
		tLine = tLine .. bbc.green .. twoSpaces .. "(complete)" .. colorEnd
	elseif frequency == (_G.LE_QUEST_FREQUENCY_DAILY or 1) then
		tLine = tLine .. twoSpaces .. "(daily)"
	elseif frequency == (_G.LE_QUEST_FREQUENCY_WEEKLY or 2)then
		tLine = tLine .. twoSpaces .. "(weekly)"
	end
	tLine = _G.format(cText, R, G, B) .. tLine .. colorEnd
	if isHeader then
		hLine = tLine
	else
		-- DON'T show header line if no quests are shown
		if hLine ~= "" then
			BasicBrokers.Quests.tooltip:AddLine(hLine)
			hLine = ""
		end
		BasicBrokers.Quests.tooltip:AddLine(tLine)
	end

end

function BasicBrokers.OnClick.Quests(_, which)

	which = which == "RightButton"
	if which then if _G.QuestHelper then _G.QuestHelper:DoSettingsMenu() end return end
	_G.ToggleQuestLog()

end

BasicBrokers.CreatePlugin("Quests", "0/25", [[Interface\Minimap\Tracking\Class]])
BasicBrokers.RegisterEvent("Quests", "PLAYER_LOGIN")

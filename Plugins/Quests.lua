-- **********
-- BASIC QUESTS
local _G = _G
local BasicBrokers = _G.BasicBrokers

function BasicBrokers.OnEvent.Quests(_, event, bag)
	local _, numQuests = _G.GetNumQuestLogEntries()
	if not numQuests then numQuests = 0 end
	BasicBrokers.Text( "Quests",  "|cFF00FF00" .. numQuests .. "|r/" .. "|cFF00FF0025" .. "|r")
end

function BasicBrokers.OnTooltip.Quests(tip)
	if not BasicBrokers.Quests.tooltip then BasicBrokers.Quests.tooltip = tip end
	BasicBrokers.Quests.tooltip:ClearLines()
	BasicBrokers.Quests.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffQuests|r")
	local numEntries = _G.GetNumQuestLogEntries()
	if numEntries == 0 then BasicBrokers.Quests.tooltip:AddLine("No quests in the QuestLog") end
	for i = 1, numEntries do
		BasicBrokers.QuestLine(i)
	end
	BasicBrokers.Quests.tooltip:AddLine(" ")
	BasicBrokers.Quests.tooltip:AddLine("Left-Click: Toggle QuestLog")
	if _G.QuestHelper then
		BasicBrokers.Quests.tooltip:AddLine("Right-Click: Open QuestHelper")
	end
end

function BasicBrokers.QuestLine(questIndex)
	local title, level, _, isHeader, _, isComplete, frequency, _, _, _, _, _, _, isStory = _G.GetQuestLogTitle(questIndex)
	-- print("QuestLine", title, level, isHeader, isComplete, frequency, isStory)
	-- local lineText, level, _, isHeader, _, isComplete, frequency = _G.GetQuestLogTitle(questIndex)
	-- print("QuestLine", questIndex, lineText, level, tag, isHeader, _, isComplete, frequency)
	-- ignore Missing header!/Weekly Quests/World Quests
	if title:find("Missing")
	or title:find("Weekly")
	or isStory
	then
		return
	end
	local cText = "|c%02X%02X%02X%02X%s|r"
	local clr = _G.QuestDifficultyColors["header"]
	if not isHeader then
		title = "    [" .. level .. "] " .. title
		clr = _G.GetQuestDifficultyColor(level)
	end
	local R, G, B = clr.r * 255, clr.g * 255, clr.b * 255
	if isComplete then
		R, G, B = 100, 150, 255
		title = title .. "  |cffffffff(complete)|r"
	elseif frequency == _G.LE_QUEST_FREQUENCY_DAILY then
		title = title .. "  (daily)"
	elseif frequency == _G.LE_QUEST_FREQUENCY_WEEKLY then
		title = title .. "  (weekly)"
	end
	title = _G.format(cText, 255, R, G, B, title)
	BasicBrokers.Quests.tooltip:AddLine(title)
end

function BasicBrokers.OnClick.Quests(_, which)
	which = which == "RightButton"
	if which then if _G.QuestHelper then _G.QuestHelper:DoSettingsMenu() end return end
	_G.ToggleQuestLog()
end

BasicBrokers.CreatePlugin("Quests", "0/25", "Interface\\Minimap\\Tracking\\Class.blp")
BasicBrokers.RegisterEvent("Quests", "QUEST_LOG_UPDATE")
BasicBrokers.RegisterEvent("Quests", "QUEST_WATCH_UPDATE")
BasicBrokers.RegisterEvent("Quests", "UNIT_QUEST_LOG_CHANGED")

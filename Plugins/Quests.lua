-- **********
-- BASIC QUESTS
function BasicBrokers.OnEvent.Quests(_, event, bag)
	local _, numQuests = GetNumQuestLogEntries()
	if not numQuests then numQuests = 0 end
	BasicBrokers.Text( "Quests",  "|cFF00FF00"..numQuests.."|r/".."|cFF00FF0025".."|r")
end

function BasicBrokers.OnTooltip.Quests(tip)
	local numEntries = GetNumQuestLogEntries()
	if not BasicBrokers.Quests.tooltip then BasicBrokers.Quests.tooltip = tip end
	BasicBrokers.Quests.tooltip:ClearLines()
	BasicBrokers.Quests.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffQuests|r")
	if numEntries == 0 then BasicBrokers.Quests.tooltip:AddLine("No quests in the QuestLog") end
	for i=1, numEntries do
		BasicBrokers.QuestLine(i)
	end
	BasicBrokers.Quests.tooltip:AddLine(" ")
	BasicBrokers.Quests.tooltip:AddLine("Left-Click: Open QuestLog")
	if QuestHelper then
		BasicBrokers.Quests.tooltip:AddLine("Right-Click: Open QuestHelper")
	end
end

function BasicBrokers.QuestLine(index)
	local lineText, level, tag, _, isHeader, _, isComplete, isDaily = GetQuestLogTitle(index);
	local cText = "|c%02X%02X%02X%02X%s|r"				
	local clr = QuestDifficultyColor["header"]
	if not isHeader then
		clr = GetDifficultyColor(level)
	end
	local R = clr.r * 255; local G = clr.g * 255; local B = clr.b * 255;
	if isComplete then 
		R = 100; G = 150; B = 255;
		lineText = "    ["..level.."] "..lineText.."  |cffffffff(complete)|r"
	elseif isDaily then
		lineText = "    ["..level.."] "..lineText.."  (daily)"
	elseif not isHeader then
		lineText = "    ["..level.."] "..lineText
	end
	lineText = format(cText, 255, R, G, B, lineText)
	BasicBrokers.Quests.tooltip:AddLine(lineText)
end

function BasicBrokers.OnClick.Quests(_, which)
	which = which == "RightButton"
	if which then if QuestHelper then QuestHelper:DoSettingsMenu() end return end
	if QuestLogFrame:IsVisible() then QuestLogFrame:Hide() else QuestLogFrame:Show() end
end

BasicBrokers.CreatePlugin("Quests","0/25","Interface\\Minimap\\Tracking\\Class.blp")
BasicBrokers.RegisterEvent("Quests", "QUEST_LOG_UPDATE");
BasicBrokers.RegisterEvent("Quests", "QUEST_WATCH_UPDATE");
BasicBrokers.RegisterEvent("Quests", "UNIT_QUEST_LOG_CHANGED");
-- **********
-- SKILLS
-- **********
local _G = _G
local BasicBrokers = _G.BasicBrokers
local bbc = BasicBrokers.hexColors
local colorEnd = _G.FONT_COLOR_CODE_CLOSE
local twoSpaces = "  "

if not BasicBrokers.isClsc then return end

function BasicBrokers.OnEvent.Skills()
	-- do nothing
end

function BasicBrokers.OnTooltip.Skills(tip)

	if not BasicBrokers.Skills.tooltip then BasicBrokers.Skills.tooltip = tip end
	BasicBrokers.SetupTooltip(tip, "Skills")

	local skillName, isHeader, _, skillRank, skillModifier, skillMaxRank
	local mySkills = {}
	local headerIndex = 0

	-- store desired skill info in mySkills table
	for i = 1, _G.GetNumSkillLines() do
		skillName, isHeader, _, skillRank, _, skillModifier, skillMaxRank = _G.GetSkillLineInfo(i)
		if skillName ~= nil then
			if isHeader then
			headerIndex = headerIndex + 1
			mySkills[headerIndex] = { name = skillName, displayHeader = false, skills = {}, }
			elseif skillMaxRank > 1 then
				if mySkills[headerIndex].name ~= "Languages" then
					mySkills[headerIndex].displayHeader = true
				end
				if skillModifier > 0 then
					skillRank = skillRank .. "(+" .. skillModifier .. ")"
				end
				table.insert(mySkills[headerIndex].skills, { name = skillName, rank = skillRank, maxrank = skillMaxRank })
			end
		end
	end

	-- display desired skill info
	for _, v in ipairs(mySkills) do
		if v.displayHeader then
			BasicBrokers.Skills.tooltip:AddLine(bbc.green .. v.name .. colorEnd)
			for _,h in ipairs(v.skills) do
				BasicBrokers.Skills.tooltip:AddDoubleLine(twoSpaces .. h.name, h.rank .. " / " .. h.maxrank)
			end
		end
	end

end

function BasicBrokers.OnClick.Skills()
	-- do nothing
end

BasicBrokers.CreatePlugin("Skills", "Skills", [[Interface\Minimap\Tracking\Ammunition]])

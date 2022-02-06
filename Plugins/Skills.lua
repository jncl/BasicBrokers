-- **********
-- BASIC SKILLS
local _G = _G
local BasicBrokers = _G.BasicBrokers

function BasicBrokers.OnEvent.Skills()
	-- do nothing
end

function BasicBrokers.OnTooltip.Skills(tip)
	local skillName, isHeader, _, skillRank, skillModifier, skillMaxRank
	local mySkills = {}
	local headerIndex = 0
	if not BasicBrokers.Skills.tooltip then BasicBrokers.Skills.tooltip = tip end
	BasicBrokers.Skills.tooltip:ClearLines()
	BasicBrokers.Skills.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffSkills|r")

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
			BasicBrokers.Skills.tooltip:AddLine("|cff69b950".. v.name .. "|r")
			for _,h in ipairs(v.skills) do
				BasicBrokers.Skills.tooltip:AddDoubleLine("  ".. h.name, h.rank .. "/" .. h.maxrank)
			end
		end
	end
end

function BasicBrokers.OnClick.Skills()
	-- do nothing
end

BasicBrokers.CreatePlugin("Skills","Skills","Interface\\Minimap\\Tracking\\Ammunition.BLP")
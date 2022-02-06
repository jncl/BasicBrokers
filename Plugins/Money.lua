-- **********
-- BASIC MONEY
local _G = _G
local BasicBrokers = _G.BasicBrokers

function BasicBrokers.OnEvent.Money(_, event)
	if event == "PLAYER_LOGIN" then
		BasicBrokers.initialMoney = _G.GetMoney()
		BasicBrokers.sessionTime_Money = _G.time()
	end
	local current = BasicBrokers.GoldToText(_G.GetMoney())
	BasicBrokers.Text( "Money",  current)
end


function BasicBrokers.OnTooltip.Money(tip)
	if not BasicBrokers.Money.tooltip then BasicBrokers.Money.tooltip = tip end
	local money = _G.GetMoney()
	local current = BasicBrokers.GoldToText(money)
	local session = money - BasicBrokers.initialMoney
	local perHour = 0
	if session ~= 0 then
		perHour =  session / (_G.time() - BasicBrokers.sessionTime_Money ) * 3600
	end
	perHour = BasicBrokers.GoldToText(perHour)
	session = BasicBrokers.GoldToText(session)
	BasicBrokers.Money.tooltip:ClearLines()
	BasicBrokers.Money.tooltip:AddLine("|cff8888eeBasicBroker:|r |cffffffffMoney|r")
	BasicBrokers.Money.tooltip:AddDoubleLine("|cff69b950  Current:|r ",current)
	BasicBrokers.Money.tooltip:AddDoubleLine("|cff69b950  Session:|r ",session)
	BasicBrokers.Money.tooltip:AddDoubleLine("|cff69b950  Per Hour:|r ",perHour)
	BasicBrokers.Money.tooltip:AddLine(" ")
	BasicBrokers.Money.tooltip:AddLine("Alt-Click: Resets Session")
end

function BasicBrokers.OnClick.Money()
	if _G.IsAltKeyDown() then
		BasicBrokers.initialMoney = _G.GetMoney()
		BasicBrokers.sessionTime_Money = _G.time()
	end
end

BasicBrokers.CreatePlugin("Money","","Interface\\Minimap\\Tracking\\Auctioneer.blp")
BasicBrokers.RegisterEvent("Money", "PLAYER_MONEY")
BasicBrokers.RegisterEvent("Money", "PLAYER_TRADE_MONEY")
BasicBrokers.RegisterEvent("Money", "TRADE_MONEY_CHANGED")
BasicBrokers.RegisterEvent("Money", "SEND_MAIL_MONEY_CHANGED")
BasicBrokers.RegisterEvent("Money", "SEND_MAIL_COD_CHANGED")
BasicBrokers.RegisterEvent("Money", "PLAYER_LOGIN")
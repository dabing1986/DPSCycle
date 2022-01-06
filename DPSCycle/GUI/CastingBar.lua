------------------------------------------------------------
-- CastingBar.lua
--
-- Abin
-- 2012-9-11
------------------------------------------------------------

local ChannelInfo = ChannelInfo
local CastingInfo = CastingInfo
local GetTime = GetTime

local _, addon = ...

local frame = CreateFrame("Frame", "DPSCycleCastingBarParent", addon.iconFrame)
addon.castBarParent = frame
frame:SetSize(120, 14)

function frame:UpdatePosition()
	self:ClearAllPoints()
	if addon.db.hideText then
		self:SetPoint("TOP", addon.iconFrame, "BOTTOM", 0, -4)
	else
		self:SetPoint("TOP", addon.iconFrame.spellText, "BOTTOM", 0, -4)
	end
end

-- function CreateFrame(frameType, name, parent, template, id)


local bar = CreateFrame("StatusBar", "DPSCycleCastingBar", frame, "BackdropTemplate")
bar:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = { left = 0, right = 0, top = 0, bottom = 0 } })
bar:SetAllPoints(frame)
bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8.BLP")
bar:Hide()

local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
border:SetBackdrop({ bgFile = "", tile = true, tileSize = 16, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5 }, })
border:SetBackdropBorderColor(0.75, 0.75, 0.75)
border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
border:SetScale(0.5)

local icon = bar:CreateTexture(bar:GetName().."Icon", "ARTWORK")
icon:SetSize(14, 14)
icon:SetPoint("RIGHT", bar, "LEFT", -2, 0)

local remainText = bar:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
remainText:SetPoint("CENTER")
remainText:SetFont(STANDARD_TEXT_FONT, 10, 1)

local maxText = bar:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
maxText:SetPoint("LEFT", bar, "RIGHT", 2, 0)
maxText:SetFont(STANDARD_TEXT_FONT, 10, 1)

--[[
local spellNameText = bar:CreateFontString("EasyCastingBarText", "ARTWORK", "GameFontHighlight")
spellNameText:SetPoint("TOP", bar, "BOTTOM", 0, -2)
spellNameText:SetFont(STANDARD_TEXT_FONT, 10)
--]]

local function StartShining()
	bar.shining = 1
	bar:SetAlpha(1)
end

local function StopShining()
	bar.shining = nil
	bar:SetAlpha(1)
end

local function GetCastingInfo(isCannel)
	local func = isCannel and ChannelInfo or CastingInfo
	return func("player")
end

local function OnCastStart(isCannel)
	StopShining()
	local name, text, texture, startTime, endTime = GetCastingInfo(isCannel)
	if not name or not startTime or not endTime then
		bar:Hide()
		return
	end

	bar.isCannel = isCannel
	icon:SetTexture(texture)
	--spellNameText:SetText(name or text)

	startTime = startTime / 1000
	endTime = endTime / 1000
	maxText:SetFormattedText("%.1f", endTime - startTime)

	local now = GetTime()
	bar:SetMinMaxValues(startTime, endTime)
	if isCannel then
		bar:SetValue(endTime - now + startTime)
	else
		bar:SetValue(now)
	end

	bar:SetStatusBarColor(0, 1, 0)
	bar:Show()
end

local function OnCastStop(reason)
	if not bar.shining then
		if reason then
			--spellNameText:SetText(reason)
			bar:SetStatusBarColor(1, 0, 0)
		elseif not bar.isCannel then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		end

		StartShining()
	end
end

local function OnCastUpdate()
	local startTime, endTime = bar:GetMinMaxValues()
	if not startTime or not endTime then
		bar:Hide()
		return
	end

	local now = GetTime()
	local remain = max(0, endTime - now)

	if bar.isCannel then
		bar:SetValue(remain + startTime)
	else
		bar:SetValue(now)
	end

	remainText:SetFormattedText("%.1f", remain)

	if remain == 0 then
		OnCastStop()
	end
end

bar:SetScript("OnUpdate", function(self, elapsed)
	if self.shining then
		local alpha = self:GetAlpha() - elapsed * 2
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.shining = nil
			self:Hide()
		end
	else
		self:SetAlpha(1)
		OnCastUpdate()
	end
end)

frame:SetScript("OnShow", function(self)
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
end)

frame:SetScript("OnHide", function(self)
	self:UnregisterAllEvents()
end)

frame:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then
		return
	end

	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
		OnCastStart()
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		OnCastStart(1)
	elseif event == "UNIT_SPELLCAST_FAILED" then
		OnCastStop(FAILED)
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		OnCastStop(INTERRUPTED)
	elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		OnCastStop()
	end
end)
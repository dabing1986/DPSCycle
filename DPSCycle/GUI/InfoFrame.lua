------------------------------------------------------------
-- InfoFrame.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local UIFrameFadeOut = UIFrameFadeOut

local _, addon = ...
local templates = addon.templates
local L = addon.L

local frame = CreateFrame("Frame", "DPSCycleInfoFrame", addon.iconFrame)
addon.infoFrame = frame
frame:SetSize(templates.BUTTON_SIZE, templates.BUTTON_SIZE)
frame:SetScale(0.6)
frame:SetPoint("BOTTOM", addon.cooldownPanel, "TOP", 0, 10)
frame:Hide()

frame.icon = frame:CreateTexture("DPSCycleInfoFrameIcon", "ARTWORK")
frame.icon:SetSize(templates.BUTTON_SIZE, templates.BUTTON_SIZE)
frame.icon:SetPoint("LEFT")
frame.text = frame:CreateFontString("DPSCycleInfoFrameText", "ARTWORK", "ZoneTextFont")

function frame:DisplayInfo(icon, text, r, g, b)
	self.icon:SetTexture(icon)
	self.text:SetText(text)
	if not r then
		r, g, b = 0.0, 0.82, 1.0
	end

	self.text:SetTextColor(r, g, b, 1)
	self.text:ClearAllPoints()

	local width = 0
	if icon then
		width = self.icon:GetWidth()
		self.text:SetPoint("LEFT", self.icon, "RIGHT", templates.BUTTON_GAP, 0)
	else
		self.text:SetPoint("LEFT")
	end

	if text then
		if width > 0 then
			width = width + templates.BUTTON_GAP
		end
		width = width + self.text:GetWidth()
	end

	if width > 0 then
		self:SetWidth(width)
	end

	UIFrameFadeOut(self, 5, 1, 0)
end
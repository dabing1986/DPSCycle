------------------------------------------------------------
-- MainFrame.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local type = type
local GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor
local GameTooltip = GameTooltip

local _, addon = ...
local L = addon.L

local templates = addon.templates

local frame = CreateFrame("Frame", "DPSCycleFrame", UIParent)
addon.frame = frame
frame:SetSize(templates.BUTTON_SIZE, templates.BUTTON_SIZE)
frame:SetFrameStrata("BACKGROUND")
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:SetClampedToScreen(true)

local mover = CreateFrame("Frame", frame:GetName().."Mover", frame)
addon.moverFrame = mover
mover:SetAllPoints(frame)
mover:SetFrameStrata("FULLSCREEN_DIALOG")

mover.icon = mover:CreateTexture(mover:GetName().."Icon", "BORDER")
mover.icon:SetAllPoints(mover)
mover.icon:SetTexture(0, 1, 0, 0.5)

mover.text = mover:CreateFontString(mover:GetName().."Text", "ARTWORK", "GameFontNormal")
mover.text:SetPoint("CENTER")
mover.text:SetText(L["title"])

mover:RegisterForDrag("LeftButton")
mover:SetScript("OnDragStart", function(self) frame:StartMoving() end)
mover:SetScript("OnDragStop", function(self) frame:StopMovingOrSizing() end)

mover:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		addon.optionPage:Open()
	end
end)

mover:SetScript("OnEnter", function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["title"])
	GameTooltip:AddLine(L["mouseover prompt"], 1, 1, 1)
	GameTooltip:Show()
end)
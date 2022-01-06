------------------------------------------------------------
-- SpellButton.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local type = type
local ATTACK = GetSpellInfo(6603)

local _, addon = ...
local L = addon.L
local templates = addon.templates

--------------------------------------------
-- DPSCycle icon frame
--------------------------------------------

local frame = templates:CreateSpellButton("DPSCycleIconFrame1", addon.frame)
addon.iconFrame = frame
frame.noSpellCheckHidden = 1
frame:SetAllPoints(addon.frame)
frame.spellText = frame:CreateFontString(frame:GetName().."SpellText", "ARTWORK", "GameFontHighlightSmall")
frame.spellText:SetPoint("TOP", frame, "BOTTOM", 0, -2)

local countFrame = CreateFrame("Frame", frame:GetName().."CountFrame", frame)
countFrame:SetAllPoints(frame.icon)
frame.countText = countFrame:CreateFontString(countFrame:GetName().."Text", "OVERLAY", "TextStatusBarText")
frame.countText:SetPoint("BOTTOMRIGHT", -1, 2)
countFrame:SetFrameLevel(6)

local frame2 = templates:CreateSequenceSpellButton("DPSCycleIconFrame2", frame)
frame.button2 = frame2
frame2:SetScale(0.7)
frame2:SetPoint("TOPLEFT", frame, "TOPRIGHT", 8, 0)

local frame3 = templates:CreateSequenceSpellButton("DPSCycleIconFrame3", frame2)
frame3:SetPoint("LEFT", frame2, "RIGHT", 8, 0)
frame.button3 = frame3

function frame:SetCountText(text, r, g, b)
	if text then
		self.countText:SetText(text)
		if r then
			self.countText:SetTextColor(r, g, b, 1)
		else
			self.countText:SetTextColor(1, 1, 1, 1)
		end
		countFrame:Show()
	else
		countFrame:Hide()
	end
end

-- Request spell from the active module
local updateElapsed = 0
function frame:OnUpdate()
	updateElapsed = 0
	local spell1, spell2, spell3 = addon:OnSpellRequest()
	if not addon:PlayerHasSpell(spell1) then
		spell1, spell2, spell3 = ATTACK
	end

	if spell1 ~= self.spellName then
		if spell == ATTACK then
			self.spellText:SetText(L["don't use spells"])
		elseif self:SetSpell(spell1) then
			self.spellText:SetText(spell1)
		else
			self.spellText:SetText()
		end
	end

	local r, g, b = self:UpdateSpellUsable()
	if r then
		self.spellText:SetTextColor(r, g, b)
	end

	if frame2:SetSpell(spell2) then
		frame2:Show()
		frame2:UpdateSequenceSpell()

		if frame3:SetSpell(spell3) then
			frame3:Show()
			frame3:UpdateSequenceSpell()
		else
			frame3:Hide()
		end
	else
		frame2:Hide()
	end
end

frame:SetScript("OnUpdate", function(self, elapsed)
	updateElapsed = updateElapsed + elapsed
	if updateElapsed > 0.2 then
		self:OnUpdate()
	end
end)

frame:SetScript("OnShow", function(self)
	local module = addon:GetModule()
	if module then
		module:SafeCall("OnShow")
	end
	self:OnUpdate()
end)

frame:SetScript("OnHide", function(self)
	self:SetSpell()
	self:Hide()
	local module = addon:GetModule()
	if module then
		module:SafeCall("OnHide")
	end
end)

-----------------------------------------------------
-- Combo points displaying
-----------------------------------------------------

local lcp = _G["LibComboPoints-1.0"]

function addon:GetComboPoints()
	return lcp:GetComboPoints()
end

function addon:SetComboPoints(points, base)
	if points and points > 0 then
		local r, g, b = lcp:GetComboColor(points, base)
		if not r then
			r, g, b = 1, 1, 1
		end
		frame:SetCountText(format("%d", points), r, g, b)
	else
		frame:SetCountText()
	end
end

lcp:HookCallback(function(points)
	local module = addon:GetModule()
	if module and module.showComboPoints then
		addon:SetComboPoints(points)
	end
end)
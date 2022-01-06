------------------------------------------------------------
-- Templates.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local max = max
local GetTime = GetTime
local format = format
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFade = UIFrameFade
local select = select
local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetSpellTexture = GetSpellTexture

local _, addon = ...
local L = addon.L

local templates = {}
addon.templates = templates

templates.BUTTON_SIZE = 32
templates.BUTTON_GAP = 4
templates.MAX_COOLDOWN_BUTTONS = 12

function templates:VerifyTimeLeft(start, duration)
	if start then
		local timeLeft = max(0, duration - GetTime() + start)
		if timeLeft < 15 then
			return timeLeft, duration == 0
		end
	end
end

local function SpellButton_UpdateSpellUsable(self, checkAura)
	local spell = self.spellName
	if not spell then
		return
	end

	local r, g, b
	if addon:IsSpellInRange(spell) then
		local usable, err = addon:IsUsableSpell(spell, nil, 1)
		if usable then
			r, g, b = 1, 1, 1
		elseif err == 3 then
			r, g, b = 0.1, 0.3, 1.0 -- out of mana
		else
			r, g, b = 0.4, 0.4, 0.4 -- disabled
		end
	else
		r, g, b = 0.8, 0.1, 0.1 -- out of range
	end
	self.icon:SetVertexColor(r, g, b)

	local _, start, duration, enable, aura
	if checkAura then
		start, duration, enable, aura = addon:_GetSeqAuraCooldown(spell)
	end

	if not start then
		_, start, duration, enable = addon:GetSpellCooldown(spell)
	end

	if start and start > 0 and duration > 0 and enable > 0 then
		self.cd:SetCooldown(start, duration);
		self.cd:Show();
	else
		self.cd:Hide();
	end
	return r, g, b, start, duration, enable, aura
end

local function SpellButton_SetSpell(self, spell)
	if addon:PlayerHasSpell(spell) then
		self.spellName = spell
		self.icon:SetTexture(GetSpellTexture(spell))
		self.icon:Show()
		self.cd:Show()
		return 1
	end

	self.spellName = nil
	self.icon:Hide()
	self.cd:Hide()
end

local function UpdateCooldownSpellButton(self, checkAura)
	local _, _, _, start, duration, enable, aura = SpellButton_UpdateSpellUsable(self, checkAura)
	local timeLeft, finished, threshold

	if aura then
		timeLeft = start and max(0, (duration - GetTime() + start)) or 0
		finished = timeLeft < 0.1
		threshold = 0
	else
		timeLeft, finished = templates:VerifyTimeLeft(start, duration)
		threshold = (self.minDuration or 1.5)
	end

	if finished then
		timeLeft = nil
	end

	if timeLeft and duration > threshold then
		self.text:SetText(format(self.timeFormat, timeLeft))
		self.text:Show()
	else
		self.text:Hide()
	end
	return timeLeft, finished, aura
end

local function UpdateSequenceSpellButton(self)
	local timeLeft, _, aura = UpdateCooldownSpellButton(self, 1)
	if timeLeft then
		if aura == 0 then
			self.text:SetTextColor(0, 0.25, 1)
		elseif aura == 1 then
			self.text:SetTextColor(1, 0.25, 0)
		else
			self.text:SetTextColor(1, 1, 0)
		end
	end
end

local function WatchButton_ShineFadeOut(self)
	self.shining = nil
	UIFrameFadeOut(self, 1);
end

local function WatchButton_ShineStartShining(self)
	if not self.shining then
		self.shining = 1
		UIFrameFade(self, { mode = "IN", timeToFade = 0.5, finishedFunc = WatchButton_ShineFadeOut, finishedArg1 = self })
	end
end

local function UpdateWatchButton(self)
	self.elapsed = 0
	local _, finished = UpdateCooldownSpellButton(self)
	if finished and not self.cooldownFinished then
		self.cooldownFinished = 1
		WatchButton_ShineStartShining(self.shine)
	end
end

local function WatchButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.2 then
		UpdateWatchButton(self)
	end
end

local function WatchButton_SetSpell(self, spell, cooldownFinished)
	self.cooldownFinished = cooldownFinished
	if SpellButton_SetSpell(self, spell) then
		self.minDuration = select(6, GetSpellInfo(spell)) == 5 and 10 or 1.5
		UpdateWatchButton(self)
		self:Show()
	else
		self:Hide()
	end
end

function templates:CreateSpellButton(name, parent)
	local button = CreateFrame("Button", name, parent)
	button:EnableMouse(false)
	button:SetSize(templates.BUTTON_SIZE, templates.BUTTON_SIZE)
	button:Hide()

	button.icon = button:CreateTexture(name.."Icon", "ARTWORK")
	button.icon:SetAllPoints(button)

	button.cd = CreateFrame("Cooldown", name.."CD", button, "CooldownFrameTemplate") -- Do not use name.."Cooldown" or the cooldown button gets messed up by ButtonFacade
	button.cd:ClearAllPoints()
	button.cd:SetAllPoints(button.icon)

	button.SetSpell = SpellButton_SetSpell
	button.UpdateSpellUsable = SpellButton_UpdateSpellUsable
	return button
end

function templates:CreateCooldownSpellButton(name, parent)
	local button = self:CreateSpellButton(name, parent)
	button.timeFormat = "%.1f"
	button.text = button.cd:CreateFontString(name.."CountText", "OVERLAY", "TextStatusBarText")
	button.text:SetPoint("TOP", button, "BOTTOM", 0, -1)
	return button
end

function templates:CreateSequenceSpellButton(name, parent)
	local button = self:CreateCooldownSpellButton(name, parent)
	button.text:SetTextColor(1, 1, 0)
	button.UpdateSequenceSpell = UpdateSequenceSpellButton
	return button
end

function templates:CreateSpellWatchButton(name, parent)
	local button = self:CreateCooldownSpellButton(name, parent)
	button.timeFormat = "%.0f"
	button.text:ClearAllPoints()
	button.text:SetPoint("CENTER", 1, -1)
	button.text:SetTextColor(0, 1, 0)

	local shine = CreateFrame("Frame", nil, button)
	button.shine = shine
	shine:SetAllPoints(button)
	shine:Hide()

	local texture = shine:CreateTexture(nil, "OVERLAY")
	texture:SetTexture("Interface\\ComboFrame\\ComboPoint")
	texture:SetBlendMode("ADD")
	texture:SetTexCoord(0.5625, 1, 0, 1)
	texture:SetWidth(50)
	texture:SetHeight(50)
	texture:SetPoint("CENTER")

	button.SetSpell = WatchButton_SetSpell
	button:SetScript("OnUpdate", WatchButton_OnUpdate)

	return button
end
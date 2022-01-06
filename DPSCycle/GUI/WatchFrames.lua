------------------------------------------------------------
-- WatchFrames.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local ipairs = ipairs
local tremove = tremove
local tinsert = tinsert
local pairs = pairs
local wipe = wipe
local type = type
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo

local _, addon = ...
local L = addon.L
local templates = addon.templates

local cooldownWatchSpells = {}
local cooldownButtons = {}
local watchSpells = {}
local watchCount = 0

local frame = CreateFrame("Frame", "DPSCycleCooldownPanel", addon.iconFrame)
addon.cooldownPanel = frame
frame:SetScale(0.5)
frame:SetSize(templates.BUTTON_SIZE, templates.BUTTON_SIZE)
frame:SetPoint("BOTTOM", addon.iconFrame, "TOP", 0, templates.BUTTON_GAP * 2)
frame:Hide()

local function FindWatchButton(button)
	local k, v
	for k, v in ipairs(cooldownButtons) do
		if v == button then
			return k
		end
	end
end

local function AddWatch(spell, cooldownFinished)
	local button = cooldownButtons[watchCount + 1]
	if button then
		watchCount = watchCount + 1
		watchSpells[spell] = button
		button:SetSpell(spell, cooldownFinished)
		return button
	end
end

local function RemoveWatch(spell, button)
	watchCount = watchCount - 1
	watchSpells[spell] = nil
	button:SetSpell()
	local i = FindWatchButton(button)
	local nextButton = cooldownButtons[i + 1]
	if nextButton and nextButton:IsShown() then
		nextButton:ClearAllPoints()
		nextButton:SetPoint(button:GetPoint(1))
		button:ClearAllPoints()
		button:SetPoint("LEFT", cooldownButtons[#cooldownButtons], "RIGHT", templates.BUTTON_GAP, 0)
		tremove(cooldownButtons, i)
		tinsert(cooldownButtons, button)
	end
end

local function RemoveAllWatches()
	local spell, button
	for spell, button in pairs(watchSpells) do
		button:SetSpell()
	end
	watchSpells = wipe(watchSpells)
	watchCount = 0
end


function frame:UpdateWidth()
	if watchCount > 0 then
		self:SetWidth(watchCount * templates.BUTTON_SIZE + (watchCount - 1) * templates.BUTTON_GAP)
	end
end

function frame:Reload()
	if self:GetParent():IsShown() then
		RemoveAllWatches()
		self:UpdateData()
	end
end

function frame:UpdateData()
	self.elapsed = 0
	local spell, spellType, changed
	for spell, spellType in pairs(cooldownWatchSpells) do
		if addon:PlayerHasSpell(spell) then
			local button = watchSpells[spell]
			local start, duration = GetSpellCooldown(spell)
			local timeLeft, cooldownFinished = templates:VerifyTimeLeft(start, duration)
			if button then
				if not timeLeft then
					RemoveWatch(spell, button)
					changed = 1
				end
			else
				if timeLeft and AddWatch(spell, cooldownFinished) then
					changed = 1
				end
			end
		end
	end

	if changed then
		self:UpdateWidth()
	end
end

function addon:InitCooldownWatchSpells(cooldowns)
	wipe(cooldownWatchSpells)
	if type(cooldowns) == "table" then
		local spell
		for _, spell in pairs(cooldowns) do
			if type(spell) == "number" then
				spell = GetSpellInfo(spell)
			end

			if type(spell) == "string" then
				cooldownWatchSpells[spell] = 1
			end
		end
	end
	frame:UpdateData()
end

frame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.5 then
		self:UpdateData()
	end
end)

frame:SetScript("OnShow", function(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("SPELLS_CHANGED")
	self:UpdateData()
end)

frame:SetScript("OnHide", function(self)
	self:UnregisterAllEvents()
	RemoveAllWatches()
end)

frame:SetScript("OnEvent", function(self, event)
	if event == "SPELLS_CHANGED" then
		RemoveAllWatches()
	end
	self:UpdateData()
end)

local i
for i = 1, templates.MAX_COOLDOWN_BUTTONS do
	local button = templates:CreateSpellWatchButton(frame:GetName().."Button"..i, frame)
	tinsert(cooldownButtons, button)
	if i == 1 then
		button:SetPoint("LEFT")
	else
		button:SetPoint("LEFT", cooldownButtons[i - 1], "RIGHT", templates.BUTTON_GAP, 0)
	end
end
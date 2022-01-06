------------------------------------------------------------
-- Core.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDead = UnitIsDead
local UnitCanAttack = UnitCanAttack
local GetSpecialization = GetSpecialization
local IsUsableSpell = IsUsableSpell
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local ceil = ceil
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetTime = GetTime
local tremove = tremove
local tinsert = tinsert
local wipe = wipe
local GetInventoryItemID = GetInventoryItemID
local IsResting = IsResting
local UnitHasVehicleUI = UnitHasVehicleUI

local addonName, addon = ...
_G["DPSCycle"] = addon
addon.name = "DPSCycle"
addon.version = GetAddOnMetadata(addonName, "Version") or "3.0"
addon.numericVersion = tonumber(addon.version) or 3.0
addon.db = {}
addon.chardb = {}

local L = addon.L

local lps = _G["LibPlayerSpells-1.0"]

function addon:GetVersion()
	return self.numericVersion, self.version
end

function addon:GetSpecialization()
	local _,_,num1,_=GetTalentTabInfo(1)
	local _,_,num2,_=GetTalentTabInfo(2)
	local _,_,num3,_=GetTalentTabInfo(3)
	local usetalent
	if num1>num2 and num1>num3 then
		usetalent=1
	elseif num2>num1 and num2>num3 then
		usetalent=2
	elseif num3>num1 and num3>num2 then
		usetalent=3
	else usetalent=1
	end
	return usetalent or 0
end

function addon:PlayerHasSpell(spell)
	return lps:PlayerHasSpell(spell)
end

function addon:GetSpellCooldown(spell)
	return lps:GetSpellCooldown(spell)
end

function addon:IsSpellInRange(spell, unit)
	return lps:IsSpellInRange(spell, unit)
end

function addon:IsUsableSpell(spell, checkCooldown, checkMana, checkRange)
	return lps:IsUsableSpell(spell, checkCooldown, checkMana, checkRange)
end

function addon:PlayerHasTalent(talent)
	return lps:PlayerHasTalent(talent)
end

function addon:GetSpellCastTime(spell, useRecord)
	return lps:GetSpellCastTime(spell, useRecord)
end

function addon:WasSpellSent(spell, elapsed)
	return lps:WasSpellSent(spell, elapsed)
end

function addon:GetLastSentSpell()
	return lps:GetLastSentSpell()
end

function addon:UnitHealthPercent(unit)
	if not unit or not UnitExists(unit) then
		return 0
	end

	local health = UnitHealth(unit) or 0
	local healthMax = UnitHealthMax(unit) or 0
	if healthMax == 0 then
		return 0
	end

	return ceil(health / healthMax * 100)
end

function addon:UnitPowerPercent(unit)
	if not unit or not UnitExists(unit) then
		return 0
	end

	local power = UnitPower(unit) or 0
	local powerMax = UnitPowerMax(unit) or 0
	if powerMax == 0 then
		return 0
	end

	return ceil(power / powerMax * 100)
end


function addon:GetRemainTime(expires)
	if expires then
		return expires - GetTime()
	else
		return 0
	end
end

function addon:CurrentSpell()
	return addon.iconFrame.spellName
end

function addon:IsDualWield()
	return (GetInventoryItemID("player", 17) or 0) > 0
end

--local dataCount = 0
local dataPool = {} -- The global queue for recycling our allocated data

function addon:AcquireData()
	local data = tremove(dataPool)
	if not data then
		--dataCount = dataCount + 1
		data = {}
	end
	return data
end

function addon:ReleaseData(data)
	if data then
		wipe(data)
		tinsert(dataPool, data)
		return 1
	end
end

local hasTarget, isStrongTarget

function addon:IsStrongTarget()
	return isStrongTarget
end

function addon:CheckConditions()
	local module = addon:GetModule()
	local valid = module and module:IsEnabled() and hasTarget and not inVehicle and not UnitIsDeadOrGhost("player") and not UnitIsDead("target") and UnitCanAttack("player", "target")
	local _,_,num1,_=GetTalentTabInfo(1)
	local _,_,num2,_=GetTalentTabInfo(2)
	local _,_,num3,_=GetTalentTabInfo(3)
	local usetalent
	if num1>num2 and num1>num3 then
		usetalent=1
	elseif num2>num1 and num2>num3 then
		usetalent=2
	elseif num3>num1 and num3>num2 then
		usetalent=3
	else
		usetalent=1
	end
	if valid then
		local func = module.OnCheckConditions
		if type(func) == "function" then
			valid = func(module, usetalent)
		end
	end

	if valid then
		addon.iconFrame:Show()
	else
		addon.iconFrame:Hide()
	end

	return valid
end

local function UpdateStrongTarget()
	isStrongTarget = hasTarget and (IsResting() or UnitClassification("target") == "worldboss" or (UnitHealthMax("target") or 0) > UnitHealthMax("player") * 10 * ceil(GetNumGroupMembers()/4))
end

-- Internal event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_FACTION")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_TARGET")
frame:RegisterEvent("UNIT_POWER_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit)
	local needCheck
	if event == "PLAYER_TARGET_CHANGED" then
		hasTarget = UnitExists("target")
		needCheck = 1
	elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		needCheck = 1
	elseif event == "UNIT_FACTION" or event == "UNIT_AURA" then
		needCheck = (unit == "player" or unit == "target")
	elseif event == "UNIT_TARGET" then
		needCheck = (unit == "target")
	end

	if needCheck then
		UpdateStrongTarget()
		addon:CheckConditions()
	end
end)
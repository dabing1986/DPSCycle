------------------------------------------------------------
-- ModuleManager.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local type = type
local error = error
local format = format
local strupper = strupper
local UnitClass = UnitClass
local ipairs = ipairs
local GetSpellInfo = GetSpellInfo

local _, addon = ...
local L = addon.L
local LIBSPELLS = _G["LibPlayerSpells-1.0"]

local DPSCYCLE_METHODS = { "CurrentSpell", "GetSpecialization", "PlayerHasSpell", "IsUsableSpell", "WasSpellSent", "UnitHealthPercent", "UnitPowerPercent",
	"GetLastSentSpell", "UnitAura", "PlayerBuff", "PlayerDebuff", "TargetBuff", "TargetDebuff", "UnitAuraTime", "PlayerBuffTime", "PlayerDebuffTime",
	"TargetBuffTime", "TargetDebuffTime", "GetSpellCastTime", "IsStrongTarget", "GetRemainTime", "SetComboPoints", "GetComboPoints", "IsDualWield", "GetSpellCooldown",
	"IsSpellInRange", "PlayerHasTalent", "UnitAuraStack", "PlayerBuffStack", "PlayerDebuffStack", "TargetBuffStack", "TargetDebuffStack",
}

local MODULE_METHODS = { "SetCountText", "DisplayInfo", "InitializeSequence", "AddSequenceSpell", "AddSequenceDebuff", "AddSequenceBuff", "CompleteSequence", "GetSequenceSpells", "IsSequenceCompleted",
}

local activeModule

function addon:OnSpellRequest()
	if activeModule and activeModule.OnSpellRequest then
		return activeModule:OnSpellRequest(self:GetSpecialization(), self:IsStrongTarget(), self:GetComboPoints())
	end
end

local function Module_IsEnabled(self)
	return self.__isEnabled
end

local function Module_SafeCall(self, method, ...)
	local func = self and self[method]
	if func and type(func) == "function" then
		return 1, func(self, ...)
	end
end

function addon:CreateModule(class, desc, hasOptions)
	if activeModule then
		return
	end

	if type(class) ~= "string" then
		error(format("bad argument #1 to 'DPSCycle:CreateModule' (string expected, got %s)", type(class)))
		return
	end

	class = strupper(class)
	local name, arg = UnitClass("player")
	if class ~= arg then
		return
	end

	local module = { name = name, class = class, desc = desc, db = {}, sequence = {}, seqDebuffs = {}, seqBuffs = {} }
	EmbedEventObject(module)

	if hasOptions then
		module.optionPage = self:CreateModuleOptionPage(name, desc or format(L["module sub title"], name))
	end

	local method
	for _, method in ipairs(DPSCYCLE_METHODS) do
		module[method] = self[method]
	end

	for _, method in ipairs(MODULE_METHODS) do
		module[method] = self["Module_"..method]
	end

	module.SafeCall = Module_SafeCall
	module.IsEnabled = Module_IsEnabled
	LIBSPELLS:HookObject(module)
	activeModule = module
	return module
end

function addon:GetModule()
	return activeModule
end

addon.Module_DisplayInfo = function(module, icon, text, r, g, b)
	addon.infoFrame:DisplayInfo(icon, text, r, g, b)
end

addon.Module_SetCountText = function(module, text, r, g, b)
	addon.iconFrame:SetCountText(text, r, g, b)
end

local function InitModule(module)
	if not module then
		return
	end

	local class = module.class
	local firstTime
	local db = addon.chardb[class]
	if type(db) ~= "table" then
		db = {}
		addon.chardb[class] = db
		firstTime = 1
	end

	module.db = db
	module:SafeCall("OnInitialize", db, firstTime)
end

local function EnableModule(module)
	if not module then
		return
	end

	module.__isEnabled = 1
	addon:InitCooldownWatchSpells(module.cooldowns)
	module:SafeCall("OnEnable")
	addon:CheckConditions()
end

local function DisableModule(module)
	if not module then
		return
	end

	module.__isEnabled = nil
	addon.iconFrame:Hide()
	addon:InitCooldownWatchSpells()
	addon:CheckConditions()
	module:UnregisterAllEvents()
	module:SafeCall("OnDisable")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
	InitModule(activeModule)
	EnableModule(activeModule)
end)
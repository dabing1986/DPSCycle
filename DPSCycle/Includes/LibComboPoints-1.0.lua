------------------------------------------------------------------------
-- LibComboPoints-1.0

-- A library for maintaining player combo points or special resources.

-- Abin (2012/9/25)

------------------------------------------------------------------------
-- API Documentation
------------------------------------------------------------------------

-- lib:HookCallback(object)
-- lib:HookCallback(func)

-- Hooks an object or a global function so object:OnComboPointsChanged(points) or func(points) will be called whenever the player combo points or special resources change.
------------------------------------------------------------------------

-- lib:GetComboPoints()

-- Returns the player combo points or special resources.
------------------------------------------------------------------------

-- lib:GetComboColor(points [, base])

-- Returns the avialable color for the specified points and base(3/5/6), if base is nil, the appropriate base for the current class will be used.
------------------------------------------------------------------------

-- lib:IsComboClass(["CLASS"])

-- Checks whether this library is available for the specified class (upper-case English), if "CLASS" is nil, the current player class will be used.
------------------------------------------------------------------------

local GetComboPoints = GetComboPoints
local UnitPowerType = UnitPowerType
local select = select
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitPower = UnitPower
local format = format
local _


local LIBNAME = "LibComboPoints-1.0"
local VERSION = 1.2

local lib = _G[LIBNAME]
if lib and lib.version >= VERSION then return end

if not lib then
	lib = {}
	_G[LIBNAME] = lib
end

lib.version = VERSION

local COMBO_DEF = {
	[3] = { { r = 0, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0, b = 0 } },
	[5] = { { r = 0, g = 1, b = 0 }, { r = 0.5, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0.5, b = 0 }, { r = 1, g = 0, b = 0 } },
	[6] = { { r = 0, g = 1, b = 0 }, { r = 0.5, g = 1, b = 0 }, { r = 1, g = 1, b = 0 }, { r = 1, g = 0.5, b = 0 }, { r = 1, g = 0, b = 0 }, { r = 1, g = 0, b = 0 } },
}

local MAELSTORM_WEAPON = GetSpellInfo(53817)
local ARCANE_CHARGE = GetSpellInfo(36032)

local comboPoints = 0

local CLASS_DEF = {
	ROGUE = {
		base = 5,
		events = { "PLAYER_TARGET_CHANGED" },
		CalcPoints = function()
			return GetComboPoints("player", "target")
		end,

		CheckEvent = function(event, unit)
			return event == "PLAYER_TARGET_CHANGED" or unit == "player"
		end,
	},

	DRUID = {
		base = 5,
		events = { "PLAYER_TARGET_CHANGED", "UNIT_DISPLAYPOWER" },
		CalcPoints = function()
			return UnitPowerType("player") == 3 and GetComboPoints("player", "target")
		end,

		CheckEvent = function(event, unit)
			return event == "PLAYER_TARGET_CHANGED" or unit == "player"
		end,
	},
}

local data = CLASS_DEF[select(2, UnitClass("player"))]

function lib:GetComboPoints()
	return comboPoints
end

function lib:GetComboColor(points, base)
	if type(base) ~= "number" then
		if data then
			base = data.base
		end
	end

	local def = COMBO_DEF[base]
	if not def then
		return
	end

	local color = def[points]
	if color then
		return color.r, color.g, color.b
	end
end

function lib:IsComboClass(class)
	local res
	if class then
		res = CLASS_DEF[class]
	else
		res = data
	end

	if res then
		return res.base
	end
end

local callbacks = lib._registeredCallbacks
if type(callbacks) ~= "table" then
	callbacks = {}
	lib._registeredCallbacks = callbacks
end

function lib:HookCallback(callback)
	if type(callback) == "table" or type(callback) == "function" then
		tinsert(callbacks, callback)
	end
end

if not data then
	return
end

local frame = lib._eventFrame
if not frame then
	frame = CreateFrame("Frame")
	lib._eventFrame = frame
end

frame:UnregisterAllEvents()
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
--frame:RegisterEvent("PLAYER_TALENT_UPDATE")

local e
for _, e in pairs(data.events) do
	frame:RegisterEvent(e)
end

frame:SetScript("OnEvent", function(self, event, ...)
	if  event == "PLAYER_ENTERING_WORLD" or data.CheckEvent(event, ...) then
		local points = data.CalcPoints() or 0
		if comboPoints ~= points then
			comboPoints = points
			local i
			for i = 1, #callbacks do
				local callback = callbacks[i]
				if type(callback) == "function" then
					callback(points)
				elseif type(callback) == "table" and type(callback.OnComboPointsChanged) == "function" then
					callback:OnComboPointsChanged(points)
				end
			end
		end
	end
end)
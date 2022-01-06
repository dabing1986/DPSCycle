------------------------------------------------------------
-- Auras.lua
--
-- Abin
-- 2012-9-09
-- Fengshen£¬ïLÉñ@Ø°Ê×Áë
-- 2020-2-5ÐÞ¸Ä
------------------------------------------------------------

local type = type
local pairs = pairs
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local wipe = wipe

local _, addon = ...
local L = addon.L

-------------------------------------------------------------------------------------
-- module:UnitAura("unit", "aura", harmful, mine)
-- module:PlayerBuff("aura", mine)
-- module:PlayerDebuff("aura", mine)
-- module:TargetBuff("aura", mine)
-- module:TargetDebuff("aura", mine)

-- module:UnitAuraTime("unit", "aura", harmful, mine)
-- module:PlayerBuffTime("aura", mine)
-- module:PlayerDebuffTime("aura", mine)
-- module:TargetBuffTime("aura", mine)
-- module:TargetDebuffTime("aura", mine)

-- module:UnitAuraStack("unit", "aura", harmful, mine)
-- module:PlayerBuffStack("aura", mine)
-- module:PlayerDebuffStack("aura", mine)
-- module:TargetBuffStack("aura", mine)
-- module:TargetDebuffStack("aura", mine)

-- Some convenient warps to Blizzard's native API, you'll find yourself using these
-- a lot in your own modules.

-- unit: [STRING] - "player", "target", "pet", "focus" etc
-- aura: [STRING] - name of the aura
-- harmful: [BOOLEAN] - true if the aura must be a debuff
-- mine: [BOOLEAN] - true if the aura must be cast by myself
-------------------------------------------------------------------------------------

function addon:UnitAura(unit, aura, harmful, mine)
	if type(aura) ~= "string" then
		return
	end

	local auraname
	for i = 1,40 do
		auraname = harmful and UnitAura(unit, i, "HARMFUL") or UnitAura(unit, i)
		if auraname == aura then
			local func = harmful and UnitDebuff or UnitBuff
			if mine then
				return func(unit or "target", i, "PLAYER")
			else
				return func(unit or "target", i)
			end
		end
	end
end

function addon:PlayerBuff(aura, mine)
	return self:UnitAura("player", aura, nil, mine)
end

function addon:PlayerDebuff(aura, mine)
	return self:UnitAura("player", aura, 1, mine)
end

function addon:TargetBuff(aura, mine)
	return self:UnitAura("target", aura, nil, mine)
end

function addon:TargetDebuff(aura, mine)
	return self:UnitAura("target", aura, 1, mine)
end

function addon:UnitAuraTime(unit, aura, harmful, mine)
	local name, _, count, _, _, expires = self:UnitAura(unit, aura, harmful, mine)
	if name then
		return max(0, expires and (expires - GetTime()) or 0), count or 0
	else
		return 0, 0
	end
end

function addon:PlayerBuffTime(aura, mine)
	return self:UnitAuraTime("player", aura, nil, mine)
end

function addon:PlayerDebuffTime(aura, mine)
	return self:UnitAuraTime("player", aura, 1, mine)
end

function addon:TargetBuffTime(aura, mine)
	return self:UnitAuraTime("target", aura, nil, mine)
end

function addon:TargetDebuffTime(aura, mine)
	return self:UnitAuraTime("target", aura, 1, mine)
end

function addon:UnitAuraStack(unit, aura, harmful, mine)
	local stack = select(3, self:UnitAura(unit, aura, harmful, mine))
	return stack or 0
end

function addon:PlayerBuffStack(aura, mine)
	return self:UnitAuraStack("player", aura, nil, mine)
end

function addon:PlayerDebuffStack(aura, mine)
	return self:UnitAuraStack("player", aura, 1, mine)
end

function addon:TargetBuffStack(aura, mine)
	return self:UnitAuraStack("target", aura, nil, mine)
end

function addon:TargetDebuffStack(aura, mine)
	return self:UnitAuraStack("target", aura, 1, mine)
end
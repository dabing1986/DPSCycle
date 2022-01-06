------------------------------------------------------------
-- API.lua
--
-- Abin
-- 2012-9-09

-- This file only presents as a documentation.
------------------------------------------------------------

-------------------------------------------------------------------------------------
-- module = DPSCycle:CreateModule("class" [, desc [, hasOptions]])

-- Create a new module for DPSCycle
--
-- class [STRING] - Required class(upper-case English), the function returns nil if the player class does not match
-- desc [nil, STRING] -- Description text to display on the option page of this module, can be any texts
--
-- Callback functions: -- The following functions are user-defined and will be called automatically, you need to define at least
--                        module:OnSpellRequest() to make the module meaningful. You should never call any of them in your code!
--
-- module:OnInitialize(db, firstTime) -- Called after the "PLAYER_LOGIN" event fires, "db" is a table where you should store your module's
--                            persistent data(it is not necessary to have a "SavedVariables" field in your module's TOC file), "firstTime" is 1 or nil
--                            which indicates whether it's the first time this player uses this module. You may also access this table via "module.db".
--                            At this moment the player data such as spells or talents are not ready yet. This is where you should do one-time
--                            initialization only.

-- module:OnCheckConditions(spec) -- Called when the framework needs to decide whether to display the spell button, if you return nil or false,
--                               the spell button will be hidden. This is useful for hiding the addon in situations such as the player is in
--                               wrong shapeshift form, or does not have required talent spec etc.

-- module:OnShow() -- Called after the DPSCycle main button shows up.

-- module:OnHide() -- Called after the DPSCycle main button hides.

-- module:OnSpellRequest(spec, strongTarget, combo) -- Called when a spell suggestion is requested, must return a spell name(string) for DPSCycle GUI to display
--                            a spell. In addition, if you want to display the 2nd and 3rd spell icons as a "spell sequence forecst", you
--                            will have to return the 2nd and 3rd spell names as well.
--                            For example, (return "Fireball", "Forst Bolt", "Arcane Missiles") will make the main icon display Fireball,
--                            the 2nd icon display Forst Bolt and the 3rd icon display Arcane Missiles.

-- module:OnSpellsChanged() -- Called when the player's spells are changed

-- module:OnTalentsChanged() -- Called when the player's talents are changed

-------------------------------------------------------------------------------------
function DPSCycle:CreateModule(class, desc, hasOptions)
	return module
end

-------------------------------------------------------------------------------------
-- DPSCycle:GetVersion()

-- Retrieves DPSCycle core version (string)
-------------------------------------------------------------------------------------
function DPSCycle:GetVersion()
	return numericVersion, version
end

-------------------------------------------------------------------------------------
-- module:GetSpecialization()

-- Retrieves index of the player specialization
-------------------------------------------------------------------------------------
function module:GetSpecialization()
	return spec
end

-------------------------------------------------------------------------------------
-- module:PlayerHasSpell("spell")

-- Queries a spell id from both player or pet books, it's really funny that Blizzard doesn't
-- provide this function by themselves...
-------------------------------------------------------------------------------------
function module:PlayerHasSpell(spell)
	return spellId, bookType
end

-------------------------------------------------------------------------------------
-- module:GetSpellCooldown("spell")

-- Get spell cooldown, returns cooldown, start, duration, enabled
-------------------------------------------------------------------------------------
function module:GetSpellCooldown(spell)
	return cooldown, start, duration, enable
end

-------------------------------------------------------------------------------------
-- module:IsSpellInRange("spell" [, "unit"])

-- Checks whether the spell is in range against the specified unit("target" by default), returns false if out of range (Unlike the native IsSpellInRange!)
-------------------------------------------------------------------------------------
function module:IsSpellInRange(spell, unit)
	return boolean
end

-------------------------------------------------------------------------------------
-- module:IsUsableSpell("spell" [, checkCooldown [, checkMana [, "checkRange"]]])

-- Checks whether a spell is usable at the moment, returns spell id if the spell is usable,
-- or nil if it's unavailable, in which case the 2nd return value indicates the error types:
-- nil: Invalid spell name
-- 1: Spell is in cooldown, the 3rd return value is time left of the cooldown, in seconds
-- 2: Spell is not castable
-- 3: Out of mana
-- 4: Out of range against the unit specified by "checkRange" ("target", "focus", "pet", etc)
-------------------------------------------------------------------------------------
function module:IsUsableSpell(spell, checkCooldown, checkMana, checkRange)
	return usable, errorType, cooldown, start, duration, enabled
end

-------------------------------------------------------------------------------------
-- module:PlayerHasTalent("talent")

-- Checks whether the player has spent point on the given talent
-------------------------------------------------------------------------------------
function module:PlayerHasTalent(talent)
	return talentSlot
end

-------------------------------------------------------------------------------------
-- module:PlayerHasGlyph("glyph")

-- Checks whether the specified glyph is installed
-------------------------------------------------------------------------------------
function module:PlayerHasGlyph(glyph)
	return glyphSlot
end

-------------------------------------------------------------------------------------
-- module:GetSpellCastTime("spell" [, useRecord])

-- Returns casting or channeling time of a spell, if useRecord is specified, DPSCycle searches internal
-- records if it was previously cast, if not found and type of useRecord is number, it returns useRecord.
-------------------------------------------------------------------------------------
function module:GetSpellCastTime(spell, useRecord)
	return castTime
end

-------------------------------------------------------------------------------------
-- module:WasSpellSent("spell" [, elapsed])

-- Checks whether a spell was previously cast, if "elapsed" is specified, the function will
-- returns true only if the spell was cast within that time span, in seconds.
-------------------------------------------------------------------------------------
function module:WasSpellSent(spell, elapsed)
	return boolean
end

-------------------------------------------------------------------------------------
-- module:GetLastSentSpell()

-- Retrives the last spell the player cast, and the time when it was cast
-------------------------------------------------------------------------------------
function module:GetLastSentSpell()
	return spell, when
end

-------------------------------------------------------------------------------------
-- module:IsStrongTarget()

-- Returns whether the target is a strong enemy
-------------------------------------------------------------------------------------
function module:IsStrongTarget()
	return boolean
end

-------------------------------------------------------------------------------------
-- module:UnitHealthPercent("unit")

-- Returns health percentage of the specified unit, return value is always an integer, 75% is represented as 75, not 0.75
-------------------------------------------------------------------------------------
function module:UnitHealthPercent(unit)
	return percent
end

-------------------------------------------------------------------------------------
-- module:UnitPowerPercent("unit")

-- Returns power/mana/rage/focus/etc percentage of the specified unit, return value is always an integer, 75% is represented as 75, not 0.75
-------------------------------------------------------------------------------------
function module:UnitPowerPercent(unit)
	return percent
end

-------------------------------------------------------------------------------------
-- module:GetRemainTime()

-- Calculates time remaining until "expires", always returns a safe numeric value, minimum is 0
-------------------------------------------------------------------------------------
function module:GetRemainTime(expires)
	return remainTime
end

-------------------------------------------------------------------------------------
-- module:GetComboPoints()

-- Returns combo points/holy power/shadow power/maelstorm/etc
-------------------------------------------------------------------------------------
function module:GetComboPoints()
	return points
end

-------------------------------------------------------------------------------------
-- module:SetComboPoints(points [, base])

-- Force the GUI to display a number in format and colors as combo points
-------------------------------------------------------------------------------------
function module:SetComboPoints(points, base)
end

-------------------------------------------------------------------------------------
-- module:IsDualWield()

-- Checks whether the player is dual-wielding, that is, equiped two weapons at same time
-------------------------------------------------------------------------------------
function module:IsDualWield()
	return boolean
end

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
function module:UnitAura(unit, aura, harmful, mine)
	return name, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, castByPlayer, value1, value2, value3
end

function module:PlayerBuff(aura, mine)
	return ...
end

function module:PlayerDebuff(aura, mine)
	return ...
end

function module:TargetBuff(aura, mine)
	return ...
end

function module:TargetDebuff(aura, mine)
	return ...
end

function module:UnitAuraTime(unit, aura, harmful, mine)
	return remainTime, stacks
end

function module:PlayerBuffTime(aura, mine)
	return remainTime, stacks
end

function module:PlayerDebuffTime(aura, mine)
	return remainTime, stacks
end

function module:TargetBuffTime(aura, mine)
	return remainTime, stacks
end

function module:TargetDebuffTime(aura, mine)
	return remainTime, stacks
end

function module:UnitAuraStack(unit, aura, harmful, mine)
	return stack
end

function module:PlayerBuffStack(aura, mine)
	return stack
end

function module:PlayerDebuffStack(aura, mine)
	return stack
end

function module:TargetBuffStack(aura, mine)
	return stack
end

function module:TargetDebuffStack(aura, mine)
	return stack
end

-------------------------------------------------------------------------------------
-- module:CurrentSpell()

-- Returns the current spell which is displayed on DPSCycle GUI
-------------------------------------------------------------------------------------
function module:CurrentSpell()
	return spellName
end

-------------------------------------------------------------------------------------
-- module:IsEnabled()

-- Checks whether the given module is the currently selected module
-------------------------------------------------------------------------------------
function module:IsEnabled()
	return boolean
end

-------------------------------------------------------------------------------------
-- module:DisplayInfo("icon", "text" [, r, g, b])

-- Displays a notify message on top of DPSCycle GUI
-------------------------------------------------------------------------------------
function module:DisplayInfo(icon, text, r, g, b)
end

-------------------------------------------------------------------------------------
-- module:SetCountText("text" [, r, g, b])

-- Display count text on DPSCycle spell button
-------------------------------------------------------------------------------------
function module:SetCountText(text, r, g, b)
end

-------------------------------------------------------------------------------------
-- module:InitializeSequence()

-- Initialize the module's internal sequence data, all contents in the sequence will be wiped out.
-- You must call this function to prepare a new sequence.
-------------------------------------------------------------------------------------
function module:InitializeSequence()
end

-------------------------------------------------------------------------------------
-- module:AddSequenceSpell("spell" [, cooldown [, castingTime [, ignoreDuration]]])

-- Adds a spell into the forecast sequence
-- spell: [STRING] - name of the spell
-- cooldown: [nil/NUMBER] - if specified, the framework will use this value instead of the spell's real cooldown time
-- castingTime: [nil/NUMBER] - if specified, the framework will use this value instead of the spell's real casting time
-- ignoreDuration: [nil/NUMBER] - the framework will ignore this spell after successful casting if it is the first spell in the sequence,
--                                default value is 0.5 second

-------------------------------------------------------------------------------------
function module:AddSequenceSpell(spell, cooldown, castingTime, ignoreDuration)
	return cooldown
end

-------------------------------------------------------------------------------------
-- module:AddSequenceDebuff("debuff" [, "unit"])

-- Adds a my-debuff into the forecast sequence
-- debuff: [STRING] - name of the debuff
-- unit: [STRING] - unitid, default value is "target"
-------------------------------------------------------------------------------------
function module:AddSequenceDebuff(debuff, unit)
	return remainTime
end

-------------------------------------------------------------------------------------
-- module:AddSequenceBuff("buff" [, "unit"])

-- Adds a buff into the forecast sequence
-- buff: [STRING] - name of the buff
-- unit: [STRING] - unitid, default value is "player"
-------------------------------------------------------------------------------------
function module:AddSequenceBuff(buff, unit)
	return remainTime
end

-------------------------------------------------------------------------------------
-- module:CompleteSequence("fillSpell" [, cooldown [, threshold]])

-- Completes the spell sequence, asfter this you cannot call "AddSequenceSpell" until next "InitializeSequence". This
-- function encloses the current sequence and,  if "fillSpell" is specified, fill spell "gaps" in the sequence using it.

-- fillSpell: [STRING] - name of the spell which is to be filled into sequence gaps.
-- duration: [NUMBER] - aribitrary duration of "fillSpell", usually its casting/channeling time or a GCD for instant-cast spell
-- threshold: [NUMBER] - specifies the minimum time span between each two spells in the sequence, if its greater than "threshold",
--                       "fillSpell" will be kept inserting between them until the time span is no longer greater than "threshold".
-------------------------------------------------------------------------------------
function module:CompleteSequence(fillSpell, duration, threshold)
end

-------------------------------------------------------------------------------------
-- module:IsSequenceCompleted()

-- Checks whether the sequence is currently completed.
-------------------------------------------------------------------------------------
function module:IsSequenceCompleted()
	return boolean
end

-------------------------------------------------------------------------------------
-- module:GetSequenceSpells()

-- Returns the first 3 spells in the sequence, you should only call this function after calling
-- "CompleteSequence", otherwise the results could likely be undesired.
-------------------------------------------------------------------------------------
function module:GetSequenceSpells()
	return spell1, spell2, spell3
end
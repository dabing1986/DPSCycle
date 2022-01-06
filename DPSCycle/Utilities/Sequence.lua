------------------------------------------------------------
-- Sequence.lua
--
-- Abin
-- 2012-9-09
------------------------------------------------------------

local tinsert = tinsert
local ipairs = ipairs
local wipe = wipe

local _, addon = ...

local GCD = 1.5

local function CompareCooldownSequence(sequence, cooldown)
	cooldown = cooldown + 0.5
	local count = #sequence
	local i
	for i = 1, count do
		if cooldown < sequence[i].cooldown then
			return i
		end
	end
	return count + 1
end

local function GetSequenceAt(sequence, position)
	local count = #sequence
	if count == 0 then
		return
	end

	if count == 1 then
		position = 1
	elseif position > count then
		position = position % count
	end

	local data = sequence[position]
	if data then
		return data.spell
	end
end

local fillData = { isFill = 1 }

local function FillSequence(sequence, spell, duration, threshold)
	if not addon:PlayerHasSpell(spell) then
		return
	end

	if not duration or duration < GCD then
		duration = GCD
	end

	if not threshold then
		threshold = duration / 2
	elseif threshold > duration then
		threshold = duration
	end

	if threshold < 0.2 then
		threshold = 0.2
	end

	fillData.spell = spell
	fillData.cooldown = duration

	local prevCD, prevCasting = 0, 0
	local count = 0
	local i = 1
	while i <= #sequence do
		local data = sequence[i]
		local cd, casting = data.cooldown, data.castingTime
		if casting then
			local len = cd - prevCD - prevCasting
			prevCD, prevCasting = cd, casting
			while len > threshold do
				len = len - duration
				tinsert(sequence, i, fillData)
				count = count + 1
				if count >= 3 then
					return
				end
				i = i + 1
			end
		end
		i = i + 1
	end

	for i = #sequence, 3 do
		tinsert(sequence, fillData)
	end
end

-------------------------------------------------------------------------------------
-- module:InitializeSequence()

-- Initialize the module's internal sequence data, all contents in the sequence will be wiped out.
-- You must call this function to prepare a new sequence.
-------------------------------------------------------------------------------------
addon.Module_InitializeSequence = function(module)
	module.sequenceCompleted = nil
	local sequence = module.sequence
	local data
	for _, data in ipairs(sequence) do
		if data ~= fillData then
			addon:ReleaseData(data)
		end
	end
	wipe(sequence)
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
addon.Module_AddSequenceSpell = function(module, spell, cooldown, castingTime, ignoreDuration)
	if module.sequenceCompleted then
		return
	end

	if not addon:PlayerHasSpell(spell) then
		return
	end

	if type(cooldown) == "number" then
		if cooldown < 0 then
			cooldown = 0
		end
	else
		cooldown = addon:GetSpellCooldown(spell)
	end

	if type(castingTime) == "number" then
		if castingTime < 0 then
			castingTime = 0
		end
	else
		castingTime = GCD
	end

	if type(ignoreDuration) ~= "number" then
		ignoreDuration = GCD
	end

	local sequence = module.sequence
	local position = CompareCooldownSequence(sequence, cooldown)
	local data = addon:AcquireData()
	data.spell = spell
	data.cooldown = cooldown
	data.castingTime = castingTime
	data.ignoreDuration = ignoreDuration
	tinsert(sequence, position, data)
	return cooldown, data
end

-------------------------------------------------------------------------------------
-- module:AddSequenceDebuff("debuff" [, "unit"])

-- Adds a my-debuff into the forecast sequence
-- debuff: [STRING] - name of the debuff
-- unit: [STRING] - unitid, default value is "target"
-------------------------------------------------------------------------------------
addon.Module_AddSequenceDebuff = function(module, debuff, unit)
	if type(debuff) == "string" then
		if type(unit) ~= "string" then
			unit = "target"
		end

		module.seqDebuffs[debuff] = unit
		return addon.Module_AddSequenceSpell(module, debuff, addon:UnitAuraTime(unit, debuff, 1, 1))
	end
end

-------------------------------------------------------------------------------------
-- module:AddSequenceBuff("buff" [, "unit"])

-- Adds a buff into the forecast sequence
-- buff: [STRING] - name of the buff
-- unit: [STRING] - unitid, default value is "player"
-------------------------------------------------------------------------------------
addon.Module_AddSequenceBuff = function(module, buff, unit)
	if type(buff) == "string" then
		if type(unit) ~= "string" then
			unit = "player"
		end
		module.seqBuffs[buff] = unit
		return addon.Module_AddSequenceSpell(module, buff, addon:UnitAuraTime(unit, buff))
	end
end

function addon:_GetSeqAuraCooldown(aura)
	if not aura then
		return
	end

	local module = addon:GetModule()
	if not module then
		return
	end

	local harmful, mine = 1, 1
	local unit = module.seqDebuffs[aura]
	if not unit then
		harmful, mine = nil
		unit = module.seqBuffs[aura]
	end

	if not unit then
		return
	end

	local _, _, _, count, _, len, expires = self:UnitAura(unit, aura, harmful, mine)
	if len and expires then
		return expires - len, len, 1, harmful and 1 or 0
	end
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
addon.Module_CompleteSequence = function(module, fillSpell, duration, threshold)
	if not module.sequenceCompleted then
		module.sequenceCompleted = 1
		FillSequence(module.sequence, fillSpell, duration, threshold)
	end
end

-------------------------------------------------------------------------------------
-- module:IsSequenceCompleted()

-- Checks whether the sequence is currently completed.
-------------------------------------------------------------------------------------
addon.Module_IsSequenceCompleted = function(module)
	return module.sequenceCompleted
end

-------------------------------------------------------------------------------------
-- module:GetSequenceSpells()

-- Returns the first 3 spells in the sequence, you should only call this function after calling
-- "CompleteSequence", otherwise the results could likely be undesired.
-------------------------------------------------------------------------------------
addon.Module_GetSequenceSpells = function(module)
	local sequence = module.sequence
	local data = sequence[1]
	if not data then
		return
	end

	local spell = data.spell
	local ignoreDuration = data.ignoreDuration
	if not data.isFill and (addon.castingSpell == spell or (ignoreDuration and ignoreDuration > 0 and addon:WasSpellSent(spell, ignoreDuration))) then
		return GetSequenceAt(sequence, 2), GetSequenceAt(sequence, 3), GetSequenceAt(sequence, 4)
	else
		return spell, GetSequenceAt(sequence, 2), GetSequenceAt(sequence, 3)
	end
end

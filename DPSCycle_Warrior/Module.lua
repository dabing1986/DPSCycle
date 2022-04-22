------------------------------------------------------------
-- 战士输出循环
-- Fengshen，風神@匕首岭
-- 2020-7-14
------------------------------------------------------------

local module = DPSCycle:CreateModule("WARRIOR")
if not module then return end


-- 乘胜追击
local VICTORY_RUSH = GetSpellInfo(34428)
-- 横扫攻击
local SWEEPING_STRIKES= GetSpellInfo(12328)
-- 战斗怒吼
local BATTLE_SHOUT = GetSpellInfo(2048)
-- 战斗姿态
local BATTLE_STANCE = GetSpellInfo(2457)
-- 狂暴之怒
local BERSERKER_RAGE = GetSpellInfo(18499)
-- 狂暴姿态
local BERSERKER_STANCE = GetSpellInfo(2458)
-- 血性狂暴
local BLOODRAGE = GetSpellInfo(2687)
-- 嗜血
local BLOODTHIRST = GetSpellInfo(30335)
-- 冲锋
local CHARGE = GetSpellInfo(11578)
-- 挑战怒吼
local CHALLENGING_SHOUT = GetSpellInfo(1161)
-- 顺劈斩
local CLEAVE = GetSpellInfo(25231)
-- 震荡猛击
local CONCUSSION_BLOW = GetSpellInfo(12809)
--local DEATH_WISH = GetSpellInfo(12328)
-- 防御姿态
local DEFENSIVE_STANCE = GetSpellInfo(71)
-- 挫志怒吼
local DEMORALIZING_SHOUT = GetSpellInfo(25203)
-- 斩杀
local EXECUTE = GetSpellInfo(25236)
-- 盗贼破甲
local EXPOSE_ARMOR = GetSpellInfo(8647)
local FLURRY = GetSpellInfo(12319)

local range5Table = { }

-- 断筋
local HAMSTRING = GetSpellInfo(25212)
-- local luanwu = GetSpellInfo(25970)
-- crippling-poison-ii
local cripplingpPoison = GetSpellInfo(3421)

local HERORIC_STRIKE = GetSpellInfo(78)
-- local INTERCEPT = GetSpellInfo(20252)
-- local LAST_STAND = GetSpellInfo(12975)
local MORTAL_STRIKE = GetSpellInfo(9347)
local OVERPOWER = GetSpellInfo(7384)
-- 拳击
local PUMMEL = GetSpellInfo(6552)
-- local RECKLESSNESS = GetSpellInfo(1719)
-- 撕裂
local REND = GetSpellInfo(772)
-- 复仇
local REVENGE = GetSpellInfo(6572)
local SHIELD_BASH = GetSpellInfo(72)
local SHIELD_BLOCK = GetSpellInfo(2565)
-- 盾牌猛击
local SHIELD_SLAM = GetSpellInfo(23922)
-- 盾墙
local SHIELD_WALL = GetSpellInfo(871)
-- 猛击
local SLAM = GetSpellInfo(1464)
-- 破甲攻击
local SUNDER_ARMOR = GetSpellInfo(25225)
-- 嘲讽
local TAUNT = GetSpellInfo(355)
-- 雷霆
local THUNDER_CLAP = GetSpellInfo(6343)
-- 旋风斩
local WHIRLWIND = GetSpellInfo(1680)
local XUNZHAOKUANGWU = GetSpellInfo(2580)
local XIAOGUZHIREN = GetSpellInfo(21153)
local GANZHI = GetSpellInfo(20600)
local JIJIU = GetSpellInfo(3273)
local QIANGXIAOZHENGJIUZHUFU = GetSpellInfo(25895)
local ZHENGJIUZHUFU = GetSpellInfo(1038)
local BAOHUZHUFU = GetSpellInfo(1022)

-- 炸药

local boom = GetSpellInfo(34428)

-- pvp

local zhisidaji = GetSpellInfo(30330)


-- 援护
-- 盾墙
-- 盾牌格挡
-- 破釜沉舟
-- 横扫攻击
-- 鲁莽
-- 死亡志愿
-- 缴械

-- module.cooldowns = { 3411, 871, 2565, 12975, 12328, 1719, 12292, 676 }

-- --pvp CD监测
module.cooldowns = {25275,3411,30330,1680,23920,676}--20252（拦截）,100(冲锋),12292(死亡之愿),30350(联盟勋章),2687(血性狂暴),18499(狂暴之怒)

local dpswarrioraoe, dpswarriorhs, dpswarriorchaofeng, dpswarriortank, pvpwarrior
local incombat, dodgetime, dodgeGUID, swingtime, arr2, arr5, arr8, arr9, arr12, arr13, arr15, arr16, isOffHand, _
local dpswarriorframe = CreateFrame("Frame")
dpswarriorframe:RegisterEvent("PLAYER_REGEN_DISABLED")
dpswarriorframe:RegisterEvent("PLAYER_REGEN_ENABLED")
dpswarriorframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
dpswarriorframe:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		incombat = 1
	elseif event == "PLAYER_REGEN_ENABLED" then
		incombat = nil
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		_, arr2, _, _, arr5, _, _, arr8, arr9, _, _, arr12, arr13, _, arr15, arr16, _, _, _, _, isOffHand = CombatLogGetCurrentEventInfo()
		if arr5 == UnitName("player") and (arr12 == "DODGE" or arr15 == "DODGE") then
			dodgetime = GetTime() or 0
			dodgeGUID = arr8
		end
		if arr5 == UnitName("player") and arr13 == OVERPOWER then
			dodgetime = 0
		end
		if arr5 == UnitName("player") and arr13 == SLAM then
			swingtime = GetTime() or 0
		end
		if arr5 == UnitName("player") and arr2 == ("SWING_DAMAGE" or "SWING_MISSED") and not (arr16 or isOffHand) then
			swingtime = GetTime() or 0
		end
	end
end)

function module:InMelee()
	local inmelee = IsSpellInRange(REND, "target")
	if inmelee == 1 then
		return 1
	else
		return nil
	end
end

function module:CanAE()
	local enemycount = 0
	for i = 1, 40 do
		local unit = "nameplate"..i
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and self:UnitAura(unit, "变形术", 1) then
			enemycount = 1
			break
		end
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and not self:UnitAura(unit, "放逐术", 1) then
			enemycount = enemycount + 1
		end
	end
	if enemycount > 1 then
		return 1
	else
		return nil
	end
end

function module:CanAOEEexecute()
	local enemycount = 0
	for i = 1, 40 do
		local unit = "nameplate"..i
		if module:UnitHealthPercent(unit) < 20 and IsSpellInRange(REND, unit) == 1  then
			enemycount = enemycount + 1
		end
	end
	if enemycount > 1 then
		return 1
	else
		return nil
	end
end

function module:CanAE4()
	local enemycount = 0
	for i = 1, 40 do
		local unit = "nameplate"..i
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and self:UnitAura(unit, "变形术", 1) then
			enemycount = 1
			break
		end
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and not self:UnitAura(unit, "放逐术", 1) then
			enemycount = enemycount + 1
		end
	end
	if enemycount >= 4 then
		return 1
	else
		return nil
	end
end

function module:CanAE2()
	local enemycount = 0
	for i = 1, 40 do
		local unit = "nameplate"..i
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and self:UnitAura(unit, "变形术", 1) then
			enemycount = 1
			break
		end
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and not self:UnitAura(unit, "放逐术", 1) then
			enemycount = enemycount + 1
		end
	end
	if enemycount > 1 and enemycount < 4 then
		return 1
	else
		return nil
	end
end

function module:EnemyCount()
	local enemycount = 0
	local enemy20count = 0 
	for i = 1, 40 do
		local unit = "nameplate"..i
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and self:UnitAura(unit, "变形术", 1) then
			enemycount = 1
			break
		end
		if UnitCanAttack("player", unit) and IsSpellInRange(REND, unit) == 1 and not self:UnitAura(unit, "放逐术", 1) then

			enemycount = enemycount + 1
			if module:UnitHealthPercent(unit) < 20 then
				enemy20count = enemy20count + 1
			end

			if enemycount > 4 or enemy20count > 4 then
				break
			end
		end
	end

	return enemycount, enemy20count
end


function module:Canop()
	if not dodgetime then
		dodgetime = 0
	end
	local opCD = self:GetSpellCooldown(OVERPOWER)
	if opCD < 1 and (GetTime() - dodgetime) < 3.1 and UnitGUID("target") == dodgeGUID then
		return 1
	else
		return nil
	end
end

function module:CanSlam()
	if not swingtime then
		swingtime = 0
	end
	if IsCurrentSpell(20569) then
		return nil
	end
	if (GetTime() - swingtime) < 0.5 and GetUnitSpeed("target") == 0 and GetUnitSpeed("player") == 0 then
		return 1
	elseif (GetTime() - swingtime) < 1 and GetUnitSpeed("target") == 0 and GetUnitSpeed("player") == 0 and (GetShapeshiftFormID() == 17 or UnitPower("player") > 65) then
		return 1
	else
		return nil
	end
end

function module:UpgradeProc()
	-- if self:IsUsableSpell(EXECUTE) then
	-- 	return EXECUTE
	-- end

	if UnitPower("player") > 75 then
		return HERORIC_STRIKE
	end

	if self:IsUsableSpell(OVERPOWER) then
		return OVERPOWER
	end

	if self:IsUsableSpell(MORTAL_STRIKE, 1, 1) then
		return MORTAL_STRIKE
	end
--[[
	if self:IsUsableSpell(REND, 1) and not self:TargetDebuff(REND, 1) and hp > 10 then
		return REND
	end
--
--	if UnitPower("player") > 45 and self:IsUsableSpell(SLAM) then
	if self:CanSlam() and self:IsUsableSpell(SLAM) then
		return SLAM
	end
]]--
--	return SLAM
end

function module:ArmsProc()
	local istt = UnitIsUnit("targettarget", "player")

	if self:IsUsableSpell(THUNDER_CLAP, 1) and dpswarrioraoe then
		return THUNDER_CLAP
	end

	if UnitPower("player") > 75 then
		return HERORIC_STRIKE
	end

	if self:IsUsableSpell(MORTAL_STRIKE, 1, 1) then
		return MORTAL_STRIKE
	end

	if self:IsUsableSpell(HAMSTRING, 1, 1) then
		return MORTAL_STRIKE
	end

	if self:IsUsableSpell(OVERPOWER) then
		return OVERPOWER
	end

	-- if self:IsUsableSpell(EXECUTE, 1, 1) then
	-- 	return EXECUTE
	-- end

	if UnitPower("player") > 14 and self:CanSlam() and not istt and self:InMelee() and UnitName("target") ~= ("熔岩奔腾者") and (hp > 30 or self:IsStrongTarget()) then
		return SLAM
	end


	if self:PlayerBuffTime(BATTLE_SHOUT) < 3 then
		return BATTLE_SHOUT
	end
end

function module:FuryHS()
	local weaponspeed = UnitAttackSpeed("player")
	-- mainSpeed, offSpeed = UnitAttackSpeed(unit)
	if not swingtime then
		swingtime = 0
	end

	if (swingtime + weaponspeed - GetTime()) < 0.3 and UnitPower("player") < 51 and IsCurrentSpell(11567) and GetShapeshiftFormID() ~= 17 then
		return JIJIU
	end

	if (GetTime() - swingtime) < 1 and not IsCurrentSpell(11567) then
		return HERORIC_STRIKE
	end

	return self:FuryProc()
end

	-- local _, _, _, _, fennuzhangwo = GetTalentInfo(1, 8)
	-- local base, posBuff, negBuff = UnitAttackPower("player")
	-- local playerAP = base + posBuff + negBuff;
	-- local enemycount , enemy20count = self.ene
	-- GetShapeshiftFormID() ~= 17
	-- Battle Stance - 17
	-- Berserker Stance - 19
	-- Defensive Stance - 18

	-- if not incombat and GetShapeshiftFormID() ~= 17 and UnitPower("player") < 11 and chargeCD < 1 then
	-- 	return BATTLE_STANCE
	-- end

	-- if self:Canop() and UnitPower("player") < (fennuzhangwo * 5 + 1) and UnitPower("player") > 4 and GetShapeshiftFormID() ~= 17 then
	-- 	return BATTLE_STANCE
	-- end

	-- if self:IsUsableSpell(OVERPOWER, 1, 1) then
	-- 	return OVERPOWER
	-- end

	-- if UnitPower("player") > 25 and self:InMelee() and GetShapeshiftFormID() == 17 and not IsCurrentSpell(11567) then
	-- 	return HERORIC_STRIKE
	-- end

	-- if incombat and UnitPower("player") < 26 and GetShapeshiftFormID() ~= 19 then
	-- 	return BERSERKER_STANCE
	-- end


function module:isAggressive()

	local mainspeed, offhandspeed = UnitAttackSpeed("player")

	if not swingtime then
		swingtime = 0
	end

	-- print("swingtime" .. swingtime)
	if swingtime + mainspeed - GetTime() < 1.5 then
		return 1
	else
		return nil
	end
end


function module:nextOffhandExpectRange()

	
	
-- Hit factor
-- Weapon	     Hit type	     f
-- Main Hand	Normal Hit	    3.5
-- Main Hand	Critical Hit	7.0
-- Off Hand	    Normal Hit	    1.75
-- Off Hand	    Critical Hit	3.5


	-- 7.5*(制造的伤害)/274.7 + f*speed/2


	local mainspeed, offhandspeed = UnitAttackSpeed("player")
	local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage('player')
	local avgDmg =( offlowDmg+offhiDmg)/2 --平均伤害
	
	local offhandrange = 7.5*avgDmg/274.7 + 2.5*offhandspeed/2

	local leng=0
	local last5offhandrage = 0
	for k, v in pairs(range5Table) do
		leng=leng+1
	end

	if leng == 5 then
		table.remove(range5Table, 1 )
	end
	
	-- print("111111" .. offhandrange)
	table.insert(range5Table, offhandrange )

	for k, v in pairs(range5Table) do
		-- print ("index:" .. k .. "-----" .. v)
		last5offhandrage=last5offhandrage+v
	end

	-- print("33333：：：" .. last5offhandrage/leng)
	return last5offhandrage/leng



end
-- 第一次修改 主要针对的双持狂暴战士
function module:FuryProc()

	-- this logic will be triggered when you equip the weapon in offhand 
	local istt = UnitIsUnit("targettarget", "player")
	local hp = self:UnitHealthPercent("target")
	local ihp = self:UnitHealthPercent("player")
	local chargeCD = self:GetSpellCooldown(CHARGE)
	local btCD, _, _,BTEnabled = self:GetSpellCooldown(BLOODTHIRST)
	local windCD, _, _,windCDEnabled = self:GetSpellCooldown(WHIRLWIND)


	
	-- -- highest level heroric strike 29707
	-- if not self:CanAE() and hp > 20 and not IsCurrentSpell(29707) then
	-- -- if not self:CanAE() and not IsCurrentSpell(29707) then
	-- 	if self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and UnitPower("player") > 70 then
	-- 		-- show BLOODTHIRST and WHIRLWIND as well if they are not in CD
	-- 		if self:IsUsableSpell(WHIRLWIND, 1, 1) then
	-- 			-- body
	-- 			return HERORIC_STRIKE, WHIRLWIND
	-- 		elseif self:IsUsableSpell(BLOODTHIRST, 1, 1)  then
	-- 			-- body
	-- 			return HERORIC_STRIKE, BLOODTHIRST
	-- 		end
	-- 		return HERORIC_STRIKE
	-- 	end

	-- 	if self:isAggressive() and self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and (UnitPower("player") -12 + self:nextOffhandExpectRange()) > 25 then
	-- 		-- show BLOODTHIRST and WHIRLWIND as well if they are not in CD
	-- 		return HERORIC_STRIKE		
	-- 	end

		
			
	-- 	-- if self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and UnitPower("player") > 40 and btCD > 1.5 and windCD > 1.5  then
	-- 	-- 	return HERORIC_STRIKE	
	-- 	-- end
	-- end


	
	if self:IsUsableSpell(VICTORY_RUSH, 1) then
		return VICTORY_RUSH
	end

	if self:IsUsableSpell(BLOODRAGE, 1, 1) and UnitPower("player") < 20 and incombat then
		return BLOODRAGE
	end

	-- when to perform HAMSTRING and OVERPOWER
	if incombat and self:InMelee() and not self:CanAE()  and hp > 24 then
	-- if not self:CanAE() then

		if self:Canop() and self:IsUsableSpell(OVERPOWER, 1, 1) and UnitPower("player") < 10  then
			return OVERPOWER
		end

		if btCD > 3 and windCD > 3 then 

			if IsCurrentSpell(29707) then
				if UnitPower("player") > 22 and self:IsUsableSpell(HAMSTRING, 1, 1) then
					-- body
					return HAMSTRING
				end
			else
				if UnitPower("player") > 45 and self:IsUsableSpell(HAMSTRING, 1, 1) then
					return HAMSTRING,HERORIC_STRIKE
				elseif UnitPower("player") < 45 and self:IsUsableSpell(HAMSTRING, 1, 1) then -- body
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 30 then
							return HAMSTRING,HERORIC_STRIKE
						elseif UnitPower("player") > 30 then
							return HAMSTRING,HERORIC_STRIKE
						elseif UnitPower("player") < 22 then
							return HAMSTRING
						end
					else
						if  UnitPower("player") > 30 then
							return HAMSTRING,HERORIC_STRIKE
						elseif  UnitPower("player") < 20 then  
							return HAMSTRING
						end						
					end						
				end				
			end
		elseif  btCD > 3 and windCD < 3 and windCD > 0 then

			if not IsCurrentSpell(29707)  then
				if UnitPower("player") > 40 then
					return HERORIC_STRIKE
				else-- body
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 40 then
							return HERORIC_STRIKE
						elseif UnitPower("player") > 40 then
							return HERORIC_STRIKE
						end
					else
						if  UnitPower("player") > 40 then
							return HERORIC_STRIKE
						end						
					end						
				end					
			end

		elseif  btCD < 3 and btCD > 0 and windCD > 3 then
			if not IsCurrentSpell(29707)  then
				if UnitPower("player") > 42 then
					return HERORIC_STRIKE
				else-- body
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 42 then
							return HERORIC_STRIKE
						elseif UnitPower("player") > 42 then
							return HERORIC_STRIKE
						end
					else
						if  UnitPower("player") > 42 then
							return HERORIC_STRIKE
						end						
					end						
				end					
			end
		elseif  btCD < 3 and windCD < 3 and btCD > 0 and windCD > 0 then
			if not IsCurrentSpell(29707)  then
				if UnitPower("player") > 67 then
					return HERORIC_STRIKE
				else-- body
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 67 then
							return HERORIC_STRIKE
						elseif UnitPower("player") > 67 then
							return HERORIC_STRIKE
						end
					else
						if  UnitPower("player") > 67 then
							return HERORIC_STRIKE
						end						
					end						
				end					
			end
		end
		

		-- print("offhandspeed:".. offhandspeed)

	end


	-- if incombat and GetShapeshiftFormID() ~= 19 then
	-- 	return BERSERKER_STANCE
	-- end

	-- if self:PlayerBuffTime(BATTLE_SHOUT) < 3 then
	-- 	return BATTLE_SHOUT
	-- end

	-- check victory-rush is usable or not 


	-- there might be the chance you will get aoe damage for the scar boss need to add additional logic here 
	-- if self:IsUsableSpell(BERSERKER_RAGE, 1, 1) and incombat and istt then
	-- 	return BERSERKER_RAGE
	-- end

	-- 单体状态
	-- print("2222222" .. self:nextOffhandExpectRange())

	if incombat and self:InMelee() and not self:CanAE() then
		
		-- 斩杀阶段
		if hp < 20 then
			
			-- 满怒斩杀>(怒气不够打嗜血旋风的)低怒斩杀>双慢旋风斩>嗜血>主慢副快旋风斩>高怒斩杀

			if hp < 7 and not module:IsStrongTarget() then
				if self:IsUsableSpell(EXECUTE, 1, 1) then
					return EXECUTE
				end
			end

			if hp < 4 and module:IsStrongTarget() then
				if self:IsUsableSpell(EXECUTE, 1, 1) then
					return EXECUTE
				end
			end

			-- 满怒斩杀
			if UnitPower("player") > 95 then
				return EXECUTE
			end

			-- (怒气不够打嗜血旋风的)低怒斩杀
			if self:IsUsableSpell(EXECUTE, 1, 1) and UnitPower("player") < 25  then
				return EXECUTE
			end

			-- print("时间".. swingtime + mainspeed - GetTime())
			-- 下一刀大概率会溢出 挂英勇斩杀
			if  self:isAggressive() and UnitPower("player") > 70  then
				return EXECUTE,HERORIC_STRIKE
			end


			-- 下一刀大概率会溢出 无脑斩杀
			if  self:isAggressive() and UnitPower("player") > 60  then
				return EXECUTE
			end

			local mainspeed, offhandspeed = UnitAttackSpeed("player")
			-- 双慢旋风斩
			if offhandspeed > 1.8 and UnitPower("player") > 25 and self:IsUsableSpell(WHIRLWIND, 1, 1)  then
				return WHIRLWIND
			end

			-- 嗜血
			if self:IsUsableSpell(BLOODTHIRST, 1, 1) and UnitPower("player") > 30 then
				if offhandspeed > 1.5  then
					if windCD > 2  then
					-- body
						return BLOODTHIRST
					end
				else
					return BLOODTHIRST
				end		
			end

			-- 主慢副快旋风斩
			if offhandspeed < 1.4 and UnitPower("player") > 25 and self:IsUsableSpell(WHIRLWIND, 1, 1)  then
				return WHIRLWIND
			end

			-- 满怒斩杀
			if UnitPower("player") > 60 then
				return EXECUTE
			end

		-- 非斩杀阶段
		elseif hp > 20 then

			if IsCurrentSpell(29707) then 

				if self:IsUsableSpell(WHIRLWIND, 1, 1) then
					if UnitPower("player") < 37 then
						-- body
						return WHIRLWIND, JIJIU
					else
						-- body
						return WHIRLWIND
					end				
				end
				
				if windCD > 1.5 then
					-- body
					if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
						if UnitPower("player") < 42 then
							-- body
							return BLOODTHIRST, JIJIU
						else
							-- body
							return BLOODTHIRST
						end	

					end
				elseif windCD < 1.5 and windCD > 0 then 

					if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 67 then
								return BLOODTHIRST
							elseif (UnitPower("player") + self:nextOffhandExpectRange()) < 67 then
								return BLOODTHIRST, JIJIU
							end
						else
							if  UnitPower("player")> 67 then
								if  UnitPower("player") > 67 then
									return BLOODTHIRST
								elseif UnitPower("player") < 67 then
									return BLOODTHIRST, JIJIU
								end
							end						
						end
					else
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) < 37 then
								return JIJIU
							end
						else
							if  UnitPower("player") < 37 then
								return JIJIU
							end						
						end
					end

				end

				-- if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
				-- 	return BLOODTHIRST
				-- end
			else
				
				-- return WHIRLWIND,HERORIC_STRIKE
				-- return BLOODTHIRST,HERORIC_STRIKE
				-- return WHIRLWIND
				-- return BLOODTHIRST
				-- return HERORIC_STRIKE

				if self:IsUsableSpell(WHIRLWIND, 1, 1) then

					if  UnitPower("player") > 67 then
						return WHIRLWIND,HERORIC_STRIKE
					end
					if btCD > 2 then
						if self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and UnitPower("player")  > 37 then
							return WHIRLWIND,HERORIC_STRIKE
						end
					else
						if self:isAggressive() then
							if (UnitPower("player") + self:nextOffhandExpectRange()) > 67 then
								return WHIRLWIND,HERORIC_STRIKE
							end
						else
							if UnitPower("player") > 67 then
								return WHIRLWIND,HERORIC_STRIKE
							end							
						end
					end
					return WHIRLWIND
				end
				
				if windCD > 2 then
					-- body
					-- BLOODTHIRST?
					-- BLOODTHIRST,HERORIC_STRIKE?
					-- HERORIC_STRIKE

					if  self:IsUsableSpell(BLOODTHIRST, 1, 1)  and UnitPower("player") > 42 then
						return BLOODTHIRST,HERORIC_STRIKE
					end
					if  self:IsUsableSpell(BLOODTHIRST, 1, 1)  and UnitPower("player") > 30 then
						return BLOODTHIRST
					end

					if btCD > 2 then
						if UnitPower("player") > 12 then
							return HERORIC_STRIKE
						end
					elseif btCD < 2 and btCD > 0 then 
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 42 then
								return HERORIC_STRIKE
							end
						else
							if  UnitPower("player") > 42 then
								return HERORIC_STRIKE
							end						
						end							
					end

				elseif windCD < 2 and windCD > 0 then--旋风斩还差2秒准备就绪 

					-- BLOODTHIRST?
					-- BLOODTHIRST,HERORIC_STRIKE?
					-- HERORIC_STRIKE?
					if self:IsUsableSpell(BLOODTHIRST, 1, 1) then 
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 67 then
								return BLOODTHIRST,HERORIC_STRIKE

							elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 55 then 
								return BLOODTHIRST
							end
						else
							if  UnitPower("player") > 67 then
								return BLOODTHIRST,HERORIC_STRIKE
							elseif  UnitPower("player") > 55 then
								return BLOODTHIRST
							end						
						end		
					else --嗜血cd没好 且旋风还剩2秒就好 只需要判断是否释放英勇
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 37 then
								return HERORIC_STRIKE
							end
						else
							if  UnitPower("player") > 37 then
								return HERORIC_STRIKE
							end						
						end	
					end

				end
			
			end
		end
	end

	-- AOE
	
	-- AOE > 1 and AOE < 4 

	if incombat and self:InMelee() and self:CanAE2() then

		if self:IsUsableSpell(WHIRLWIND, 1, 1) and self:IsUsableSpell(SWEEPING_STRIKES, 1, 1) then
			return WHIRLWIND
		end

		if self:IsUsableSpell(SWEEPING_STRIKES, 1, 1) and UnitPower("player") > 40 then
			return SWEEPING_STRIKES
		end

		if self:PlayerBuff("横扫攻击") then
			-- body
			if self:CanAOEEexecute() and self:IsUsableSpell(EXECUTE, 1, 1) then
				return EXECUTE
			end
	
			-- return BLOODTHIRST
			-- return BLOODTHIRST,CLEAVE
			-- return CLEAVE
			-- return WHIRLWIND,CLEAVE
			-- return WHIRLWIND

			if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
				if IsCurrentSpell(25231) then
					if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
						return BLOODTHIRST
					end
				else

					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
							return BLOODTHIRST,CLEAVE

						elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 30 then 
							return BLOODTHIRST
						end
					else
						if  UnitPower("player") > 50 then
							return BLOODTHIRST,CLEAVE
						elseif  UnitPower("player") > 30 then
							return BLOODTHIRST
						end						
					end	
				end
			else --嗜血不可用
				if IsCurrentSpell(25231)then
					if btCD > 2 then
						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							return WHIRLWIND
						end
					else

						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							if self:isAggressive() then
								if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
									return WHIRLWIND
								end
							else
								if  UnitPower("player") > 75 then
									return WHIRLWIND
								end						
							end	
							
						end					
					end
					
				else --顺劈没在队列
					if btCD > 2 then
						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							if self:isAggressive() then
								if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
									return WHIRLWIND,CLEAVE
		
								elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 20 then 
									return CLEAVE
								end
							else
								if  UnitPower("player") > 45 then
									return WHIRLWIND,CLEAVE
								elseif  UnitPower("player") > 20 then
									return CLEAVE
								end						
							end	
							
						else
							if self:IsUsableSpell(CLEAVE, 1, 1) then
								return CLEAVE
							end
						end
					else --嗜血＜2秒 但是没好

						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							if self:isAggressive() then
								if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
									return WHIRLWIND,CLEAVE
		
								elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then 
									return CLEAVE
								end
							else
								if  UnitPower("player") > 75 then
									return WHIRLWIND,CLEAVE
								elseif  UnitPower("player") > 50 then
									return CLEAVE
								end						
							end	
							
						else
							if self:isAggressive() then
								if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
									return CLEAVE
								end
							else
								if  UnitPower("player") > 50 then
									return CLEAVE
								end						
							end	
						end		
					end


				end
			end	-- body

		else
				-- 没有横扫 但是还是aoe
					-- 旋风斩》顺劈》嗜血
			if not self:IsUsableSpell(SWEEPING_STRIKES, 1) then
			-- return BLOODTHIRST
			-- return BLOODTHIRST,CLEAVE
			-- return CLEAVE
			-- return WHIRLWIND,CLEAVE
			-- return WHIRLWIND

				if self:IsUsableSpell(WHIRLWIND, 1, 1) then
					if IsCurrentSpell(25231) then
						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							return WHIRLWIND
						end
					else

						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
								return WHIRLWIND,CLEAVE

							elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 25 then 
								return WHIRLWIND
							end
						else
							if  UnitPower("player") > 45 then
								return WHIRLWIND,CLEAVE
							elseif  UnitPower("player") > 25 then
								return WHIRLWIND
							end						
						end	
					end
				else --旋风不可用
					if IsCurrentSpell(25231)then
						if windCD > 2 then
							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								return BLOODTHIRST
							end
						else

							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
										return BLOODTHIRST
									end
								else
									if  UnitPower("player") > 75 then
										return BLOODTHIRST
									end						
								end	
								
							end					
						end
						
					else --顺劈没在队列
						if windCD > 2 then
							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
										return BLOODTHIRST,CLEAVE
			
									elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 20 then 
										return CLEAVE
									end
								else
									if  UnitPower("player") > 50 then
										return BLOODTHIRST,CLEAVE
									elseif  UnitPower("player") > 20 then
										return CLEAVE
									end						
								end	
								
							else
								if self:IsUsableSpell(CLEAVE, 1, 1) then
									return CLEAVE
								end
							end
						else --旋风＜2秒 但是没好

							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
										return BLOODTHIRST,CLEAVE
			
									elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then 
										return CLEAVE
									end
								else
									if  UnitPower("player") > 75 then
										return BLOODTHIRST,CLEAVE
									elseif  UnitPower("player") > 45 then
										return CLEAVE
									end						
								end	
								
							else
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
										return CLEAVE
									end
								else
									if  UnitPower("player") > 45 then
										return CLEAVE
									end						
								end	
							end		
						end


					end
				end	-- body				
			end
		end
	end

	-- AOE > 4 

	if incombat and self:InMelee() and self:CanAE4() then

		if self:IsUsableSpell(WHIRLWIND, 1, 1) and self:IsUsableSpell(SWEEPING_STRIKES, 1, 1) then
			return WHIRLWIND
		end

		if self:IsUsableSpell(SWEEPING_STRIKES, 1, 1) and UnitPower("player") > 50 then
			return SWEEPING_STRIKES
		end

		if self:PlayerBuff("横扫攻击") then
			-- body
			-- 顺劈＞旋风斩＞嗜血

			-- return CLEAVE
			-- return WHIRLWIND,CLEAVE
			-- return BLOODTHIRST,CLEAVE

			if  IsCurrentSpell(25231)  then
				if self:IsUsableSpell(WHIRLWIND, 1) then
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
							return WHIRLWIND
						end
					else
						if  UnitPower("player") > 45 then
							return WHIRLWIND
						end						
					end	

				else
					if self:IsUsableSpell(BLOODTHIRST, 1) then
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
								return BLOODTHIRST
							end
						else
							if  UnitPower("player") > 50 then
								return BLOODTHIRST
							end						
						end	
					end
				end
			else --顺劈不在队列
				if self:IsUsableSpell(WHIRLWIND, 1) then
					if self:isAggressive() then
						if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
							return WHIRLWIND,CLEAVE

						elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 20 then 
							return CLEAVE
						end
					else
						if  UnitPower("player") > 45 then
							return WHIRLWIND,CLEAVE
						elseif  UnitPower("player") > 20 then
							return CLEAVE
						end						
					end	

				else
					if self:IsUsableSpell(BLOODTHIRST, 1) then
						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
								return BLOODTHIRST,CLEAVE
	
							elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 20 then 
								return CLEAVE
							end
						else
							if  UnitPower("player") > 50 then
								return BLOODTHIRST,CLEAVE
							elseif  UnitPower("player") > 20 then
								return CLEAVE
							end						
						end	
					else
						return CLEAVE
					end
				end		
			end
			
		else
			if not self:IsUsableSpell(SWEEPING_STRIKES, 1) then
				if self:IsUsableSpell(WHIRLWIND, 1, 1) then
					if IsCurrentSpell(25231) then
						if self:IsUsableSpell(WHIRLWIND, 1, 1) then
							return WHIRLWIND
						end
					else

						if self:isAggressive() then
							if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
								return WHIRLWIND,CLEAVE

							elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 25 then 
								return WHIRLWIND
							end
						else
							if  UnitPower("player") > 45 then
								return WHIRLWIND,CLEAVE
							elseif  UnitPower("player") > 25 then
								return WHIRLWIND
							end						
						end	
					end
				else --旋风不可用
					if IsCurrentSpell(25231)then
						if windCD > 2 then
							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								return BLOODTHIRST
							end
						else

							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
										return BLOODTHIRST
									end
								else
									if  UnitPower("player") > 75 then
										return BLOODTHIRST
									end						
								end	
								
							end					
						end
						
					else --顺劈没在队列
						if windCD > 2 then
							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 50 then
										return BLOODTHIRST,CLEAVE
			
									elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 20 then 
										return CLEAVE
									end
								else
									if  UnitPower("player") > 50 then
										return BLOODTHIRST,CLEAVE
									elseif  UnitPower("player") > 20 then
										return CLEAVE
									end						
								end	
								
							else
								if self:IsUsableSpell(CLEAVE, 1, 1) then
									return CLEAVE
								end
							end
						else --旋风＜2秒 但是没好

							if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 75 then
										return BLOODTHIRST,CLEAVE
			
									elseif (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then 
										return CLEAVE
									end
								else
									if  UnitPower("player") > 75 then
										return BLOODTHIRST,CLEAVE
									elseif  UnitPower("player") > 45 then
										return CLEAVE
									end						
								end	
								
							else
								if self:isAggressive() then
									if  (UnitPower("player") + self:nextOffhandExpectRange()) > 45 then
										return CLEAVE
									end
								else
									if  UnitPower("player") > 45 then
										return CLEAVE
									end						
								end	
							end		
						end


					end
				end	--
			end	
		end
	end
end

function module:TwoHandFury()
	local istt = UnitIsUnit("targettarget", "player")
	local hp = self:UnitHealthPercent("target")
	local ihp = self:UnitHealthPercent("player")
	local chargeCD = self:GetSpellCooldown(CHARGE)
	local btCD = self:GetSpellCooldown(BLOODTHIRST)
	local wwCD = self:GetSpellCooldown(WHIRLWIND)
	local base, posBuff, negBuff = UnitAttackPower("player")
	local playerAP = base + posBuff + negBuff;

	--UnitIsTapped("target") and not UnitIsTappedByPlayer("target")

	if not incombat and GetShapeshiftFormID() ~= 17 and UnitPower("player") < 26 and chargeCD < 1 then
		return BATTLE_STANCE
	end

	-- if self:Canop() and UnitPower("player") < 26 and UnitPower("player") > 4 and GetShapeshiftFormID() ~= 17 then
	-- 	return BATTLE_STANCE
	-- end

	if self:IsUsableSpell(OVERPOWER, 1, 1) then
		return OVERPOWER
	end

	-- if incombat and UnitPower("player") < 26 and GetShapeshiftFormID() ~= 19 and not self:Canop() then
	-- 	return BERSERKER_STANCE
	-- end

	if self:PlayerBuffTime(BATTLE_SHOUT) < 3 then
		return BATTLE_SHOUT
	end

	if self:IsUsableSpell(WHIRLWIND, 1, 1) and self:CanAE() and self:InMelee() and UnitName("target") ~= ("维克尼拉斯大帝") then
		return WHIRLWIND
	end

	-- if self:IsUsableSpell(EXECUTE, 1, 1) then
	-- 	return EXECUTE
	-- end

	if self:IsUsableSpell(BLOODTHIRST, 1, 1) and playerAP > 1200 then
		return BLOODTHIRST
	end

	if self:IsUsableSpell(CLEAVE, 1, 1) and UnitPower("player") > 25 and self:CanAE() and self:InMelee() and wwCD > 0.1 and not IsCurrentSpell(20569) and UnitInRaid("player") and UnitName("target") ~= ("维克尼拉斯大帝") then
		return CLEAVE
	end

	if self:IsUsableSpell(WHIRLWIND, 1, 1) and self:InMelee() and UnitName("target") ~= ("维克尼拉斯大帝") and UnitName("target") ~= ("克苏恩") then
		return WHIRLWIND
	end

	if self:IsUsableSpell(BLOODTHIRST, 1, 1) then
		return BLOODTHIRST
	end

	if UnitPower("player") > 38 and self:CanSlam() and not istt and self:InMelee() and UnitName("target") ~= ("熔岩奔腾者" or "堕落的瓦拉斯塔兹") and (hp > 30 or self:IsStrongTarget()) then
		return SLAM
	end

	if UnitPower("player") > 25 and self:CanSlam() and self:InMelee() and GetShapeshiftFormID() == 17 and btCD > 0.5 and UnitName("target") ~= ("堕落的瓦拉斯塔兹") then
		return SLAM
	end
--[[
	if self:IsUsableSpell(DEATH_WISH, 1, 1) and self:InMelee() and not istt then
		return DEATH_WISH
	end
]]--
	if self:IsUsableSpell(BERSERKER_RAGE) and incombat and istt then
		return BERSERKER_RAGE
	end

	if self:IsUsableSpell(BLOODRAGE) and UnitPower("player") < 30 and ihp > 55 and incombat then
		return BLOODRAGE
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and UnitPower("player") > 84 then
		return UnitName("target") == ("堕落的瓦拉斯塔兹") and CLEAVE or HERORIC_STRIKE
	end

	if self:IsUsableSpell(BERSERKER_RAGE) and incombat and UnitName("target") ~= ("奥妮克希亚") and UnitName("target") ~= ("玛格曼达") and UnitName("target") ~= ("奈法利安") and UnitName("target") ~= ("古拉巴什狂暴者") and UnitName("target") ~= ("格拉斯") and self:InMelee() then
		return BERSERKER_RAGE
	end
end

function module:FuryTank()
	local istt = UnitIsUnit("targettarget", "player")
	local hp = self:UnitHealthPercent("target")
	local chargeCD = self:GetSpellCooldown(CHARGE)

	if self:PlayerBuff("保护祝福") or self:PlayerBuff("拯救祝福") or self:PlayerBuff(QIANGXIAOZHENGJIUZHUFU) then
		return JIJIU
	end

	if not incombat and GetShapeshiftFormID() ~= 17 and UnitPower("player") < 26 and chargeCD < 1 then
		return BATTLE_STANCE
	end

	if self:PlayerBuff(BERSERKER_RAGE) and GetShapeshiftFormID() ~= 18 then
		return DEFENSIVE_STANCE
	end

	if self:IsUsableSpell(CLEAVE, 1) and UnitPower("player") > 60 and self:CanAE() and not IsCurrentSpell(20569) and UnitName("target") ~= ("维克尼拉斯大帝") then
		return CLEAVE
	end

	-- if hp < 20 and UnitName("target") == ("堕落的瓦拉斯塔兹") and GetShapeshiftFormID() == 17 then
	-- 	return EXECUTE
	-- end

	-- if self:IsUsableSpell(EXECUTE, 1, 1) then
	-- 	return EXECUTE
	-- end

	if incombat and UnitPower("player") < 26 and GetShapeshiftFormID() ~= 18 then
		return DEFENSIVE_STANCE
	end

	if self:IsUsableSpell(BLOODTHIRST, 1) and UnitPower("player") > 49 then
		return BLOODTHIRST
	end

	if self:IsUsableSpell(REVENGE, 1) then
		return REVENGE
	end

	if self:IsUsableSpell(BLOODTHIRST, 1, 1) and GetShapeshiftFormID() == 17 then
		return BLOODTHIRST
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1) and UnitPower("player") > 60 and not IsCurrentSpell(11567) then
		return HERORIC_STRIKE
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1) and not IsCurrentSpell(11567) and self:TargetDebuffStack(SUNDER_ARMOR) > 4 then
		return HERORIC_STRIKE
	end

	if self:TargetDebuffTime(SUNDER_ARMOR) < 3 or self:TargetDebuffStack(SUNDER_ARMOR) < 5 then
		return SUNDER_ARMOR
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1) and not IsCurrentSpell(11567) then
		return HERORIC_STRIKE
	end

	if UnitPower("player") > 65 then
		return SUNDER_ARMOR
	end
end

function module:ChaoFeng()
	local istt = UnitIsUnit("targettarget", "player")
	local hp = self:UnitHealthPercent("target")
	local chaofengCD = self:GetSpellCooldown(TAUNT)
	local chengjietongjiCD = self:GetSpellCooldown(CONCUSSION_BLOW)
	local tiaozhannuhouCD = self:GetSpellCooldown(CHALLENGING_SHOUT)

	if self:IsUsableSpell(TAUNT, 1, 1) and not (self:TargetDebuff(TAUNT) or self:TargetDebuff(CONCUSSION_BLOW) or self:TargetDebuff(CHALLENGING_SHOUT)) and not istt then --古拉巴什狂暴者
		return TAUNT
	end

	if GetShapeshiftFormID() ~= 17 and chengjietongjiCD < 1 and chaofengCD > 1 then
		return BATTLE_STANCE
	end

	if self:IsUsableSpell(CONCUSSION_BLOW, 1, 1) and chaofengCD > 1 and not (self:TargetDebuff(TAUNT) or self:TargetDebuff(CONCUSSION_BLOW) or self:TargetDebuff(CHALLENGING_SHOUT)) and not istt then
		return CONCUSSION_BLOW
	end

	if GetShapeshiftFormID() ~= 18 and chengjietongjiCD > 1 and hp > 20 then
		return DEFENSIVE_STANCE
	end

	if self:IsUsableSpell(CHALLENGING_SHOUT, 1, 1) and chaofengCD > 1 and chengjietongjiCD > 1 and not (self:TargetDebuff(TAUNT) or self:TargetDebuff(CONCUSSION_BLOW) or self:TargetDebuff(CHALLENGING_SHOUT)) and not istt then
		return CHALLENGING_SHOUT
	end

	return spec == 2 and self:FuryTank() or self:ProtectionProc()
end

function module:ProtectionProc()
	local chargeCD = self:GetSpellCooldown(CHARGE)

	if self:PlayerBuff("保护祝福") or self:PlayerBuff("拯救祝福") or self:PlayerBuff(QIANGXIAOZHENGJIUZHUFU) then
		return JIJIU
	end

	if not incombat and GetShapeshiftFormID() ~= 17 and UnitPower("player") < 26 and chargeCD < 1 then
		return BATTLE_STANCE
	end

	if self:PlayerBuff(BERSERKER_RAGE) and GetShapeshiftFormID() ~= 18 then
		return DEFENSIVE_STANCE
	end

	if self:IsUsableSpell(CLEAVE, 1) and UnitPower("player") > 60 and self:CanAE() and not IsCurrentSpell(20569) and UnitName("target") ~= ("维克尼拉斯大帝") then
		return CLEAVE
	end

	-- if self:IsUsableSpell(EXECUTE, 1, 1) then
	-- 	return EXECUTE
	-- end

	-- if incombat and UnitPower("player") < 26 and GetShapeshiftFormID() ~= 18 then
	-- 	return DEFENSIVE_STANCE
	-- end

	if self:IsUsableSpell(SHIELD_SLAM, 1) and UnitPower("player") > 45 then
		return SHIELD_SLAM
	end

	if self:IsUsableSpell(REVENGE, 1) then
		return REVENGE
	end

	if self:IsUsableSpell(SHIELD_SLAM, 1) then
		return SHIELD_SLAM
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1) and UnitPower("player") > 60 and not IsCurrentSpell(11567) then
		return HERORIC_STRIKE
	end

	if self:TargetDebuffTime(SUNDER_ARMOR) < 3 or self:TargetDebuffStack(SUNDER_ARMOR) < 5 then
		return SUNDER_ARMOR
	end

	if self:IsUsableSpell(HERORIC_STRIKE, 1) and not IsCurrentSpell(11567) then
		return HERORIC_STRIKE
	end

	if UnitPower("player") > 65 then
		return SUNDER_ARMOR
	end
end

function module:pvpwarrior()

	-- if self:IsUsableSpell(HERORIC_STRIKE, 1, 1) and UnitPower("player") > 90 then
	-- 	return HERORIC_STRIKE
	-- end
	
	-- if self:Canop() and UnitPower("player") < 26 and UnitPower("player") > 4 and GetShapeshiftFormID() ~= 17 then
	-- 	return BATTLE_STANCE
	-- end

	-- --压制可用，施放压制
	-- if self:IsUsableSpell(OVERPOWER) then
	-- 	return OVERPOWER
	-- end

-- --如果不在战斗状态，且在战斗姿态，施放冲锋
-- 	if not incombat and self:IsUsableSpell(CHARGE) then
-- 		return CHARGE
-- 	end

-- 致残毒药 3421
--没有断筋debuff则施放断筋
	local leftime, _ = self:UnitAuraTime("target", HAMSTRING, true)
	if  leftime < 3 and not self:TargetDebuff(cripplingpPoison) and self:IsUsableSpell(HAMSTRING, 1, 1) and UnitPower("player") > 7 then            
		return HAMSTRING
	end

	if not self:TargetDebuff(HAMSTRING) and not self:TargetDebuff(cripplingpPoison) and self:IsUsableSpell(HAMSTRING, 1, 1) and UnitPower("player") > 7 then            
		return HAMSTRING
	end

--触发乘胜追击优先使用乘胜追击  
	if self:IsUsableSpell(VICTORY_RUSH) then
		return VICTORY_RUSH
	end  

--没有致死debuff且怒气>29,则施放致死打击	
	if not self:TargetDebuff(zhisidaji) and UnitPower("player") > 29 then
		return zhisidaji
	end	


-- --有致死debuff，斩杀可用，怒气>13，施放斩杀	
-- 	if self:TargetDebuff(zhisidaji) and self:IsUsableSpell(EXECUTE) and UnitPower("player") > 13 then
-- 		return EXECUTE
-- 	end

-- --有致死debuff，致死打击可用，怒气>29，施放致死打击		
-- 	if self:TargetDebuff(zhisidaji) and self:IsUsableSpell(zhisidaji, 1) and UnitPower("player") > 29 then
-- 		return zhisidaji
-- 	end	



-- --有致死debuff，旋风斩可用，怒气>25，施放旋风斩
-- 	if self:TargetDebuff(zhisidaji) and self:IsUsableSpell(WHIRLWIND) and UnitPower("player") > 25 then
-- 		return WHIRLWIND
-- 	end	

-- --有致死debuff，没有破甲debuff，怒气>15，使用破甲攻击
-- 	if self:TargetDebuff(zhisidaji) and self:TargetDebuffStack(SUNDER_ARMOR) < 3 and UnitPower("player") > 15 then            
-- 		return SUNDER_ARMOR
-- 	end	
end

function module:OnSpellRequest(spec, strongTarget)
	if self:IsUsableSpell(CHARGE, 1, 1, 1) then
		return CHARGE
	end
	if dpswarriorhs and not dpswarrioraoe then
		return self:FuryHS()
	end
	if dpswarriorchaofeng then
		return self:ChaoFeng()
	end
	if pvpwarrior then
		return self:pvpwarrior()
	end
	if dpswarriortank then
		return self:FuryTank()
	elseif spec == 1 then
		return self:ArmsProc()
	elseif spec == 2 then
		if self:IsDualWield() then
			local OffHandLink = GetInventoryItemLink("player", 17)
			local OffHandType = select(7, GetItemInfo(OffHandLink))
			if OffHandType == "盾牌" then
				return self:FuryTank()
			else
				return self:FuryProc()
			end
		else
			return self:TwoHandFury()
		end
	elseif spec == 3 then
		return self:ProtectionProc()
	end
end

SLASH_DPSWARRIOR1 = "/dpswarrior"
SLASH_DPSWARRIOR2 = "/warr"
SlashCmdList["DPSWARRIOR"] = function(msg)
	local command = string.lower(msg)
	if (command == "ae") then
		if dpswarrioraoe then
			dpswarrioraoe = nil
			print("solo solo solo")
		else
			dpswarrioraoe = 1
			print("open AE mode.")
		end
	elseif (command == "hs") then
		if dpswarriorhs then
			dpswarriorhs = nil
			print("恢复常用输出循环")
		else
			dpswarriorhs = 1
			print("开启极限英勇模式")
		end
	elseif (command == "tank") then
		if dpswarriortank then
			dpswarriortank = nil
			print("取消强制狂暴双持坦克")
		else
			dpswarriortank = 1
			print("开启强制狂暴双持坦克模式")
		end
	elseif (command == "chaofeng") then
		if dpswarriorchaofeng then
			dpswarriorchaofeng = nil
			print("关闭嘲讽模式，恢复常用坦克循环")
		else
			dpswarriorchaofeng = 1
			print("开启嘲讽模式，保证目标为自己。")
		end
	elseif (command == "pvp") then
		if pvpwarrior then
			pvpwarrior = nil
			print("关闭嘲讽模式，恢复常用坦克循环")
		else
			pvpwarrior = 1
			print("pvp开始。")
		end	
	elseif (command == "") then
		print("请使用参数ae开关AE模式，使用参数hs开关极限英勇模式，使用参数chaofeng开关坦克嘲讽模式，使用参数tank开关狂暴双持坦克模式。")
	end
end
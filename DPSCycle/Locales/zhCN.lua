if GetLocale() ~= "zhCN" then return end
local _, addon = ...

addon.L = {
	["title"] = "DPS Cycle",
	["sub title"] = "DPS输出循环技能提示",
	["module sub title"] = "%sDPS输出循环提示",
	["scale"] = "缩放",
	["alpha"] = "透明度",
	["lock"] = "锁定框体位置",
	["mouseover prompt"] = "拖拽左键移动，点击右键或输入 |cff00ff00/dps|r 进行设置。",
	["command prompt"] = "输入 |cff00ff00/dps|r 或 |cff00ff00/dps module|r 进行设置。",
	["hide text"] = "隐藏法术名称",
	["spell button"] = "技能按钮",
	["cooldown buttons"] = "冷却按钮",
	["GUI settings"] = "GUI设置:",
	["hide cooldown buttons"] = "隐藏冷却按钮",
	["spell filters"] = "技能提示过滤:",
	["don't use spells"] = "请等待提示...",
	["spell cooldown monitor"] = "技能冷却监视:",
	["display info"] = "信息显示:",
	["misc"] = "其它:",
	["enable"] = "启用%s",
	["disable"] = "禁用%s",
	["keep"] = "保持%s",
	["don't keep"] = "不保持%s",
	["suggest"] = "提示%s",
	["don't suggest"] = "不提示%s",
	["check"] = "检查%s",
	["don't check"] = "不检查%s",
	["display"] = "显示%s",
	["don't display"] = "不显示%s",
	["gained"] = "获得: %s！",
	["lost"] = "失去: %s！",
	["hide castbar"] = "隐藏施法条",
}
------------------------------------------------------------
-- OptionFrame.lua
--
-- Abin
-- 2009-6-18
------------------------------------------------------------

local type = type
local select = select
local UnitClass = UnitClass
local UnitName = UnitName
local pairs = pairs

local addonName, addon = ...
local L = addon.L

-- GUI options

local frame = UICreateInterfaceOptionPage("DPSCycleOptionPage", L["title"], L["sub title"])
addon.optionPage = frame
frame.title:SetText(L["title"].." "..addon.version)

local modulePageId = 0
function addon:CreateModuleOptionPage(title, desc)
	modulePageId = modulePageId + 1
	return UICreateInterfaceOptionPage("DPSCycleModuleOptionPage"..modulePageId, title, desc, L["title"])
end

local function HideShowRegion(region, hide)
	if hide then
		region:Hide()
	else
		region:Show()
	end
end

local group = frame:CreateMultiSelectionGroup(L["GUI settings"])
frame:AnchorToTopLeft(group)
group:AddButton(L["lock"], "lock")
group:AddButton(L["hide text"], "hideText")
group:AddButton(L["hide cooldown buttons"], "hideCooldown")
group:AddButton(L["hide castbar"], "hideCastbar")

group.OnCheckInit = function(self, value) return addon.db[value] end
group.OnCheckChanged = function(self, value, checked)
	addon.db[value] = checked
	if value == "lock" then
		HideShowRegion(addon.moverFrame, checked)
	elseif value == "hideText" then
		HideShowRegion(addon.iconFrame.spellText, checked)
		addon.castBarParent:UpdatePosition()
	elseif value == "hideCooldown" then
		HideShowRegion(addon.cooldownPanel, checked)
	elseif value == "hideCastbar" then
		HideShowRegion(addon.castBarParent, checked)
	end
end

local function DPSCycleOptionPage_CreateSlider(key, minVal, maxVal, func)
	local slider = frame:CreateSlider(L[key], minVal, maxVal, 5, "%d%%")
	slider.func = func
	slider:SetWidth(220)
	slider:SetHeight(15)

	slider.OnSliderChanged = function(self, value)
		addon.db[key] = value
		addon.frame[self.func](addon.frame, value / 100)
	end

	return slider
end

local scaleSlider = DPSCycleOptionPage_CreateSlider("scale", 50, 250, "SetScale")
scaleSlider:SetPoint("TOPLEFT", group[-1], "BOTTOMLEFT", 12, -30)

local alphaSlider = DPSCycleOptionPage_CreateSlider("alpha", 0, 100, "SetAlpha")
alphaSlider:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -40)

function frame:default()
	scaleSlider:SetValue(100)
	alphaSlider:SetValue(100)
	addon.frame:ClearAllPoints()
	addon.frame:SetPoint("CENTER")
end

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then

		if type(DPSCycleDB) ~= "table" then
			DPSCycleDB = {}
		end
		addon.db = DPSCycleDB

		if type(DPSCycleCharDB) ~= "table" then
			DPSCycleCharDB = {}
		end
		addon.chardb = DPSCycleCharDB

		scaleSlider:SetValue(addon.db.scale or 100)
		alphaSlider:SetValue(addon.db.alpha or 100)

		if addon.db.lock then
			addon.moverFrame:Hide()
		end

		if addon.db.hideText then
			addon.iconFrame.spellText:Hide()
		end

		if not addon.db.hideCooldown then
			addon.cooldownPanel:Show()
		end

		if addon.db.hideCastbar then
			addon.castBarParent:Hide()
		end
		addon.castBarParent:UpdatePosition()

		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..L["title"].." "..addon.version.."|r by Abin loaded.")
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff78"..L["title"]..":|r "..L["command prompt"])
	end
end)

------------------------------------------------------------
-- ButtonFacade(Masque) support
------------------------------------------------------------

local bfs = CreateButtonFacadeSupport(L["title"], "DPSCycleDB")
if bfs then
	bfs:AddGroup(L["spell button"], "DPSCycleIconFrame", 3)
	bfs:AddGroup(L["cooldown buttons"], addon.cooldownPanel:GetName().."Button", addon.templates.MAX_COOLDOWN_BUTTONS)
end

------------------------------------------------------------
-- Slash command handler: "/dpscycle"
------------------------------------------------------------

SLASH_DPSCYCLE1 = "/dps"
SLASH_DPSCYCLE2 = "/dpscycle"
SlashCmdList["DPSCYCLE"] = function(cmd)
	frame:Open()
end
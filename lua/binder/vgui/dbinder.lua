local CONFIG = {
	Title = "Configuration des Touches",
	TitleFont = "Syncopate:20",
	LabelFont = "Syncopate:14",
	ButtonFont = "Syncopate:12",
	Bindings = {
		{Label = "Attaque - Légère", ConVar = "g_key_atk_left", Default = MOUSE_LEFT},
		{Label = "Attaque - Capacité", ConVar = "g_key_atk_right", Default = MOUSE_RIGHT},
		{Label = "Protection", ConVar = "g_key_shield", Default = KEY_E},
		{Label = "Esquive", ConVar = "g_key_dash", Default = KEY_R},
		{Label = "Ultime", ConVar = "g_key_ult", Default = KEY_Q},
		{Label = "1e - 3e Personne", ConVar = "g_key_calcview", Default = KEY_F1},
		{Label = "Mode Combat", ConVar = "g_key_deploy", Default = KEY_H},
		{Label = "Radio - Parler", ConVar = "g_key_radio_talk", Default = KEY_F},
		{Label = "Radio - Muet", ConVar = "g_key_radio_mute", Default = KEY_G},
		{Label = "Inventaire - Menu", ConVar = "g_key_inventory", Default = KEY_I},
		{Label = "Escouade - Menu", ConVar = "g_key_squad", Default = KEY_J},
		{Label = "Faction - Menu", ConVar = "g_key_faction", Default = KEY_P}
	}
}

local PANEL = {}

function PANEL:Init()
	self:SetTitle("")
	self:SetDraggable(true)
	self:ShowCloseButton(false)
	self:gSetSize(500, 700)
	self:Center()
	self:MakePopup()

	self:gCreateConVars()
	self:SetupUI()
	self:SetAlpha(0)
	self:gFadeIn(0.4)

	self:RegisterResolutionChangeCallback()
end

function PANEL:RegisterResolutionChangeCallback()
	self.hookID = "BinderMenu_OnScreenSizeChanged_" .. tostring(self)

	self.OnScreenSizeChangedHook = function()
		if IsValid(self) then
			self:RefreshLayout()
		else
			hook.Remove("OnScreenSizeChanged", self.hookID)
		end
	end

	hook.Add("OnScreenSizeChanged", self.hookID, self.OnScreenSizeChangedHook)
end

function PANEL:RefreshLayout()
	self:gSetSize(500, 700)
	self:Center()

	if IsValid(self.closeButton) then
		self.closeButton:gSetSize(30, 30)
		self.closeButton:gSetPos(460, 10)
	end

	if IsValid(self.containerPanel) then
		self.containerPanel:gSetPos(15, 55)
		self.containerPanel:gSetSize(470, 575)
	end

	if IsValid(self.resetButton) then
		self.resetButton:gSetSize(250, 35)
		self.resetButton:gSetPos(125, 650)
	end

	if IsValid(self.scroll) and IsValid(self.scroll:GetVBar()) then
		self.scroll:GetVBar():SetWide(gRespX(5))
	end

	self:RebuildBindingList()
end

function PANEL:gCreateConVars()
	for _, binding in ipairs(CONFIG.Bindings) do
		if not ConVarExists(binding.ConVar) then
			CreateClientConVar(binding.ConVar, binding.Default, true, false)
		end
	end
end

function PANEL:RebuildBindingList()
	if IsValid(self.scroll) then
		self.scroll:Clear()

		local yPos = 10
		for i, binding in ipairs(CONFIG.Bindings) do
			local panel = vgui.Create("DPanel", self.scroll)
			panel:gSetPos(10, yPos)
			panel:gSetSize(450, 50)
			panel.Paint = function(self, w, h)
				draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 150))

				if self:IsHovered() then
					draw.RoundedBox(8, 0, 0, w, h, Color(70, 70, 70, 30))
				end

				draw.SimpleText(binding.Label, CONFIG.LabelFont, gRespX(15), h/2 + gRespY(1), Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			local binder = vgui.Create("DBinder", panel)
			binder:gSetPos(245, 5)
			binder:gSetSize(200, 40)
			binder:SetValue(GetConVar(binding.ConVar):GetInt())
			binder:SetFont(CONFIG.LabelFont)
			binder:SetTextColor(Color(255, 255, 255))
			binder.isWaitingForKey = false
			binder.Paint = function(self, w, h)
				if self:IsHovered() or self.isWaitingForKey then
					draw.RoundedBox(8, 0, 0, w, h, Color(180, 50, 50, 150))
				else
					draw.RoundedBox(8, 0, 0, w, h, Color(60, 60, 60, 150))
				end

				if not self.originalText or self:GetText() ~= self.originalText then
					self.originalText = self:GetText()
				end
			end

			local oldOnMousePressed = binder.OnMousePressed
			binder.OnMousePressed = function(self, code)
				self.isWaitingForKey = true
				if oldOnMousePressed then
					oldOnMousePressed(self, code)
				end
			end
			binder.OnChange = function(self, key)
				self.isWaitingForKey = false
				RunConsoleCommand(binding.ConVar, key)
				surface.PlaySound("ui/buttonclick.wav")
			end

			yPos = yPos + 50 + 10
		end
	end
end

function PANEL:SetupUI()
	self.closeButton = vgui.Create("DButton", self)
	self.closeButton:gSetSize(30, 30)
	self.closeButton:gSetPos(460, 10)
	self.closeButton:SetText("")
	self.closeButton:SetFont(CONFIG.ButtonFont)
	self.closeButton:SetTextColor(Color(255, 255, 255))
	self.closeButton.Paint = function(self, w, h)
		if self:IsHovered() then
			draw.RoundedBox(8, 0, 0, w, h, Color(200, 50, 50, 150))
		else
			draw.RoundedBox(8, 0, 0, w, h, Color(150, 40, 40, 100))
		end
		draw.SimpleText("✕", CONFIG.ButtonFont, w/2, h/2, Color(255, 255, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.closeButton.DoClick = function()
		self:gFadeOut(0.3, 0, function()
			self:Remove()
		end)
	end

	self.containerPanel = vgui.Create("DPanel", self)
	self.containerPanel:gSetPos(15, 55)
	self.containerPanel:gSetSize(470, 575)
	self.containerPanel.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 100))
	end

	self.scroll = vgui.Create("DScrollPanel", self.containerPanel)
	self.scroll:Dock(FILL)

	local scrollBar = self.scroll:GetVBar()
	scrollBar:SetWide(gRespX(5))
	scrollBar.Paint = function(self, w, h) 
		draw.RoundedBox(8, 0, 0, w, h, Color(60, 60, 60, 100))
	end
	scrollBar.btnUp.Paint = function(self, w, h) end
	scrollBar.btnDown.Paint = function(self, w, h) end
	scrollBar.btnGrip.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(120, 120, 120, 150))
	end

	self:RebuildBindingList()

	self.resetButton = vgui.Create("DButton", self)
	self.resetButton:gSetSize(250, 35)
	self.resetButton:gSetPos(125, 650)
	self.resetButton:SetText("")
	self.resetButton:SetFont(CONFIG.ButtonFont)
	self.resetButton:SetTextColor(Color(220, 220, 220))
	self.resetButton.Paint = function(self, w, h)
		if self:IsHovered() then
			draw.RoundedBox(8, 0, 0, w, h, Color(80, 100, 120, 180))
		else
			draw.RoundedBox(8, 0, 0, w, h, Color(60, 80, 100, 150))
		end
		draw.SimpleText("Réinitialiser", CONFIG.ButtonFont, w/2, h/2, Color(220, 220, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.resetButton.DoClick = function()
		for _, binding in ipairs(CONFIG.Bindings) do
			RunConsoleCommand(binding.ConVar, binding.Default)
		end
		surface.PlaySound("ui/buttonclickrelease.wav")
		self:RebuildBindingList()
	end
end

function PANEL:OnRemove()
	if self.hookID then
		hook.Remove("OnScreenSizeChanged", self.hookID)
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 180))
	draw.RoundedBox(8, gRespX(1), gRespY(1), w-gRespX(2), h-gRespY(2), Color(30, 30, 30, 180))
	draw.SimpleText(CONFIG.Title, CONFIG.TitleFont, w/2, gRespY(25), Color(255, 255, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("gBinderMenu", PANEL, "DFrame")

function gCreateConVars()
	for _, binding in ipairs(CONFIG.Bindings) do
		if not ConVarExists(binding.ConVar) then
			CreateClientConVar(binding.ConVar, binding.Default, true, false)
		end
	end
end

function gOpenBinderMenu()
	if IsValid(GPYMOUSSS.Binder) then
		GPYMOUSSS.Binder:Remove()
	end

	if gui.IsGameUIVisible() then
		gui.HideGameUI()
	end

	gCreateConVars()

	GPYMOUSSS.Binder = vgui.Create("gBinderMenu")
end

function gToggleBinderMenu()
	if IsValid(GPYMOUSSS.Binder) then
		GPYMOUSSS.Binder:gFadeOut(0.3, 0, function()
			GPYMOUSSS.Binder:Remove()
		end)
	else
		gOpenBinderMenu()
	end
end

concommand.Add("gpym_bindings", function()
	gToggleBinderMenu()
end)

gCreateConVars()
local PANEL = {}

function PANEL:Init()
	if PS_ColorPanel and PS_ColorPanel:IsValid() then
		PS_ColorPanel:Remove()
	end
	
	self:SetTitle("PointShop Color Chooser")
	self:SetSize(300, 300)
	
	self:SetBackgroundBlur(true)
	self:SetDrawOnTop(true)
	
	self.colorpicker = vgui.Create('DColorMixer', self)
	--colorpicker:DockMargin(0, 0, 0, 60)
	self.colorpicker:Dock(FILL)
	
	local done = vgui.Create('UPS_DSWButton', self)
	done:DockMargin(0, 5, 0, 0)
	done:Dock(BOTTOM)
	
	done:SetTexts('Done')
	
	done.DoClick = function()
		self.OnChoose(self.colorpicker:GetColor())
		self:Close()
	end
	
	self:Center()
	self:Show()
	self:MakePopup()
	
	PS_ColorPanel = self
end

function PANEL:OnChoose(color)
	-- nothing, gets over-ridden
end

function PANEL:Paint()
	surface.SetDrawColor(UPS_Config.Col.CC.Main_OutLine)
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	
	surface.SetDrawColor(UPS_Config.BGCol.CC_Canvas)
	surface.DrawRect(1,1,self:GetWide()-2,self:GetTall()-2)
	
end

function PANEL:SetColor(color)
	self.colorpicker:SetColor(color or Color(255, 255, 255, 255))
end

vgui.Register('DPointShopColorChooser', PANEL, 'DFrame')

if CLIENT then
	UPS_IntroPanelInstalled = UPS_IntroPanelInstalled or false
	function UPS_CreateIntroPanel(mother)
		if UPS_IntroPanelInstalled then return end
		local INTRO = vgui.Create("UPS_Intro",mother)
		INTRO:SetPos(0,0)
		INTRO:SetSize(mother:GetSize())
		UPS_IntroPanelInstalled = UPS_Config.ShowIntroOnly1Time
	end

	local PANEL = {}
	function PANEL:Init()
		self.CreatedTime = CurTime()
	end

	function PANEL:Think()
		if (CurTime() - self.CreatedTime) > 2.5 then
			self:Remove()
		end
	end
	
	function PANEL:Paint()
		local DeltaTime = CurTime() - self.CreatedTime
		
		if DeltaTime <= 1.5 then
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0,0,0,255))
			local XX,YY = self:GetWide()/2 , self:GetTall()/2
			draw.SimpleText("Ultimate", 'RXF_Treb_S40', XX+230, YY-40, Color(0,255,255,(1.5-DeltaTime)*255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
			draw.SimpleText("PointShop", 'RXF_Treb_TitlePS', XX, YY, Color(0,150,255,(1.5-DeltaTime)*255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.SimpleText("Created By _Undefined", 'RXF_Treb_S40', XX, YY+50, Color(150,220,255,(1.5-DeltaTime)*255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.SimpleText("ReSkined By RocketMania", 'RXF_Treb_S40', XX, YY+100, Color(150,220,255,(1.5-DeltaTime)*255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
		elseif DeltaTime <= 2.5 then
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(0,0,0,(2.5-DeltaTime)*255))
		end
		
		
		
		

	end
	vgui.Register("UPS_Intro",PANEL,"DPanel")
end -- if CLIENT then end
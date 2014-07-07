local meta = FindMetaTable("Panel")

function meta:UPS_PanelAnim_Appear_FlyIn(data)
	local DelayValue = (data.Delay or 0)
	local Delay = CurTime() + DelayValue	
	local Dir = data.Dir or "FromLeft"
	local Speed = data.Speed or 1 -- 1초 후 애니메이션 끝.
	local StartTime = CurTime() + DelayValue
	local Smoother = data.Smooth or 1
	local Fade = data.Fade or false
		
	local OldThink = self.Think or function() end
	if Dir == "FromLeft" then
		---SETTINGS
		self.PA = {}
			local PX,PY = self:GetPos()
			self.PA.Pos = {x=PX,y=PY}
		---SETTINGS
		
		self:SetPos(0-self:GetWide(),PY)
		local SP = 0-self:GetWide()
		function self:Think()
			OldThink(self)
			
			local DeltaTime = math.min(Speed,CurTime() - StartTime)
			if DeltaTime > 0 then
				local DeltaSpeed = (math.pow(DeltaTime/Speed,1/Smoother))
				self:SetPos(SP+(PX+self:GetWide())*DeltaSpeed,PY)
				if Fade then self:SetAlpha(DeltaSpeed*(255+Fade)-Fade) end
				if DeltaTime >= Speed then
					function self:Think()
						OldThink(self)
					end
					return
				end
			end
		end
	elseif Dir == "FromRight" then
		---SETTINGS
		self.PA = {}
			local PX,PY = self:GetPos()
			self.PA.Pos = {x=PX,y=PY}
		---SETTINGS
	
		self:SetPos(ScrW(),PY)
		function self:Think()
			OldThink(self)
			
			local DeltaTime = math.min(Speed,CurTime() - StartTime)
			if DeltaTime > 0 then
				local DeltaSpeed = (math.pow(DeltaTime/Speed,1/Smoother))
				self:SetPos(ScrW() - ( ScrW()-PX)*DeltaSpeed,PY)
				if Fade then self:SetAlpha(DeltaSpeed*(255+Fade)-Fade) end
				if DeltaTime >= Speed then
					function self:Think()
						OldThink(self)
					end
					return
				end
			end
		end
	elseif Dir == "FromTop" then
		---SETTINGS
		self.PA = {}
			local PX,PY = self:GetPos()
			self.PA.Pos = {x=PX,y=PY}
		---SETTINGS
	
		self:SetPos(PX,0 - self:GetTall())
		function self:Think()
			OldThink(self)
			
			local DeltaTime = math.min(Speed,CurTime() - StartTime)
			if DeltaTime > 0 then
				local DeltaSpeed = (math.pow(DeltaTime/Speed,1/Smoother))
				self:SetPos(PX,PY*DeltaSpeed)
				if Fade then self:SetAlpha(DeltaSpeed*(255+Fade)-Fade) end
				if DeltaTime >= Speed then
					function self:Think()
						OldThink(self)
					end
					return
				end
			end
		end
	elseif Dir == "FromBottom" then
		---SETTINGS
		self.PA = {}
			local PX,PY = self:GetPos()
			self.PA.Pos = {x=PX,y=PY}
		---SETTINGS
	
		self:SetPos(PX,ScrH() + self:GetTall())
		function self:Think()
			OldThink(self)
			
			local DeltaTime = math.min(Speed,CurTime() - StartTime)
			if DeltaTime > 0 then
				local DeltaSpeed = (math.pow(DeltaTime/Speed,1/Smoother))
				self:SetPos(PX,ScrH()-(ScrH()-PY)*DeltaSpeed)
				if Fade then self:SetAlpha(DeltaSpeed*(255+Fade)-Fade) end
				if DeltaTime >= Speed then
					function self:Think()
						OldThink(self)
					end
					return
				end
			end
		end
	end
	
end
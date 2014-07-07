local meta = FindMetaTable("Panel")



function meta:UPS_PanelAnim_Fade(data)
	local Speed = (data.Speed or 1) -- 1초 후 애니메이션 끝.
	local StartTime = CurTime() + (data.Delay or 0)
	local Fade = (data.Fade or false)
		
	local OldThink = self.Think or function() end
		
		if self.SetDisabled then self:SetDisabled(true) end
		local SP = 0-self:GetWide()
		function self:Think()
			OldThink(self)
			
			local DeltaTime = math.min(Speed,CurTime() - StartTime)
			if DeltaTime > 0 then
				if self.SetDisabled then self:SetDisabled(false) end
				local DeltaSpeed = (math.pow(DeltaTime/Speed,1))
				if Fade then self:SetAlpha(DeltaSpeed*(255+Fade)-Fade) end
				if DeltaTime >= Speed then
					function self:Think()
						OldThink(self)
					end
					return
				end
			else
				self:SetAlpha(0)
			end
		end

end
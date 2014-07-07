local PANEL = {}

local CirMat = Material("particle/Particle_Ring_Wave_Additive")

function PANEL:Init()
	self:SetModel(LocalPlayer():GetModel())
	
	self.Zoom = 100
	self.MinZoom = 40
	self.MaxZoom = 200
	
	
	self.Height = 40
	self.MinHeight = 20
	self.MaxHeight = 80
	
	self.CamPos = Vector(self.Zoom,0,self.Height)
	self.ViewPos = Vector(0,0,self.Height)
	
	self.CamAngle = (self.ViewPos - self.CamPos):Angle()
	self:SetAnimated(false)
	
	self.RingBurstDelay = CurTime()
	self.RingBurstCount = 0
	self.ZoomTime = CurTime()
	self.RingBurst = {}
	self:BurstRing()
	
	self.ZoomTime = CurTime() + 0.3
	self.CamUpTime = CurTime() + 0.3
end

function PANEL:OnCursorEntered()
	self.Hovering = true
end

function PANEL:OnCursorExited()
	self.Hovering = false
end

function PANEL:OnMouseWheeled(mc)
	self.ZoomHere = self.ZoomHere or self.Zoom
	
	self.ZoomHere = self.ZoomHere - mc *10
	self.ZoomHere = math.min(self.ZoomHere,self.MaxZoom)
	self.ZoomHere = math.max(self.ZoomHere,self.MinZoom)

	self.ZoomTime = CurTime() + 0.6
end

function PANEL:Think()
	if self.RingBurstDelay < CurTime() then
		if self.RingBurstCount == 0 then
			self.RingBurstDelay = CurTime() + 0.4
			self.RingBurstCount = 1
			self:BurstRing()
		elseif self.RingBurstCount == 1 then
			self.RingBurstDelay = CurTime() + 3
			self.RingBurstCount = 0
			self:BurstRing()
		end
	end
	
	-- ZOOM LERP
	self.ZoomHere = self.ZoomHere or self.Zoom
	self.Zoom = Lerp(FrameTime()*10,self.Zoom,self.ZoomHere)
	
	
	if !self.Hovering then return end
	
		if input.IsMouseDown(MOUSE_LEFT) then
			if !self.LM then
				self.LM = true
				local MX,MY = gui.MousePos()
				self.LastMousePos_X = MX
				self.LastMousePos_Y = MY
			else
				local CX,CY = gui.MousePos()
				local DX,DY = self.LastMousePos_X-CX,self.LastMousePos_Y-CY
				
				if DY > 0.01 then
					self.CamUpTime = CurTime() + 0.6
				end
				
				self.CamAngle.y = self.CamAngle.y - DX/150
				
				self.Height = self.Height - DY/30
				self.Height = math.min(self.Height,self.MaxHeight)
				self.Height = math.max(self.Height,self.MinHeight)
	
				self.CamPos = Vector(self.Zoom,0,self.Height)
				self.ViewPos = Vector(0,0,self.Height)
				
				self.LastMousePos_X = CX
				self.LastMousePos_Y = CY
				
			end
		else
			if self.LM then
				self.LM = false
			end
		end
end

function PANEL:BurstRing()
	local DB = {}
	DB.Speed = 50
	DB.LifeTime = 2
	DB.StartSize = 10
	DB.EndSize = 500
	DB.CreatedTime = CurTime()
	
	table.insert(self.RingBurst,DB)
end

function PANEL:Paint()

	self.CamPos = Vector(math.sin(self.CamAngle.y)*self.Zoom,math.cos(self.CamAngle.y)*self.Zoom,self.Height)
	if ( !IsValid( self.Entity ) ) then return end

	surface.SetDrawColor( UPS_Config.BGCol.Preview )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local w, h = self:GetSize()
	cam.Start3D( self.CamPos, (self.ViewPos - self.CamPos):Angle(), self.fFOV, x, y, w, h, 5, 4096 )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( math.min(self:GetAlpha()/255,self.colColor.a/255) )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end
	self.Entity:DrawModel()

	self:DrawOtherModels()
	
	-- RING
		render.SetMaterial( CirMat )
		-- Basic Ring
					render.DrawQuadEasy( Vector(0,0,0),
						Vector(0.1,0,90),
						70,70,
						UPS_Config.Col.PV.FootRing,
						CurTime()*60 
					)
					
		-- Ring Burst
		for k,v in pairs(self.RingBurst) do
			local DeltaTime = CurTime() - v.CreatedTime
			local DeltaPercent = DeltaTime/v.LifeTime
			local DeltaPercentREV = 1-DeltaPercent
			
			if DeltaPercent <= 1 then
				local Col = UPS_Config.Col.PV.BurstRing
				local Size = v.StartSize + (DeltaPercent*(v.EndSize-v.StartSize))
					render.DrawQuadEasy( Vector(0,0,0),
						Vector(0.1,0,90),
						Size,Size,
						Color(Col.r,Col.g,Col.b,DeltaPercentREV*255),
						0 
					)
			else
				self.RingBurst[k] = nil
			end
		end
				


	
	render.SetBlend(1)
	render.SuppressEngineLighting( false )
	cam.End3D()
	
	self.LastPaint = RealTime()
	

		local AnimationLerp = FrameTime()
		AnimationLerp = AnimationLerp * 5
		-- ZOOM
			local Col1 = UPS_Config.Col.PV.Zoom
			local Col2 = UPS_Config.Col.PV.ZoomBar
			self.ZoomAlpha = self.ZoomAlpha or 0
			if self.ZoomTime and self.ZoomTime > CurTime() then
				self.ZoomAlpha = Lerp(AnimationLerp,self.ZoomAlpha,255)
			else
				self.ZoomAlpha = Lerp(AnimationLerp,self.ZoomAlpha,0)
			end
			
			if self.ZoomAlpha > 0 then
				draw.SimpleText("Zoom", "RXF_TrebOut_S20", self:GetWide()-60,self:GetTall()/2-140, Color(Col2.r,Col2.g,Col2.b,self.ZoomAlpha),TEXT_ALIGN_CENTER)
				surface.SetDrawColor( Color(Col1.r,Col1.g,Col1.b,self.ZoomAlpha*0.4) )
				surface.DrawRect( self:GetWide()-60, self:GetTall()/2-120, 1, 240 )
				
				local Percent = (self.Zoom - self.MinZoom) / (self.MaxZoom - self.MinZoom)
				local PosY = self:GetTall()/2-120 + Percent*230
				
				surface.SetDrawColor( Color(Col2.r,Col2.g,Col2.b,self.ZoomAlpha*0.8) )
				surface.DrawRect( self:GetWide()-70, PosY, 20, 10 )
			end
		-- Height
			local Col1 = UPS_Config.Col.PV.Height
			local Col2 = UPS_Config.Col.PV.HeightBar
			self.CamUpAlpha = self.CamUpAlpha or 0
			if self.CamUpTime and self.CamUpTime > CurTime() then
				self.CamUpAlpha = Lerp(AnimationLerp,self.CamUpAlpha,255)
			else
				self.CamUpAlpha = Lerp(AnimationLerp,self.CamUpAlpha,0)
			end
			
			if self.CamUpAlpha > 0 then
				draw.SimpleText("Cam Up", "RXF_TrebOut_S20", self:GetWide()-130,self:GetTall()/2-140, Color(Col2.r,Col2.g,Col2.b,self.CamUpAlpha),TEXT_ALIGN_CENTER)
				surface.SetDrawColor( Color(Col1.r,Col1.g,Col1.b,self.CamUpAlpha*0.4) )
				surface.DrawRect( self:GetWide()-130, self:GetTall()/2-120, 1, 240 )
				
				local Percent = (self.Height - self.MinHeight) / (self.MaxHeight - self.MinHeight)
				local PosY = self:GetTall()/2-120 + Percent*230
				
				surface.SetDrawColor( Color(Col2.r,Col2.g,Col2.b,self.CamUpAlpha*0.8) )
				surface.DrawRect( self:GetWide()-140, PosY, 20, 10 )
			end
		
end



function PANEL:DrawOtherModels()
	local ply = LocalPlayer()
	
	if PS.ClientsideModels[ply] then
		for item_id, model in pairs(PS.ClientsideModels[ply]) do
			local ITEM = PS.Items[item_id]
			
			if not ITEM.Attachment and not ITEM.Bone then PS.ClientsideModel[ply][item_id] = nil continue end
			
			local pos = Vector()
			local ang = Angle()
			
			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)
				if not attach_id then return end
				
				local attach = self.Entity:GetAttachment(attach_id)
				
				if not attach then return end
				
				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)
				if not bone_id then return end
				
				pos, ang = self.Entity:GetBonePosition(bone_id)
			end
			
			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
			
			model:SetPos(pos)
			model:SetAngles(ang)
			
			model:DrawModel()
		end
	end
	
	if PS.HoverModel then
		local ITEM = PS.Items[PS.HoverModel]
		
		if ITEM.NoPreview then return end -- don't show
		if ITEM.WeaponClass then return end -- hack for weapons
		
		if not ITEM.Attachment and not ITEM.Bone then -- must be a playermodel?
			self:SetModel(ITEM.Model)
		else
			local model = PS.HoverModelClientsideModel
			
			local pos = Vector()
			local ang = Angle()
			
			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)
				if not attach_id then return end
				
				local attach = self.Entity:GetAttachment(attach_id)
				
				if not attach then return end
				
				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)
				if not bone_id then return end
				
				pos, ang = self.Entity:GetBonePosition(bone_id)
			end
			
			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
			
			model:SetPos(pos)
			model:SetAngles(ang)
			
			model:DrawModel()
		end
	else
		self:SetModel(LocalPlayer():GetModel())
	end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')

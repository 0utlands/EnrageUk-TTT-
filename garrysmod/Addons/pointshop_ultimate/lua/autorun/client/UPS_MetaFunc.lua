-- RocketMania's
local Fonts = {}
	Fonts["RXF_CoolV"] = "coolvetica"
	Fonts["RXF_Treb"] = "Trebuchet MS"
	
	
for a,b in pairs(Fonts) do
	for k=10,100 do
		surface.CreateFont( a .. "_S"..k,{font = b,size = k,weight = 700})
		surface.CreateFont( a .. "Out_S"..k,{font = b,size = k,weight = 700,outline = true})
	end
	
	surface.CreateFont( "RXF_Treb_TitlePS",{font = "Trebuchet MS",size = 200,weight = 700,outline = true})
end

local meta = FindMetaTable("Panel")
function meta:UPS_DrawBoarder(width,col)
	width = width or 1
	col = col or UPS_Config.Col.MN.SCBarOutLine
	
	surface.SetDrawColor( col )
	surface.DrawRect( 0, 0, self:GetWide(), width )
	surface.DrawRect( 0, self:GetTall()-width, self:GetWide(), width )
	surface.DrawRect( 0, 0, width, self:GetTall() )
	surface.DrawRect( self:GetWide()-width, 0, width, self:GetTall() )
end
function meta:UPS_PaintListBarC(bCol,iCol)
	local bCol = bCol or UPS_Config.Col.MN.SCBarOutLine
	local iCol = iCol or Color(0,0,0,255)
	
	self.VBar.btnDown.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.btnUp.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.btnGrip.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.Paint = function(selfk)
	end
end
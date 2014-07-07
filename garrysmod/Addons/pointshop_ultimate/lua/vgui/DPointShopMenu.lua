surface.CreateFont('PS_Heading', { font = 'coolvetica', size = 64 })
surface.CreateFont('PS_Heading2', { font = 'coolvetica', size = 24 })
surface.CreateFont('PS_Heading3', { font = 'coolvetica', size = 19 })

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3

hook.Add("PS_ItemAdjusted","PS_Item_Adjusted",function()
	if PS.ShopMenu and PS.ShopMenu:IsValid() then
		PS.ShopMenu:UpdateMyInventory(nil,false)
		PS.ShopMenu:UpdateCurrentShopList(nil,false)
	end
end)

local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:PS_GetItems()
	
	for category_id, CATEGORY in pairs(PS.Categories) do
		
		local catmenu = menu:AddSubMenu(CATEGORY.Name)
		
		table.SortByMember(PS.Items, PS.Config.SortItemsBy, function(a, b) return a > b end)
		
		for item_id, ITEM in pairs(PS.Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end

local PANEL = {}

function PANEL:UpdateMyInventory(FilterName,Fade)
	if self.INVList and self.INVList:IsValid() then
		self.INVList:UpdateList(FilterName,Fade)
	end
end

function PANEL:UpdateCurrentShopList(Name)
	if self.SHOPList and self.SHOPList:IsValid() then
		self.SHOPList:UpdateList(FilterName,Fade)
	end
end

function PANEL:ReBulidCanvas()
	if self.Canvas then
		self.Canvas:Remove()
	end
	self.Canvas = vgui.Create("DPanel",self)
	self.Canvas:SetPos(0,self.TopBar:GetTall())
	self.Canvas:SetSize(self:GetWide(),self:GetTall() - self.TopBar:GetTall())
	self.Canvas.Paint = function(slf)
		if slf.BGCol then
			surface.SetDrawColor(slf.BGCol)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		end
	end
	function self.Canvas:SetBGCol(color)
		self.BGCol = color
	end
	return self.Canvas
end


function PANEL:Init()
local MotherPanel = self
	self:SetSize( ScrW() * UPS_Config.Size[1],ScrH() * UPS_Config.Size[2] )
	self:Center()
	
	self.TopBar = vgui.Create("DPanel",self)
	self.TopBar:SetSize(self:GetWide(),80)
	self.TopBar:SetPos(0,0)
	self.TopBar.Paint = function(slf)
		surface.SetDrawColor( UPS_Config.BGCol.MainTitle )
		surface.DrawRect(0, 0, slf:GetWide(), slf:GetTall())
		surface.SetDrawColor( UPS_Config.Col.MN.ButtomLine )
		surface.DrawRect(0, slf:GetTall()-1, slf:GetWide(), 1)
		draw.SimpleText("Ultimate", 'RXF_Treb_S25', 230, 7, UPS_Config.Col.MN.UlimateText)
		draw.SimpleText("PointShop", 'RXF_Treb_S80', 20, 2, UPS_Config.Col.MN.PointShopText)
		
		draw.SimpleText("Created by _Undefined", 'RXF_Treb_S20', 350, 30, UPS_Config.Col.MN.Creators)
		draw.SimpleText("Reskined by RocketMania", 'RXF_Treb_S20', 350, 50,UPS_Config.Col.MN.Creators)
	end

		local Button = vgui.Create("UPS_DSWButton",self.TopBar)
		Button:SetSize(120,39)
		Button:SetPos(self.TopBar:GetWide()-250,self.TopBar:GetTall()-40)
		Button.BoarderCol = Color(0,0,0,0)
		Button:SetTexts("Give "..PS.Config.PointsName)
		Button.Font = "RXF_Treb_S20"
		Button.Click = function(slf)
			vgui.Create('DPointShopGivePoints')
		end
		
		local Button = vgui.Create("UPS_DSWButton",self.TopBar)
		Button:SetSize(120,39)
		Button:SetPos(self.TopBar:GetWide()-120,self.TopBar:GetTall()-40)
		Button.BoarderCol = Color(0,0,0,0)
		Button:SetTexts("Close")
		Button.Font = "RXF_Treb_S20"
		Button.Click = function(slf)
			PS:ToggleMenu()
		end
		
		
	
	self:ReBulidCanvas()
	self:CanvasBuild_Main()
	
	UPS_CreateIntroPanel(self)
end

function PANEL:Think()
	if self.ClientsList and self.ClientsList:IsValid() then
		local lines = self.ClientsList:GetLines()
		
		for _, ply in pairs(player.GetAll()) do
			local found = false
			
			for _, line in pairs(lines) do
				if line.Player == ply then
					found = true
				end
			end
			
			if not found then
				self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
			end
		end
		
		for i, line in pairs(lines) do
			if IsValid(line.Player) then
				local ply = line.Player
				
				line:SetValue(1, ply:GetName())
				line:SetValue(2, ply:PS_GetPoints())
				line:SetValue(3, table.Count(ply:PS_GetItems()))
			else
				self.ClientsList:RemoveLine(i)
			end
		end
	end
end

function PANEL:Paint()
	surface.SetDrawColor( 0,0,0,255 )
	surface.DrawRect(0, 0, ScrW(), ScrH())
end


function PANEL:CanvasBuild_Main()
	local Canvas = self:ReBulidCanvas()
	
	-- Menu Buttons 
	local BTNs = {}
	table.insert(BTNs,{
		PrintName = "Shop",
		Func = function(Main)
			self:CanvasBuild_Shop()
		end
	})
	table.insert(BTNs,{
		PrintName = "My Inventory",
		Func = function()
			self:CanvasBuild_Inventory()
		end
	})
	
	if ((PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin())) then
	table.insert(BTNs,{
		PrintName = "Admin Panel",
		Func = function()
			self:CanvasBuild_Admin()
		end
	})
	end
		
	table.insert(BTNs,{
		PrintName = "Close Pointshop",
		Func = function(Main)
			PS:ToggleMenu()
		end
	})
	
	-- preview panel
	if PS.Config.DisplayPreviewInMenu then
		local previewpanel = vgui.Create('DPointShopPreview', Canvas)
		previewpanel:SetSize(Canvas:GetWide(),Canvas:GetTall())
		previewpanel:SetPos(0,0)
		previewpanel.ZoomHere = 150
	end
	
	for k,v in pairs(BTNs) do
		local Button = vgui.Create("UPS_DSWButton",Canvas)
		Button:SetSize(Canvas:GetWide()/4,Canvas:GetWide()/15)
		Button:SetPos(50,50 + (k-1)*(Canvas:GetWide()/15+10))
		Button:SetTexts(v.PrintName)
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			v:Func(self)
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromLeft",Speed=0.8,Fade=500,Smooth=10,Delay = k/10})
	end
end

function PANEL:UpdateFilterList()
	if !self.FilterLister or !self.FilterLister:IsValid() then return end
	
	self.FilterLister:Clear()
	local ListerPanel = self.FilterLister
	
			-- sorting
			local categories = {}
			for _, i in pairs(PS.Categories) do
				table.insert(categories, i)
			end
			table.sort(categories, function(a, b) 
				if a.Order == b.Order then 
					return a.Name < b.Name
				else
					return a.Order < b.Order
				end
			end)
			local items = {}
			for _, i in pairs(PS.Items) do
				table.insert(items, i)
			end
			table.SortByMember(items, "Name", function(a, b) return a > b end)
	
					for _, CATEGORY in pairs(categories) do
						if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
							if not table.HasValue(CATEGORY.AllowedUserGroups, LocalPlayer():PS_GetUsergroup()) then
								continue
							end
						end
						
						if CATEGORY.CanPlayerSee then
							if not CATEGORY:CanPlayerSee(LocalPlayer()) then
								continue
							end
						end
						
						local Button = vgui.Create("UPS_DSWButton")
						Button:SetSize(self.FilterLister:GetWide()/2-5,40)
						Button:SetTexts(CATEGORY.Name) -- 'icon16/' .. CATEGORY.Icon .. '.png'
						Button.Font = "RXF_Treb_S20"
						Button:SetToolTip(CATEGORY.Name)
						Button.BoarderCol = Color(0,0,0,0)
						Button.Click = function(slf)
							ListerPanel.CurCategory = CATEGORY.Name
							if ListerPanel.OnFilterSelected then
								ListerPanel:OnFilterSelected(CATEGORY.Name)
							end
						end
						Button.PaintBackGround = function(slf)
							if ListerPanel.CurCategory and ListerPanel.CurCategory == CATEGORY.Name then
								local COL = UPS_Config.Col.MN.DSWClickFX
								COL.a = 50
								surface.SetDrawColor( COL )
								surface.DrawRect(1, 1, slf:GetWide()-2, slf:GetTall()-2)
							end
						end
						self.FilterLister:AddItem(Button)
					end
end

function PANEL:CanvasBuild_Admin()
	local Canvas = self:ReBulidCanvas()
		Canvas:SetBGCol(UPS_Config.BGCol.AP_CanvasBG)

		local Title = vgui.Create("DPanel",Canvas)
		Title:SetPos(20,5)
		Title:SetSize(Canvas:GetWide() -40,40)
		Title.Paint = function(slf)
			draw.SimpleText("Player Management Panel", 'RXF_Treb_S30', slf:GetWide()/2, 10, UPS_Config.Col.AP.TitleText,TEXT_ALIGN_CENTER)
		end
	
		local Button = vgui.Create("UPS_DSWButton",Title)
		Button:SetSize(250,30)
		Button:SetPos(Title:GetWide()-260,10)
		Button:SetTexts("Goto Main")
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			self:CanvasBuild_Main()
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=0.8,Fade=500,Smooth=10,Delay = 0.5})
		

		local FilterTitle = vgui.Create("DPanel",Canvas)
		FilterTitle:SetPos(50,60)
		FilterTitle:SetSize(Canvas:GetWide()-100,30)
		FilterTitle.Paint = function(slf)
		
		end
		
			local PlayerClick = function() end -- Precache
			local PlayerList = vgui.Create("DPanelList", Canvas) -- Precache
		
				local Button = vgui.Create("UPS_DSWButton",FilterTitle)
				Button:SetSize(100,30)
				Button:SetPos(0,0)
				Button:SetTexts("No.")
				Button.Font = "RXF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Num")
				end
			
				local Button = vgui.Create("UPS_DSWButton",FilterTitle)
				Button:SetSize(300,30)
				Button:SetPos(FilterTitle:GetWide()/5*2-150,0)
				Button:SetTexts("Nick Name")
				Button.Font = "RXF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Nick")
				end
			
				local Button = vgui.Create("UPS_DSWButton",FilterTitle)
				Button:SetSize(100,30)
				Button:SetPos(FilterTitle:GetWide()-200,0)
				Button:SetTexts("Points")
				Button.Font = "RXF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Points")
				end
			
				local Button = vgui.Create("UPS_DSWButton",FilterTitle)
				Button:SetSize(100,30)
				Button:SetPos(FilterTitle:GetWide()-100,0)
				Button:SetTexts("Items")
				Button.Font = "RXF_Treb_S25"
				Button.BoarderCol = Color(0,0,0,0)
				Button.Click = function(slf)
					PlayerList:ReBuild("Items")
				end
			
				
		

			PlayerList:SetPos(50,90);
			PlayerList:SetSize(Canvas:GetWide()-100, Canvas:GetTall()-120);
			PlayerList:SetSpacing(0);
			PlayerList:SetPadding(0);
			PlayerList:EnableVerticalScrollbar(true);
			PlayerList:EnableHorizontal(true);
			PlayerList:UPS_PaintListBarC()
			PlayerList.Paint = function(slf) --
			end
			local Dir = true
			
			PlayerList.ReBuild = function(slf,Order)
				local LIST = {}
				for k,v in pairs(player.GetAll()) do
					local TB2Insert = {}
					TB2Insert.Num = k
					TB2Insert.Points = v:PS_GetPoints()
					TB2Insert.Items = table.Count(v:PS_GetItems())
					TB2Insert.Nick = v:Nick()
					TB2Insert.Ply = v
					table.insert(LIST,TB2Insert)
				end
				slf:Clear()
				
				slf.Order = slf.Order or Order
				
				if Order == slf.Order then
					if !Dir then 
						Dir = true 
					else 
						Dir = false 
					end
				end
				slf.Order = Order
				
				if Dir then
					table.SortByMember(LIST, Order)
				else
					table.SortByMember(LIST, Order, function(a, b) return a < b end)
				end
				
				for k,DB in pairs(LIST) do
							local BGP = vgui.Create("UPS_DSWButton")
							BGP:SetSize(PlayerList:GetWide(), 30)
							BGP:SetTexts("")
							BGP.BoarderCol = Color(0,0,0,0)
							BGP.Count = k%2
							BGP.Click = function(slf)
								PlayerClick(DB.Ply)
							end
							BGP.Think = function(slf)
								if !DB.Ply or !DB.Ply:IsValid() then
									slf:Remove()
								end
							end
							BGP.PaintOverlay = function(slf)
								draw.SimpleText("No." .. DB.Num, 'RXF_Treb_S22', 10, 2, UPS_Config.Col.AP.List_No)
								draw.SimpleText(DB.Ply:Nick(), 'RXF_Treb_S22', slf:GetWide()/5*2, 2, UPS_Config.Col.AP.List_PlayerNick,TEXT_ALIGN_CENTER)
								draw.SimpleText(DB.Ply:PS_GetPoints(), 'RXF_Treb_S22', slf:GetWide()-150, 2, UPS_Config.Col.AP.List_PlayerPoints,TEXT_ALIGN_CENTER)
								draw.SimpleText(table.Count(DB.Ply:PS_GetItems()), 'RXF_Treb_S22', slf:GetWide()-50, 2, UPS_Config.Col.AP.List_PlayerItems,TEXT_ALIGN_CENTER)
							end
							BGP.PaintBackGround = function(slf)
								surface.SetDrawColor( Color(0,10,slf.Count*10+10,120) )
								surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
								
								surface.SetDrawColor( UPS_Config.Col.AP.List_ButtomLine )
								surface.DrawRect( 1, slf:GetTall()-1, slf:GetWide()-2, 1 )
							end
							BGP:UPS_PanelAnim_Fade({Speed=0.5,Fade=100,Delay=k/50})
						PlayerList:AddItem(BGP)
				end
				
			end
		
			PlayerList:ReBuild("Num")


		PlayerClick = function(ply)
			local menu = DermaMenu()
			
			menu:AddOption('Set '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Set "..PS.Config.PointsName.." for " .. ply:GetName(),
					"Set "..PS.Config.PointsName.." to...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_SetPoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Give '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Give "..PS.Config.PointsName.." to " .. ply:GetName(),
					"Give "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_GivePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Take '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Take "..PS.Config.PointsName.." from " .. ply:GetName(),
					"Take "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_TakePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddSpacer()
			
			BuildItemMenu(menu:AddSubMenu('Give Item'), ply, UNOWNED_ITEMS, function(item_id)
				net.Start('PS_GiveItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			BuildItemMenu(menu:AddSubMenu('Take Item'), ply, OWNED_ITEMS, function(item_id)
				net.Start('PS_TakeItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			menu:Open()
		end
end

function PANEL:CanvasBuild_Inventory()
	local Canvas = self:ReBulidCanvas()
	Canvas:SetBGCol(UPS_Config.BGCol.INVCanvasBG)

		local previewpanel = vgui.Create('DPointShopPreview', Canvas)
		previewpanel:SetSize(Canvas:GetWide()/7*4,Canvas:GetTall()-40)
		previewpanel:SetPos(Canvas:GetWide()/7*3,20)
		previewpanel:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=1.2,Fade=500,Smooth=10,Delay=0.2})
	
		local Button = vgui.Create("UPS_DSWButton",Canvas)
		Button:SetSize(Canvas:GetWide()/4,Canvas:GetWide()/16)
		Button:SetPos(Canvas:GetWide()-Button:GetWide()-10,10)
		Button:SetTexts("Goto Main")
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			self:CanvasBuild_Main()
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=0.8,Fade=500,Smooth=10,Delay = 0.5})
		
		local Button = vgui.Create("UPS_DSWButton",Canvas)
		Button:SetSize(Canvas:GetWide()/4,Canvas:GetWide()/16)
		Button:SetPos(Canvas:GetWide()-Button:GetWide()-10,Button:GetTall()+16)
		Button:SetTexts("Goto Shop")
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			self:CanvasBuild_Shop()
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=0.8,Fade=500,Smooth=10,Delay = 0.7})
		
		
		
		local Title = vgui.Create("DPanel",Canvas)
		Title:SetPos(20,5)
		Title:SetSize(Canvas:GetWide()/7*3 -40,40)
		Title.Paint = function(slf)
			surface.SetDrawColor( UPS_Config.BGCol.INVTitleBG )
			surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			
			draw.SimpleText("Inventory", 'RXF_Treb_S30', 30, 10, UPS_Config.Col.INV.INVTitle,TEXT_ALIGN_LEFT)
		end
		
		local LeftMaster = vgui.Create("DPanel",Canvas)
		LeftMaster:SetPos(20,50)
		LeftMaster:SetSize(Canvas:GetWide()/7*3 -40,Canvas:GetTall()-60)
		LeftMaster:UPS_PanelAnim_Appear_FlyIn({Dir="FromLeft",Speed=0.8,Fade=500,Smooth=10})
		LeftMaster.Paint = function(slf)
			surface.SetDrawColor( UPS_Config.BGCol.INVLeftCanvasBG )
			surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			
			draw.SimpleText("Filters", 'RXF_Treb_S30', 30, 10, UPS_Config.Col.INV.FilterTitleText,TEXT_ALIGN_LEFT)
			draw.SimpleText("Inventory Items", 'RXF_Treb_S30', 30, 140, UPS_Config.Col.INV.FilterTitleText,TEXT_ALIGN_LEFT)
		end
		
		-- Fliters
			local FilterList = vgui.Create("DPanelList", LeftMaster) self.FilterLister = FilterList
			FilterList:SetPos(10,40);
			FilterList:SetSize(LeftMaster:GetWide()-20, 90);
			FilterList:SetSpacing(0);
			FilterList:SetPadding(0);
			FilterList:EnableVerticalScrollbar(true);
			FilterList:EnableHorizontal(true);
			FilterList:UPS_PaintListBarC()
			FilterList.Paint = function(slf) --
				surface.SetDrawColor( UPS_Config.BGCol.INVFilterLister )
				surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			end
			FilterList.OnFilterSelected = function(slf,FilterName)
				if slf.INVList then
					slf.INVList:UpdateList(FilterName,true)
				end
			end
			self:UpdateFilterList()
			

		-- Item List
			local INVList = vgui.Create("DPanelList", LeftMaster) FilterList.INVList = INVList self.INVList = INVList
			INVList:SetPos(10,170);
			INVList:SetSize(LeftMaster:GetWide()-20, LeftMaster:GetTall()-180);
			INVList:SetSpacing(0);
			INVList:SetPadding(0);
			INVList:EnableVerticalScrollbar(true);
			INVList:EnableHorizontal(false);
			INVList:UPS_PaintListBarC()
			INVList.Paint = function(slf) --
				surface.SetDrawColor( UPS_Config.BGCol.INVItemsLister )
				surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			end
			function INVList:UpdateList(FilterName,Fade)
				self:Clear()
				if FilterName then self.LastFilterName = FilterName end
				FilterName = FilterName or self.LastFilterName
				
				if !FilterName then return end
					local items = {}
					for _, i in pairs(PS.Items) do
						if i.Category == FilterName and LocalPlayer():PS_HasItem(i.ID) then
							table.insert(items, i)
						end
					end
					table.SortByMember(items, "Name", function(a, b) return a > b end)
						
						
					local Count = 0
					for _, ITEM in pairs(items) do
							Count = Count + 1
							
							local Price = PS.Config.CalculateSellPrice(LocalPlayer(), ITEM)
							
							local BGP = vgui.Create("UPS_DSWButton")
							BGP.BoarderCol = Color(0,0,0,0)
							BGP.TextCol = Color(0,0,150,255)
							BGP:SetSize(self:GetWide(), 70)
							BGP:SetTexts("")
							BGP.Count = Count%2
							BGP.FXCol = UPS_Config.Col.INV_LST_ItemHoverCol
							BGP.PaintOverlay = function(slf)
								draw.SimpleText(ITEM.Name, 'RXF_Treb_S30', slf:GetTall()+5, 2, UPS_Config.Col.INV_LST_ItemName)
								draw.SimpleText("Refund : " .. string.Comma(Price), 'RXF_Treb_S25', slf:GetWide()-5, slf:GetTall()-25, UPS_Config.Col.INV_LST_ItemRefund,TEXT_ALIGN_RIGHT)
								if LocalPlayer():PS_HasItemEquipped(ITEM.ID) then
									draw.SimpleText("Equipped", 'RXF_Treb_S25', slf:GetWide()-5, 2, UPS_Config.Col.INV_LST_EquippedText,TEXT_ALIGN_RIGHT)
								end
							end
							BGP.PaintBackGround = function(slf)
								surface.SetDrawColor( Color(0,10,slf.Count*10+10,120) )
								surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
								
								surface.SetDrawColor( UPS_Config.Col.INV_LST_ButtomLine )
								surface.DrawRect( 1, slf:GetTall()-1, slf:GetWide()-2, 1 )
							end
							BGP.CursorEnter = function(slf)
								if slf.Icon then
									slf.Icon:OnCursorEntered()
								end
							end
							BGP.CursorExit = function(slf)
								if slf.Icon then
									slf.Icon:OnCursorExited()
								end
							end
							if Fade then
								BGP:UPS_PanelAnim_Fade({Speed=0.5,Fade=100,Delay=Count/20})
							end
							
							local model = vgui.Create('DPointShopItem',BGP) BGP.Icon = model
							model:SetData(ITEM)
							model:SetPos(1,1)
							model:SetSize(BGP:GetTall()-2, BGP:GetTall()-2)
									
									BGP.Click = function(slf)
										model:DoClick()
									end
									
							self:AddItem(BGP)
					end
			
			end
			
end



function PANEL:CanvasBuild_Shop()
	local Canvas = self:ReBulidCanvas()
	Canvas:SetBGCol(UPS_Config.BGCol.ShopCanvasBG)
	
		local previewpanel = vgui.Create('DPointShopPreview', Canvas)
		previewpanel:SetSize(Canvas:GetWide()/7*4,Canvas:GetTall()-40)
		previewpanel:SetPos(Canvas:GetWide()/7*3,20)
		previewpanel:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=1.2,Fade=500,Smooth=10,Delay=0.2})
	
		local Button = vgui.Create("UPS_DSWButton",Canvas)
		Button:SetSize(Canvas:GetWide()/4,Canvas:GetWide()/16)
		Button:SetPos(Canvas:GetWide()-Button:GetWide()-10,10)
		Button:SetTexts("Goto Main")
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			self:CanvasBuild_Main()
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=0.8,Fade=500,Smooth=10,Delay = 0.5})
		
		local Button = vgui.Create("UPS_DSWButton",Canvas)
		Button:SetSize(Canvas:GetWide()/4,Canvas:GetWide()/16)
		Button:SetPos(Canvas:GetWide()-Button:GetWide()-10,Button:GetTall()+16)
		Button:SetTexts("Goto Inventory")
		Button.Font = "RXF_Treb_S25"
		Button.Click = function(slf)
			self:CanvasBuild_Inventory()
		end
		Button:UPS_PanelAnim_Appear_FlyIn({Dir="FromRight",Speed=0.8,Fade=500,Smooth=10,Delay = 0.7})
		
		
		local Title = vgui.Create("DPanel",Canvas)
		Title:SetPos(20,5)
		Title:SetSize(Canvas:GetWide()/7*3 -40,40)
		Title.Paint = function(slf)
			surface.SetDrawColor( UPS_Config.BGCol.ShopTitleBG )
			surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
								
			draw.SimpleText("Shop", 'RXF_Treb_S30', 30, 10, UPS_Config.Col.SP.ShopTitle,TEXT_ALIGN_LEFT)
			draw.SimpleText("You have " .. LocalPlayer():PS_GetPoints() .. " Points", 'RXF_Treb_S20', slf:GetWide()-10, 20, UPS_Config.Col.SP.MyPoints,TEXT_ALIGN_RIGHT)
		end
		
		local LeftMaster = vgui.Create("DPanel",Canvas)
		LeftMaster:SetPos(20,50)
		LeftMaster:SetSize(Canvas:GetWide()/7*3 -40,Canvas:GetTall()-60)
		LeftMaster:UPS_PanelAnim_Appear_FlyIn({Dir="FromLeft",Speed=0.8,Fade=500,Smooth=10})
		LeftMaster.Paint = function(slf)
			surface.SetDrawColor( UPS_Config.BGCol.ShopLeftCanvasBG )
			surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			
			draw.SimpleText("Filters", 'RXF_Treb_S30', 30, 10, UPS_Config.Col.SP.FilterTitleText,TEXT_ALIGN_LEFT)
			draw.SimpleText("Shop Items", 'RXF_Treb_S30', 30, 140, UPS_Config.Col.SP.FilterTitleText,TEXT_ALIGN_LEFT)
		end
		
		-- Fliters
			local FilterList = vgui.Create("DPanelList", LeftMaster) self.FilterLister = FilterList
			FilterList:SetPos(10,40);
			FilterList:SetSize(LeftMaster:GetWide()-20, 90);
			FilterList:SetSpacing(0);
			FilterList:SetPadding(0);
			FilterList:EnableVerticalScrollbar(true);
			FilterList:EnableHorizontal(true);
			FilterList:UPS_PaintListBarC()
			FilterList.Paint = function(slf) --
				surface.SetDrawColor( UPS_Config.BGCol.ShopFilterLister )
				surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			end
			FilterList.OnFilterSelected = function(slf,FilterName)
				if slf.SHOPList then
					slf.SHOPList:UpdateList(FilterName,true)
				end
			end
			self:UpdateFilterList()
			

		-- Item List
			local SHOPList = vgui.Create("DPanelList", LeftMaster) FilterList.SHOPList = SHOPList self.SHOPList = SHOPList
			SHOPList:SetPos(10,170);
			SHOPList:SetSize(LeftMaster:GetWide()-20, LeftMaster:GetTall()-180);
			SHOPList:SetSpacing(0);
			SHOPList:SetPadding(0);
			SHOPList:EnableVerticalScrollbar(true);
			SHOPList:EnableHorizontal(false);
			SHOPList:UPS_PaintListBarC()
			SHOPList.Paint = function(slf) --
				surface.SetDrawColor( UPS_Config.BGCol.ShopItemsLister )
				surface.DrawRect( 0, 0,slf:GetWide(), slf:GetTall() )
			end
			function SHOPList:UpdateList(FilterName,Fade)
				self:Clear()
				if FilterName then self.LastFilterName = FilterName end
				FilterName = FilterName or self.LastFilterName
				
				if !FilterName then return end
					local items = {}
					for _, i in pairs(PS.Items) do
						if i.Category == FilterName and !LocalPlayer():PS_HasItem(i.ID) then
							table.insert(items, i)
						end
					end
					table.SortByMember(items, "Name", function(a, b) return a > b end)
						
						
					local Count = 0
					for _, ITEM in pairs(items) do
							Count = Count + 1
							
							local Price = PS.Config.CalculateBuyPrice(LocalPlayer(), ITEM)
							
							local BGP = vgui.Create("UPS_DSWButton")
							BGP.BoarderCol = Color(0,0,0,0)
							BGP.TextCol = Color(0,0,150,255)
							BGP:SetSize(self:GetWide(), 70)
							BGP:SetTexts("")
							BGP.Count = Count%2
							BGP.FXCol = UPS_Config.Col.LST_ItemHoverCol
							BGP.PaintOverlay = function(slf)
								draw.SimpleText(ITEM.Name, 'RXF_Treb_S30', slf:GetTall()+5, 2, UPS_Config.Col.LST_ItemName)
								draw.SimpleText("Price : " .. string.Comma(Price), 'RXF_Treb_S25', slf:GetWide()-5, slf:GetTall()-25, UPS_Config.Col.LST_ItemPrice,TEXT_ALIGN_RIGHT)
							end
							BGP.PaintBackGround = function(slf)
								surface.SetDrawColor( Color(0,10,slf.Count*10+10,120) )
								surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
								
								surface.SetDrawColor( UPS_Config.Col.LST_ButtomLine )
								surface.DrawRect( 1, slf:GetTall()-1, slf:GetWide()-2, 1 )
							end
							BGP.CursorEnter = function(slf)
								if slf.Icon then
									slf.Icon:OnCursorEntered()
								end
							end
							BGP.CursorExit = function(slf)
								if slf.Icon then
									slf.Icon:OnCursorExited()
								end
							end
							if Fade then
								BGP:UPS_PanelAnim_Fade({Speed=0.5,Fade=100,Delay=Count/20})
							end
							
							local model = vgui.Create('DPointShopItem',BGP) BGP.Icon = model
							model:SetData(ITEM)
							model:SetPos(1,1)
							model:SetSize(BGP:GetTall()-2, BGP:GetTall()-2)
									
									BGP.Click = function(slf)
										model:DoClick()
									end
									
							self:AddItem(BGP)
					end
			
			end
			
end
vgui.Register('DPointShopMenu', PANEL)

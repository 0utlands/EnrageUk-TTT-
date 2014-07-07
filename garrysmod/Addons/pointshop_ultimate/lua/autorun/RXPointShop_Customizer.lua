UPS_Config = {}

UPS_Config.Size = {1,1} -- x,y
	-- 1 means 100%. so 1,1 makes gui to fit your screen.
	-- 0.5 , 0.5 will make gui to half size of your screen.

UPS_Config.ShowIntroOnly1Time = true
UPS_Config.Col = {}
UPS_Config.BGCol = {}

/* ───────────────────────────────────
	Background Color Part ( Light Black & Deep Black )
─────────────────────────────────── */
	-- Main Title
		UPS_Config.BGCol.MainTitle = Color(40,40,40,255)
		
	-- Preview 
		UPS_Config.BGCol.Preview = Color(10,10,10,255)
		
	-- DSWButtons ( almost every buttons )
		UPS_Config.BGCol.DSWButton = Color(0,0,0,0)

	-- Shop
		UPS_Config.BGCol.ShopCanvasBG = Color(20,20,20,255)
		UPS_Config.BGCol.ShopLeftCanvasBG = Color(30,30,30,255)
		UPS_Config.BGCol.ShopTitleBG = Color(50,50,50,255)
		UPS_Config.BGCol.ShopFilterLister = Color(10,10,10,255)
		UPS_Config.BGCol.ShopItemsLister = Color(10,10,10,255)
		
	-- Inventory
		UPS_Config.BGCol.INVCanvasBG = Color(20,20,20,255)
		UPS_Config.BGCol.INVLeftCanvasBG = Color(30,30,30,255)
		UPS_Config.BGCol.INVTitleBG = Color(50,50,50,255)
		UPS_Config.BGCol.INVFilterLister = Color(10,10,10,255)
		UPS_Config.BGCol.INVItemsLister = Color(10,10,10,255)
		
	-- Admin Panel
		UPS_Config.BGCol.AP_CanvasBG = Color(30,30,30,255)
	
	-- Give Points
		UPS_Config.BGCol.GP_TitleBG = Color(40,40,40,255)
		UPS_Config.BGCol.GP_BodyBG = Color(20,20,20,255)
	
	-- Color Chooser
		UPS_Config.BGCol.CC_Canvas = Color(20,20,20,255)
		
		
/* ───────────────────────────────────
	Color Part ( Blue & Black )
─────────────────────────────────── */

	-- Preview 
		UPS_Config.Col.PV = {}
		
		-- Ring FXs
			UPS_Config.Col.PV.FootRing = Color(0,255,255,255)
			UPS_Config.Col.PV.BurstRing = Color(0,200,255,255)

		-- Information ( Zoom , height )
			UPS_Config.Col.PV.Zoom = Color(0,150,255,255)
			UPS_Config.Col.PV.ZoomBar = Color(0,255,255,255)
			
			UPS_Config.Col.PV.Height = Color(0,150,255,255)
			UPS_Config.Col.PV.HeightBar = Color(0,255,255,255)
		
	-- Item Icon
		UPS_Config.Col.IC = {}
		UPS_Config.Col.IC.BackGround = Color(0,50,255,5)

	-- Main
		UPS_Config.Col.MN = {}
			-- Top Title
			UPS_Config.Col.MN.PointShopText = Color(0,200,255,255)
			UPS_Config.Col.MN.UlimateText = Color(0,255,255,255)
			UPS_Config.Col.MN.Creators = Color(100,150,255,255)
			UPS_Config.Col.MN.ButtomLine = Color(0,150,255,255)
			
			-- DSWButtons ( almost buttons )
			UPS_Config.Col.MN.DSWBoarderCol = Color(0,150,255,255)
			UPS_Config.Col.MN.DSWTextCol = Color(255,255,255,255)
			UPS_Config.Col.MN.DSWClickFX = Color(0,150,255,255)
			
			-- Scroll Bars
			UPS_Config.Col.MN.SCBarOutLine = Color(0,150,255,255)
			
	-- Shop
		UPS_Config.Col.SP = {}
		UPS_Config.Col.SP.ShopTitle = Color(0,255,255,255)
		UPS_Config.Col.SP.MyPoints = Color(100,200,255,255)
		UPS_Config.Col.SP.FilterTitleText = Color(100,200,255,255)
		
		-- Lists
			UPS_Config.Col.LST_ItemName = Color(0,200,255,255)
			UPS_Config.Col.LST_ItemPrice = Color(150,150,255,255)
			UPS_Config.Col.LST_ButtomLine = Color(0,200,255,20)
			UPS_Config.Col.LST_ItemHoverCol = Color(0,50,120,255)
			
	-- Inventory
		UPS_Config.Col.INV = {}
		UPS_Config.Col.INV.INVTitle = Color(0,255,255,255)
		UPS_Config.Col.INV.FilterTitleText = Color(100,200,255,255)
		
		-- Lists
			UPS_Config.Col.INV_LST_ItemName = Color(0,200,255,255)
			UPS_Config.Col.INV_LST_ItemRefund = Color(150,150,255,255)
			UPS_Config.Col.INV_LST_EquippedText = Color(0,255,255,255)
			UPS_Config.Col.INV_LST_ButtomLine = Color(0,200,255,20)
			UPS_Config.Col.INV_LST_ItemHoverCol = Color(0,50,120,255)
	
	-- Admin Panel
		UPS_Config.Col.AP = {}
		UPS_Config.Col.AP.TitleText = Color(0,255,255,255)
		UPS_Config.Col.AP.List_No = Color(0,255,255,255)
		UPS_Config.Col.AP.List_PlayerNick = Color(0,200,255,255)
		UPS_Config.Col.AP.List_PlayerPoints = Color(0,255,255,255)
		UPS_Config.Col.AP.List_PlayerItems = Color(0,255,255,255)
		UPS_Config.Col.AP.List_ButtomLine = Color(0,150,255,50)
	
	-- Point Give Menu
	UPS_Config.Col.PG = {}
	UPS_Config.Col.PG.Main_OutLine = Color(0,150,255,255)
	UPS_Config.Col.PG.Main_TitleText = Color(0,220,255,255)
	
	-- Color Chooser Menu
	UPS_Config.Col.CC = {}
	UPS_Config.Col.CC.Main_OutLine = Color(0,150,255,255)
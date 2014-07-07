if SERVER then return end

function table.HasKey(t,k)
	for o, m in pairs(t)do
		return k == o
	end
end

local function MV_FixString(s)
	return string.sub(s, 1, string.find(s, ".bsp")-1)
end

net.Receive("DoMVNotify", function(len)
	chat.AddText(unpack(net.ReadTable()))
	chat.PlaySound()
end)

local function MV_StopClientVote()
	hook.Remove("Think", "FixCursorMVP")
	gui.EnableScreenClicker(false)
	for _, btn in pairs(MAPV.SaveButton)do
		hook.Remove("Think", "MV_FADED_"..btn) -- fail safes
		hook.Remove("Think", "MV_FADEU_"..btn)
	end
	MAPV.LPinVOTE = false
	for _, VGUI in pairs(MAPV.VGUI)do
		VGUI:Remove()
	end
end

hook.Add("PlayerBindPress", "MV_NoTalking", function(ply, bind, pressed)
	if MAPV.LPinVOTE and MAPV["MutePlayers"] then
		if string.find(bind, "voicerecord") then
			return true
		end
	end
end)

local function MV_StartCleintVote()
	surface.CreateFont( "MV_TITLE", { font = MAPV["FontType"], size = 16, weight = 1000, antialias = true } )
	surface.CreateFont( "MV_PRCNT", { font = MAPV["FontType"], size = 13, weight = 100, antialias = true } )
	surface.CreateFont( "MV_TAG", { font = MAPV["FontType"], size = 13, weight = 1000, antialias = true } )
	surface.CreateFont( "MV_MAPVOTE", { font = MAPV["FontType"], size = 30, weight = 1000, antialias = true } )
	surface.CreateFont( "MV_TIME", { font = MAPV["FontType"], size = 11, weight = 1000, antialias = true } )

	MAPV.SavePercent = {}
	MAPV.SavePercentBar = {}
	MAPV.SaveButton = {}
	MAPV.SaveFadeBox = {}
	local map_list = net.ReadTable()
	local BoxWid, BoxTal = ScrW()*0.12, ScrH()*0.65
	
	gui.EnableScreenClicker(true)
	
	if MAPV["MutePlayers"] then
		LocalPlayer():ConCommand("-voicerecord")
	end
	
	MAPV.VGUI = {}
	
	MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, 0, ScrW(), ScrH() )
	MAPV.VGUI[#MAPV.VGUI]:SetColor(Color(0,0,0,240))
	
	MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DLabel")
	MAPV.VGUI[#MAPV.VGUI]:SetText("MAPVOTE")
	MAPV.VGUI[#MAPV.VGUI]:SetSize(200,50)
	MAPV.VGUI[#MAPV.VGUI]:SetPos(ScrW()/2-((#map_list/2)*(BoxWid+5)), (ScrH()/2-(BoxTal/2))-50)
	MAPV.VGUI[#MAPV.VGUI]:SetFont("MV_MAPVOTE")
	
	MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DLabel")
	MAPV.VGUI[#MAPV.VGUI]:SetText(string.ToMinutesSecondsMilliseconds(MAPV["VoteTime"]))
	MAPV.VGUI[#MAPV.VGUI]:SetSize(200,50)
	MAPV.VGUI[#MAPV.VGUI]:SetPos(ScrW()/2-((#map_list/2)*(BoxWid+5))+125, (ScrH()/2-(BoxTal/2))-43)
	MAPV.VGUI[#MAPV.VGUI]:SetFont("MV_TIME")
	MAPV.TimeLeftVGUI = #MAPV.VGUI
	
	MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create( "DGrid" )
    MAPV.VGUI[#MAPV.VGUI]:SetPos( ScrW()/2-((#map_list/2)*(BoxWid+5)), ScrH()/2-(BoxTal/2) )
    MAPV.VGUI[#MAPV.VGUI]:SetCols( #map_list )
    MAPV.VGUI[#MAPV.VGUI]:SetColWide( BoxWid+10 )
	MAPV.VGUI[#MAPV.VGUI]:SetRowHeight(BoxTal)
	local GRID = #MAPV.VGUI
	
	for _, map in pairs(map_list)do
		local MAP = MAPV["ImagesAndTags"][MV_FixString(map)] or {}
		
		if MAPV["LastBoxMode"] == 2 and _ == 6 then
			local mmm = {}
			if MAPV["ImagesAndTags"][game.GetMap()] == nil then
				mmm = nil
			else
				mmm = MAPV["ImagesAndTags"][game.GetMap()].IMAGETABLE
			end
			MAP = { NAME = "Extend", IMAGETABLE = mmm, TAG = nil }
		elseif MAPV["LastBoxMode"] == 3 and _ == 6 then
			local mmm = { MAPV["RandomMapImage"] }
			MAP = { NAME = "Random", IMAGETABLE = mmm, TAG = nil }
		end
		
		MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, 0, BoxWid, BoxTal )
		MAPV.VGUI[#MAPV.VGUI]:SetColor(Color(45,53,71,255))
		MAPV.VGUI[GRID]:AddItem(MAPV.VGUI[#MAPV.VGUI])
		local LAST_MAP_BOX = #MAPV.VGUI
		
		local map_img = MAPV["DefaultImage"]
		local map_wid = 1080
		if MAP.IMAGETABLE then
			local map_tbl = table.Random(MAP.IMAGETABLE)
			local ex_map = string.Explode("  ", map_tbl)
			map_img = ex_map[1]
			if ex_map[2] then
				map_wid = tonumber(ex_map[2])
			end
		end
		
		MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("HTML", MAPV.VGUI[LAST_MAP_BOX])
		MAPV.VGUI[#MAPV.VGUI]:SetPos( -(map_wid)/2, 0)
		MAPV.VGUI[#MAPV.VGUI]:SetSize( map_wid, 1080)
		MAPV.VGUI[#MAPV.VGUI]:OpenURL(map_img)
		
		MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, BoxTal-50, BoxWid, 50 )
		MAPV.VGUI[#MAPV.VGUI]:SetColor(Color(0,0,0,180))
		MAPV.VGUI[#MAPV.VGUI]:SetParent(MAPV.VGUI[LAST_MAP_BOX])
		local LAST_TITLE_BOX = #MAPV.VGUI
		
		MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DLabel", MAPV.VGUI[LAST_TITLE_BOX])
		local map_text = MAP.NAME or string.upper(string.Replace(MV_FixString(map), "_", " "))
		MAPV.VGUI[#MAPV.VGUI]:SetText(string.upper(map_text))
		surface.SetFont("MV_TITLE")
		local ww, hh = surface.GetTextSize(MAPV.VGUI[#MAPV.VGUI]:GetText())
		MAPV.VGUI[#MAPV.VGUI]:SetSize(BoxWid,50)
		MAPV.VGUI[#MAPV.VGUI]:SetPos((BoxWid/2)-ww/2, 5)
		MAPV.VGUI[#MAPV.VGUI]:SetFont("MV_TITLE")
		
		if MAP.TAG then
			MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, 0, BoxWid, 20 )
			MAPV.VGUI[#MAPV.VGUI]:SetColor(Color(0,0,0,180))
			MAPV.VGUI[#MAPV.VGUI]:SetParent(MAPV.VGUI[LAST_MAP_BOX])
			local LAST_TAG_BOX = #MAPV.VGUI
			
			MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DLabel", MAPV.VGUI[LAST_TAG_BOX])
			local tag_text = MAP.TAG
			MAPV.VGUI[#MAPV.VGUI]:SetText(string.upper(tag_text))
			surface.SetFont("MV_TAG")
			local ww, hh = surface.GetTextSize(MAPV.VGUI[#MAPV.VGUI]:GetText())
			MAPV.VGUI[#MAPV.VGUI]:SetSize(BoxWid,20)
			MAPV.VGUI[#MAPV.VGUI]:SetPos((BoxWid/2)-ww/2, 0)
			MAPV.VGUI[#MAPV.VGUI]:SetFont("MV_TAG")
		end
		
		MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DLabel", MAPV.VGUI[LAST_TITLE_BOX])
		MAPV.VGUI[#MAPV.VGUI]:SetText("0%")
		surface.SetFont("MV_PRCNT")
		local ww, hh = surface.GetTextSize(MAPV.VGUI[#MAPV.VGUI]:GetText())
		MAPV.VGUI[#MAPV.VGUI]:SetSize(BoxWid,50)
		MAPV.VGUI[#MAPV.VGUI]:SetPos((BoxWid/2)-ww/2, -5)
		MAPV.VGUI[#MAPV.VGUI]:SetFont("MV_PRCNT")
		table.insert(MAPV.SavePercent, #MAPV.VGUI)
		
		MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, 40, 0, 10 )
		MAPV.VGUI[#MAPV.VGUI]:SetColor(MAPV["MainColor"])
		MAPV.VGUI[#MAPV.VGUI]:SetParent(MAPV.VGUI[LAST_TITLE_BOX])
		table.insert(MAPV.SavePercentBar, #MAPV.VGUI)
		
		MAPV.VGUI[#MAPV.VGUI+1] = VGUIRect( 0, 0, BoxWid, BoxTal )
		MAPV.VGUI[#MAPV.VGUI]:SetColor(Color(0,0,0,MAPV["BoxDarkness"]))
		MAPV.VGUI[#MAPV.VGUI]:SetParent(MAPV.VGUI[LAST_MAP_BOX])
		table.insert(MAPV.SaveFadeBox, #MAPV.VGUI)
		
		MAPV.VGUI[#MAPV.VGUI+1] = vgui.Create("DButton", MAPV.VGUI[LAST_MAP_BOX])
		MAPV.VGUI[#MAPV.VGUI]:SetText("")
		MAPV.VGUI[#MAPV.VGUI]:SetSize(BoxWid,BoxTal)
		MAPV.VGUI[#MAPV.VGUI]:SetDrawBackground(false)
		table.insert(MAPV.SaveButton, #MAPV.VGUI)
		
	end
	
	hook.Add("Think", "FixCursorMVP", function()
		if !vgui.CursorVisible() and MAPV.LPinVOTE then
			gui.EnableScreenClicker(true)
		end
	end)
	MAPV.WillEndAt = CurTime()+MAPV["VoteTime"]
	MAPV.ClientVotes = {0,0,0,0,0,0}
	MAPV.LPinVOTE = true
	
	timer.Simple(MAPV["VoteTime"], function()
		MV_StopClientVote()
	end)
	
end
net.Receive("DoMVSendInfo", MV_StartCleintVote)

net.Receive("MV_UpdateVotes", function()
	MAPV.ClientVotes = net.ReadTable()
	for _, p in pairs(MAPV.SavePercent)do
		local NewPercent = math.ceil((MAPV.ClientVotes[_]/#player.GetAll()*100)) .. "%"
		surface.SetFont("MV_PRCNT")
		local ww, hh = surface.GetTextSize(NewPercent)
		MAPV.VGUI[p]:SetPos(((ScrW()*0.12)/2)-ww/2, -5)
		MAPV.VGUI[p]:SetText(NewPercent)
	end
	for _, b in pairs(MAPV.SavePercentBar)do
		MAPV.VGUI[b]:SetSize(Lerp(MAPV.ClientVotes[_]/#player.GetAll(), 0, ScrW()*0.12), 10)
	end
end)

hook.Add("Think", "MV_FadeAnim", function()
	if MAPV.LPinVOTE then 
		for _, btn in pairs(MAPV.SaveButton)do
			MAPV.VGUI[btn].OnCursorEntered = function()
				hook.Remove("Think", "MV_FADEU_"..btn)
				hook.Add("Think", "MV_FADED_"..btn, function()
					MAPV.VGUI[MAPV.SaveFadeBox[_]]:SetColor(Color(0,0,0,MAPV.VGUI[MAPV.SaveFadeBox[_]]:GetColor().a-MAPV["AnimationSpeed"]))
					if MAPV.VGUI[MAPV.SaveFadeBox[_]]:GetColor().a <= 0 then
						hook.Remove("Think", "MV_FADED_"..btn)
					end
				end)
			end
			MAPV.VGUI[btn].OnCursorExited = function()
				hook.Remove("Think", "MV_FADED_"..btn)
				hook.Add("Think", "MV_FADEU_"..btn, function()
					MAPV.VGUI[MAPV.SaveFadeBox[_]]:SetColor(Color(0,0,0,MAPV.VGUI[MAPV.SaveFadeBox[_]]:GetColor().a+MAPV["AnimationSpeed"]))
					if MAPV.VGUI[MAPV.SaveFadeBox[_]]:GetColor().a >= MAPV["BoxDarkness"] then
						hook.Remove("Think", "MV_FADEU_"..btn)
					end
				end)
			end
			MAPV.VGUI[btn].DoClick = function()
				net.Start("MV_SendVote")
				net.WriteFloat(LocalPlayer():EntIndex())
				net.WriteFloat(_)
				net.SendToServer()
			end
		end
		MAPV.VGUI[MAPV.TimeLeftVGUI]:SetText(string.ToMinutesSecondsMilliseconds(math.max(math.Round(MAPV.WillEndAt-CurTime(), 2), 0)))
	end
end)
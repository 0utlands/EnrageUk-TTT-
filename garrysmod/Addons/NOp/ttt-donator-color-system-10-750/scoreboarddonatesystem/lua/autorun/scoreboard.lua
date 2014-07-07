-- Config
local CustomRankEnabled = false -- If you want people to change their rank name/color. If you change this to true you must use the sb_row supplied in the root of this addon's ZIP, read the README for more information.
local allowedcolorgroups = { -- Groups that can change name colors. Put commas at the end of each line except for the last one.
"superadmin",
"sponsor",
"vip",
"owner",
"donator",
"developer",
"admind",
"modd",
"triald",
"senioradmin"
}
local allowedrankgroups = {-- Groups that can change rank names/colors. Put commas at the end of each line except for the last one. This does nothing if CustomRankEnabled is set to false
"superadmin",
"sponsor",
"vip",
"owner",
"donator",
"developer",
"admind",
"modd",
"triald",
"senioradmin"
}
-- End config
if SERVER then
AddCSLuaFile()
util.AddNetworkString("NameColor")
util.AddNetworkString("CustomRank")
net.Receive("CustomRank", function(len, ply)
	if !ply:CanChangeRank() then ply:notify("You are not allowed to set your custom rank!") return end
	local ranktable = net.ReadTable()
		ply:SetPData("SB_rankcolor_r", ranktable.r or ply:GetPData("SB_rankcolor_r", 255))
		ply:SetPData("SB_rankcolor_g", ranktable.g or ply:GetPData("SB_rankcolor_g", 255))
		ply:SetPData("SB_rankcolor_b", ranktable.b or ply:GetPData("SB_rankcolor_b", 255))
		ply:SetPData("SB_rankcolor_a", ranktable.a or ply:GetPData("SB_rankcolor_a", 255))
		ply:SetPData("SB_ranktext", ranktable.name or ply:GetPData("SB_ranktext", ""))
		
		ply:SetNWInt("SB_rankcolor_r", ranktable.r or ply:GetPData("SB_rankcolor_r", 255))
		ply:SetNWInt("SB_rankcolor_g", ranktable.g or ply:GetPData("SB_rankcolor_g", 255))
		ply:SetNWInt("SB_rankcolor_b", ranktable.b or ply:GetPData("SB_rankcolor_b", 255))
		ply:SetNWInt("SB_rankcolor_a", ranktable.a or ply:GetPData("SB_rankcolor_a", 255))
		ply:SetNWString("SB_ranktext", ranktable.name or ply:GetPData("SB_ranktext", ""))
end)
net.Receive("NameColor", function(len, ply)
	if !ply:CanChangeColor() then ply:notify("You are not allowed to set your name color!") return end
	local namecolor = net.ReadTable()
		ply:SetPData("SB_namecolor_r", namecolor.r or ply:GetPData("SB_namecolor_r", 255))
		ply:SetPData("SB_namecolor_g", namecolor.g or ply:GetPData("SB_namecolor_g", 255))
		ply:SetPData("SB_namecolor_b", namecolor.b or ply:GetPData("SB_namecolor_b", 255))
		ply:SetPData("SB_namecolor_a", namecolor.a or ply:GetPData("SB_namecolor_a", 255))
		
		ply:SetNWInt("SB_namecolor_r", namecolor.r or ply:GetPData("SB_namecolor_r", 255))
		ply:SetNWInt("SB_namecolor_g", namecolor.g or ply:GetPData("SB_namecolor_g", 255))
		ply:SetNWInt("SB_namecolor_b", namecolor.b or ply:GetPData("SB_namecolor_b", 255))
		ply:SetNWInt("SB_namecolor_a", namecolor.a or ply:GetPData("SB_namecolor_a", 255))
end)
hook.Add("PlayerInitialSpawn", "GiveNetworkedDataForDonation", function(ply)
		ply:SetNWInt("SB_namecolor_r", ply:GetPData("SB_namecolor_r", 255))
		ply:SetNWInt("SB_namecolor_g", ply:GetPData("SB_namecolor_g", 255))
		ply:SetNWInt("SB_namecolor_b", ply:GetPData("SB_namecolor_b", 255))
		ply:SetNWInt("SB_namecolor_a", ply:GetPData("SB_namecolor_a", 255))
		
		ply:SetNWInt("SB_rankcolor_r", ply:GetPData("SB_rankcolor_r", 255))
		ply:SetNWInt("SB_rankcolor_g", ply:GetPData("SB_rankcolor_g", 255))
		ply:SetNWInt("SB_rankcolor_b", ply:GetPData("SB_rankcolor_b", 255))
		ply:SetNWInt("SB_rankcolor_a", ply:GetPData("SB_rankcolor_a", 255))
		ply:SetNWString("SB_ranktext", ply:GetPData("SB_ranktext", ply:GetUserGroup():gsub("^%l", string.upper)))
end)
end
plymeta = FindMetaTable("Player")
function plymeta:CanChangeColor()
	for k, v in pairs(allowedcolorgroups) do
		if self:GetUserGroup() == v then return true end
	end
	return false
end
function plymeta:CanChangeRank()
	if !CustomRankEnabled then return end
	for k, v in pairs(allowedrankgroups) do
		if self:GetUserGroup() == v then return true end
	end
	return false
end
if CLIENT then
hook.Add("TTTSettingsTabs", "DonatorMenu", function(dtabs)
	if !LocalPlayer():CanChangeColor() then return end
	
	local donpage = vgui.Create("DPanelList", dtabs)
		donpage:StretchToParent(0,0,1,0)
		donpage:EnableVerticalScrollbar(true)
		donpage:SetPadding(10)
		donpage:SetSpacing(10)
   
	dtabs:AddSheet("Name Color", donpage, "icon16/heart.png", false, false, "Donator Only Page To Change Your Rank Color")
	
	local label = vgui.Create("DLabel", donpage)
		label:SetFont("DefaultBold")
		label:SetText("Thank you for donating! Please change the color picker to whatever you want your namecolor to\nbe, and click 'Save'.")
		label:SizeToContents()
		label:SetDark(true)
	
	local red = LocalPlayer():GetNWInt("SB_namecolor_r", 255)
	local blue = LocalPlayer():GetNWInt("SB_namecolor_g", 255)
	local green = LocalPlayer():GetNWInt("SB_namecolor_b", 255)
	
	local colormixer = vgui.Create("DColorMixer", donpage)
		colormixer:SetPos(1,56) 
		colormixer:SetSize(500,500)
		colormixer:SetSize(500, 300)
		colormixer:SetAlphaBar( false )
		colormixer:SetColor(Color(red,blue,green))

	local save = vgui.Create("DButton", donpage)
		save:SetPos(515,335)
		save:SetText("Save")
		save.DoClick = function()
		local namecolor = colormixer:GetColor()
			net.Start("NameColor")
				net.WriteTable(namecolor)
			net.SendToServer()
		end
end)
hook.Add("TTTSettingsTabs", "DonatorMenu2", function(dtabs)
	if !LocalPlayer():CanChangeRank() then return end
	
	local donpage = vgui.Create("DPanelList", dtabs)
		donpage:StretchToParent(0,0,1,0)
		donpage:EnableVerticalScrollbar(true)
		donpage:SetPadding(10)
		donpage:SetSpacing(10)
   
	dtabs:AddSheet("Custom Rank", donpage, "icon16/heart.png", false, false, "Donator Only Page To Change Your Rank Color")
	
	local label = vgui.Create("DLabel", donpage)
		label:SetFont("DefaultBold")
		label:SetText("Thank you for donating! Please change the color picker to whatever you want your rank color/name to\nbe, and click 'Save'.")
		label:SizeToContents()
		label:SetDark(true)
	
	local red = LocalPlayer():GetNWInt("SB_rankcolor_r", 255)
	local blue = LocalPlayer():GetNWInt("SB_rankcolor_g", 255)
	local green = LocalPlayer():GetNWInt("SB_rankcolor_b", 255)
	local name = LocalPlayer():GetNWString("SB_ranktext","")
	
	local tboxlabel = vgui.Create("DLabel", donpage)
		tboxlabel:SetFont("DefaultBold")
		tboxlabel:SetText("Rank Text:")
		tboxlabel:SetPos(80, 33)
		tboxlabel:SizeToContents()
		tboxlabel:SetDark(true)
	
	local tbox = vgui.Create("DTextEntry", donpage)
		tbox:SetText(name)
		tbox:SetMultiline(false)
		tbox:SetSize(175,20) 
		tbox:SetPos(150,30)
		tbox.OnEnter = function(self)
			nametosend = self:GetValue()
		end
	
	local colormixer = vgui.Create("DColorMixer", donpage)
		colormixer:SetPos(1,56) 
		colormixer:SetSize(500,500)
		colormixer:SetSize(500, 300)
		colormixer:SetAlphaBar( false )
		colormixer:SetColor(Color(red,blue,green))

	local save = vgui.Create("DButton", donpage)
		save:SetPos(515,335)
		save:SetText("Save")
		save.DoClick = function()
		local ranktable = colormixer:GetColor()
		ranktable.name = tbox:GetValue()
			net.Start("CustomRank")
				net.WriteTable(ranktable)
			net.SendToServer()
		end
end)
hook.Add("TTTScoreboardColorForPlayer", "DonatorScoreboardSystem", function(ply)
	local color = {}
	color.r = ply:GetNWInt("SB_namecolor_r", 0)
	color.g = ply:GetNWInt("SB_namecolor_g", 0)
	color.b = ply:GetNWInt("SB_namecolor_b", 0)
	color.a = ply:GetNWInt("SB_namecolor_a", 255)
	return color
end)
end
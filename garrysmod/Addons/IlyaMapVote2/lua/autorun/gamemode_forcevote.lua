-- If your not using ttt or deathrun, you can still leave this here, it shouldn't effect your 
-- gamemode.
hook.Add( "TTTDelayRoundStartForVote", "StartMapVote",function()
	if GetGlobalInt("ttt_rounds_left", 4) == 1 then
		if !MAPV.VoteOpen then
			MV_StartVote()
		end
	end
end)

hook.Add( "OnRoundSet", "moop voote", function( round, winner )
	if round == ROUND_PREPARING then
		if GetGlobalInt("dr_rounds_left") == 1 then
			MV_StartVote()
		end
	end
end)
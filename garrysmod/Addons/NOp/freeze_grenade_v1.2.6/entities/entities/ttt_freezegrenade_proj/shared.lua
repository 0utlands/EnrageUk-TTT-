//by MaZy
-- freezer nade.

if SERVER then
   AddCSLuaFile("shared.lua")
end

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"

// Here you can set your own model
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )

--how many seconds they are under frozen effect
local freeze_starttime = 5 

--How far
local radius = 300 

--Should it show countdown?
local boolShowCountdown = true

--Color of the countdown
local countdownColor = Vector(255,0,0,255)

--Should it show bubbles?
local boolShowBubbleEffect = true

--Color of the bubble
local bubbleEffectColor = Vector(0,0,255,0)

--Should clients have screeneffect?
local boolShowScreenEffect = true

--Should it explode on impact or should it use timer
local explode_on_impact = true

--if you want you can change to own sound
local frozen_sound_path = "physics/glass/glass_pottery_break3.wav"
local defrozen_sound_path = "physics/glass/glass_sheet_break1.wav"
local boom_sound = Sound("weapons/underwater_explode3.wav")


local screen_effect_started = false

local PlayerFreezeList = {}
local Freeze_hud_markereffect = {}

meta = FindMetaTable("Player")
 
function meta:SetEffectState(bool_state)
	self:SetNetworkedBool("fg_frozen", bool_state)
end

function meta:SetCountdownEffect(Countdown)
	self:SetNetworkedFloat("fg_frozen_cd", Countdown)
end

function meta:IsFreezed()
	return self:GetNetworkedBool("fg_frozen") == true 
end

function meta:GetFrozenEffectCountdown()
	return self:GetNetworkedFloat("fg_frozen_cd") - CurTime()
end

function meta:frozeneffect_finished()
	return self:GetFrozenEffectCountdown() <= 0
end

if SERVER then
	function check_radius(pos, radius) 
		for k, ply in pairs(ents.FindInSphere(pos, radius)) do
			if IsValid(ply) then
				if ply:IsPlayer() and ply:Alive() then	
					ply:SetEffectState(true)
					ply:SetCountdownEffect(CurTime() + freeze_starttime)
					ply:Freeze( true )
					ply:EmitSound(frozen_sound_path, ply:GetPos(), 50, 100) 
				end
			end
		end
	end
	
	local function checker()
		for _, ply in pairs(player.GetAll()) do
			if IsValid(ply) then
				if ply:IsFreezed() == true then
					if(ply:frozeneffect_finished() or not ply:Alive() or ply:Health() <= 0) then
						ply:SetEffectState(false)
						ply:SetCountdownEffect(freeze_starttime)
						ply:Freeze( false )
					end
				end
			end
		end
	end
	hook.Add("Think", "freezegrenade_checker", function() checker() end)
else 
	hook.Remove("RenderScreenspaceEffects", "freezegrenade_DrawFreezerEffect")


	function  freeze_effect()
		local tab =
		{
		 [ "$pp_colour_addr" ] = 0.05,
		 [ "$pp_colour_addg" ] = 0.05,
		 [ "$pp_colour_addb" ] = 0.8,
		 [ "$pp_colour_brightness" ] = 0,
		 [ "$pp_colour_contrast" ] = 1,
		 [ "$pp_colour_colour" ] = 2.0,
		 [ "$pp_colour_mulr" ] = 0,
		 [ "$pp_colour_mulg" ] = 0.02,
		 [ "$pp_colour_mulb" ] = 0
		}
		DrawColorModify( tab )

		DrawMaterialOverlay( "models/props_c17/fisheyelens", -0.4	)
		DrawMaterialOverlay( "models/Shadertest/predator", 0.2	)

	end

	function create_marker_effect( ply  )
		if IsValid(ply) then
			local tb = {}
			tb.ply = ply
			tb.Pos = ply:GetPos() + Vector(math.random(-15,15), math.random(-15,15), math.random(-5,15))
			tb.Text = "O" // Bubble lol ^^
			tb.DieTime = CurTime() + 1
			tb.color = bubbleEffectColor
			
			table.insert(Freeze_hud_markereffect, tb)
		end
	end
		
	hook.Add( "HUDPaint", "freezergrenade_drawhud", function() 
	
		//take list at PlayerList (who is under frozen effect)
		for _, ply in pairs( player.GetAll() ) do
		
			if ply:IsFreezed() then
				if boolShowScreenEffect then
					if( ply == LocalPlayer() and screen_effect_started == false) then
						print("starte effect")
						hook.Add("RenderScreenspaceEffects", "freezegrenade_DrawFreezerEffect", function() freeze_effect() end)
						screen_effect_started = true
					end
				end
	
				//should draw bubble (just random)
				if boolShowScreenEffect then
					local boolShowMarker = math.random(0,15) == 0 or false
					if boolShowMarker then
						create_marker_effect(ply)
					end
				end
				if boolShowCountdown then
					local cd = ply:GetFrozenEffectCountdown()
					local CountdownSec = math.Round(cd, 1)
					local pos = ply:GetPos()
					local distance = pos:Distance(LocalPlayer():GetPos())
					local drawPos = (pos  + Vector(0,0, 75 + distance/27)):ToScreen()
					draw.DrawText( "Frozen effect " .. CountdownSec .. " Seconds",  "DermaDefault", drawPos.x, drawPos.y, countdownColor, TEXT_ALIGN_CENTER )
				end
			else
				if screen_effect_started then
					if(LocalPlayer() == ply) then
						screen_effect_started = false
						hook.Remove("RenderScreenspaceEffects", "freezegrenade_DrawFreezerEffect")
					end
				end
			end
		end
		
		for k, tb in pairs( Freeze_hud_markereffect ) do
		
			local pos = tb.Pos
			local distance = pos:Distance(LocalPlayer():GetPos())
			
			local drawPos = (pos  + Vector(0,0, 55 + distance/27)):ToScreen()
			tb.Pos.z = tb.Pos.z + 55 * FrameTime()
					
			local CooldownSec = (tb.DieTime - CurTime())
			local alpha = 255*CooldownSec/1
			alpha = math.Clamp(alpha, 0 , 255)
					 
			draw.DrawText( tb.Text,  "DermaDefault", drawPos.x, drawPos.y, Color(tb.color.r,tb.color.g ,tb.color.b,alpha), TEXT_ALIGN_CENTER )
			
			if tb.DieTime < CurTime() then
				table.remove(Freeze_hud_markereffect, k)
			end
		end
		
	end)
end 

function ENT:Initialize()
   if not self:GetRadius() then self:SetRadius(radius) end
	
   return self.BaseClass.Initialize(self)
end

function ENT:Think( )
	if explode_on_impact then 
		self:SetDetonateTimer(5)
		
		local spos = self.Entity:GetPos()
		local tr = util.TraceLine({start=spos + Vector(0,0,-5), endpos=spos + Vector(0,0,-35), filter=self.thrower})
		
		if tr.Hit then
			self.Entity:Explode(tr)
		end
	else
	   local etime = self:GetExplodeTime() or 0
	   if etime != 0 and etime < CurTime() then
		  -- if thrower disconnects before grenade explodes, just don't explode
		  if SERVER and (not IsValid(self:GetThrower())) then
			 self:Remove()
			 etime = 0
			 return
		  end

		  -- find the ground if it's near and pass it to the explosion
		  local spos = self.Entity:GetPos()
		  local tr = util.TraceLine({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=self.thrower})

		  local success, err = pcall(self.Explode, self, tr)
		  if not success then
			 -- prevent effect spam on Lua error
			 self:Remove()
			 ErrorNoHalt("ERROR CAUGHT: ttt_basegrenade_proj: " .. err .. "\n")
		  end
	   end
	end
	
end

function ENT:Explode(tr)

	if SERVER then
		self.Entity:SetNoDraw(true)
		self.Entity:SetSolid(SOLID_NONE)

		-- pull out of the surface
		if tr then
			if tr.Fraction != 1.0 then
				self.Entity:SetPos(tr.HitPos + tr.HitNormal * 0.6)
			end
		end

		local pos = self.Entity:GetPos()	

		check_radius(pos, self:GetRadius())

		self:SetDetonateExact(0)

		sound.Play(boom_sound, pos, 100, 100) 

		self:Remove()
	else
		local pos = self.Entity:GetPos()

		local em = ParticleEmitter(pos) 
		for i=1, 400 do  
			//strider_blackball 
			//ice effect ar2_muzzle1
			local part = em:Add("sprites/ar2_muzzle1",pos)
			if part then 
				part:SetColor(255,255,255,math.random(255))
				part:SetVelocity(Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)):GetNormal() * radius)
				part:SetDieTime(3)
				part:SetLifeTime(1)   
				part:SetStartSize(75) 
				part:SetEndSize(1)  
			end 
		end 
		
		em:Finish()  
		self:SetDetonateExact(0)
	end
end

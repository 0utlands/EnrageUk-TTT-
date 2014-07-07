
--- Credit transfer tab for equipment menu
local GetTranslation = LANG.GetTranslation
function CreateTransferMenu(parent)
   local dform = vgui.Create("DForm", parent)
   dform:SetName(GetTranslation("xfer_menutitle"))
   dform:StretchToParent(0,0,0,0)
   dform:SetAutoSize(false)

   if LocalPlayer():GetCredits() <= 0 then
      dform:Help(GetTranslation("xfer_no_credits"))
      return dform
   end

   local bw, bh = 100, 20
   local dsubmit = vgui.Create("DButton", dform)
   dsubmit:SetSize(bw, bh)
   dsubmit:SetDisabled(true)
   dsubmit:SetText(GetTranslation("xfer_send"))
   dsubmit:SetTextColor( tttreskin.tdmsendbtntext )
   dsubmit.OnCursorEntered = function(self)
    self:SetTextColor( tttreskin.tdmsendbtntexthover )
  end
  dsubmit.OnCursorExited = function(self)
    self:SetTextColor( tttreskin.tdmsendbtntext )
  end
  dsubmit.Paint = function(self,w,h)
    draw.RoundedBox( 0, 0, 0, w, h, tttreskin.tdmsendbtnborder )
    draw.RoundedBox( 0, 1, 1, w-2, h-2, tttreskin.tdmsendbtngrdtop )

    surface.SetDrawColor( tttreskin.tdmsendbtngrdbtm )
    surface.SetTexture( surface.GetTextureID( "gui/gradient" ) )
    surface.DrawTexturedRectRotated( w/2, h/2, h-1, w-2, 90 )

    draw.RoundedBox( 0, 1, 1, w-2, 1, tttreskin.tdmsendbtnshine )
   end

   local selected_uid = nil

   local dpick = vgui.Create("DComboBox", dform)
   dpick.OnSelect = function(s, idx, val, data)
                       if data then
                          selected_uid = data
                          dsubmit:SetDisabled(false)
                       end
                    end

   dpick:SetWide(250)

   -- fill combobox
   local r = LocalPlayer():GetRole()
   for _, p in pairs(player.GetAll()) do
      if IsValid(p) and p:IsActiveRole(r) and p != LocalPlayer() then
         dpick:AddChoice(p:Nick(), p:UniqueID())
      end
   end

   -- select first player by default
   if dpick:GetOptionText(1) then dpick:ChooseOptionID(1) end

   dsubmit.DoClick = function(s)
                        if selected_uid then
                           RunConsoleCommand("ttt_transfer_credits", tostring(selected_uid) or "-1", "1")
                        end
                     end

   dsubmit.Think = function(s)
                      if LocalPlayer():GetCredits() < 1 then
                         s:SetDisabled(true)
                      end
                   end

   dform:AddItem(dpick)
   dform:AddItem(dsubmit)

   dform:Help(LANG.GetParamTranslation("xfer_help", {role = LocalPlayer():GetRoleString()}))

   return dform
end

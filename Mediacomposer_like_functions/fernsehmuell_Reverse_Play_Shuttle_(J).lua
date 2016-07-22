-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

function is_playing_reverse()
    retval,value=reaper.GetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle")  --check if reverse playing
    if not tonumber(value) then value="0" end
    if value=="1" then return 1 else return 0 end
end

function main()
  reaper.Undo_BeginBlock()
  reverse_function=reaper.NamedCommandLookup("_RS34fef017042a3928853cd794b2a58786e835a71a") -- fernsehmuell_Reverse_Play_Shuttle_Background.lua
  if is_playing_reverse()>0 then
    reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 2) --set reverse status to 2 -> button pressed again!
  else
    reaper.Main_OnCommand(reverse_function, 0)
  end
  
  reaper.Undo_EndBlock("PLAY REVERSE fernsehmuell", -1)
end

main()


-- @version 1.1
-- @author Udo Sauer
-- @changelog
--   better way to get commandID of backgroundscript

function is_playing_reverse()
    retval,value=reaper.GetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle")  --check if reverse playing
    if not tonumber(value) then value="0" end
    if value=="1" then return 1 else return 0 end
end

function GetPath(str)
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    separator = "\\"
  else
    separator = "/"
  end
  return str:match("(.*"..separator..")")
end

function main()
  reaper.Undo_BeginBlock()
  is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()
  reverse_function = reaper.AddRemoveReaScript(true, 0, GetPath(filename).."fernsehmuell_Reverse_Play_Shuttle_Background.lua", true)
  --reverse_function=reaper.NamedCommandLookup("_RS28389260f2e3c333a10d41c8ab150ebee11d2e92") -- fernsehmuell_Reverse_Play_Shuttle_Background.lua

  if reverse_function ~= 0 then
    if is_playing_reverse()>0 then
      reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 2) --set reverse status to 2 -> button pressed again!
    else
      reaper.Main_OnCommand(reverse_function, 0)
    end
  else
    reaper.ShowMessageBox("the script file: "..GetPath(filename).."fernsehmuell_Reverse_Play_Shuttle_Background.lua".. " is missing.", "Warning: LUA Script missing.", 0)
  end
  reaper.Undo_EndBlock("PLAY REVERSE fernsehmuell", -1)
end

main()




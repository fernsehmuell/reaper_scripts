-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits
if playstate==0 or playstate==2 then
  reaper.MoveEditCursor(-0.4, 0)
end

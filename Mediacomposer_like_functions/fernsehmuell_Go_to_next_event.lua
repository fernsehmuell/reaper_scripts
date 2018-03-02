-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

reaper.Main_OnCommand(1016, 0) -- stop playback
timecodes={} -- array holding all edit timecodes
tracks_count=reaper.GetNumTracks()
selected_tracks_count=reaper.CountSelectedTracks(0)
pos=reaper.GetCursorPosition()

if selected_tracks_count>0 then
    --find events (start/end of items)
    for t=1,selected_tracks_count,1 do
        Track= reaper.GetSelectedTrack(0,t-1) --get a selected track
        items_count=reaper.GetTrackNumMediaItems(Track) --count items in track
       
        --analyse this track (collect all start and end points of all items)
        for i=1,items_count,1 do
            mediaitem=reaper.GetTrackMediaItem(Track, i-1)
            in_point=reaper.GetMediaItemInfo_Value(mediaitem, "D_POSITION")
            out_point=in_point + reaper.GetMediaItemInfo_Value(mediaitem, "D_LENGTH")
            table.insert(timecodes,in_point)
            table.insert(timecodes,out_point)
        end
    end

    table.sort(timecodes) -- sort timecodes
    for i, tc in ipairs(timecodes) do -- search first timecode>cursor pos, then jump to that tc and end
      if tc>pos then
        reaper.MoveEditCursor(tc-pos, 0)
        return 1
      end
    end
else
  reaper.Main_OnCommand(41168, 0)
end


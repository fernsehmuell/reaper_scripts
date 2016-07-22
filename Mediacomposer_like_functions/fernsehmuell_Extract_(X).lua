function clear_all_in_and_out_markers()
    reaper.Main_OnCommand(40635,0) -- Time selection: Remove time selection (40635)
    reaper.SetProjExtState(0, "Fernsehmuell", "StartpointIsZero", "False") -- clear IN-Point is Zero datastore value
    reaper.SetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point", "") -- clear OUT-Point datastore value

    retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
    for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
        index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
        if name == " [ in" or name == " out ]" then
            reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is a IN or OUT marker
        end
    end
end

function there_are_in_and_out_points()
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) --get start and end point
    retval, out_before_in = reaper.GetProjExtState(0, "Fernsehmuell", "End_Point_before_Start_Point") --check if there is an OUT-Point in the datastore
    if (out_before_in ~= "") then out_pos=tonumber(out_before_in) end -- if there is an OUT in the datastore, then use that one
    if out_pos==in_pos and out_pos>0 then out_pos=out_pos+1 end -- if IN and OUT are on the end we need this hack
    return in_pos~=out_pos
end

function goto_in()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec
    if playstate==1 then reaper.Main_OnCommand(1016,0) end --stop as mediacomposer does (do we need that?)
    
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) -- get start and end point
    
    if (in_pos==0.0 and out_pos==0.0) then -- no start point set, OR startpoint is 0.0 -> goto start like avid MC
        reaper.Main_OnCommand(40042,0) --Transport: Go to start of project (40042)
    else
        if (in_pos~=out_pos) then -- start and end point are set
            reaper.Main_OnCommand(40630,0) --Go to start of time selection
        else
            actpos=reaper.GetCursorPosition()
            reaper.MoveEditCursor(in_pos-actpos, 0)
        end
    end
end

function main_selected_tracks()
reaper.Undo_BeginBlock()
    --safe ripple mode
    toggle_state=reaper.GetToggleCommandState(40311)
    toggle_state_one=reaper.GetToggleCommandState(40310)

    goto_in() --move cursor to IN point
        
    --lift to clear area:
    reaper.Main_OnCommand(40309,0) -- Set ripple editing off
    reaper.Main_OnCommand(40289,0) -- unselect all items
    reaper.Main_OnCommand(40718,0) -- Item: Select all items on selected tracks in current time selection
    if reaper.CountSelectedMediaItems(0) > 0 then
        reaper.Main_OnCommand(40312,0) -- Item: Remove selected area of items
    end
    
    in_pos, out_pos = reaper.GetSet_LoopTimeRange(0,0,0,0,0) -- get start and end point
    
    --loop through all selected tracks and move all clips right from outpoint
    for t=1,reaper.CountSelectedTracks(0),1 do
        Track= reaper.GetSelectedTrack(0,t-1) --get a selected track
        items_count=reaper.GetTrackNumMediaItems(Track) --count items in track
        StartPos=0
        for i=1,items_count,1 do
            mediaitem=reaper.GetTrackMediaItem(Track, i-1)
            StartPos=reaper.GetMediaItemInfo_Value(mediaitem, "D_POSITION")
            if StartPos>=in_pos then -- move if right from out
                reaper.SetMediaItemInfo_Value(mediaitem,"D_POSITION",StartPos-(out_pos-in_pos))
            end
        end
        
    end

    --restore ripple mode
    reaper.Main_OnCommand(40309,0) -- Set ripple editing off
    if toggle_state==1 then
        reaper.Main_OnCommand(40311,0) -- Set ripple editing all tracks
    elseif toggle_state_one==1 then
        reaper.Main_OnCommand(40310,0) -- Set ripple editing per track
    end
    clear_all_in_and_out_markers()
    reaper.Main_OnCommand(40289,0) -- unselect all items
    
reaper.Undo_EndBlock("Lift (fernsehmuell script)", -1)
end

function main()
  if there_are_in_and_out_points() and out_before_in == "" then
      if reaper.CountSelectedTracks(0)==0 or reaper.CountTracks(0)==0 then
          -- if no (selected) tracks just leave
      else
          main_selected_tracks()
      end
  end
end

reaper.runloop(main)




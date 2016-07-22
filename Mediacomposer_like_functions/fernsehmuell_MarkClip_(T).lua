-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

--emulate avid mediacomposer MARK CLIP functionality
--if one or more tracks are selected only use these tracks
--if no track is selected search for nearest cuts to cursor position in all tracks and set in/out
function get_position()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits
    if playstate==1 or playstate==4 then
        return reaper.GetPlayPosition()
    else
        return reaper.GetCursorPosition()
    end
end

function get_last_timecode()
    -- get last timecode of whole project (is there an easier way???)
    last_tc=0
    for t=1, reaper.GetNumTracks(),1 do
        Track= reaper.GetTrack(0,t-1) --get track
        if reaper.GetTrackNumMediaItems(Track)>0 then
            mediaitem=reaper.GetTrackMediaItem(Track, reaper.GetTrackNumMediaItems(Track)-1) -- get last item
            in_point=reaper.GetMediaItemInfo_Value(mediaitem, "D_POSITION")
            out_point=in_point + reaper.GetMediaItemInfo_Value(mediaitem, "D_LENGTH")
            if out_point>last_tc then last_tc=out_point end
        end
    end
    return last_tc
end

function get_closest_in_point_in_all_selected_tracks(pos,next) -- next=0 point has to be <=pos, next=1 point has to be <pos
    in_pos=0 track_in_pos=0
    for t=1,number_of_tracks_to_scan,1 do
        for i=#timecodes[t],1,-1 do
            if next==0 then result=timecodes[t][i]<=pos else result = timecodes[t][i]<pos end
            if result then track_in_pos=timecodes[t][i] break end
        end
        if track_in_pos>in_pos then in_pos=track_in_pos end
    end
    return in_pos
end

function get_closest_out_point_in_all_selected_tracks(pos) --next=0 point has to be <=pos, next=1 point has to be <pos
    out_pos=last_timecode --get last timecode (project end)
    track_out_pos=out_pos
    for t=1,number_of_tracks_to_scan,1 do
        for i=1, #timecodes[t],1 do
            if timecodes[t][i]>pos then
                track_out_pos=timecodes[t][i]
                break
            end
        end
        if track_out_pos<out_pos then out_pos=track_out_pos end
    end
    return out_pos
end

function is_this_edit_in_all_selected_tracks(pos)
    found_in_tracks=0
    for t=1,number_of_tracks_to_scan,1 do
        for i=1,#timecodes[t], 1 do
            if timecodes[t][i]==pos then
                found_in_tracks=found_in_tracks+1
                break
            end
        end
        if t>found_in_tracks then
            return 0
        end
    end
    return 1
end

function clear_all_in_and_out_markers()
    retval, marker_count, regions_count = reaper.CountProjectMarkers(0) -- get number of markers
    for i=marker_count-1,0,-1 do -- count backwards, so numbering of markers does not change!
        index, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i) -- get name of marker i
        if name == " [ in" or name == " out ]" then
            reaper.DeleteProjectMarkerByIndex(0, index-1) -- delete marker if it is a IN or OUT marker
        end
    end
end

function main()
    reaper.Undo_BeginBlock()
        timecodes={} -- array holding all edit timecodes [track][itemnumber]
        tracks_count=reaper.GetNumTracks()
        selected_tracks_count=reaper.CountSelectedTracks(0)
        if selected_tracks_count>0 then number_of_tracks_to_scan=selected_tracks_count else number_of_tracks_to_scan=tracks_count     end
        last_timecode=get_last_timecode()
        
        playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits
        if playstate==1 then reaper.Main_OnCommand(1008,0) reaper.Main_OnCommand(1016,0) end --stop as mediacomposer does (do we need that?)
        if playstate==1 or playstate==4 then position=reaper.GetPlayPosition() else position=reaper.GetCursorPosition() end --get cursor position
        
        --find in and out points
        for t=1,number_of_tracks_to_scan,1 do
            timecodes[t]={}
            if selected_tracks_count>0 then 
                Track= reaper.GetSelectedTrack(0,t-1) --get a selected track
            else
                Track= reaper.GetTrack(0,t-1) --get track
            end
            items_count=reaper.GetTrackNumMediaItems(Track) --count items in track
           
            --analyse this track (collect all start and end points of all items)
            counter=0
            for i=1,items_count,1 do
                counter=counter+1
                mediaitem=reaper.GetTrackMediaItem(Track, i-1)
                out_point_last=out_point
                in_point=reaper.GetMediaItemInfo_Value(mediaitem, "D_POSITION")
                out_point=in_point + reaper.GetMediaItemInfo_Value(mediaitem, "D_LENGTH")
                if (i>1) and (in_point>out_point_last) then --check if there is a gap
                    timecodes[t][counter]=out_point_last
                    counter=counter+1
                end
                timecodes[t][counter]=in_point
            end
            timecodes[t][counter+1]=out_point --set last edit point to list
        end
        
        if selected_tracks_count>0 then --normal operation: there are selected tracks
            --search the closest common IN Point to the cursor position in all tracks
            in_point=position
            first=0    
            while true do       
                in_point=get_closest_in_point_in_all_selected_tracks(in_point,first)
                first=1
                if is_this_edit_in_all_selected_tracks(in_point)==1 or in_point==0 then
                    break
                end
            end
        
            --search the closest common OUT point to the cursor pos
            out_point=position
            while true do        
                out_point=get_closest_out_point_in_all_selected_tracks(out_point)
                if is_this_edit_in_all_selected_tracks(out_point)==1 or out_point==last_timecode then
                    if out_point<=in_point then out_point = last_timecode end
                    break
                end
            end
                
        elseif tracks_count>0 then --no tracks selected, but there are tracks
            in_point=get_closest_in_point_in_all_selected_tracks(position,1)
            out_point=get_closest_out_point_in_all_selected_tracks(position)
        end
        
        --set new time selection
        retval, retval2 = reaper.GetSet_LoopTimeRange(1,0,in_point,out_point,0)
        
        clear_all_in_and_out_markers()
        
        --set new markers
        reaper.AddProjectMarker2(0, false, in_point, 0, " [ in", 0, 0xFFFF00|0x1000000) -- set marker
        reaper.AddProjectMarker2(0, false, out_point, 0, " out ]", 0, 0xFFFF00|0x1000000) -- set marker
        
    reaper.Undo_EndBlock("Mark Clip (fernsehmuell script)", -1)
end -- main function end

function start()
    if get_position()<=get_last_timecode() then
      main()
    end
end

reaper.defer(start)







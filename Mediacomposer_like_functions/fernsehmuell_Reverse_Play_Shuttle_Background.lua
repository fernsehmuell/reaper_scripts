-- @version 1.0
-- @author Udo Sauer
-- @changelog
--   Initial release

debug=false
function dbg(text)
    if debug then reaper.ShowConsoleMsg(tostring(text).."\n") end
end

function get_position()
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits
    if playstate==1 or playstate==4 then
        return reaper.GetPlayPosition()
    else
        return reaper.GetCursorPosition()
    end
end

function is_playing_reverse()
    retval,value=reaper.GetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle")  --check if reverse playing
    if not tonumber(value) then value="0" end
    if value=="1" then
        return 1
    elseif value=="2" then
        return 2
    elseif value=="3" then
        return 3
    else
        return 0
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

function check_position() --check if cursor is past the last edit, if so goto to lastedit -0.1 sec.
    start_position=get_position() --get cursor position
    end_position=get_last_timecode()
    if start_position>=end_position then
        start_position=math.max(0,end_position-0.1)
    end
    reaper.MoveEditCursor(start_position-get_position(),0)
end

function init()
    ignoreonexit=0
    speed_list = {1,2,3,5,8}
    max_speed=#speed_list
    speed=1
    reaper.Main_OnCommand(40521, 0) -- set play speed to 1
    reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 1) -- store state in datastore
    starttime=reaper.time_precise() --get actual time
    check_position()
    reaper.OnPlayButton()
    dbg("init_ende")
end

function onexit()
    if ignoreonexit==0 then
        reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 0) -- store state in datastore
        reaper.Main_OnCommand(40521, 0) -- set play speed to 1
        reaper.Main_OnCommand(1007,0) --play
        reaper.Main_OnCommand(1008,0) --pause
        reaper.Main_OnCommand(1016,0) --stop
    end
    
    while reaper.Undo_CanUndo2(0)=="PLAY REVERSE fernsehmuell" or reaper.Undo_CanUndo2(0)=="Playrate Change" or reaper.Undo_CanUndo2(0)=="Set project playspeed"do
      reaper.Undo_DoUndo2(0)
    end
    
end

function runloop() --BACKGROUND Loop
    playstate= reaper.GetPlayState()==1 or reaper.GetPlayState()==2
    dbg(playstate)
    dbg(is_playing_reverse())
    if is_playing_reverse()==2 then --increase speed
        speed=math.min(speed+1, max_speed)
        starttime=reaper.time_precise() --get actual time after speedchange!
        reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 1) -- store state in datastore
        start_position=get_position()
        reaper.Main_OnCommand(1008,0) --pause
    end

    if is_playing_reverse()==1 and playstate and reaper.GetCursorPosition()>0 then --reverse playing -> move cursor
        time_passed=(reaper.time_precise()-starttime) * speed_list[speed]
        reaper.MoveEditCursor(start_position-time_passed-reaper.GetCursorPosition(), 0)
        reaper.OnPlayButton()
        reaper.CSurf_OnPlayRateChange(1.0+speed_list[speed]/10000.0)
        reaper.defer(runloop) -- restart loop
    end

    if is_playing_reverse()==3 then --play was pressed: stop reverse playing and play forward
        reaper.Main_OnCommand(40521, 0) -- set play speed to 1
        reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 0) -- store state in datastore    
        reaper.Main_OnCommand(1008,0) --pause
        reaper.Main_OnCommand(1016,0) --stop
        reaper.OnPlayButton() --play
        ignoreonexit=1
    end
end

init()
reaper.atexit(onexit)
reaper.defer(runloop)


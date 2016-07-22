function incr_pbrate(n) -- increase rate ~6% n times
    n=math.min(n,200) -- limit n to 200
    for i=1, n, 1 do
      reaper.Main_OnCommand(40522, 0) -- incr playrate by ~6%
    end  
end

function is_playing_reverse()
    retval,value=reaper.GetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle")  --check if reverse playing
    if not tonumber(value) then value="0" end
    if value=="1" then
        return 1
    elseif value=="2" then
        return 2
    else
        return 0
    end
end

function stop_reverse_loop()
    reaper.SetProjExtState(0, "Fernsehmuell", "Reverse_Play_Shuttle", 3) -- store state in datastore, no reverse play
end

function init_function()
    reaper.Undo_BeginBlock()
    if is_playing_reverse()>0 then stop_reverse_loop() return 5 end --reaper.defer(stop_reverse_loop) end
    playstate=reaper.GetPlayState() --0 stop, 1 play, 2 pause, 4 rec possible to combine bits

    if playstate==1 then -- reaper is playing
        playrate=reaper.Master_GetPlayRate(0) -- read playrate
        if playrate<1 then reaper.CSurf_OnPlayRateChange(1.0) end --  if rate<1 set playrate=1
        if math.floor(playrate+0.5)==1 then reaper.CSurf_OnPlayRateChange(2.0) end --  if rate is 1x incr to 2x
        if math.floor(playrate+0.5)==2 then reaper.CSurf_OnPlayRateChange(3.0)  end --  if rate is 2x incr. to ~3x
        if math.floor(playrate+0.5)==3 then reaper.CSurf_OnPlayRateChange(3.9685) reaper.defer(incr_pbrate(4)) end --  if rate is 3x incr. to ~5x
        if math.floor(playrate+0.5)==5 then reaper.CSurf_OnPlayRateChange(4.0) reaper.defer(incr_pbrate(12)) end --  if rate is 5x incr. to ~8x
    elseif playstate==0 or playstate==2 then -- reaper ist paused or stopped
        reaper.CSurf_OnPlayRateChange(1.0)
        reaper.Main_OnCommand(1007,0) -- play
    end
    reaper.Undo_EndBlock("PLAY fernsehmuell", -1)
    return 1
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

function runloop()
    playstate=reaper.GetPlayState()
    
    if playstate==1 then -- if playing restart loop
        reaper.defer(runloop)
    end
    
    if playstate==0 or playstate==2 then -- STOP/PAUSE -> change playrate to 1 and reset all undo points
        if reaper.GetPlayPosition()+0.3 >=get_last_timecode() then
            reaper.Main_OnCommand(40043,0)
        end 
        reaper.CSurf_OnPlayRateChange(1)
        undo_done=0
        while reaper.Undo_CanUndo2(0)=="PLAY fernsehmuell" or reaper.Undo_CanUndo2(0)=="Playrate Change" do
            reaper.Undo_DoUndo2(0)
        end
    end
end

if init_function()==1 then --if rev=1 run loop, else just leave (ending loop)
    reaper.defer(runloop) -- run without generating an undo point
end

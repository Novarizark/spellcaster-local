begin
    ; regrid x, y
    reg_x=360
    reg_y=181

    ; mon days
    mon_days=(/-999, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)

    ; raw in
    raw_data="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/clim/hindcast/t2m.46day.2017-01-21.ecmwf.s2s.nc"
    raw_in=addfile(raw_data, "r")
    ; var1 (esm, fcst_time, lat0, lon0)
    var1=raw_in->TMP_P61_L103_GLL0_avg24h
    
    time0=raw_in->forecast_time0

    ini_time_str=str_strip(var1@initial_time)

    ; initime_date(0) mm/dd/yyyy
    initime_date=str_split(ini_time_str, " ")
    
    ; array(0)  mm
    ; array(1)  dd
    ; array(2)  yyyy (hh:MM)
    ini_time_array=str_split(ini_time_str,"/")
    mm=stringtoint(ini_time_array(0))
    dd=stringtoint(ini_time_array(1))

    tmp_array=str_split(ini_time_array(2)," ")
    yyyy=stringtoint(tmp_array(0))

    day_rank=day_of_year(yyyy,mm,dd)
    print(day_rank)
    
    if (mm .lt. 12) then
        next_mon=mm+1
        end_mon_day_rank=day_of_year(yyyy,mm+1, 1)
    else
        next_mon=1
        end_mon_day_rank=day_of_year(yyyy,12, 31)+1
    end if

    ; use new mon first day rank minus ini time day to get new mon start position in fcst_time
    new_mon_strt_pos=end_mon_day_rank-day_rank
    new_mon_end_pos=new_mon_strt_pos+mon_days(next_mon)-1
    if (new_mon_end_pos .gt. 45) then
        new_mon_end_pos=45
    end if
    ;print(new_mon_strt_pos)
    ;print(new_mon_end_pos)
    time0=time0-24 ; shift time pointer 24 hr to represtent the correct pos of daily mean
    time0@units="hours since "+yyyy+"-"+mm+"-"+dd
    print(cd_calendar(time0,-2))
    

    ; calculate T+1 mean (esm, lat, lon)
    var_next_mon_mean=dim_avg_n_Wrap(var1(new_mon_strt_pos:new_mon_end_pos,:,:),0 )
    ;var_next_mon_mean=dim_avg_n_Wrap(var1(:, new_mon_strt_pos:new_mon_end_pos,:,:),1 )
    ;var_next_mon_mean:=f2fsh_Wrap(var_next_mon_mean, (/reg_y,reg_x/))
    printVarSummary(var_next_mon_mean)
  
    hdl=systemfunc("rm ../../data/realtime/T2m.pro.ECS2S.nextmon.mean.nc")
    out_file=addfile("../../data/realtime/T2m.pro.ECS2S.nextmon.mean.nc","c")
    var_next_mon_mean&lat_0=var_next_mon_mean&lat_0(::-1)
    out_file->T2m=var_next_mon_mean

    next_mon@long_name="the predicted month indicator, 1-Jan, 12-Dec"
    out_file->fcst_mon=next_mon
end

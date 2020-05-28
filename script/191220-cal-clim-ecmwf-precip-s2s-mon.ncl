;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"

begin
    
    var="precip" 
    n_date=33
    frq_per_day=4
    ; mon days
    mon_days=(/-999, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)


    datalist="../data/clim/hindcast/datalist"
    rec_date = asciiread(datalist,(/n_date/),"string")
    do ii=0,n_date-1
        
        all_files=systemfunc("ls ../data/clim/hindcast/"+var+"*"+rec_date(ii))
        files_hdl=addfiles(all_files,"r")
        
        ListSetType (files_hdl, "join")             ; concatenate or "merge" (default)
        var1:=files_hdl[:]->TPRATE_P61_L1_GLL0_acc
        
        time0=files_hdl[0]->forecast_time0

        ini_time_str=str_strip(var1@initial_time)
        print(""+ini_time_str)
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
        ;print(day_rank)
        
        if (mm .lt. 12) then
            next_mon=mm+1
            end_mon_day_rank=day_of_year(yyyy,mm+1, 1)
        else
            next_mon=1
            end_mon_day_rank=(day_of_year(yyyy,12, 31)+1)
        end if

        ; use new mon first day rank minus ini time day to get new mon start position in fcst_time
        new_mon_strt_pos=frq_per_day*(end_mon_day_rank-day_rank)
        new_mon_end_pos=frq_per_day*(end_mon_day_rank-day_rank+mon_days(next_mon))
        if (new_mon_end_pos .gt. 45*frq_per_day) then
            new_mon_end_pos=45*frq_per_day
        end if
        print(new_mon_strt_pos)
        print(new_mon_end_pos)
        time0@units="hours since "+yyyy+"-"+mm+"-"+dd
        calendar=cd_calendar(time0,-3)
        print(""+calendar(new_mon_strt_pos)+"-->"+calendar(new_mon_end_pos)) 
        var1_acc:=var1(:,0,:,:)
        var1_acc=var1(:,new_mon_end_pos,:,:)-var1(:,new_mon_strt_pos,:,:)
        var1_acc:=dim_avg_n_Wrap(var1_acc,0)
        hdl=systemfunc("rm ../data/clim/"+var+".nextmon.clim."+rec_date(ii))
        out_file=addfile("../data/clim/"+var+".nextmon.clim."+rec_date(ii),"c")
        out_file->precip=var1_acc

        next_mon@long_name="the predicted month indicator, 1-Jan, 12-Dec"
        out_file->fcst_mon=next_mon

    end do
        
end





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
    
    var="t2m" 


    datalist="../data/clim/hindcast/datalist"
    rec_date = asciiread(datalist,(/33/),"string")
    dayrank=new((/33/), "integer")
    do ii=0, 32
        ini_time_array=str_split(rec_date(ii), "-")
        ; array(0)  mm
        ; array(1)  dd
        mm=stringtoint(ini_time_array(0))
        dd=stringtoint(ini_time_array(1))
        dayrank(ii)=day_of_year(1999,mm,dd)
    end do
    
    all_files=systemfunc("ls ../data/clim/"+var+".nextmon.clim.[0-9]*")
    in_hdl=addfiles(all_files,"r")
    ListSetType (in_hdl, "join")             ; concatenate or "merge" (default)
    var1:=in_hdl[:]->T2m
    var1!0="ini_day"
    var1&ini_day=dayrank
    fcst=in_hdl[:]->fcst_mon
    hdl=systemfunc("rm ../data/clim/"+var+".nextmon.clim.ecmwf.s2s.nc")
    out_file=addfile("../data/clim/"+var+".nextmon.clim.ecmwf.s2s.nc","c")
    out_file->t2m=var1
    out_file->fcst_mon=fcst
end





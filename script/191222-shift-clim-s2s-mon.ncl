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
    n_date=33

    ; s2s in      
    s2s_clim=addfile("../data/clim/t2m.nextmon.clim.ecmwf.s2s.nc","r")
    var1=s2s_clim->$var$
    day_rank=s2s_clim->ini_day
    fcst=s2s_clim->fcst_mon
    ; era5 81-10 in
    era5_30=addfile("../data/clim/T2m.clim.REA5.1981-2010.nc","r")
    clim_var1=era5_30->T2_CLIM
    ; era5 99-18 in
    era5_20=addfile("../data/clim/T2m.clim.ERA5.1999-2018.nc","r")
    clim_var2=era5_20->T2_CLIM

    diff_clim=clim_var1
    diff_clim=(/clim_var2-clim_var1/)
    diff_clim:=f2fsh_Wrap(diff_clim,(/121,240/))
    
    do ii=0,n_date-1
        var1(ii,:,:)=var1(ii,:,:)-diff_clim(fcst(ii)-1,:,:)
    end do

    hdl=systemfunc("rm ../data/clim/"+var+".nextmon.clim.s2s.1981-2010.nc")
    out_file=addfile("../data/clim/"+var+".nextmon.clim.s2s.1981-2010.nc","c")
    out_file->$var$=var1
    out_file->ini_day=day_rank
    out_file->fcst_mon=fcst
        
end





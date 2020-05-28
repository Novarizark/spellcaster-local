
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    
    ;Fig name
    g_fig_name="../fig/forecast-era5_map"
    
    ;Font size
    g_font=0.012

    ;Countor Level for Stations
    cn_bin=0.1
    cn_levels=5

    ; *** EC hindcast clim in ***
    clim_in=addfile("/home/yhuangci/lee/workspace/spellcaster-local/data/clim/T2m.clim.REA5.1981-2010.nc","r")
    clim_var=clim_in->T2_CLIM

    ; *** T+1 EC S2S in ***
    raw_data="/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/era5/sfc201912.nc"
    raw_in=addfile(raw_data, "r")
    
    ; var1(n_esm, nlat0, nlon0)
    var=raw_in->2T_GDS0_SFC
    ; fcst_mon is the flag of which mon is predicted, 1-Jan and 12-Dec
    fcst_mon=12
    
    ; ----get ini_time day_rank
    ini_time_str=str_strip(var@initial_time)
    
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

    ini_day=day_of_year(yyyy,mm,dd)
    
    ;Fig title
    fig_title=month_abbr(fcst_mon)+" T2m Anom"

   
    dims=dimsizes(var)
    n_esm=dims(0)

    ; *** Sta in ***
    pdata_fn     = "../data/station/south_china_result.csv"
    rec=readAsciiTable(pdata_fn, 5, "float",1 )
    
    ; rec
    ; 0     station number
    ; 1     lat*100
    ; 2     lon*100
    ; 3     alt in m 
    ; 4     pc score
    n_sta=dimsizes(rec)
    n_sta:=n_sta(0)

    ; calculate 
    var_ano=var
    var_ano=var-clim_var(fcst_mon-1,:,:)

    var_ano_mean=dim_avg_n_Wrap(var_ano,0)
    printVarSummary(var_ano)    
;**********************************************************************************************
    wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

    plot = new((/1/),graphic)

    ;color table
    color_table="CBR_coldhot"
    ;color_table="radar"

    gsn_define_colormap(wks,color_table) ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ; gsn_define_colormap(wks,"NCV_jaisnd")
    ; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ; gsn_define_colormap(wks,"MPL_ocean")
    ; gsn_define_colormap(wks,"MPL_Blues")

    cmap = read_colormap_file(color_table)    ; returns 254 x 4 array (R, G, B, T) dim4-Transparency
    rgba = span_color_rgba(cmap,cn_levels)
    rgb_all=new((/cn_levels,4/),"float")
   ; rgb_all(0,:)=(/0.5,0.5,0.5,1.0/) 
    rgb_all(:,:)=(/rgba/)


  res                  = True       ; use plot options

  res@gsnFrame         = False
  res@gsnDraw  = False
  res@gsnLeftString =  fig_title
  ;res@gsnCenterString = "PM2.5_diff(no-gz_test)"
  res@gsnRightStringFontHeightF=0.01
  res@gsnRightString = "Updated On: "+systemfunc("date")
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
 
  res@cnFillOn=True
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnLevels = (/-2, -1,-0.5,0.5, 1, 2/) ; fake values to erease shading colors
  ;res@cnLevels = (/-200, -100, 100, 200/) ; fake values to erease shading colors
  ;res@lbLabelStrings      =(/"-2.0","-1.0","+1.0","+2.0"/)

  res@mpMinLatF            = 16        ; zoom in on map
  res@mpMaxLatF            = 27
  res@mpMinLonF            = 104
  res@mpMaxLonF            = 118
 
;  res@mpMinLatF            = 20       ; zoom in on map
;  res@mpMaxLatF            = 60
;  res@mpMinLonF            = 90
;  res@mpMaxLonF            = 140



  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 4.0
  res@tmYLTickSpacingF = 2.0

    res@tmXBLabelFontHeightF =g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
    res@tiMainFontHeightF= g_font
    ;res@lbLabelFontHeightF = 0.02
    ;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
    res@tmXBMajorThicknessF = 2.0
    res@tmYLMajorThicknessF = 2.0
    res@tmXBMinorThicknessF = 2.0
    res@tmYLMinorThicknessF = 2.0
    res@tmBorderThicknessF = 2.0
    res@tmYLMajorLengthF = 0.002


res@mpFillOn                = True
res@mpOutlineOn             = False  ; Use outlines from shapefile
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
res@mpOceanFillColor        = "blue"
;res@mpOutlineBoundarySets   = "NoBoundaries"

  plot = gsn_csm_contour_map_ce(wks,var_ano, res) ; dim1 = 0 for lvl = 0
;  plot2 = gsn_csm_map(wks, res) ; dim1 = 0 for lvl = 0
;  overlay(plot,plot2)
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True      ; draw diqujie or not

  chinamap = add_china_map(wks,plot,cnres)

  draw(plot)
  frame(wks)
end

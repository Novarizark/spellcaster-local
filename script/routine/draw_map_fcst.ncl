
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    ;Fig name
    g_fig_name="../../fig/forecast_map"
    
    ;Fig title
    fig_title="T2m Anom"

    ;Font size
    g_font=0.012

    ;Countor Level for Stations
    cn_bin=0.1
    cn_levels=11


    ; *** T+1 EC S2S in ***
    raw_data="../../data/realtime/T2m.pro.ECS2S.nextmon.mean.nc"
    raw_in=addfile(raw_data, "r")
    
    ; var1(n_esm, nlat0, nlon0)
    var=raw_in->T2m
    ; fcst_mon is the flag of which mon is predicted, 1-Jan and 12-Dec
    fcst_mon=raw_in->fcst_mon
    
    dims=dimsizes(var)
    n_esm=dims(0)

    ; *** Clim in ***
    clim_data=addfile("../../data/clim/T2m.clim.interim.1981-2010.nc","r")
    var_clim=clim_data->T2_CLIM
    

    ; *** Sta in ***
    pdata_fn     = "../../data/station/south_china_result.csv"
    rec=readAsciiTable(pdata_fn, 5, "float",1 )
    
    ; rec
    ; 0     station number
    ; 1     lat*100
    ; 2     lon*100
    ; 3     alt in m 
    ; 2     pc score
    n_sta=dimsizes(rec)
    n_sta:=n_sta(0)


    ; calculate 
    var_mean=dim_avg_n_Wrap(var, 0)
    var_ano=var_mean
    var_ano=var_mean-var_clim(fcst_mon-1,:,:)
    ;print(var_ano(0,:,:))    
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
  res@gsnRightString = "Updated On: "+systemfunc("date")
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
 
  res@cnFillOn=True
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnLevels=(/5.0,7.0,9.0,11.0,13.0,15.0,17.0,19.0,21.0/)+273.15
  ;  res@cnLevels = (/-2, -1, 1, 2/) ; fake values to erease shading colors
  ;res@cnLevels = (/-200, -100, 100, 200/) ; fake values to erease shading colors
  ;res@lbLabelStrings      =(/"-2.0","-1.0","+1.0","+2.0"/)

;  res@mpMinLatF            = 16        ; zoom in on map
;  res@mpMaxLatF            = 27
;  res@mpMinLonF            = 104
;  res@mpMaxLonF            = 118
 
  res@mpMinLatF            = 20       ; zoom in on map
  res@mpMaxLatF            = 60
  res@mpMinLonF            = 80
  res@mpMaxLonF            = 140



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
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"

;  plot = gsn_csm_contour_map_ce(wks,var_mean, res) ; dim1 = 0 for lvl = 0
  plot = gsn_csm_contour_map_ce(wks,var_clim(10,:,:), res) ; dim1 = 0 for lvl = 0
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

;  chinamap = add_china_map(wks,plot,cnres)


  gsres=True
  gsres@gsMarkerIndex=16
  gsres@gsMarkerSizeF      = 0.015
  gsres@gsMarkerThicknessF = 0.7
  gsres_out=gsres
  gsres_out@gsMarkerSizeF      = 0.018
  gsres_out@gsMarkerColor="Black"
  

  draw(plot)
  frame(wks)
end

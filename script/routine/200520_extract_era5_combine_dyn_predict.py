'''
    Script for reorg all time ERA5 data
'''
import os

import numpy as np
import pandas as pd
import xarray as xr
import datetime


#era5_t2m_arch_fn='../../data/era5/test.nc'
era5_t2m_arch_fn='../../data/era5/T2m.mon.REA5.1979-present.nc'
era_clim_file='../../data/era5/T2m.clim.REA5.1981-2010.nc'

#s2s forecast file
s2s_fcst_file='../../data/realtime/CFSv2.T2m.nc'

# meta file
sta_meta_file='../../data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'


# post process blended output
blend_outdir='../../data/all_feature/era-bind-s2s/'


# function defination part
def get_station_df(sta_path):
    '''get station meta info (lat, lon, elev)'''
    df = pd.read_excel(sta_path)
    df=df.dropna()
    return(df)

def conv_deg(deg_str):
    '''convert to degree info'''
    value=int(deg_str)//100
    value=value+(int(deg_str)-value*100)/60
    return(value)

def normalize(np_v): 
    norm = np.linalg.norm(np_v) 
    if norm == 0: 
        return np_v 
    return np_v / norm

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():


    # ERA T2m
    ds = xr.open_dataset(era5_t2m_arch_fn)
    var1 = ds['t2m']
    hist_time= ds['time']
    
    #ERA T2m clim
    ds_clim = xr.open_dataset(era_clim_file)
    clim_var1 = ds_clim['T2_CLIM']
    
    #S2S data
    ds_s2s = xr.open_dataset(s2s_fcst_file)
    fcst_var1=ds_s2s['anom'][0,0,0,:,:]
    fcst_time=ds_s2s['TIME']

    total_mon=len(hist_time.values)
    total_yr=total_mon//12
    res_mon=total_mon-total_yr*12

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
        
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
        #print(sta_num+' '+row['省份']+' '+row['站名'])
        lat_sta=conv_deg(row['纬度(度分)'][0:-1])
        lon_sta=conv_deg(row['经度(度分)'][0:-1])
        var=var1.sel(latitude=lat_sta,longitude=lon_sta,method='nearest')
        clim_var=clim_var1.sel(g0_lat_0=lat_sta,g0_lon_1=lon_sta,method='nearest')
        #print(var.sel(time='2018-01-01').values-clim_var[0].values)
        #repeat clim_series
        clim_series=np.tile(clim_var.values,total_yr)
        var_series=var.values
        ano_series=var_series[0:total_mon-res_mon]-clim_series
        if res_mon > 0:
            res_series=var_series[total_mon-res_mon:]-clim_series[:res_mon]
            ano_series=np.append(ano_series,res_series)
        #ano_series=normalize(ano_series)
        # now blend s2s fcst data
        ano_series=np.append(ano_series, fcst_var1.sel(LAT=lat_sta, LON=lon_sta, method='nearest').values)
        np_time=np.append(hist_time.values, fcst_time.values)
        df =pd.DataFrame(ano_series, index=np_time, columns=['tave_ano'])
        df.to_csv(blend_outdir+sta_num+'.t2m.csv') 


if __name__ == "__main__":
    main()



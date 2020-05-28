'''
    Script for reorg all time GISS data
'''
import os

import numpy as np
import pandas as pd
import xarray as xr
import datetime


giss_t2m_arch_fn='../../data/all_feature/giss.air.mon.ano.nc'

#s2s forecast file
s2s_fcst_file='../../data/realtime/CFSv2.T2m.nc'

# meta file
sta_meta_file='../../data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'

# post process blended output
blend_outdir='../../data/all_feature/giss-bind-s2s/'


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


    # GISS T2m
    ds = xr.open_dataset(giss_t2m_arch_fn)
    var1 = ds['air'].loc['1950-01-01':,:,:]
    hist_time= ds['time'].loc['1950-01-01':]

    
    #S2S data
    ds_s2s = xr.open_dataset(s2s_fcst_file)
    fcst_var1=ds_s2s['anom'][0,0,0,:,:]
    fcst_time=ds_s2s['TIME']

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
        
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
       # print(sta_num+' '+row['省份']+' '+row['站名'])
        lat_sta=conv_deg(row['纬度(度分)'][0:-1])
        lon_sta=conv_deg(row['经度(度分)'][0:-1])
        var=var1.sel(lat=lat_sta,lon=lon_sta,method='nearest')
        #print(var.sel(time='2018-01-01').values)
        ano_series=np.append(var.values, fcst_var1.sel(LAT=lat_sta, LON=lon_sta, method='nearest').values)
        np_time=np.append(hist_time.values, fcst_time.values)
        df =pd.DataFrame(ano_series, index=np_time, columns=['giss_ano'])
        df=df.fillna(0)
        df.to_csv(blend_outdir+sta_num+'.t2m.csv') 


if __name__ == "__main__":
    main()



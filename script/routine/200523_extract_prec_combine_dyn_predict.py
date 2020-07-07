'''
    Script for reorg all time ERA5 data
'''
import os

import numpy as np
import pandas as pd
import xarray as xr
import datetime


# prec/l data
prec_arch_fn='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/precip.land.mon.mean.1x1.nc'

#s2s forecast file
s2s_fcst_file='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/realtime/CFSv2.Prec.nc'

# meta file
sta_meta_file='/disk/hq247/yhuangci/lzhenn/data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'

# post process blended output
blend_outdir='/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/prec-bind-s2s/'


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


    # PREC/L data
    ds = xr.open_dataset(prec_arch_fn)
    var1 = ds['precip'].loc['1979-01-01':,:,:]
    hist_time= ds['time'].loc['1979-01-01':]
    #print(var1.loc['1981-01-01':'2010-12-31',:,:])

    

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
        clim_var = var.loc['1981-01-01':'2010-12-31'].groupby("time.month").mean()
        ano_var = (var.groupby("time.month") - clim_var)
        ano_series=np.concatenate((ano_var.values,np.array((0.0,)),(fcst_var1.sel(LAT=lat_sta, LON=lon_sta, method='nearest').values,)))
        np_time=np.append(hist_time.values, np.datetime64('now'))
        np_time=np.append(np_time, fcst_time.values)
        df =pd.DataFrame(ano_series, index=np_time, columns=['prec_ano'])
        df=df.fillna(0)
        df.to_csv(blend_outdir+sta_num+'.prec.csv') 


if __name__ == "__main__":
    main()



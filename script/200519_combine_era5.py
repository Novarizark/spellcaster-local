'''
    Script for reorg all time ERA5 data
'''

import xarray as xr
import pandas as pd
import datetime

era5_grib_org_prefix='../data/era5/sfc'


append_rank=pd.date_range(start='1979-01',end='2020-01',freq='M')

date_suffix=datetime.datetime.strftime(append_rank[0], '%Y%m')
ds_grib = xr.open_dataset(era5_grib_org_prefix+date_suffix+'.grib', engine='cfgrib', backend_kwargs={'errors': 'ignore'})
var=ds_grib['t2m']
print(var)
#print(var_hist.sel(time=hist_time[-1].values,g0_lat_0=26.5, g0_lon_1=118.0, method='nearest'))

# Step2: Concatenate
for date_itm in append_rank[1:]:
    date_suffix=datetime.datetime.strftime(date_itm, '%Y%m')
    print(date_suffix)
    ds_grib = xr.open_dataset(era5_grib_org_prefix+date_suffix+'.grib', engine='cfgrib', backend_kwargs={'errors': 'ignore'})
    var_tmp=ds_grib['t2m']
    var=xr.concat([var, var_tmp], dim='time')


var.to_netcdf('../data/era5/T2m.mon.REA5.1979-2019.nc')

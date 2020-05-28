'''
    Script for reorg all time ERA5 data
'''

import xarray as xr
import pandas as pd
import datetime

#era5_t2m_arch_fn='../../data/era5/test.nc'
era5_t2m_arch_fn='../../data/era5/T2m.mon.REA5.1979-2019.nc'
era5_t2m_present_fn='../../data/era5/T2m.mon.REA5.1979-present.nc'
era5_grib_org_prefix='../../data/era5/sfc'

# get in previous file
ds= xr.open_dataset(era5_t2m_arch_fn)
var = ds['t2m']
hist_time=ds['time']

append_rank=pd.date_range(start=hist_time[-1].values,end=datetime.datetime.now()+datetime.timedelta(days=15),freq='M')
print(append_rank)

# Step1: Refresh Last Mon
date_suffix=datetime.datetime.strftime(append_rank[0], '%Y%m')
print('refresh '+date_suffix)
ds_grib = xr.open_dataset(era5_grib_org_prefix+date_suffix+'.grib', engine='cfgrib', backend_kwargs={'errors': 'ignore'})
var_tmp=ds_grib['t2m']
var.loc[{'time':hist_time[-1].values}]=var_tmp.values
var_out=var
# Step2: Concatenate
for date_itm in append_rank[1:]:
    date_suffix=datetime.datetime.strftime(date_itm, '%Y%m')
    print('update '+date_suffix)
    ds_grib = xr.open_dataset(era5_grib_org_prefix+date_suffix+'.grib', engine='cfgrib', backend_kwargs={'errors': 'ignore'})
    var_tmp=ds_grib['t2m']
    var_out=xr.concat([var_out, var_tmp], dim='time')

ds.close()
var_out.to_netcdf(era5_t2m_present_fn)

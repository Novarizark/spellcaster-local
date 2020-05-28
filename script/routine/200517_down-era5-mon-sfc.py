import cdsapi
import sys
import datetime

c = cdsapi.Client()

era5_libdir=sys.argv[1]

shift_frame=[0, -1, -2] # -2 mon, -1 mon, +0 mon

datenow=datetime.datetime.now()

for fr in shift_frame:
    year=datenow.year
    mon=('%0.2d' % datenow.month)
    try:
        c.retrieve(
            'reanalysis-era5-single-levels-monthly-means',
                {
            'variable':[
            '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
            '2m_temperature','mean_sea_level_pressure','mean_wave_direction',
            'mean_wave_period','sea_surface_temperature','significant_height_of_combined_wind_waves_and_swell',
            'surface_pressure','total_precipitation'
                ],  
                
                "product_type": "reanalysis",
                'year':str(year),
                'month':mon,
                'format':'grib'
            },
            era5_libdir+'sfc'+str(year)+mon+'.grib')
    except:
        # just another try...
        c.retrieve(
            'reanalysis-era5-single-levels-monthly-means',
                {
            'variable':[
            '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
            '2m_temperature','mean_sea_level_pressure','mean_wave_direction',
            'mean_wave_period','sea_surface_temperature','significant_height_of_combined_wind_waves_and_swell',
            'surface_pressure','total_precipitation'
                ],  
                
                "product_type": "reanalysis",
                'year':str(year),
                'month':mon,
                'format':'grib'
            },
            era5_libdir+'sfc'+str(year)+mon+'.grib')
    datenow=datenow+datetime.timedelta(days=-30)

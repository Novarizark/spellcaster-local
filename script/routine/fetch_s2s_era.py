# -*- coding: UTF-8 -*-
# Try if After 15th and before 25th, True
# then download EC S2S raw data 
#			LZN	
#			Oct 26, 2019

import datetime
import os

#Main Func

def main():
    archive_path='../../data/realtime/s2s_realtime.grib'

    date_lastday=datetime.datetime.now()+datetime.timedelta(days=-1)
    date_str=date_lastday.strftime('%Y%m%d')
    date_str_dash=date_lastday.strftime('%Y-%m-%d')
    date_year=date_str[0:4]
    date_day=date_str[6:]
    if int(date_day)>=15:
        url='http://10.1.64.154/s2s/search/s2sFiledown/s2s_ncc/-s2s-ecmf-'+date_year+'-'+date_str_dash+'/s2s_ecmf_'+date_year+'_'+date_str+'_2t.grib'
        print(url)
        os.system('wget '+url+' -O '+archive_path)
        os.system('ncl_convert2nc '+archive_path+' -o ../../data/realtime/')

if __name__=='__main__':
    main()
















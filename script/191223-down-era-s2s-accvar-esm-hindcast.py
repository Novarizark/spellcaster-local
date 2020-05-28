#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
from datetime import date,timedelta
import pandas as pd

server = ECMWFDataServer()


df_range=pd.read_csv("acc-req-list", sep='\s+',index_col='date')
# generate date list
curr_date=date(2019,1,1)
end_date=date(2019,12,31)
td=timedelta(days=1)
date_lst=[]

while curr_date<=end_date:
    
    if ((curr_date.day > 14) and (curr_date.day<25)) and ((curr_date.weekday() == 0) or (curr_date.weekday()==3)):
        date_lst.append(curr_date) 
    curr_date=curr_date+td

# loop the list
for frame in date_lst:
    frame_str=frame.isoformat()
    frame_mon_day=frame_str[5:]
    print(df_range.loc[frame_mon_day,:])
    for lyear in range(1999,2019):
        hdate=str(lyear)+'-'+frame_mon_day
        tgt_name=hdate
        print(hdate)
        server.retrieve({
            "class": "s2",
            "dataset": "s2s",
            "date": frame_str,
            "expver": "prod",
            "hdate": hdate,
            "levtype": "sfc",
            "model": "glob",
            "number": "1/2/3/4/5/6/7/8/9/10",
            "origin": "ecmf",
            "param": "228228", # total precip
            "step": str(df_range.loc[frame_mon_day,'strt'])+"/"+str(df_range.loc[frame_mon_day,'end']),
            "stream": "enfh",
            "time": "00:00:00",
            "type": "pf",
            "target": "../data/clim/hindcast/precip.46day."+hdate+".esm.nextmon.ecmwf.s2s.grib",
        })

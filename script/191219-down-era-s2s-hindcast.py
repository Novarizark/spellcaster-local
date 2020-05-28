#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
from datetime import date,timedelta

server = ECMWFDataServer()


# generate date list
curr_date=date(2019,10,16)
end_date=date(2019,10,18)
td=timedelta(days=1)
date_lst=[]

while curr_date<=end_date:
    
    if ((curr_date.day > 14) and (curr_date.day<25)) and ((curr_date.weekday() == 0) or (curr_date.weekday()==3)):
        date_lst.append(curr_date) 
    curr_date=curr_date+td


for frame in date_lst:
    frame_str=frame.isoformat()
    frame_mon_day=frame_str[5:]
    for lyear in range(2018,2019):
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
            "param": "167", # 167-t2m
            "step": "0-24/24-48/48-72/72-96/96-120/120-144/144-168/168-192/192-216/216-240/240-264/264-288/288-312/312-336/336-360/360-384/384-408/408-432/432-456/456-480/480-504/504-528/528-552/552-576/576-600/600-624/624-648/648-672/672-696/696-720/720-744/744-768/768-792/792-816/816-840/840-864/864-888/888-912/912-936/936-960/960-984/984-1008/1008-1032/1032-1056/1056-1080/1080-1104",
            "stream": "enfh",
            "time": "00:00:00",
            "type": "pf",
            "target": "../data/clim/hindcast/t2m.46day."+hdate+".esm.ecmwf.s2s.grib",
        })
    # end year loop
    #exit()
# end date loop

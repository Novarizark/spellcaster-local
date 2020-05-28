#! /usr/bin/env python
#  Deal with splined data 
#   
#               L_Zealot
#               May 17, 2020
#               Clear Water Bay, HK 
#
import numpy as np
import pandas as pd
import datetime
import sys
#-------------------------------------
# Function Definition Part
#-------------------------------------
def parse_line(line, df):
    '''Let's parse the individual line'''
    try:
        year=int(line[0:4])
    except:
        return(df)

    line0=line[4:]
    for ii in range(0, 12):
        date0=datetime.date(year,ii+1,1)
        value0=float(line0[7*ii:7*ii+7])
        if value0 > -999.0:
            df.loc[date0]=value0
    return(df)

#----------------------------------------------------
# Main function
#----------------------------------------------------
def main():

    # Start Time 
    start_time = '1979-01'
    
    feature_libdir=sys.argv[1]
    time_frames=pd.date_range(start=start_time, end=datetime.datetime.today(), freq='M').to_period()
    df = pd.DataFrame(np.nan, index=time_frames, columns=['qbo'])
    
    
    with open (feature_libdir+'qbo.u50.ano.index', 'r') as fr:
        lines=fr.readlines()
        for line in lines:
            df = parse_line(line, df)
    df.to_csv(feature_libdir+'qbo.u50.index.csv')

if __name__ == "__main__":
    main()





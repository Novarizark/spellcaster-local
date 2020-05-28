#! /usr/bin/env python
#   Try sklearn lasso model 
#   
#               L_Zealot
#               Aug 16, 2019
#               Guangzhou, GD
#

import os
import json

import numpy as np
import pandas as pd
from sklearn.linear_model import Lasso
import joblib
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import datetime
from matplotlib.pyplot import savefig


# function defination part
def get_station_df(sta_path):
    '''get station meta info (lat, lon, elev)'''
    df = pd.read_excel(sta_path)
    df=df.dropna()
    return(df)


def construct_lag_array2d(df, lag_step):
    """
        construct lag array 2d (n features x m samples)
        from -lag_step to -1
    """
    org_col_list=df.columns.values.tolist()
    col_list=[itm+'_lag1' for itm in org_col_list]
    X_all = np.array(df.values)
    X=X_all[:-lag_step,:]    
    for ii in range(1, lag_step):
        X_tmp=X_all[ii:(-lag_step+ii),:]
        X=np.concatenate((X,X_tmp),1)
        new_list=[itm+'_lag'+str(ii+1) for itm in org_col_list]
        col_list.extend(new_list)
    return X, col_list

def construct_lag_array1d(df, lag_step,array_name):
    """
        construct lag array 1d (1 feature and m samples)
        from -lag_step to -1
        args:
            df          dataframe contains series
            lag_step    how long the lag takes
            array_name  series name, e.g. 'aao_idx'
        returns:
            X           lagged series, 2-D
            col_list    col names
    """
    org_col_list=list(array_name)
    col_list=[array_name+'_lag1']
    
    X_all = np.array(df.values)
    X=X_all[:-lag_step]
    X=X[:,np.newaxis]   # change to 2-D
    for ii in range(1, lag_step):
        X_tmp=X_all[ii:(-lag_step+ii)]
        X_tmp=X_tmp[:,np.newaxis]
        X=np.concatenate((X,X_tmp),axis=1)
        new_list=[array_name+'_lag'+str(ii+1)]
        col_list.extend(new_list)
    return X, col_list

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------
def main():
    # Station Number
    tgt_sta_num='59287'

    # meta file
    sta_meta_file='../../data/station/SURF_CLI_CHN_PRE_MUT_HOMO_STATION.xls'
    
    # Label Dir
    label_dir='../../data/station/mon/Tave/'

    # Feature lib
    cpc_prim_lib_dir="../../data/all_feature/all_org_features.csv"
    era5_lib_dir="../../data/all_feature/era-bind-s2s/"
    giss_lib_dir="../../data/all_feature/giss-bind-s2s/"
    
    # Model Storage Dir
    model_out_dir='../../data/model_archive/'
    
    # Result Dict File
    result_in_file='../../json_base/whole_china_t2m_result.json'
   
    # Prediction Output
    out_dir='../../result/'

    # Model Parameter
    lag_step=24
    data_feed_year=10    # feed in previous years

    # define label start time according to lag step
    label_init_date=datetime.datetime.now()
    # 
    start_year=label_init_date.year-data_feed_year
    label_start_date=datetime.datetime.strptime(str(start_year)+'0101', '%Y%m%d')

    # magic_alpha from lassoCV results
    #magic_alpha=0.802779265085
    #magic_alpha=1.0
    #magic_alpha=1.07682989906 train_data
    
# ------------------------ Data Loading ----------------------

    # Get in Station meta
    sta_df=get_station_df(sta_meta_file)
    
    # Get in lasso json dict 
    with open(result_in_file) as f:
        result_dic=json.load(f)
    

    # CPC Features
    df_cpc_prim         =  pd.read_csv(cpc_prim_lib_dir, index_col=0, parse_dates=True)
    df_cpc_prim = df_cpc_prim[df_cpc_prim.index.year>=start_year]
    df_cpc_prim.loc[label_init_date]=df_cpc_prim.iloc[-1].values
    df_cpc_prim_lag, cpc_prim_list=construct_lag_array2d(df_cpc_prim, lag_step)
   
    X_features = np.array(df_cpc_prim_lag) 
    col_list_X=cpc_prim_list
    # 74 idx
    #df_feature0=dcomp_seasonality(df_tmp_features, True)
    #df_feature0=df_feature0.dropna(axis=1, how='any')
    #df_feature0=df_feature0[df_feature0.index.year>=start_year]
    #X, col_list_X=construct_lag_array2d(df_feature0, lag_step)

    # 
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag,X),axis=1) # with 74 cir index
    #X_features = np.concatenate((cpc_aao_lag, cpc_prim_lag),axis=1) # without 74 cir index
    #col_list_X.extend(cpc_prim_list)
    #col_list_X.extend(col_list_X)

    icount=0
    list_sta=[]
    list_result=[]
    for idx, row in sta_df.iterrows():
        sta_num=str(int(row['区站号']))
        print(sta_num+' '+row['省份']+' '+row['站名'])
        
        try:
            itm=result_dic[sta_num]
            lasso_wgt=itm['sign_score']
        except:
            print('Cannot find '+sta_num+' in json dict, use default weight')
            lasso_wgt=0.0
        

        if lasso_wgt > 0.0:
            # Read station-based feature, era5 deg in anom, not era5 is combined with dyn forecast
            # so it has T+1 (lag0) info
            df_era5=pd.read_csv(era5_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
            df_era5=df_era5[df_era5.index.year>=start_year]
            
            # note we remove the combined part
            lst_era5_lag, col_era5_lag=construct_lag_array1d(df_era5.loc[:label_init_date], lag_step, 'era5') 
            lst_era5_lag=np.squeeze(lst_era5_lag)
            
            # giss deg in anom, also combined dyn forecast, treat it as lag1 when conducting lag generation
            df_giss=pd.read_csv(giss_lib_dir+sta_num+'.t2m.csv', index_col=0, parse_dates=True)
            df_giss=df_giss[df_giss.index.year>=start_year]
            lst_giss_lag, col_giss_lag=construct_lag_array1d(df_giss, lag_step, 'giss') 
            lst_giss_lag=np.squeeze(lst_giss_lag)
            
            X = np.concatenate((X_features, lst_era5_lag, lst_giss_lag),axis=1) # with 74 cir index
            col_list_X.extend(col_era5_lag)
            col_list_X.extend(col_giss_lag)
            (n_samples, n_features)=X.shape

                   
            lasso_model = joblib.load( model_out_dir+sta_num+'.t2m.model')

            # make prediction
            predict_Y=lasso_model.predict(X)
            
            # std adjustment by observations
            df_lbl=pd.read_csv(label_dir+sta_num+'.txt',index_col=0, parse_dates=True)
            df_lbl=df_lbl[(df_lbl.index >= label_start_date)]
            df_lbl = df_lbl.groupby(df_lbl.index.month).transform(lambda x: (x-x.mean())) # calculate monthly anomaly
            predict_Y=predict_Y*np.std(df_lbl.values)/np.std(predict_Y)
        # end if 
        
        #sigmoid function
        base_sigm=10.0*lasso_wgt-6.0
        sigm = 1./(1. + np.exp(-base_sigm))
        y_lasso=predict_Y[-1]*lasso_wgt*sigm
        
        #stiff boundary
        if abs(y_lasso)>8.0:
            y_lasso=0.0
            lasso_wgt=0.0
        y_final=y_lasso+(1.0-lasso_wgt*sigm)*df_giss.iloc[-1].values
        
        print("lasso: %4.2f; dyn:%4.2f; final:%4.2f" % (y_lasso, df_giss.iloc[-1].values[0],y_final))
        list_sta.append(sta_num)
        list_result.append([y_lasso, df_giss.iloc[-1].values[0],y_final[0]])
#        if icount==50:
#            break
        icount=icount+1
    # end for
    np_result=np.array(list_result)
    df =pd.DataFrame(np_result, index=list_sta, columns=['lasso', 'dyn', 'final'])
    df.to_csv(out_dir+'fcst.I'+label_init_date.strftime('%y%m%d')+'.P'+df_giss.index[-1].strftime('%y%m')+'.t2m.csv')
if __name__ == "__main__":
    main()




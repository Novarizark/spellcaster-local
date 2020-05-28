'''
    Script for reorg all time cpc data
'''
import pandas as pd
import numpy as np
import datetime


# global constant
cpc_prim_lib_dir='../../data/all_feature/'

cpc_prim_lib=['detrend.nino34.ascii.txt', 'monthly.aao.index.b79.current.ascii',
                'nao_index.tim', 'pna_index.tim', 'qbo.u50.index.csv', 
                'epnp_index.tim', 'monthly.ao.index.b50.current.ascii',
                'poleur_index.tim',  'wp_index.tim']


def load_nino(path_cpc_idx, cpc_lib, strt_yr):
    '''load nino idx'''
    df_cpc_idx_raw=pd.read_csv(path_cpc_idx+cpc_lib, sep='\s+')
    df_cpc_idx_raw=df_cpc_idx_raw[(df_cpc_idx_raw['YR']>=strt_yr)]
    return(df_cpc_idx_raw['ANOM'].values)

def load_cpc_idx(path_cpc_idx, cpc_lib, strt_yr, strt_line, data_col):
    '''dict map for loading cpc idx'''
    df_cpc_idx_raw=pd.read_csv(path_cpc_idx+cpc_lib, sep='\s+', header=strt_line)
    df_cpc_idx_raw=df_cpc_idx_raw[(df_cpc_idx_raw.iloc[:,0]>=strt_yr)]
    return df_cpc_idx_raw.iloc[:,2].values

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

def main():
    # pd date_range
    date_series=pd.date_range(start='1979-01',end=datetime.datetime.now(),freq='M')
    #dict map for loading cpc idx


    # init np array
    np_idx_array=np.zeros((len(cpc_prim_lib),len(date_series)))
    icount=0
    for itm in cpc_prim_lib:
        if itm=='detrend.nino34.ascii.txt':
            np_cpc_prim =load_nino(cpc_prim_lib_dir, itm, date_series[0].year)
        elif itm=='monthly.aao.index.b79.current.ascii':        
            np_cpc_prim =load_cpc_idx(cpc_prim_lib_dir, itm, date_series[0].year,None,3)
        elif itm=='monthly.ao.index.b50.current.ascii':        
            np_cpc_prim =load_cpc_idx(cpc_prim_lib_dir, itm, date_series[0].year,None,3)
        elif itm=='qbo.u50.index.csv':        
            df_cpc_prim=pd.read_csv(cpc_prim_lib_dir+itm)
            np_cpc_prim=df_cpc_prim['qbo'].values
        else:
            np_cpc_prim =load_cpc_idx(cpc_prim_lib_dir, itm, date_series[0].year,9,3)
                
        np_idx_array[icount,:]=np_cpc_prim
        icount=icount+1
    
    np_idx_array=np.where(abs(np_idx_array)>90,0.0,np_idx_array)
    df =pd.DataFrame(np.transpose(np_idx_array), index=date_series, columns=[ 'nino34','aao','nao','pna','qbo','epnp','ao','poleur','wp'])
    df=df.to_period()
    df.to_csv(cpc_prim_lib_dir+'all_org_features.csv')

if __name__ == "__main__":
    main()



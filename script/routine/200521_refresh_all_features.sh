
FLIB_DIR=/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/
ERA5LIB_DIR=/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/era5/
DYN_DIR=/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/realtime/

YST=$(date --date="yesterday" +"%Y%m%d")
NXTMON=$(date --date="1 month" +"%Y%m")

TODAY=$(date +"%d")
if [ $TODAY = "20" ]; then
    # download cpc indices
    wget https://www.cpc.ncep.noaa.gov/products/analysis_monitoring/ensostuff/detrend.nino34.ascii.txt -O $FLIB_DIR/detrend.nino34.ascii.txt
    wget https://origin.cpc.ncep.noaa.gov/data/indices/qbo.u50.index -O $FLIB_DIR/qbo.u50.index
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/nao_index.tim -O $FLIB_DIR/nao_index.tim
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/pt_index.tim -O $FLIB_DIR/pt_index.tim
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/tnh_index.tim -O $FLIB_DIR/tnh_index.tim
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/pna_index.tim -O $FLIB_DIR/pna_index.tim
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/wp_index.tim -O $FLIB_DIR/wp_index.tim
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/epnp_index.tim -O $FLIB_DIR/epnp_index.tim
    wget https://origin.cpc.ncep.noaa.gov/products/precip/CWlink/daily_ao_index/monthly.ao.index.b50.current.ascii -O $FLIB_DIR/monthly.ao.index.b50.current.ascii
    wget https://origin.cpc.ncep.noaa.gov/products/precip/CWlink/daily_ao_index/aao/monthly.aao.index.b79.current.ascii -O $FLIB_DIR/monthly.aao.index.b79.current.ascii
    wget ftp://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/poleur_index.tim -O $FLIB_DIR/poleur_index.tim 

    sed -ni '/ANOM/,/-999/p' $FLIB_DIR/qbo.u50.index
    sed -n '/ANOM/,/-999/p' $FLIB_DIR/qbo.u50.index > $FLIB_DIR/qbo.u50.ano.index

    # download giss surf t analysis
    wget ftp://ftp2.psl.noaa.gov/Datasets/gistemp/combined/250km/air.2x2.250.mon.anom.comb.nc -O $FLIB_DIR/giss.air.mon.ano.nc
    # download giss surf prec analysis
    wget ftp://ftp.cdc.noaa.gov/Datasets/precl/1.0deg/precip.mon.mean.1x1.nc -O $FLIB_DIR/precip.land.mon.mean.1x1.nc
fi
# CFSv2
wget https://www.cpc.ncep.noaa.gov/products/people/mchen/CFSv2FCST/monthly/data/CFSv2.T2m.${YST}.${NXTMON}.nc -O $DYN_DIR/CFSv2.T2m.nc
wget https://www.cpc.ncep.noaa.gov/products/people/mchen/CFSv2FCST/monthly/data/CFSv2.Prec.${YST}.${NXTMON}.nc -O $DYN_DIR/CFSv2.Prec.nc

# ERA5
python 200517_down-era5-mon-sfc.py $ERA5LIB_DIR

# Reorg data
echo ">>Reorgnize cir_idx..."
python 200521_org_qbo.py $FLIB_DIR
python 200521_combine_cpc_prim.py

echo ">>Reorgnize era5..."
python 200517_convert_era5.py

echo ">>Combine era5 and dyn..."
python 200520_extract_era5_combine_dyn_predict.py
echo ">>Combine giss and dyn..."
python 200520_extract_giss_combine_dyn_predict.py
echo ">>Combine prec/l and dyn..."
python 200523_extract_prec_combine_dyn_predict.py

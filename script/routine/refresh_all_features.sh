
FLIB_DIR=/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/all_feature/
ERA5LIB_DIR=/disk/hq247/yhuangci/lzhenn/workspace/spellcaster-local/data/era5/

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
python org_qbo.py $FLIB_DIR

# download and reorgnize era5 latest monthly data
python 200517_down-era5-mon-sfc.py $ERA5LIB_DIR
python 200517_convert_era5.py





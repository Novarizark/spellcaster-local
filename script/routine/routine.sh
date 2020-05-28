source /g6/liqq/lzhenn/bashrc_lzn
ROUT_PATH=/g6/liqq/lzhenn/spellcaster/script/routine
cd $ROUT_PATH
# fetch data
python ${ROUT_PATH}/fetch_s2s_era.py
ncl ${ROUT_PATH}/deal_s2s_data.ncl
ncl ${ROUT_PATH}/draw_station_fcst.ncl



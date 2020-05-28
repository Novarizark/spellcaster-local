#!/bin/bash
source ~/.bashrc
# refresh features
echo "PHASE I: REFRESH"
sh 200521_refresh_all_features.sh

# forecast
echo "PHASE II: SPELLCASTER"
python 200526-spellcaster-t2m.py
python 200526-spellcaster-prec.py

# post-processing
echo "PHASE III: POST_PROCESSING"
python 200526-draw-station-map-t2m-fcst.py
python 200526-draw-station-map-prec-fcst.py

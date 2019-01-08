#!/usr/bin/env bash

set -ex

wget https://www.cryptodatadownload.com/cdd/gemini_BTCUSD_2018_1min.csv
wget https://www.cryptodatadownload.com/cdd/gemini_BTCUSD_2017_1min.csv
wget https://www.cryptodatadownload.com/cdd/gemini_BTCUSD_2016_1min.csv
wget https://www.cryptodatadownload.com/cdd/gemini_BTCUSD_2015_1min.csv

# Combine in one file, removing headers
echo "unix_time,timestamp,symbol,open,high,low,close,volume" > btcusd_1min.csv
tail -n +3 gemini_BTCUSD_2018_1min.csv >> btcusd_1min.csv
tail -n +3 gemini_BTCUSD_2017_1min.csv >> btcusd_1min.csv
tail -n +3 gemini_BTCUSD_2016_1min.csv >> btcusd_1min.csv
tail -n +3 gemini_BTCUSD_2015_1min.csv >> btcusd_1min.csv

# Remove some columns
cut -d, -f1,3 --complement btcusd_1min.csv > data.csv

# Add a T to the timestamp column
sed -i -re 's/([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})/\1T\2/' data.csv
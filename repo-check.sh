#!/bin/bash
set -eux

declare -A head base fv3 mom6 cice cmeps datm ww3 fms cmake stoch nems

head['repo']='https://github.com/MinsukJi-NOAA/ufs-weather-model'
head['branch']='feature/ci-regional-model'

base['repo']='https://github.com/ufs-community/ufs-weather-model'
base['branch']='develop'

fv3['repo']='https://github.com/NOAA-EMC/fv3atm'
fv3['branch']='develop'

mom6['repo']='https://github.com/NOAA-EMC/MOM6'
mom6['branch']='dev/emc'

cice['repo']='https://github.com/NOAA-EMC/CICE'
cice['branch']='emc/develop'

cmeps['repo']='https://github.com/NOAA-EMC/CMEPS'
cmeps['branch']='emc/develop'

datm['repo']='https://github.com/NOAA-EMC/NEMSdatm'
datm['branch']='develop'

ww3['repo']='https://github.com/NOAA-EMC/WW3'
ww3['branch']='develop'

fms['repo']='https://github.com/NOAA-GFDL/FMS'
fms['branch']='main'

cmake['repo']='https://github.com/NOAA-EMC/CMakeModules'
cmake['branch']='develop'

stoch['repo']='https://github.com/noaa-psd/stochastic_physics'
stoch['branch']='master'

nems['repo']='https://github.com/NOAA-EMC/NEMS'
nems['branch']='develop'

git clone --branch ${base['branch']} --recurse-submodules ${base['repo']} test-base
cd test-base
base_dir=$(pwd)
base['sha']="$(git rev-parse origin/${base['branch']})" 
#cd $base_dir/FV3
#fv3['sha']=
#cd $base_dir/MOM6-interface/MOM6
#mom6['sha']=
#cd $base_dir/CICE-interface/CICE
#cice['sha']=
#cd $base_dir/WW3
#ww3['sha']=
#cd $base_dir/stochastic_physics
#stoch['sha']=
#cd $base_dir/NEMS
#nems['sha']=
#cd $base_dir/FMS
#fms['sha']=
#cd $base_dir/DATM
#datm['sha']=
#cd CMakeModules
#cmake['sha']=
#cd CMEPS-interface/CMEPS
#cmeps['sha']=

cd ..
git clone --branch ${head['branch']} --recurse-submodules ${head['repo']} test-head
cd test-head
head_dir=$(pwd)
git remote add upstream ${base['repo']}
git fetch upstream
base_common=$(git merge-base upstream/${base['branch']} @)
if [[ $base_common == ${base['sha']} ]]; then
  echo "MATCH"
else
  echo "NO MATCH"
fi

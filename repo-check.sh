#!/bin/bash
set -eu

declare -A head base fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake
submodules="fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake"

head[repo]='https://github.com/MinsukJi-NOAA/ufs-weather-model'
head[branch]='feature/ci-regional-model'

base[repo]='https://github.com/ufs-community/ufs-weather-model'
base[branch]='develop'

fv3[repo]='https://github.com/NOAA-EMC/fv3atm'
fv3[branch]='develop'
fv3[dir]='FV3'

mom6[repo]='https://github.com/NOAA-EMC/MOM6'
mom6[branch]='dev/emc'
mom6[dir]='MOM6-interface/MOM6'

cice[repo]='https://github.com/NOAA-EMC/CICE'
cice[branch]='emc/develop'
cice[dir]='CICE-interface/CICE'

ww3[repo]='https://github.com/NOAA-EMC/WW3'
ww3[branch]='develop'
ww3[dir]='WW3'

stoch[repo]='https://github.com/noaa-psd/stochastic_physics'
stoch[branch]='master'
stoch[dir]='stochastic_physics'

fms[repo]='https://github.com/NOAA-GFDL/FMS'
fms[branch]='main'
fms[dir]='FMS'

nems[repo]='https://github.com/NOAA-EMC/NEMS'
nems[branch]='develop'
nems[dir]='NEMS'

cmeps[repo]='https://github.com/NOAA-EMC/CMEPS'
cmeps[branch]='emc/develop'
cmeps[dir]='CMEPS-interface/CMEPS'

datm[repo]='https://github.com/NOAA-EMC/NEMSdatm'
datm[branch]='develop'
datm[dir]='DATM'

cmake[repo]='https://github.com/NOAA-EMC/CMakeModules'
cmake[branch]='develop'
cmake[dir]='CMakeModules'

# Get top-level and component-level SHA-1
root_dir=$(pwd)
git clone --quiet --branch ${base[branch]} --recurse-submodules ${base[repo]} test-base
cd test-base
base_dir=$(pwd)
base[sha]="$(git rev-parse origin/${base[branch]})" 

for submodule in $submodules; do
  eval cd $base_dir/'${'$submodule'[dir]}'
  eval $submodule'[sha]=$(git log -n 1 | head -1 | sed "s/commit //")'
done

#cd $base_dir/FV3
#fv3['sha']=$(git branch | grep -o "at [a-zA-Z0-9]\{4,9\}" | sed 's/^...//;s/.$//')
#fv3[sha]=$(git log -n 1 | head -1 | sed 's/commit //')

cd ${root_dir}
git clone --quiet --branch ${head['branch']} --recurse-submodules ${head['repo']} test-head
cd test-head
head_dir=$(pwd)
git remote add upstream ${base['repo']}
git fetch upstream
base_common=$(git merge-base upstream/${base['branch']} @)
if [[ $base_common == ${base[sha]} ]]; then
  echo "UFS up to date"
else
  echo "UFS not up to date"
fi


for submodule in $submodules; do
  eval cd $head_dir/'${'$submodule'[dir]}'
  eval git remote add upstream '${'$submodule'[repo]}'
  git fetch --quiet upstream
  common=$(eval git merge-base upstream/'${'$submodule'[branch]}' @)
  if (eval test $common = '${'$submodule'[sha]}'); then
    echo "$submodule is up to date"
  else
    echo "$submodule is not up to date"
  fi
done

#cd $head_dir/FV3
#git remote add upstream ${fv3['repo']}
#git fetch upstream
#fv3_common=$(git merge-base upstream/${fv3['branch']} @)
#if [[ $fv3_common == ${fv3['sha']} ]]; then
#  echo "FV3 up to date"
#else
#  echo "FV3 not up to date"
#fi

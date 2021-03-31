#!/bin/bash
set -eu

declare -A head base fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake
submodules="fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake"

#head[repo]='https://github.com/MinsukJi-NOAA/ufs-weather-model'
#head[branch]='feature/ci-regional-model'
head[repo]="https://github.com/$1"
head[branch]="$2"

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

# Get top-level and component-level SHA-1 of top of develop of ufs-weather-model
root_dir=$(pwd)
git clone --quiet --branch ${base[branch]} ${base[repo]} test-base
cd test-base
base[sha]=$(git log -n 1 | head -1 | sed "s/commit //")

git submodule status >all_sha
for submodule in $submodules; do
  eval $submodule'[sha]=$(cat all_sha | grep "${'$submodule'[dir]}" | cut -c 2-41)'
done
rm -f all_sha

# Check if UFS and components are up to date with ufs-weather-model develop
cd ${root_dir}
git clone --quiet --branch ${head['branch']} --recurse-submodules ${head['repo']} test-head
cd test-head
head_dir=$(pwd)
git remote add upstream ${base['repo']}
git fetch --quiet upstream
base_common=$(git merge-base upstream/${base['branch']} @)
if [[ $base_common == ${base[sha]} ]]; then
  echo "UFS is up to date"
else
  echo "UFS is not up to date"
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

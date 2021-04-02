#!/bin/bash
set -eux

# This script checks if head repo of PR is up to date with ufs-weather-model develop
# Checks for top level (ufs-weather-model) and next level components (submodules)
usage() {
  echo
  echo "Usage: $program <GitHub Username> <Branch name>"
  echo
  exit 1
}

result() {
  if [[ -n $comment ]]; then
    comment+="Please update your repositories"
    printf %s "$comment"
  fi
}

readonly program=$(basename $0)
[[ $# != 2 ]] && usage

# Declare variables
declare -A head base fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake
submodules="fv3 mom6 cice ww3 stoch fms nems cmeps datm cmake"
comment=''

# Head branch: this is the branch from which PR is made
head[repo]="https://github.com/$1/ufs-weather-model"
head[branch]="$2"

# Base branch: this is the top of develop of ufs-weather-model
base[repo]='https://github.com/ufs-community/ufs-weather-model'
base[branch]='develop'

# Submodules to check
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

# Get sha-1's of the top of develop of ufs-weather-model
app="Accept: application/vnd.github.v3+json"
url="https://api.github.com/repos/ufs-community/ufs-weather-model/branches/develop"
base[sha]=$(curl -sS -H "$app" $url | ./json_helper.py repository)
for submodule in $submodules; do
  eval url=https://api.github.com/repos/ufs-community/ufs-weather-model/contents/'${'$submodule'[dir]}'
  eval $submodule'[sha]=$(curl -sS -H "$app" $url | ./json_helper.py component)'
done

# Check if the head branch is up to date with the base branch
git clone -q -b ${head['branch']} --recursive ${head['repo']} test-head && cd test-head
head_dir=$(pwd)
git remote add upstream ${base['repo']}
git fetch -q upstream
common=$(git merge-base upstream/${base['branch']} @)
if [[ $common != ${base[sha]} ]]; then
  #printf "* ufs-weather-model is **NOT** up to date\\\\n"
  comment="* ufs-weather-model is **NOT** up to date\n"
fi

for submodule in $submodules; do
  eval cd $head_dir/'${'$submodule'[dir]}'
  eval git remote add upstream '${'$submodule'[repo]}'
  git fetch -q upstream
  common=$(eval git merge-base upstream/'${'$submodule'[branch]}' @)
  if (eval test $common != '${'$submodule'[sha]}'); then
    #printf "* $submodule is **NOT** up to date\\\\n"
    comment+="* $submodule is **NOT** up to date\n"
  fi
done

result

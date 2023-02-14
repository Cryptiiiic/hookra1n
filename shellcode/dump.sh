#!/usr/bin/env zsh
#set -o xtrace

script_name=$(realpath -s "$0")
script_base=$(dirname "$script_name")
gnu_dd=0
gnu_stat=0

t8015_stage2_offset=0x26BA0
t8015_stage2_size=0xCB0
t8015_stage2_gnu_offset=158624
t8015_stage2_gnu_size=3248

function bin_check() {
  tmp=$(command -v strings)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing strings command!"; exit -1; fi
  tmp=$(command -v dd)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing dd command!"; exit -1; fi
  tmp=$(command -v stat)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing stat command!"; exit -1; fi
  tmp=$(dd --version)
  if [[ "$?" == 0 ]]; then gnu_dd=1; fi
  tmp=$(stat --version)
  if [[ "$?" == 0 ]]; then gnu_stat=1; fi
}

function version_check() {
  version=$(strings $1 | grep 1337 | head -n1 | tr -d '\n')
  if [[ "$version" != "Checkra1n 0.1337.1" ]]; then echo "[FATAL_ERROR]: Unsupported checkra1n version!"; exit -1; fi
  type=$(file $1 | grep "Mach\-O universal")
  if [[ $type == *"Mach-O universal"* ]]; then echo -n; else echo "[FATAL_ERROR]: $1 isn't a macOS binary"; exit -1; fi
  echo "[SUCCESS]: Dumping $version"
}

function t8015_stage2_dump() {
  if [[ $gnu_dd == 1 ]]; then
    dd if=$1 bs=1 skip=$t8015_stage2_gnu_offset count=$t8015_stage2_gnu_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  else
    dd if=$1 bs=1 skip=$t8015_stage2_offset count=$t8015_stage2_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  fi
  if [[ $gnu_stat == 1 ]]; then
    tmp=$(stat -c %s ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "3248" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  else
    tmp=$(stat -f %z ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "3248" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  fi
  echo "[SUCCESS]: Successfully dumped t8015 stage2 shellcode from checkra1n!"
}

function main() {
  if [[ "$1" == "" ]]; then echo "$script_name <checkra1n path>"; exit -1; fi
  bin_check
  version_check $1
  mkdir -p ${script_base}/checkra1n_dump
  t8015_stage2_dump $1
}

main $@
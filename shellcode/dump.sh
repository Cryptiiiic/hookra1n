#!/usr/bin/env zsh
#set -o xtrace

script_name=$(realpath "$0")
script_base=$(dirname "$script_name")
gnu_dd=0
gnu_stat=0

c1337_1_t8015_stage2_offset=0x26BA0
c1337_1_t8015_stage2_size=0xCB0
c1337_1_t8015_stage2_gnu_offset=158624
c1337_1_t8015_stage2_gnu_size=3248

c1337_2_t8015_stage2_offset=0x26B40
c1337_2_t8015_stage2_size=0xD0C
c1337_2_t8015_stage2_gnu_offset=158528
c1337_2_t8015_stage2_gnu_size=3340

function bin_check() {
  tmp=$(command -v strings)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing strings command!"; exit -1; fi
  tmp=$(command -v dd)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing dd command!"; exit -1; fi
  tmp=$(command -v stat)
  if [[ "$tmp" == "" || "$?" != 0 ]]; then echo "[FATAL_ERROR]: Missing stat command!"; exit -1; fi
  tmp=$(dd --version 2>/dev/null)
  if [[ "$?" == 0 ]]; then gnu_dd=1; fi
  tmp=$(stat --version 2>/dev/null)
  if [[ "$?" == 0 ]]; then gnu_stat=1; fi
}



function c1337_2_version_check() {
  version=$(strings $1 | grep 1337 | head -n1 | tr -d '\n')
  if [[ "$version" != "Checkra1n 0.1337.2" ]]; then echo "[INFO]: checkra1n isn't version 0.1337.2"; return 1; fi
  type=$(file $1 | grep "Mach\-O universal")
  if [[ $type == *"Mach-O universal"* ]]; then echo -n; else echo "[FATAL_ERROR]: $1 isn't a macOS binary"; exit -1; fi
  echo "[SUCCESS]: Dumping $version"
}

function c1337_1_version_check() {
  version=$(strings $1 | grep 1337 | head -n1 | tr -d '\n')
  if [[ "$version" != "Checkra1n 0.1337.1" ]]; then echo "[FATAL_ERROR]: Unsupported checkra1n version!"; exit -1; fi
  type=$(file $1 | grep "Mach\-O universal")
  if [[ $type == *"Mach-O universal"* ]]; then echo -n; else echo "[FATAL_ERROR]: $1 isn't a macOS binary"; exit -1; fi
  echo "[SUCCESS]: Dumping $version"
  return 0
}

function c1337_2_t8015_stage2_dump() {
  if [[ $gnu_dd == 1 ]]; then
    dd if=$1 bs=1 skip=$c1337_2_t8015_stage2_gnu_offset count=$c1337_2_t8015_stage2_gnu_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  else
    dd if=$1 bs=1 skip=$c1337_2_t8015_stage2_offset count=$c1337_2_t8015_stage2_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  fi
  if [[ $gnu_stat == 1 ]]; then
    tmp=$(stat -c %s ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "$c1337_2_t8015_stage2_gnu_size" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  else
    tmp=$(stat -f %z ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "$c1337_2_t8015_stage2_gnu_size" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  fi
  echo "[SUCCESS]: Successfully dumped t8015 stage2 shellcode from checkra1n!"
}

function c1337_1_t8015_stage2_dump() {
  if [[ $gnu_dd == 1 ]]; then
    dd if=$1 bs=1 skip=$c1337_1_t8015_stage2_gnu_offset count=$c1337_1_t8015_stage2_gnu_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  else
    dd if=$1 bs=1 skip=$c1337_1_t8015_stage2_offset count=$c1337_1_t8015_stage2_size of=${script_base}/checkra1n_dump/t8015_stage2.bin status=none
  fi
  if [[ $gnu_stat == 1 ]]; then
    tmp=$(stat -c %s ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "$c1337_1_t8015_stage2_gnu_size" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  else
    tmp=$(stat -f %z ${script_base}/checkra1n_dump/t8015_stage2.bin)
    if [[ "$tmp" != "$c1337_1_t8015_stage2_gnu_size" ]]; then echo "[FATAL_ERROR]: Failed to dump t8015 stage2 shellcode from checkra1n!"; exit -1; fi
  fi
  echo "[SUCCESS]: Successfully dumped t8015 stage2 shellcode from checkra1n!"
}

function main() {
  if [[ "$1" == "" ]]; then echo "$script_name <checkra1n path>"; exit -1; fi
  bin_check
  mkdir -p ${script_base}/checkra1n_dump
  c1337_2_version_check $1
  if [[ "$?" == 0 ]]; then c1337_2_t8015_stage2_dump $1; return 0; fi
  c1337_1_version_check $1
  c1337_1_t8015_stage2_dump $1
  return 0;
}

main $@
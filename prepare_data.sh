#!/bin/bash
# Copyright 2019 ASLP@NPU.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: ychen00818@gmail.com (chenyi)

current_working_dir=$(pwd)
data_dir=data/unisound_qtrain
wav_dir=${data_dir}/audio
pcm_dir=${data_dir}/pcm
config_dir=${data_dir}/config
train_dir=${data_dir}/train
test_dir=${data_dir}/test
num_test_case=20
train_scp=$config_dir/train.scp
test_scp=$config_dir/test.scp

stage=0

set -euo pipefail

[ ! -e $pcm_dir ] && mkdir -p $pcm_dir
[ ! -e $config_dir ] && mkdir -p $config_dir
#[ ! -e $train_dir ] && mkdir -p $train_dir
[ ! -e $test_dir ] && mkdir -p $test_dir
if [ $stage -le 0 ];then
  for x in $wav_dir/*.wav
  do
    b=${x##*/}
    echo Extracting pcm data from $b
    sox $wav_dir/$b -r 16000 -b 16 -c 1 -e signed-integer -t raw - > $pcm_dir/${b%.*}.s16
  done
fi

if [ $stage -le 1 ];then
  find $pcm_dir -name '*.s16' |shuf  >  $config_dir/all.scp

  awk -v count=${num_test_case} '{if (NR > count) { print $0 > "'$train_scp'"; } else { print $0 > "'$test_scp'"; }}' $config_dir/all.scp
fi

if [ $stage -le 2 ];then
  echo Preparing training data with dump_data
  ./dump_data -train $train_scp  $data_dir/features.f32 $data_dir/data.u8
fi

if [ $stage -le 3 ];then
  echo Preparing test data with dump_data
  ./dump_data -test $test_scp  $test_dir 

fi


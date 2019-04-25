#!/bin/bash
data=taco_lpc/HW-TEST/24_19w
out=taco_lpc/HW-TEST/24_19w/wav

[ ! -e $out ] && mkdir -p $out
for x in $data/*.f32
do
   b=${x##*/}
   echo $b
   ./lpcnet_demo -synthesis $x $out/$b.pcm
   sox -t raw -c 1 -e signed-integer -b 16 -r 16000 $out/$b.pcm $out/$b.wav
done

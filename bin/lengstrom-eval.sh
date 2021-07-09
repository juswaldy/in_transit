rootdir=/home/jus/notebook/jus/styletransfer
style=$1
python evaluate.py --checkpoint ${rootdir}/lengstrom/checkpoint/${style} \
  --in-path ${rootdir}/pics \
  --out-path ${rootdir}/results/lengstrom \
  --allow-different-dimensions \
  --batch-size 4

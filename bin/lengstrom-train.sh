rootdir=/home/jus/notebook/jus/styletransfer
style=$1
python style.py --style ${rootdir}/style/${style} \
  --checkpoint-dir ${rootdir}/lengstrom/checkpoint/${style} \
  --test ${rootdir}/pics/jus.jpg \
  --test-dir ${rootdir}/lengstrom/test \
  --content-weight 1.5e1 \
  --checkpoint-iterations 1000 \
  --batch-size 20

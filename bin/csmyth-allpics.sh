content_weight=$1
style_weight=$2

codedir=/home/jus/github/neural-style-tf
rootdir=/home/jus/notebook/jus/styletransfer
content_dir=${rootdir}/pics/all
style_dir=${rootdir}/style/maya
img_output_dir=${rootdir}/results/csmyth/maya
device='/gpu:1'

pushd $codedir
for content_filename in ${content_dir}/*.jpg; do
	for style_dir in `find $styleroot -maxdepth 1 -mindepth 1 ! -name '*pynb*'`; do
		style_filenames=`find $style_dir -type f -printf ' %f'`
		img_name=`basename $content_filename`

		python csmyth.py \
		  --content_img_dir "${content_dir}" \
		  --style_imgs_dir "${style_dir}" \
		  --img_output_dir "${img_output_dir}" \
		  --content_weight $content_weight \
		  --style_weight $style_weight \
		  --device "${device}" \
		  --verbose;
	done
done
popd


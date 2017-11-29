#0!/bin/bash
caffe_path=../../../caffe_nd_sense_segmetation/.build_release/tools
log_dir=LOG
mkdir -p $log_dir
mkdir -p trained_weights
GLOG_log_dir=$log_dir $caffe_path/caffe.bin train \
--solver=solver.prototxt \
--gpu 0
#--snapshot=trained_weights/inception_fcn_mscal_classifier_iter_12470.solverstate \
#--gpu 3
#--weights=../../trained_temp/bigneuron_7fm_vgg_init_deconv_iter_391.caffemodel \

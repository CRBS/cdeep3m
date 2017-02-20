#0!/bin/bash
caffe_path=../../../caffe_nd_sense_segmetation/.build_release/tools
log_dir=LOG
GLOG_log_dir=$log_dir $caffe_path/caffe.bin train \
--solver=solver.prototxt \
--gpu 3 \
--weights=trained_weights/inception_fcn_mscal_classifier_fullstacks_train_iter_44000.caffemodel
#--snapshot=trained_weights/inception_fcn_mscal_classifier_fullstacks_train_iter_1322.solverstate
#--snapshot=trained_weights/inception_fcn_iter_20069.solverstate \
#--gpu 3
#--weights=../../trained_temp/bigneuron_7fm_vgg_init_deconv_iter_391.caffemodel \

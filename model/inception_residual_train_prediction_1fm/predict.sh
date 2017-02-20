#!/bin/bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.0/lib64
caffe_path=/tempspace/tzeng/caffe_nd_sense_segmetation/build/tools
GLOG_logtostderr=1 $caffe_path/predict_seg_new.bin \
--model=deploy.prototxt \
--weights=trained_weights/inception_fcn_mscal_classifier_iter_12000.caffemodel \
--data=../../data/snemi3d_test.h5 \
--predict=predict_single/snemi3d_valid.h5 \
--shift_axis=2 \
--shift_stride=1 \
--gpu=0

#snemi3d_valid.h5

#snemi3d_test.h5

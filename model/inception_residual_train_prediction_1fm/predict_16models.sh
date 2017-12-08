#!/bin/bash
# need bash shell
caffe_path=/tempspace/tzeng/caffe_nd_sense_segmetation/build/tools
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.0/lib64
for idx in {1..16..1}
  do
  predict_dir=predict/v$idx;
if [ ! -d "$predict_dir" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
  mkdir "predict/v$idx"
fi
GLOG_logtostderr=1 $caffe_path/predict_seg_new.bin \
--model=deploy.prototxt \
--weights=trained_weights/inception_fcn_mscal_classifier_iter_50000.caffemodel \
--data=../../data/snemi3d_train_full_stacks_v$idx.h5 \
--predict=$predict_dir/test.h5 \
--shift_axis=2 \
--shift_stride=1 \
--gpu=0

 done
#snemi3d_test_v$idx.h5

#snemi3d_train_full_stacks_v$idx.h5

#snemi3d_valid.h5
#snemi3d_test_last10slice.h5

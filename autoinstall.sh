pip install -r requirements.txt
CWD=`pwd`
export TF_DIR=/tmp/tensorflow
mkdir $TF_DIR 
cd $TF_DIR
echo `pwd`
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/protoc-3.14.0-linux-x86_64.zip
unzip protoc-3.14.0-linux-x86_64.zip -d protoc
export PATH=$PATH:`pwd`/protoc/bin

git clone https://github.com/tensorflow/models
cd models
git checkout 8a06433
cd $TF_DIR/models/research
protoc object_detection/protos/*.proto --python_out=.

git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
make
cp -r pycocotools/ $TF_DIR/models/research/

cd $TF_DIR/models/research
cp object_detection/packages/tf2/setup.py .
# force tensorflow==2.2
sed -i "s/'tf-models-official'/'tf-models-official', 'tensorflow==2.2'/" setup.py
python -m pip install .


pip install numpy==1.20
# finally fix bug in tensorflow array_ops file
cd $CWD
file=`python -c 'from tensorflow.python.ops import array_ops; print(array_ops.__file__)'`
sed -i "s/np.prod/tf.math.reduce_prod/g" $file
sed -i 's/import numpy as np/import numpy as np; import tensorflow as tf/' $file

echo "Downloading pre-trained model"
wget http://download.tensorflow.org/models/object_detection/tf2/20200711/faster_rcnn_resnet152_v1_640x640_coco17_tpu-8.tar.gz
tar xzf faster_rcnn_resnet152_v1_640x640_coco17_tpu-8.tar.gz


echo "Done"
#python object_detection/builders/model_builder_tf2_test.py


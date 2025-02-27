#!/bin/bash

pip install open3d numpy opencv-python


#install support for madpose for accurate camera tracking
if [[ " $@ " =~ " -madpose " ]]; then
	if [ "$(uname)" == "Linux" ]; then
		sudo apt-get install -y libeigen3-dev libceres-dev libopencv-dev
	else
		brew install cmake ninja opencv
	fi
	
	git clone https://github.com/MarkYu98/madpose

	cd madpose/ext/
	
	git clone --recursive https://github.com/pybind/pybind11
	git clone --recursive https://github.com/tsattler/RansacLib
	
	cd ..
	
	if [ "$(uname)" == "Linux" ]; then
		pip install .
	else
		pip3.11 install .
	fi
	
	cd ..
	
	exit
	
fi


#install support for stereocrafter for ML based infill
if [[ " $@ " =~ " -stereocrafter " ]]; then
	git clone --recursive https://github.com/TencentARC/StereoCrafter

	cd StereoCrafter
	
	pip install transformers diffusers accelerate

	# in StereoCrafter project root directory
	mkdir weights
	cd ./weights
	
	sudo apt-get install -y git-lfs
	git clone https://huggingface.co/TencentARC/StereoCrafter
	
	#git clone https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt-1-1 #Not needed, is automaticly downloaded 
	
	
	
	exit
	
fi


#install support for unidepth (requires cuda 11.8 and torch 2.2.0)
if [[ " $@ " =~ " -unidepth " ]]; then
	git clone https://github.com/lpiccinelli-eth/UniDepth

	cd UniDepth

	#export VENV_DIR=<YOUR-VENVS-DIR>
	#export NAME=Unidepth

	#python -m venv $VENV_DIR/$NAME
	#source $VENV_DIR/$NAME/bin/activate

	# Install UniDepth and dependencies
	pip install -e . --extra-index-url https://download.pytorch.org/whl/cu118

	# Install Pillow-SIMD (Optional)
	pip uninstall pillow
	CC="cc -mavx2" pip install -U --force-reinstall pillow-simd
	
	cd ..
	
	cp -a src/unidepth_video.py UniDepth/.
	
	exit
fi


#install Video-Depth-Anything
git clone https://github.com/DepthAnything/Video-Depth-Anything
cd Video-Depth-Anything
pip install -r requirements.txt

mkdir checkpoints
cd checkpoints
wget https://huggingface.co/depth-anything/Video-Depth-Anything-Large/resolve/main/video_depth_anything_vitl.pth
cd ..


#install Depth-Anything-V2
git clone https://github.com/DepthAnything/Depth-Anything-V2
cd Depth-Anything-V2
pip install -r requirements.txt

cd metric_depth
mkdir checkpoints
cd checkpoints
wget https://huggingface.co/depth-anything/Depth-Anything-V2-Metric-Hypersim-Large/resolve/main/depth_anything_v2_metric_hypersim_vitl.pth
cd ..

cd ..
cd ..
cd ..

cp -a src/metric_dpt_func.py Video-Depth-Anything/Depth-Anything-V2/metric_depth/.
cp -a src/video_metric_convert.py Video-Depth-Anything/.


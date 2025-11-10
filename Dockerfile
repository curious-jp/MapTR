FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

# Install prerequisites
RUN apt-get update && apt-get install -y \
  wget \
  git \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
  rm -r Miniconda3-latest-Linux-x86_64.sh

# Add conda to PATH
ENV PATH /opt/miniconda3/bin:$PATH

# Update conda and accept ToS
RUN conda config --set quiet True
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda update -n base -c defaults conda -y

# Create the conda environment
RUN conda create -n maptr python=3.8 -y

# Set the environment and CUDA variables
ENV CONDA_DEFAULT_ENV maptr
ENV PATH /opt/miniconda3/envs/maptr/bin:/usr/local/cuda/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV CPLUS_INCLUDE_PATH="/usr/local/cuda/include"
ENV C_INCLUDE_PATH="/usr/local/cuda/include"
ENV TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6"

# Install dependencies in the conda environment
RUN pip install --upgrade pip
RUN pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html
RUN pip install mmcv-full==1.4.0
RUN pip install mmdet==2.14.0
RUN pip install mmsegmentation==0.14.1
RUN pip install timm
RUN pip install lyft_dataset_sdk numba==0.48.0 plyfile tensorboard "trimesh>=2.35.39,<2.35.40" "networkx>=2.8" "numpy>=1.21" scikit-image nuscenes-devkit

# Clone MapTR repository
RUN git clone https://github.com/hustvl/MapTR.git /MapTR

# Install mmdet3d and GKT
WORKDIR /MapTR/mmdetection3d
RUN python setup.py develop --no-deps

WORKDIR /MapTR/projects/mmdet3d_plugin/maptr/modules/ops/geometric_kernel_attn
RUN python setup.py build install

# Install other requirements
WORKDIR /MapTR
RUN pip install -r requirement.txt

# Prepare pretrained models
RUN mkdir -p /MapTR/ckpts && \
  cd /MapTR/ckpts && \
  wget https://download.pytorch.org/models/resnet50-19c8e357.pth && \
  wget https://download.pytorch.org/models/resnet18-f37072fd.pth

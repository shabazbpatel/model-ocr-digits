FROM acusensehub/keras:cpu

VOLUME ["/home/_data", "/home/_inputs", "/home/_shared_outputs", "/home/src", "/home/_snapshots"]

# set keras backend to theano
ENV KERAS_BACKEND=tensorflow

RUN apt-get update; \
    apt-get install -y \
      build-essential \
      python-setuptools \
      libatlas-dev \
      libatlas3gf-base

RUN update-alternatives --set libblas.so.3 \
      /usr/lib/atlas-base/atlas/libblas.so.3; \
    update-alternatives --set liblapack.so.3 \
      /usr/lib/atlas-base/atlas/liblapack.so.3

RUN pip install -U scikit-learn

RUN apt-get install -y \
             cmake \
             && apt-get clean

# git clone the repo from OpenCV official repository on GitHub.
RUN mkdir /opt/opencv-build && cd /opt/opencv-build \
&& git clone https://github.com/Itseez/opencv && cd opencv \
&& git checkout master && mkdir build

WORKDIR /opt/opencv-build/opencv/build

ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64

# OpenCV repository is kept but all building intermediate files are removed.
# All other dependencies is using the default settings from CMake file of OpenCV.
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt .. \
&& make -j2 && make install && make clean && cd .. && rm -rf build

# Let python can find the newly install OpenCV modules.
RUN echo '/opt/lib/python2.7/dist-packages/'>/usr/lib/python2.7/dist-packages/cv2.pth
RUN echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc


VOLUME ["/home/_data", "/home/_inputs", "/home/_shared_outputs", "/home/src", "/home/_snapshots"]

# Setup environment variables
ENV INPUT_DIR=/home/_inputs
ENV SHARED_OUTPUT_DIR=/home/_shared_outputs
ENV SNAPSHOTS_DIR=/home/_snapshots
ENV DATA_DIR=/home/_data
ENV SRC_DIR=/home/src

# Run commands to make code work
RUN apt-get update -y

# Numpy / Scipy reqs
RUN apt-get install -y  ipython \
		        ipython-notebook \
                        python-pandas \
    		        python-sympy \
    		        tesseract-ocr\
    		        python-skimage

RUN pip install pytesseract

RUN pip install flask
EXPOSE 5000
RUN mkdir -p /home/src

COPY src /home/src

RUN find /home/src/scripts -name "*.sh" -exec chmod +x {} +

# Working directory: this is where unix scripts will run from
WORKDIR /home/src
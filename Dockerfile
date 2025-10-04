FROM tensorflow/tensorflow:2.13.0

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-get -y update
RUN apt-get install -y python3-pip software-properties-common wget ffmpeg

COPY requirements.txt /
COPY setup.cfg /
COPY setup.py /
COPY pyproject.toml /
ADD src src
RUN pip install --upgrade pip setuptools wheel
WORKDIR /
ENV AM_I_IN_A_DOCKER_CONTAINER Yes
RUN pip install opencv-python>=4.7.0
RUN pip install cmake
RUN pip install "setuptools_scm<8"
RUN pip install -e .[tfcpu,api]
# RUN gdown https://drive.google.com/uc?id=1czUSFvk6Z49H-zRikTc67g2HUUz4imON
# RUN unzip log.zip
# RUN rm log.zip
COPY docs/app.toml /docs/app.toml
ADD log/store log/store

COPY resources /usr/local/resources
RUN mv /usr/local/resources .

RUN python -m dfp.deploy --image resources/123.jpg --weight log/store/G --postprocess --colorize --save output.jpg --loadmethod log
CMD ["python","-m","dfp.app", "--postprocess=1", "--weight", "log/store/G"]

EXPOSE 1111

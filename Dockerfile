FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    sox \
    flac \
    cmake \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/espnet/espnet /app/espnet

WORKDIR /app/espnet/tools
RUN ./setup_anaconda.sh miniconda espnet 3.8

RUN make

RUN /app/espnet/tools/miniconda/bin/conda run -n espnet /bin/bash /app/espnet/tools/installers/install_parallel-wavegan.sh

WORKDIR /app/espnet/egs2/Kazakh_TTS
COPY . /app/espnet/egs2/Kazakh_TTS
RUN /app/espnet/tools/miniconda/bin/conda run -n espnet pip install -r requirements.txt
RUN /app/espnet/tools/miniconda/bin/conda run -n espnet conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
COPY parallelwavegan_male1_checkpoint.zip /app/
COPY kaztts_male1_tacotron2_train.loss.ave.zip /app/

RUN unzip /app/parallelwavegan_male1_checkpoint.zip -d /app/parallelwavegan_male1_checkpoint/ && \
    unzip /app/kaztts_male1_tacotron2_train.loss.ave.zip -d /app/kaztts_male1_tacotron2_train.loss.ave/ && \
    rm /app/parallelwavegan_male1_checkpoint.zip /app/kaztts_male1_tacotron2_train.loss.ave.zip && \
    mkdir -p /app/espnet/egs2/Kazakh_TTS/tts1/exp && \
    mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_stats_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/ && \
    mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_train_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/ && \
    mv /app/parallelwavegan_male1_checkpoint/ /app/espnet/egs2/Kazakh_TTS/tts1/exp/vocoder

EXPOSE 8000

ENTRYPOINT ["bash", "/app/espnet/egs2/Kazakh_TTS/start.sh"]

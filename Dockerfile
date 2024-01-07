FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    sox \
    flac \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ARG COMMIT_HASH=1b5622c676ed7eccb20d1f825dd0f9a16e8e5064
RUN git clone https://github.com/espnet/espnet

RUN apt-get update && apt-get install -y wget

WORKDIR /app/espnet/tools
RUN ./setup_anaconda.sh miniconda espnet 3.8
RUN make

RUN /app/espnet/tools/miniconda/bin/conda run -n espnet /bin/bash /app/espnet/tools/installers/install_parallel-wavegan.sh

RUN apt-get install -y unzip

ARG CACHEBUST=1
RUN git clone https://github.com/nuromirzak/Kazakh_TTS.git /app/espnet/egs2/Kazakh_TTS

WORKDIR /app/espnet/egs2/Kazakh_TTS
RUN /app/espnet/tools/miniconda/bin/conda run -n espnet pip install -r requirements.txt

COPY parallelwavegan_male1_checkpoint.zip /app/
COPY kaztts_male1_tacotron2_train.loss.ave.zip /app/
RUN unzip /app/parallelwavegan_male1_checkpoint.zip -d /app/parallelwavegan_male1_checkpoint/
RUN unzip /app/kaztts_male1_tacotron2_train.loss.ave.zip -d /app/kaztts_male1_tacotron2_train.loss.ave/

RUN mkdir -p /app/espnet/egs2/Kazakh_TTS/tts1/exp
RUN mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_stats_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/
RUN mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_train_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/
RUN mv /app/parallelwavegan_male1_checkpoint/ /app/espnet/egs2/Kazakh_TTS/tts1/exp/vocoder

EXPOSE 8000

WORKDIR /app/espnet/egs2/Kazakh_TTS

COPY start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]

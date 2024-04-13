FROM ubuntu:jammy as base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    sox \
    flac \
    cmake \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

FROM base as builder

RUN git clone --depth 1 https://github.com/espnet/espnet /app/espnet

WORKDIR /app/espnet/tools
RUN ./setup_anaconda.sh miniconda espnet 3.8

RUN make

RUN /app/espnet/tools/miniconda/bin/conda run -n espnet /bin/bash /app/espnet/tools/installers/install_parallel-wavegan.sh

ARG COMMIT_HASH=caching
RUN git clone https://github.com/nuromirzak/Kazakh_TTS.git /app/espnet/egs2/Kazakh_TTS

WORKDIR /app/espnet/egs2/Kazakh_TTS
RUN /app/espnet/tools/miniconda/bin/conda run -n espnet pip install -r requirements.txt

FROM base

COPY --from=builder /app /app

WORKDIR /app/espnet/egs2/Kazakh_TTS

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

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/bin/bash", "./start.sh"]

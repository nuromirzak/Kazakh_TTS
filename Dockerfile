FROM continuumio/anaconda3:2023.09-0

WORKDIR /app

RUN apt-get update && apt-get install -y \
    cmake \
    sox \
    flac

RUN git clone https://github.com/espnet/espnet

WORKDIR /app/espnet/tools

RUN ./setup_anaconda.sh miniconda espnet 3.8

RUN apt-get install -y build-essential

RUN make

RUN apt-get install -y unzip

RUN bash /app/espnet/tools/installers/install_parallel-wavegan.sh

ARG CACHEBUST=1

RUN git clone https://github.com/nuromirzak/Kazakh_TTS.git /app/espnet/egs2/Kazakh_TTS

WORKDIR /app/espnet/egs2/Kazakh_TTS

RUN pip install -r requirements.txt

COPY parallelwavegan_male1_checkpoint.zip /app/
COPY kaztts_male1_tacotron2_train.loss.ave.zip /app/

RUN unzip /app/parallelwavegan_male1_checkpoint.zip -d /app/parallelwavegan_male1_checkpoint/
RUN unzip /app/kaztts_male1_tacotron2_train.loss.ave.zip -d /app/kaztts_male1_tacotron2_train.loss.ave/

RUN mkdir -p /app/espnet/egs2/Kazakh_TTS/tts1/exp

RUN mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_stats_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/
RUN mv /app/kaztts_male1_tacotron2_train.loss.ave/exp/tts_train_raw_char /app/espnet/egs2/Kazakh_TTS/tts1/exp/
RUN mv /app/parallelwavegan_male1_checkpoint/ /app/espnet/egs2/Kazakh_TTS/tts1/exp/vocoder

EXPOSE 8000

ENTRYPOINT ["tail", "-f", "/dev/null"]

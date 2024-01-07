from aniketd/ghcup:latest

ENV BOT_TOKEN=''

COPY . ./work-dir

WORKDIR /work-dir

RUN stack build
CMD ["stack", "run"]

# Base docker image
FROM debian:bookworm

# install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    wget \
    unzip \
    libglu1-mesa \
    libxi-dev \
    libxmu-dev \
    libglu1-mesa-dev \
    ca-certificates

# download links available at: https://www.flashforge.com/download-center
ARG FLASHPRINT_URL="https://en.fss.flashforge.com/10000/software/d9f30e5fad8a33e09039a2ceb0a96dc0.zip" 
RUN EXTENSION=$(basename $FLASHPRINT_URL | rev | cut -d. -f1 | rev) && \
    wget $FLASHPRINT_URL -O /tmp/flashprint.$EXTENSION && \
     if [ "$EXTENSION" = "zip" ]; then \
        unzip -p /tmp/flashprint.$EXTENSION '*.deb' > /tmp/flashprint.deb; \
    fi
RUN apt-get install --no-install-recommends -y /tmp/flashprint.deb

# remove build dep
RUN apt-get remove -y wget unzip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean

# find FlashPrint executable create entrypoint
RUN export FLASHPOINT=$(find /usr/share -type f -name 'FlashPrint' -executable) && \
    echo "#!/bin/sh" > entrypoint.sh && \
    echo "export XDG_RUNTIME_DIR=/tmp/runtime-flashprint" >> entrypoint.sh && \
    echo "$FLASHPOINT" >> entrypoint.sh && \
    chmod +x entrypoint.sh

# reduced permission user
RUN adduser --disabled-password --gecos '' --home /home/flashprint flashprint
USER flashprint

# entry point
CMD /entrypoint.sh

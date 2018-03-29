FROM ubuntu:16.04
LABEL maintainer="richohan.dev@gmail.com"

RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      build-essential \
      git \
      lsb-release \
      sudo \
      udev \
      usbutils \
      wget \
      vim \
      usbutils \
    && apt-get clean all

# Add user and a file under sudoers.d that makes user movidius able to execute sudo without password
RUN useradd -c "Movidius User" -m movidius
RUN echo "movidius ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-installer

RUN mkdir -p /etc/udev/rules.d/

# Clone latest version of NCSDK and sample code from source.
USER movidius
WORKDIR /home/movidius
RUN git clone https://github.com/movidius/ncsdk.git

# Compile NCSDK
WORKDIR /home/movidius/ncsdk
RUN make install

WORKDIR /home/movidius

# Dockerfile has constraints that make it impossible to run specific privileged commands during compilation.
# See: https://stackoverflow.com/questions/32510778/error-using-mount-command-within-dockerfile
# The command below should be specifically executed after the initialization of the container.
CMD sudo mount --rbind /host/dev /dev && bash
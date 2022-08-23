FROM debian:stretch

# RUN apt-get update -y && apt-get install -y software-properties-common gcc && \
    # add-apt-repository -y ppa:deadsnakes/ppa 
    # apt-get install -y python3.8 python3-pip curl wget unzip procps openjdk-8-jdk coreutils && \
    # ln -s /usr/bin/python3 /usr/bin/python && \
    # apt-get install -y r-base && \

# Prepare dirs
RUN mkdir -p /tmp/logs/ && chmod a+w /tmp/logs/ && mkdir /app && chmod a+rwx /app && mkdir /data && chmod a+rwx /data
ENV JAVA_HOME=/usr
ENV SPARK_HOME=/usr/bin/spark-3.3.0-bin-hadoop3
ENV PATH=$SPARK_HOME:$PATH:/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON=/usr/bin/python
ENV PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
ENV APP=/app
ENV SHARED_WORKSPACE=/opt/workspace
RUN mkdir -p ${SHARED_WORKSPACE}


#Install Python=3.8
# RUN apt update && \
#     apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
#     libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev curl \
#     wget libbz2-dev && \
#     wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && \
#     tar -xf Python-3.8.0.tgz && cd Python-3.8.0 && \
#     ./configure --enable-optimizations && \
#     make -j 8 && make altinstall && \
#     cd .. && rm -rf ./Python-3.8.0* && \
#     curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#     python3.8 get-pip.py && rm -rf ./get-pip.py && \
#     pip3 install numpy scipy matplotlib && \
#     rm -f /usr/bin/python && ln -s /usr/local/bin/python3.8 /usr/bin/python


# Installing Miniconda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        mercurial \
        openssh-client \
        procps \
        subversion \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py39_4.12.0

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
        SHA256SUM="78f39f9bae971ec1ae7969f0516017f2413f17796670f7040725dd83fcff5689"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
        SHA256SUM="ff6fdad3068ab5b15939c6f422ac329fa005d56ee0876c985e22e622d930e424"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
        SHA256SUM="5f4f865812101fdc747cea5b820806f678bb50fe0a61f19dc8aa369c52c4e513"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
        SHA256SUM="1fe3305d0ccc9e55b336b051ae12d82f33af408af4b560625674fa7ad915102b"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy



# System packages
RUN apt-get clean && apt-get update -y && \
    apt-get install -y curl wget unzip procps openjdk-8-jdk coreutils && \
    rm -rf /var/lib/apt/lists/*

# Install Spark
RUN curl https://dlcdn.apache.org/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-3.3.0-bin-hadoop3 /usr/bin/ && \
    mkdir /usr/bin/spark-3.3.0-bin-hadoop3/logs && \
    rm spark.tgz

# Install Scala in Docker
ARG SCALA_VERSION=2.12.12
RUN mkdir -p ${SHARED_WORKSPACE}/data && \
    mkdir -p /usr/share/man/man1 && \
    curl https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb -k -o scala.deb && \
    apt install -y ./scala.deb && \
    rm -rf scala.deb /var/lib/apt/lists/*

# Setup Ammonium Inside Docker
RUN curl -L -o /usr/local/bin/amm https://git.io/vASZm && chmod +x /usr/local/bin/amm

# Install Almond for Scala Support
ARG SCALA_KERNEL_VERSION=0.10.9

RUN apt-get install -y ca-certificates-java --no-install-recommends && \
    curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond:${SCALA_KERNEL_VERSION} --scala ${SCALA_VERSION} -- --display-name "Scala ${SCALA_VERSION}" --install && \
    rm -f coursier

VOLUME ${SHARED_WORKSPACE}
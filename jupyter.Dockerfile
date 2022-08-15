FROM mk-spark-base

# Python packages
RUN pip3 install wget requests pandas numpy datawrangler findspark jupyterlab pyspark spylon-kernel


# Installing Almond to add Compatiblity with Scala in Jupyter Lab
ARG SCALA_VERSION=2.12.12
ARG SCALA_KERNEL_VERSION=0.10.9

RUN apt-get install -y ca-certificates-java --no-install-recommends && \
    curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond:${SCALA_KERNEL_VERSION} --scala ${SCALA_VERSION} -- --display-name "Scala ${SCALA_VERSION}" --install && \
    rm -f coursier

ADD ./shared_storage/ ${SHARED_WORKSPACE}/

EXPOSE 8888

WORKDIR ${SHARED_WORKSPACE}

CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
FROM mk-spark-base

# Python packages
# RUN pip3 install wget requests pandas numpy datawrangler findspark jupyterlab pyspark spylon-kernel

# Reference from https://gist.github.com/luminoso/bcdfed320eb1dec3da80ab902dd957f9

ENV PATH /opt/conda/bin:$PATH

SHELL ["/bin/bash", "--login", "-c"]

RUN conda config --add channels conda-forge \
    && conda config --set channel_priority strict

# SHELL ["conda", "activate", "kaus", "/bin/bash", "-c"]
RUN conda create --strict-channel-priority -n kaus python=3.8 && \
    conda init bash
    
SHELL ["conda", "run", "-n", "kaus", "/bin/bash", "-c"]

RUN pip install  wget requests pandas numpy datawrangler findspark jupyterlab jupyter_contrib_nbextensions  pyspark spylon-kernel
    # conda install xeus-cling -c conda-forge && \
    # conda install xeus -c conda-forge

RUN conda install -y ipywidgets

RUN conda clean --all --yes

RUN echo "conda activate kaus" >> ~/.bashrc

SHELL ["/bin/bash", "-c"]
ADD ./shared_storage/ ${SHARED_WORKSPACE}/
WORKDIR ${SHARED_WORKSPACE}

EXPOSE 8888

CMD source activate kaus && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
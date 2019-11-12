FROM jupyter/scipy-notebook

USER root
WORKDIR    /tmp

# Python stuff
RUN python3 -m pip install --upgrade setuptools && \
    python3 -m pip install --upgrade wheel && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install quandl papermill[all] httpie prefect plotly[all] ipyaggrid

RUN jupyter labextension install ipyaggrid

RUN mkdir /home/qdb/
WORKDIR    /home/qdb/

ADD quasardb-*.whl /tmp
RUN python3 --version
RUN python3 -m pip install /tmp/quasardb-*.whl


# QuasarDB stuff
ADD qdb-*-server.tar.gz /opt/qdb/
ADD qdb-*-utils.tar.gz /opt/qdb/

# Fix workdir, permissions
WORKDIR    /home/jovyan
RUN fix-permissions /home/jovyan
USER jovyan

# Entrypoint

ADD docker-wrapper.sh /home/jovyan/docker-wrapper.sh
ENTRYPOINT /home/jovyan/docker-wrapper.sh

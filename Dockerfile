# the base miniconda3 image
FROM debian:buster-slim
RUN apt-get update && apt-get -y --no-install-recommends install gpg  wget curl ca-certificates zip bzip2
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
RUN /bin/bash /Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p /opt/conda && \
    rm /Miniconda3-py39_4.9.2-Linux-x86_64.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
RUN ln -s /opt/conda/bin/conda /bin/conda
# load in the environment.yml file - this file controls what Python packages we install
ADD environment.yml /
# install the Python packages we specified into the base environment
RUN conda update -n base conda -y && conda env update
# download the coder binary, untar it, and allow it to be executed
RUN wget https://github.com/cdr/code-server/releases/download/v3.11.0/code-server-3.11.0-linux-amd64.tar.gz \
    && tar -xzvf code-server-3.11.0-linux-amd64.tar.gz && chmod +x code-server-3.11.0-linux-amd64/code-server
RUN rm code-server-3.11.0-linux-amd64.tar.gz
RUN wget -q https://downloads.apache.org/spark//spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
RUN tar xf spark-3.1.2-bin-hadoop3.2.tgz
RUN rm -f spark-3.1.2-bin-hadoop3.2.tgz
ENV SPARK_HOME /spark-3.1.2-bin-hadoop3.2
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2
RUN apt-get update && apt-get -y --no-install-recommends install unzip
RUN curl -s "https://get.sdkman.io" | bash
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    yes | sdk install java 8.0.275.hs-adpt && \    
    rm -rf $HOME/.sdkman/archives/* && \
    rm -rf $HOME/.sdkman/tmp/*"
RUN ls -ld $HOME/.sdkman/candidates/java/8.0.275.hs-adpt
RUN mv $HOME/.sdkman/candidates/java/8.0.275.hs-adpt /opt/8.0.275.hs-adpt
RUN ln -s /opt/8.0.275.hs-adpt/bin/java /usr/bin/java
RUN java -version
ADD ./code /example
COPY docker-entrypoint.sh /usr/local/bin/
RUN echo "/opt/conda/bin/conda activate base" >> ~/.bashrc
RUN ln -s /opt/conda/bin/python /usr/local/bin/python
#RUN ufw disable
ENTRYPOINT ["docker-entrypoint.sh"]
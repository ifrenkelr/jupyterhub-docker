FROM jupyterhub/jupyterhub

RUN apt update && \
	apt-get install npm python3 python3-dev python3-pip git vim cron curl pandoc wget build-essential r-base r-base-dev libzmq3-dev pkg-config cmake texlive-xetex default-jre openjdk-11-jre-headless openjdk-8-jre-headless rsync -y && \
	python3 -m pip install jupyterhub notebook jupyterlab && \
	npm install -g configurable-http-proxy

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# UPDATE PIP
RUN python3 -m pip install --upgrade pip

# INSTALL JUPYTERHUB AUTHENTICATOR
RUN mkdir -p /jupyter_utils && cd /jupyter_utils && git clone https://github.com/jupyterhub/nativeauthenticator.git && cd /jupyter_utils/nativeauthenticator && pip3 install -e .

# CREATE JUPYTERHUB CONFIG FILE
RUN mkdir /etc/jupyterhub && cd /etc/jupyterhub  && jupyterhub --generate-config -f jupyterhub_config.py

# UPDATE JUPYTERHUB CONFIG FILE
COPY /jupyterhub_config.py /etc/jupyterhub/jupyterhub_config.py

# INSTALL PYTHON PACKAGES
COPY /pip_pkgs.txt /jupyter_utils/pip_pkgs.txt
RUN pip3 install -r /jupyter_utils/pip_pkgs.txt

# Install Java kernel for JUPYTER
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip && unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Add R to Jupyter kernel
RUN R -e "install.packages('devtools')" && R -e "install.packages('IRkernel', repos='http://cran.rstudio.com/')" && R -e "IRkernel::installspec(user = FALSE)" && R -e "install.packages(c('vioplot', 'MASS','CARAT','E1071','rpart','KernLab','Nnet','ggplot2','dplyr'))"

# Install spylon kernel (Scala)
RUN pip3 install spylon-kernel && python3 -m spylon_kernel install

# Install MatLab kernel
RUN pip3 install matlab_kernel

# Install Bash kernel
RUN pip3 install bash_kernel && python3 -m bash_kernel.install

# CUSTOMIZE UI COMPONENTS
COPY /page.html /usr/local/share/jupyterhub/templates/page.html
COPY /icons/java/* /usr/share/jupyter/kernels/java/
COPY /icons/bash/* /usr/local/share/jupyter/kernels/bash/
COPY /icons/matlab/* /usr/local/share/jupyter/kernels/matlab/
COPY /icons/scala/* /usr/local/share/jupyter/kernels/spylon-kernel/

RUN chmod 777 /tmp && /etc/init.d/cron restart

EXPOSE 8000

CMD ["/usr/local/bin/jupyterhub","-f","/etc/jupyterhub/jupyterhub_config.py"]

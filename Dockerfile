FROM amazon/aws-glue-libs:glue_libs_3.0.0_image_01

USER root

SHELL ["/bin/bash", "-c"]

WORKDIR /work
ADD . .

RUN bash -c "rm /home/glue_user/spark/conf/hive-site.xml"

RUN yum install --setopt=sslverify=0 -y dos2unix
# RUN dos2unix do/coverage.sh

RUN python3 -m pip config set global.trusted-host "pypi.org files.pythonhosted.org pypi.python.org"
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install -r requirements-validation.txt -r software/requirements.txt -r software/requirements-test.txt

ENV PYTHONPATH $PYTHONPATH:/work/software/src:/work/software/tests
ENV PATH $PATH:/home/glue_user/spark/bin

RUN echo 'alias pytest_cov=/work/do/pytest_cov.sh' >> ~/.bashrc

ENTRYPOINT []
CMD bash -c 'pytest --cov-report= --cov=/work/software/src/ /work/software/tests/'
# wsl --restart
# wsl --shutdown
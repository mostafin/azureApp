FROM python:3.6.2
WORKDIR /whoami
COPY /whoami /whoami

RUN pip install --requirement /whoami/requirements.txt

ENTRYPOINT [ "python" ]
CMD ["/whoami/whoami.py"]
FROM python:3-alpine

WORKDIR /src

RUN apk update

RUN apk add	py3-pip && pip install boto3

COPY main.py /src/main.py

CMD ["/usr/local/bin/python3", "/src/main.py"]

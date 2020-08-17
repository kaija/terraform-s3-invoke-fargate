.PHONY: all
all:
	docker build -t kaija/s3read .

run:
	docker run -e AWS_BUCKET=diamond-terraform-aaron -e AWS_OBJECT=test.txt -v /home/kaija/.aws/credentials:/root/.aws/credentials -v /home/kaija/.aws/config:/root/.aws/config kaija/s3read

push:
	docker push kaija/s3read

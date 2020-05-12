build:
	docker build -t tippecanoe .
	docker run -it -v $(PWD)/tmp:/tmp --rm tippecanoe bash -c "cp /packages/* /tmp/"

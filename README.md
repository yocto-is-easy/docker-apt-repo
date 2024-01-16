Debian-repository for Docker
============================

A local repository for publishing deb files for use with apt.

This docker box provides an apt repository based on the tool reprepro. 
The repository is served by an nginx server.


Usage
-----

### Running the box

Clone the repository, enter the directory.

Add your ssh keys to the keys dir in repository(create it by your own)

Start up docker compose:

	docker-compose up --build

### Uploading packages

First you need to upload needed packages to the docker container

	scp <your-deb-packet> user@2.2.0.2:/docker/incoming

Then enter docker container:

	docker exec -ti debpack-container bash

And upload deb packages with:

	deb-import

### Accessing the repository

Add the following line to your source list

	deb http://192.168.0.105:49161/ mocto main

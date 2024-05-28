# AWS-LAB
This aim of this project is to provision a complete AWS infrastructure with a RDS instance and to deploy on that infrastructure  a web application that is micro-serviced and has SSL certifictates.
___________________________
This branch contains the node express app files and the Dockerfile for creating the dockerizd image for the project.

The backend app connects to the db and pulls queries from it.

There are 6 env vars you need to configure when you provision this service:

1. DB_HOST - The DB host adress
2. DB_USER - DB servers username to login
3. DB_DATABASE -  DB servers db to connect to
4. DB_PASSWORD - DB servers password for login
5. DB_PORT - Port of the db server
6. PORT - Port of the service that is will run on

7. * Note the Dockerimage contains the curl command for installation

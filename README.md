# AWS-LAB
This aim of this project is to provision a complete AWS infrastructure with a RDS instance and to deploy on that infrastructure  a web application that is micro-serviced and has SSL certifictates.
___________________________
This branch contains the node react for creating the frontend service app files and the Dockerfile for creating the dockerizd image for the project.

The frontend app connect to the backend service and sends a get request every X seconds, the time interval can be configured by clicking the number on 'Welcome Labcom *number*' and changing the seconds interval.

There is one .env file that contains the address of the backend service.

*This webapp runs on *npm serve* becuase of older dependencies that are making the forntend app crash so we provide an .env file for that, unline the backend which runs fine with runtime env vars.

Snap of the frontend:
![Screenshot from 2024-05-22 11-00-59](https://github.com/VadimV1/AWS-LAB/assets/20540663/9473838a-ec48-4f80-b742-f6a851abe1cc)

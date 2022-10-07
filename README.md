[![Code Review Doctor](https://codereview.doctor/pseusys/HogWeedGo/main.svg)](https://codereview.doctor/pseusys/HogWeedGo)
[![SERVER](https://github.com/pseusys/HogWeedGo/actions/workflows/server.yml/badge.svg)](https://github.com/pseusys/HogWeedGo/actions/workflows/server.yml)
[![CLIENT](https://github.com/pseusys/HogWeedGo/actions/workflows/client.yml/badge.svg)](https://github.com/pseusys/HogWeedGo/actions/workflows/client.yml)
[![ML-HELPER](https://github.com/pseusys/HogWeedGo/actions/workflows/ml-helper.yml/badge.svg)](https://github.com/pseusys/HogWeedGo/actions/workflows/ml-helper.yml)
[![REPORT](https://github.com/pseusys/HogWeedGo/actions/workflows/report.yml/badge.svg)](https://github.com/pseusys/HogWeedGo/actions/workflows/report.yml)

# HogWeedGo

(This project was my bachelor thesis, report available [here](https://github.com/pseusys/HogWeedGo/releases/download/v0.0.1-report/report.pdf))

HogWeedGo is a software system for monitoring potentially dangerous plant species.
However, because of it's decentralized structure, it can be used for monitoring any immovable objects with minor changes.

## The Idea
The idea is simple: there are `users` (volunteers, clients, drones, etc.) and `experts` (ecologists, system administrators).  
From time to time users find something that is worth being mentioned, for example a potentially dangerous plant. They send a `report` about it to experts.
Report contains short description, address, photo, and a type of object found.
Experts can store, modify, delete reports, collect statistics and correct mistakes.
In case of emergency, there is a way for experts to contact any user and to block or delete his account.

## The System
The system consists of two major parts:
1. Server application (python3, django, postgresql, docker)  
The server application provides experts with possibility to create, modify and delete reports and user accounts.
There are some possibilities to sort and filter reports (and even more are yet to come!).
Server application provides a handy web interface to experts as well as documented REST API for client application(s) and external resources for monitoring results displaying.

2. Client application (dart, flutter)  
Client application provides an interface for server application report creating and sending API as well as brief overview over general monitoring results.
Client application is still under construction ⚠️.

3. ML Helper (python, tensorflow)  
ML helper is a JuPyter Notebook used for training convolutional neural network to automatically label objects being reported (judging by their photos).
Trained neural network will be embedded into client application, it's output will be used for giving users appropriate reporting advices.

## Building and Deployment
An easy deployment pipeline has been set up for server application, see [here](https://github.com/pseusys/HogWeedGo/tree/main/server#launch-server-locally).

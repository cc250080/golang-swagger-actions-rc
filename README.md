# GO-Swagger Github Actions Pipeline
The objective of this repo is to take notes of the process of creating a pipeline for the application https://github.com/segator/go-swagger-example

The app creator also provided with e2e tests that need to be executed during the deployment pipeline.

## Requisites


    https://go.dev/ >= 1.17
    https://github.com/go-swagger/go-swagger

This application is sending messages to SQS, so having a SQS, so having an SQS queue available and reachable is also part of the requisites.

## First Steps

### Run the app on local

 * Setup aws cli with a user with enough rights to create basic resources
* Use the aws cli to create a SQS queue with an auto-purge of 180 seconds
* Use IAM to create a policy that allows only to create and read messages from this Queue
* Create a user with only this Policy assigned and generate AWS KEYS

After the SQS queue was ready, I only had to install go and swagger-go, build the app, run it and run the e2e tests against it.

Important to note that for the app to work I had to configure different AWS related environment variables.

### Dockerize the App

With the goal to try a multilayered *Dockerfile* and end with a small as possible final Docker Container I created the *Dockerfile* that can be found in the root folder of this repo.

### Use github actions from the MarketPlace

Since I am new to this tool I wanted to test the *Github Actions* way of doing this process, not only using *Jobs* but also predefined actions that act as plugins.
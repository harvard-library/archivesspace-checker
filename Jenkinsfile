#!groovy
@Library('lts-basic-pipeline') _

// projName: The directory name for the project on the servers for it's docker/config files
// intTestPort: port of integration test container
// intTestEndpoints: List of integration test endpoints i.e. ['healthcheck/', 'another/example/']
// default values: slackChannel = "lts-jenkins-notifications"

// Signature is: "<imageName>", "<stackName>", "<projName>", "<intTestPort>", endpoints, "<slackChannel>

def endpoints = []
ltsBasicPipeline.call("archivesspace-checker", "ARCHECK", "archeck", "", endpoints)
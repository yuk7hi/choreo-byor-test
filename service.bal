import ballerina/http;
import ballerina/log;
import ballerina/os;

service / on new http:Listener(8090) {
    function init() {
        log:printInfo("Service started successfully...");
    }

    resource function get alive(http:Caller caller) {
        string testValue = os:getEnv("TEST_KEY");
        log:printInfo("ENVIRONMENT: " + testValue);
        log:printInfo(caller.remoteAddress.toBalString());
        log:printInfo(caller.getRemoteHostName().toString());

        checkpanic caller->respond(testValue.toJson());
    }
}
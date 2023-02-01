import ballerina/http;
import ballerina/log;

service / on new http:Listener(8090) {
    function init() {
        log:printInfo("Service started successfully...");
    }

    resource function get alive(http:Caller caller) {
        log:printInfo(caller.remoteAddress.toBalString());
        log:printInfo(caller.getRemoteHostName().toString());
    }
}
import ballerina/http;
import ballerina/log;
import ballerina/os;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type MysqlConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
    mysql:Options options;
    sql:ConnectionPool connectionPool;
|};

configurable MysqlConfig testDbConfig = ?;
final mysql:Client testDbClient = check new (
    testDbConfig.host,
    testDbConfig.user,
    testDbConfig.password,
    testDbConfig.database,
    testDbConfig.port,
    testDbConfig.options,
    testDbConfig.connectionPool
);

// configurable map<string[]> testStringArrayMap = ?;

service / on new http:Listener(8090) {
    function init() {
        log:printInfo("Service started successfully...");
    }

    resource function get alive(http:Caller caller) {
        string testValue = os:getEnv("TEST_KEY");
        log:printInfo("ENVIRONMENT: " + testValue);
        log:printInfo(caller.remoteAddress.toBalString());
        log:printInfo(caller.getRemoteHostName().toString());

        // log:printInfo(testStringArrayMap.toString());

        checkpanic caller->respond(testValue.toJson());
    }
}
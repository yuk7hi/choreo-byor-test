import ballerina/http;
import ballerina/log;
import ballerina/os;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/random;
import ballerina/time;
import ballerinax/mysql.driver as _;
import ballerina/constraint;

type MysqlConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
    mysql:Options options;
    sql:ConnectionPool connectionPool;
|};

type IndexOfvsSomeResult record {|
    int index;
    time:Seconds indexOfTime;
    time:Seconds someTime;
    decimal speedFactor;
|};

# Exact time and day of a week upto minute precision.
type TimeAndDayOfWeek record {
    # Hour as an integer
    @constraint:Int {
        minValue: 0,
        maxValue: 23
    }
    int hour;
    # Minute as an integer
    @constraint:Int {
        minValue: 0,
        maxValue: 59
    }
    int minute;
};

# Configuration for a scheduled task triggered via an HTTP endpoint.
type ScheduledTask record {
    # Task name
    string name;
    # Task trigger endpoint
    @constraint:String {
        pattern: {
            value: re `^http[s]?://.*`,
            message: "Endpoint should be a valid HTTP URL"
        }
    }
    string endpoint;
    # Scheduled period (in seconds)
    decimal|TimeAndDayOfWeek period;
};

configurable ScheduledTask[] scheduledTasks = ?;

// configurable MysqlConfig testDbConfig = ?;
// final mysql:Client testDbClient = check new (
//     testDbConfig.host,
//     testDbConfig.user,
//     testDbConfig.password,
//     testDbConfig.database,
//     testDbConfig.port,
//     testDbConfig.options,
//     testDbConfig.connectionPool
// );

configurable map<string> testStringArrayMap = ?;

service / on new http:Listener(8090) {
    function init() {
        log:printInfo("Service started successfully...");
    }

    resource function get alive(http:Caller caller) {
        string testValue = os:getEnv("TEST_KEY");
        log:printInfo("ENVIRONMENT: " + testValue);
        log:printInfo(caller.remoteAddress.toBalString());
        log:printInfo(caller.getRemoteHostName().toString());

        log:printInfo(testStringArrayMap.toString());

        checkpanic caller->respond(testValue.toJson());
    }

    resource function get listEnv() returns json|error {
        map<string> envList = os:listEnv();
        return envList;
    }

    resource function get indexOfvsSome() returns json|error {
        string[] testArray = [];
        testArray.setLength(1000 * 1000);

        IndexOfvsSomeResult[] results = [];

        // Generate random numbers for the test array
        foreach var [i, _] in testArray.enumerate() {
            int randomNum = check random:createIntInRange(0, 1000 * 1000 * 1000);
            testArray[i] = randomNum.toString();
        }

        foreach var i in int:range(0, 10, 1) {
            int index = check random:createIntInRange(0, 1000 * 1000 - 1);
            match i {
                0 => {
                    index = 9;
                }
                9 => {
                    index = 1000 * 1000 - 10;
                }
                _ => {
                }
            }

            log:printInfo("Index: " + index.toString());
            string[] clonedArray = testArray.clone();
            clonedArray[index] = "X";

            time:Utc someStartTime = time:utcNow();
            boolean _ = clonedArray.some(s => s == "X");
            time:Seconds someTime = time:utcDiffSeconds(time:utcNow(), someStartTime);

            time:Utc indexOfStartTime = time:utcNow();
            int? _ = clonedArray.indexOf("X");
            time:Seconds indexOfTime = time:utcDiffSeconds(time:utcNow(), indexOfStartTime);

            decimal speedFactor = someTime / indexOfTime;

            results.push({index, indexOfTime, someTime, speedFactor});
        }

        decimal avgSpeedFactor = results.reduce(
            function(decimal sum, IndexOfvsSomeResult next) returns decimal
                => sum + next.speedFactor, 0d
        ) / results.length();

        return {avgSpeedFactor, results};
    }
}

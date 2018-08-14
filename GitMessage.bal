import ballerina/http;
import ballerina/io;
import wso2/twilio;

documentation {
A service endpoint represents a listener.
}
endpoint http:Listener listener {
    port:8080
};

documentation {
A service is a network-accessible API
Advertised on '/hello', port comes from listener endpoint
}
endpoint twilio:Client twilioClient {
    accountSId:"19349315",
    authToken:"93b5cf7411afb8ef6d6fc8e60962e0d55ebb191f"
};
service<http:Service> jsons bind listener {

    documentation {
A resource is an invokable API method
Accessible at '/hello/sayHello
'caller' is the client invoking this resource

P{{caller}} Server Connector
P{{request}} Request
}
    payload (endpoint caller, http:Request request) {
        http:Response response = new;
        var payload = request.getJsonPayload();
        match payload {
            json myJsonPayload => {
                // io:println(myJsonPayload["commits"])
                foreach (commit in myJsonPayload["commits"]){
                    io:println(commit["author"]["name"]);
                    io:println(commit["message"]);
                    string sms = commit["author"]["name"].toString()+" made a new change("+commit["message"].toString()+")";
                    var details = twilioClient->sendSms("+15005550006", "+94775633985", untaint sms);
                    match details {
                        twilio:SmsResponse smsResponse => io:println(smsResponse);
                        twilio:TwilioError twilioError => io:println(twilioError);
                    }
                }
                response.setJsonPayload({"status":"ok"});
            }
            any => {
                io:println("invalid response");
                response.setJsonPayload({"status":"error"});
            }
        }
        // io:println(payload);
        // io:println(request);

        // Send a response back to caller
        // Errors are ignored with '_'
        // -> indicates a synchronous network-bound call
        _ = caller -> respond(response);
    }
}


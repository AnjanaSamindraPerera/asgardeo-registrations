import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/googleapis.gmail;
import ballerina/io;
import ballerina/regex;


configurable asgardeo:ListenerConfig config = ?;

configurable string googleClientId = ?;
configurable string googleClientSecret = ?;
configurable string googleRefreshToken = ?;
configurable string senderEmail = ?;
configurable string receiverEmail = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
      log:printInfo(event.toJsonString());

      asgardeo:GenericUserData? userData = event.eventData;
      string? userName = userData?.userName;

      error? err = sendMail(<string> userName);
      if (err is error) {
          log:printInfo(err.message());
      }
     return;
    }
    
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
        
        log:printInfo(event.toJsonString());

        asgardeo:GenericUserData? userData = event.eventData;
        string? userName = userData?.userName;

        error? err = sendMail(<string> userName);
        if (err is error) {
            log:printInfo(err.message());
        }
        return;
    }
    
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
    
        log:printInfo(event.toJsonString());

        asgardeo:GenericUserData? userData = event.eventData;
        string? userName = userData?.userName;

        error? err = sendMail(<string> userName);
        if (err is error) {
            log:printInfo(err.message());
        }
        return; 
    }
}

service /ignore on httpListener {}

function sendMail(string recipientEmail) returns error? {

    string rawEmailTemplate = check io:fileReadString("./index.html");
    string emailTemplate = regex:replaceAll(rawEmailTemplate, "newUser", recipientEmail);

    gmail:ConnectionConfig gmailConfig = {
        auth: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: googleRefreshToken,
            clientId: googleClientId,
            clientSecret: googleClientSecret
        }
    };
    
    gmail:Client gmailClient = check trap new (gmailConfig);
    string userId = "me";
    gmail:MessageRequest messageRequest = {
        recipient: recipientEmail,
        subject: "Your Dream Home with John Doe Holdings",
        messageBody:  emailTemplate,
        contentType: gmail:TEXT_HTML,
        sender: "Asgardeo E2E Test <senderEmail>"
    };
    gmail:Message m = check gmailClient->sendMessage(messageRequest, userId = userId);
    log:printInfo(m.toJsonString());
}

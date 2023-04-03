import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/googleapis.gmail;
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
    
    string rawEmailTemplate= "<!DOCTYPE html><html><head></head><body><h1>Welcome to John Doe Holdings Pvt Ltd!</h1><div>Dear NewUser,<br><br>Thank you for signing up with <b>John Doe Holdings Pvt Ltd!</b> We're thrilled to have you join us and are looking forward to your contributions to our organization.</div><div><br/>Best regards,<br/>Manager,<br/>John Doe Holdings Pvt Ltd</div></body></html>";

    string emailTemplate = regex:replaceAll(rawEmailTemplate, "NewUser", recipientEmail);

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

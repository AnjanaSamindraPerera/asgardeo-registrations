import ballerinax/trigger.asgardeo;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
      //Not Implemented
    }
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
      //Not Implemented
    }
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
      //Not Implemented
    }
}

service /ignore on httpListener {}
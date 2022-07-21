#import "RNUmp.h"
#include <UserMessagingPlatform/UserMessagingPlatform.h>

@implementation RNUmp

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_MODULE()

// NSString *const FORM_STATUS_UNKNOWN = @"form_status_unknown"; // Form status unknown. You should call requestConsentInfoUpdateWithParameters:completionHandler: in this case.
// NSString *const FORM_STATUS_AVAILABLE = @"form_status_available"; // A consent form is available and can be loaded.
// NSString *const FORM_STATUS_UNAVAILABLE = @"form_status_unavailable"; // A consent form is not available.

// NSString *const CONSENT_STATUS_UNKNOWN = @"consent_status_unknown"; // Unknown consent status.
// NSString *const CONSENT_STATUS_REQUIRED = @"consent_status_required"; // User consent required but not yet obtained.
// NSString *const CONSENT_STATUS_NOT_REQUIRED = @"consent_status_not_required"; // User consent not required. For example, the user is not in the EEA or UK.
// NSString *const CONSENT_STATUS_OBTAINED = @"consent_status_obtained"; // User consent obtained. Personalization not defined.

- (NSDictionary *)constantsToExport {
    return @{
        // @"FORM_STATUS_UNKNOWN" : [NSNumber numberWithInt:UMPFormStatusUnknown],
        // @"FORM_STATUS_AVAILABLE" : [NSNumber numberWithInt:UMPFormStatusAvailable],
        // @"FORM_STATUS_UNAVAILABLE" : [NSNumber numberWithInt:UMPFormStatusUnavailable],

        @"CONSENT_STATUS_UNKNOWN" : [NSNumber numberWithInt:UMPConsentStatusUnknown],
        @"CONSENT_STATUS_REQUIRED" : [NSNumber numberWithInt:UMPConsentStatusRequired],
        @"CONSENT_STATUS_NOT_REQUIRED" : [NSNumber numberWithInt:UMPConsentStatusNotRequired],
        @"CONSENT_STATUS_OBTAINED" : [NSNumber numberWithInt:UMPConsentStatusObtained]
    };
}

RCT_EXPORT_METHOD(requestConsentInfoUpdate
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    @try {
        // Create a UMPRequestParameters object.
        UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
        
        // UMPDebugSettings *debugSettings = [[UMPDebugSettings alloc] init];
        // debugSettings.geography = UMPDebugGeographyEEA;
        // debugSettings.testDeviceIdentifiers = @[ @"6F9BAB85-B474-4563-8ABC-4E4E061490F7" ];
        // parameters.debugSettings = debugSettings;
        
        // Set tag for under age of consent. Here NO means users are not under age.
        parameters.tagForUnderAgeOfConsent = NO;

        // Request an update to the consent information.
        [UMPConsentInformation.sharedInstance
            requestConsentInfoUpdateWithParameters:parameters
                completionHandler:^(NSError *_Nullable error) {
                    if (error) {
                        NSLog(@"RNUmp [UMP requestConsentInfoUpdate] error: %@", error.localizedDescription);
                        reject(@"requestConsentInfoUpdate_error", error.localizedDescription, error);
                    } else {
                        NSLog(@"RNUmp [UMP requestConsentInfoUpdate] formStatus: %@", @(UMPConsentInformation.sharedInstance.formStatus));
                        NSDictionary *payload = @{
                            // @"formStatus":@(UMPConsentInformation.sharedInstance.formStatus),
                            @"consentStatus":@(UMPConsentInformation.sharedInstance.consentStatus),
                            @"isConsentFormAvailable":@(UMPConsentInformation.sharedInstance.formStatus == UMPFormStatusAvailable),
                        };
                        resolve(payload);
                    }
                }];
        
    } @catch (NSError *error) {
        NSLog(@"RNUmp [UMP requestConsentInfoUpdate] error: %@", error.localizedDescription);
        reject(@"requestConsentInfoUpdate_error", error.localizedDescription, error);
    }
}

RCT_EXPORT_METHOD(showConsentForm
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    @try {
        [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form,
                                              NSError *loadError) {
            if (loadError) {
                NSLog(@"RNUmp [UMP loadWithCompletionHandler] error: %@", loadError.localizedDescription);
                reject(@"loadWithCompletionHandler_error", loadError.localizedDescription, loadError);
            } else {
                [form
                    presentFromViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                        completionHandler:^(NSError *_Nullable dismissError) {
                        resolve([NSNumber numberWithInt:UMPConsentInformation.sharedInstance.consentStatus]);
                        // if (UMPConsentInformation.sharedInstance.consentStatus ==
                        //     UMPConsentStatusObtained) {
                        //         resolve(CONSENT_STATUS_OBTAINED);
                        // } else if (UMPConsentInformation.sharedInstance.consentStatus ==
                        //     UMPConsentStatusNotRequired) {
                        //         resolve(CONSENT_STATUS_NOT_REQUIRED);
                        // } else if (UMPConsentInformation.sharedInstance.consentStatus ==
                        //     UMPConsentStatusRequired) {
                        //         resolve(CONSENT_STATUS_REQUIRED);
                        // } else if (UMPConsentInformation.sharedInstance.consentStatus ==
                        //     UMPConsentStatusUnknown) {
                        //         resolve(CONSENT_STATUS_UNKNOWN);
                        // }
                    }];
                
            }
        }];
    } @catch (NSError *error) {
        NSLog(@"RNUmp [UMP showConsentForm] error: %@", error.localizedDescription);
        reject(@"showConsentForm_error", error.localizedDescription, error);
    }
}

RCT_EXPORT_METHOD(reset) {
    @try {
        NSLog(@"RNUmp [UMP reset]");
        [UMPConsentInformation.sharedInstance reset];
    } @catch (NSError *error) {
        NSLog(@"RNUmp [UMP reset] error: %@", error.localizedDescription);
    }
}   

RCT_EXPORT_METHOD(getTCFConsent:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSLog(@"RNUmp [getTCFConsent]");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *tcfConsent = [prefs stringForKey:@"IABTCF_AddtlConsent"];
        NSLog(@"RNUmp [getTCFConsent] %@: ", tcfConsent);
        resolve(tcfConsent);
    } @catch (NSError *error) {
        NSLog(@"RNUmp [getTCFConsent] error: %@", error.localizedDescription);
        reject(@"getTCFConsent error", error.localizedDescription, nil);
    }
}

@end

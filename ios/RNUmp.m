#import "RNUmp.h"
#include <UserMessagingPlatform/UserMessagingPlatform.h>

@implementation RNUmp

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(showConsentForm
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    @try {
        // Create a UMPRequestParameters object.
        UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];
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
                        UMPFormStatus formStatus =
                            UMPConsentInformation.sharedInstance.formStatus;
                        if (formStatus == UMPFormStatusAvailable) {
                            [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form,
                                    NSError *loadError) {
                                    if (loadError) {
                                        NSLog(@"RNUmp [UMP loadWithCompletionHandler] error: %@", loadError.localizedDescription);
                                        reject(@"loadWithCompletionHandler_error", loadError.localizedDescription, loadError);
                                    } else {
                                        // Present the form. You can also hold on to the reference to present later.
                                        if (UMPConsentInformation.sharedInstance.consentStatus ==
                                            UMPConsentStatusRequired) {
                                            [form
                                                presentFromViewController:self
                                                    completionHandler:^(NSError *_Nullable dismissError) {
                                                    resolve(UMPConsentInformation.sharedInstance.consentStatus);
                                                }];
                                        } else {
                                            // Keep the form available for changes to user consent.
                                        }
                                    }
                                }];
                        }
                    }
                }];
        
    } @catch (NSError *error) {
        NSLog(@"RNUmp [UMP showConsentForm] error: %@", error.localizedDescription);
        reject(@"showConsentForm_error", error.localizedDescription, error);
    }
}

@end

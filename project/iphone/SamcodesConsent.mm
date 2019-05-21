#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

#import "PersonalizedAdConsent.h"

#include "SamcodesConsent.h"

extern "C" void sendConsentUpdateEvent(const char* type, const char* error, int consent);
extern "C" void sendConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree);

// Returns a deep copy of the given string as a UTF8 string
// Must be deallocated with free() when we're done with it
const char* deepCopyString(NSString* s)
{
    if(s == nil) {
        return strdup("");
    }
    const char* strUtf8Data = [s UTF8String];
    if(strUtf8Data == NULL) {
        return strdup("");
    }
    return strdup(strUtf8Data);
}

void dispatchConsentUpdateEvent(NSString* type, NSString* error, int consent)
{
    NSLog(@"Will dispatch consent update event: [%@] with error message: [%@]", type, error);
    
    const char* typeChars = deepCopyString(type);
    const char* errorChars = deepCopyString(error);
    
    void (^blockClosure)() = ^void() {
        sendConsentUpdateEvent(
            typeChars,
            errorChars,
            consent
        );
        
        free((void*)(typeChars));
        free((void*)(errorChars));
    };
    
    dispatch_async(dispatch_get_main_queue(), blockClosure);
}

void dispatchConsentFormEvent(NSString* type, NSString* error, int consent, bool userPrefersAdFree)
{
    NSLog(@"Will dispatch consent form event: [%@] with error message: [%@]", type, error);
    
    const char* typeChars = deepCopyString(type);
    const char* errorChars = deepCopyString(error);
    
    void (^blockClosure)() = ^void() {
        sendConsentFormEvent(
            typeChars,
            errorChars,
            consent,
            userPrefersAdFree
        );
        
        free((void*)(typeChars));
        free((void*)(errorChars));
    };
    
    dispatch_async(dispatch_get_main_queue(), blockClosure);
}

PACConsentForm* sharedConsentForm = NULL;

// Note this mirrors an enum abstract in the Haxe code, be sure to check this hasn't changed if using a newer consent SDK
int consentStatusToInt(PACConsentStatus consentStatus)
{
    return (int)(consentStatus);
}
PACConsentStatus intToConsentStatus(int consentStatus)
{
    PACConsentStatus s = (PACConsentStatus)(consentStatus);
    return s;
}

namespace samcodesconsent
{
    void requestStatus(const char* publisherId)
    {
        NSLog(@"Will request GDPR consent status");
        
        NSString* nsPublisherId = [NSString stringWithUTF8String:publisherId];
        NSArray<NSString*>* publisherIds = [NSArray arrayWithObjects:nsPublisherId, nil];
        
        [PACConsentInformation.sharedInstance requestConsentInfoUpdateForPublisherIdentifiers:publisherIds
        completionHandler:^(NSError *_Nullable error) {
            if (!error) {
                // Consent info update succeeded. The shared PACConsentInformation instance has been updated.
                PACConsentStatus c = PACConsentInformation.sharedInstance.consentStatus;
                int consentValue = consentStatusToInt(c);
                dispatchConsentUpdateEvent(@"onConsentInfoUpdated", @"", consentValue);
            } else {
                // Consent info update failed.
                NSString* errorDescription = [error localizedDescription];
                dispatchConsentUpdateEvent(@"onFailedToUpdateConsentInfo", errorDescription, 0);
            }
        }];
    }
    
    void requestConsentForm(const char* privacyUrl, bool personalizedAdsOption, bool nonPersonalizedAdsOption, bool adFreeOption)
    {
        NSLog(@"Will request GDPR consent form");
        
        NSString* privacyUrlString = [NSString stringWithUTF8String:privacyUrl];
        NSURL* privacyURL = [NSURL URLWithString:privacyUrlString];
        
        sharedConsentForm = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
        
        sharedConsentForm.shouldOfferPersonalizedAds = personalizedAdsOption ? YES : NO;
        sharedConsentForm.shouldOfferNonPersonalizedAds = nonPersonalizedAdsOption ? YES : NO;
        sharedConsentForm.shouldOfferAdFree = adFreeOption ? YES : NO;
        
        [sharedConsentForm loadWithCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"Load complete. Error: %@", error);
            if (!error) {
                // Load successful.
                dispatchConsentFormEvent(@"onConsentFormLoaded", @"", 0, false);
            } else {
                // Report error.
                NSString* errorDescription = [error localizedDescription];
                dispatchConsentFormEvent(@"onConsentFormError", errorDescription, 0, false);
            }
        }];
    }
    
    bool displayConsentForm()
    {
        NSLog(@"Will display GDPR consent form");
        
        UIViewController* rvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        if(rvc == NULL) {
            NSLog(@"Will fail to display consent form, couldn't get root view controller");
            return false;
        }
        
        if(sharedConsentForm == NULL) {
            NSLog(@"Will fail to display consent form, it was NULL. Perhaps requestConsentForm didn't complete successfully.");
            return false;
        }
        
        // Note this isn't quite when the form is opened, but there doesn't seem to be a better place to put this...
        dispatchConsentFormEvent(@"onConsentFormOpened", @"", 0, false);
        
        [sharedConsentForm presentFromViewController:rvc
           dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
               NSLog(@"Did dismiss GDPR consent form");
               
               if (!error) {
                   // Check the user's consent choice.
                   PACConsentStatus c = PACConsentInformation.sharedInstance.consentStatus;
                   int consentValue = consentStatusToInt(c);
                   dispatchConsentFormEvent(@"onConsentFormClosed", @"", consentValue, false);
               } else {
                   // Handle error.
                   NSString* errorDescription = [error localizedDescription];
                   dispatchConsentFormEvent(@"onConsentFormError", errorDescription, 0, false);
               }
        }];
        
        return true;
    }
    
    bool isRequestLocationInEeaOrUnknown()
    {
        return [PACConsentInformation.sharedInstance isRequestLocationInEEAOrUnknown];
    }
    
    int getConsentStatus()
    {
        return consentStatusToInt([PACConsentInformation.sharedInstance consentStatus]);
    }
    
    void setConsentStatus(int consentStatus)
    {
        PACConsentStatus c = intToConsentStatus(consentStatus);
        [PACConsentInformation.sharedInstance setConsentStatus:c];
    }
}

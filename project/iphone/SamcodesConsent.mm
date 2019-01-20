#include <ctype.h>
#include <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

#import "PersonalizedAdConsent.h"

#include "SamcodesConsent.h"

extern "C" void sendConsentUpdateEvent(const char* type, const char* error, int consent);
extern "C" void sendConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree);

PACConsentForm* sharedConsentForm = NULL;

void queueConsentUpdateEvent(const char* type, const char* error, int consent)
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		sendConsentUpdateEvent(type, error, consent);
	}];
}

void queueConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree)
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		sendConsentFormEvent(type, error, consent, userPrefersAdFree);
	}];
}

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
		
		NSString* publisherId = [NSString stringWithUTF8String:publisherId];
		NSArray<NSString*>* publisherIds = [NSArray arrayWithObjects:publisherId, nil];
		
		[PACConsentInformation.sharedInstance requestConsentInfoUpdateForPublisherIdentifiers:publisherIds
			completionHandler:^(NSError *_Nullable error) {
				if (!error) {
					// Consent info update succeeded. The shared PACConsentInformation instance has been updated.
					PACConsentStatus c = PACConsentInformation.sharedInstance.consentStatus;
					int consentValue = consentStatusToInt(c);
					queueConsentUpdateEvent("onConsentInfoUpdated", "", consentValue);
				} else {
					// Consent info update failed.
					NSString* errorDescription = [error localizedDescription];
					queueConsentUpdateEvent("onFailedToUpdateConsentInfo", [errorDescription cStringUsingEncoding:[NSString defaultCStringEncoding]], 0);
				}
			}
		];
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
				queueConsentFormEvent("onConsentFormLoaded", "", 0, false);
			} else {
				// Report error.
				NSString* errorDescription = [error localizedDescription];
				queueConsentFormEvent("onConsentFormError", [errorDescription cStringUsingEncoding:[NSString defaultCStringEncoding]], 0, false);
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
		queueConsentFormEvent("onConsentFormOpened", "", 0, false);
		
		[sharedConsentForm presentFromViewController:rvc
			dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
				NSLog(@"Did dismiss GDPR consent form");
				
				if (!error) {
					// Check the user's consent choice.
					PACConsentStatus c = PACConsentInformation.sharedInstance.consentStatus;
					int consentValue = consentStatusToInt(c);
					queueConsentFormEvent("onConsentFormClosed", "", consentValue, false);
				} else {
					// Handle error.
					NSString* errorDescription = [error localizedDescription];
					queueConsentFormEvent("onConsentFormError", [errorDescription cStringUsingEncoding:[NSString defaultCStringEncoding]], 0, false);
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
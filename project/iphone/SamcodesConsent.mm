#include <ctype.h>
#include <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

#include "SamcodesConsent.h"

extern "C" void sendConsentUpdateEvent(const char* type, const char* error, int consent);
extern "C" void sendConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree);

void queueConsentUpdateEvent(const char* type, const char* error, int consent)
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		sendConsentUpdateEvent(type, error, consent);
	}];
}

void queueConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree)
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		sendConsentFormEvent(type, error, consent, userPreferAdFree);
	}];
}

// TODO

@interface MyChartboostDelegate : NSObject<ChartboostDelegate>
@end

@implementation MyChartboostDelegate

// Called before requesting an interstitial via the Chartboost API server.
- (BOOL)shouldRequestInterstitial:(CBLocation)location
{
	queueChartboostEvent("shouldRequestInterstitial", [location cStringUsingEncoding:[NSString defaultCStringEncoding]], "", 0, -1, false);

	return YES;
}

// Called before an interstitial will be displayed on the screen.
- (BOOL)shouldDisplayInterstitial:(CBLocation)location
{
	queueChartboostEvent("shouldDisplayInterstitial", [location cStringUsingEncoding:[NSString defaultCStringEncoding]], "", 0, -1, false);

	return YES;
}

// Called after an interstitial has been displayed on the screen.
- (void)didDisplayInterstitial:(CBLocation)location
{
	queueChartboostEvent("didDisplayInterstitial", [location cStringUsingEncoding:[NSString defaultCStringEncoding]], "", 0, -1, false);
}

@end

namespace samcodesconsent
{
	void requestStatus(const char* publisherId)
	{
		// TODO
	}
	
	void requestConsentForm(const char* privacyUrl, bool personalizedAdsOption, bool nonPersonalizedAdsOption, bool adFreeOption)
	{
		// TODO
	}
	
	bool displayConsentForm()
	{
		// TODO
	}
	
	bool function isRequestLocationInEeaOrUnknown()
	{
		// TODO
	}
	
	int getConsentStatus()
	{
		// TODO
	}
	
	void setConsentStatus(int consentStatus)
	{
		// TODO
	}
}
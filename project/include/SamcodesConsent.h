#ifndef CONSENTEXT_H
#define CONSENTEXT_H

namespace samcodesconsent
{
	void requestStatus(const char* publisherId);
	void requestConsentForm(const char* privacyUrl, bool personalizedAdsOption, bool nonPersonalizedAdsOption, bool adFreeOption);
	bool displayConsentForm();
	bool function isRequestLocationInEeaOrUnknown();
	int getConsentStatus();
	void setConsentStatus(int consentStatus);
}

#endif
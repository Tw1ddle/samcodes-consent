#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <hx/CFFIPrime.h>

#include "SamcodesConsent.h"

using namespace samcodesconsent;

#ifdef IPHONE

AutoGCRoot* consentUpdateEventHandle = 0;
AutoGCRoot* consentFormEventHandle = 0;

void samcodesconsent_set_consent_update_listener(value onEvent)
{
	if(consentUpdateEventHandle == 0) {
		consentUpdateEventHandle = new AutoGCRoot(onEvent);
	} else {
		consentUpdateEventHandle->set(onEvent);
	}
}
DEFINE_PRIME1v(samcodesconsent_set_consent_update_listener);

void samcodesconsent_set_consent_form_listener(value onEvent)
{
	if(consentFormEventHandle == 0) {
		consentFormEventHandle = new AutoGCRoot(onEvent);
	} else {
		consentFormEventHandle->set(onEvent);
	}
}
DEFINE_PRIME1v(samcodesconsent_set_consent_form_listener);

void samcodesconsent_request_status(HxString publisherId)
{
	requestStatus(publisherId);
}
DEFINE_PRIME1v(samcodesconsent_request_status);

void samcodesconsent_request_consent_form(HxString privacyPolicyUrl, bool personalizedAdsOption, bool nonPersonalizedAdsOption, bool adFreeOption)
{
	requestConsentForm(privacyPolicyUrl, personalizedAdsOption, nonPersonalizedAdsOption, adFreeOption);
}
DEFINE_PRIME4v(samcodesconsent_request_consent_form);

bool samcodesconsent_display_consent_form()
{
	displayConsentForm();
}
DEFINE_PRIME0(samcodesconsent_display_consent_form);

bool samcodesconsent_is_request_location_in_eea_or_unknown()
{
	return isRequestLocationInEeaOrUnknown();
}
DEFINE_PRIME0(samcodesconsent_is_request_location_in_eea_or_unknown);

int samcodesconsent_get_consent_status()
{
	return getConsentStatus();
}
DEFINE_PRIME0(samcodesconsent_get_consent_status);

void samcodesconsent_set_consent_status(int consent)
{
	setConsentStatus(consent);
}
DEFINE_PRIME1v(samcodesconsent_set_consent_status);

extern "C" void samcodesconsent_main()
{
}
DEFINE_ENTRY_POINT(samcodesconsent_main);

extern "C" int samcodesconsent_register_prims()
{
	return 0;
}

extern "C" void sendConsentUpdateEvent(const char* type, const char* error, int consent)
{
	if(consentUpdateEventHandle == 0)
	{
		return;
	}
	value o = alloc_empty_object();
	alloc_field(o, val_id("type"), alloc_string(type));
	alloc_field(o, val_id("error"), alloc_string(error));
	alloc_field(o, val_id("consent"), alloc_int(consent));
	val_call1(consentUpdateEventHandle->get(), o);
}

extern "C" void sendConsentFormEvent(const char* type, const char* error, int consent, bool userPrefersAdFree)
{
	if(consentFormEventHandle == 0)
	{
		return;
	}
	value o = alloc_empty_object();
	alloc_field(o, val_id("type"), alloc_string(type));
	alloc_field(o, val_id("error"), alloc_string(error));
	alloc_field(o, val_id("consent"), alloc_int(consent));
	alloc_field(o, val_id("userprefersadfree"), alloc_bool(userPrefersAdFree));
	val_call1(consentFormEventHandle->get(), o);
}

#endif
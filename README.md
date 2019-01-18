# Samcodes GDPR Consent

[![Travis Build Status](https://img.shields.io/travis/Tw1ddle/samcodes-gdpr-consent.svg?style=flat-square)](https://travis-ci.org/Tw1ddle/samcodes-gdpr-consent)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/samcodes-gdpr-consent/blob/master/LICENSE)

WORK IN PROGRESS

Unofficial Google Mobile Ads Consent SDK support for Haxe OpenFL Android and iOS targets. See the demo app [here](https://github.com/Tw1ddle/samcodes-ads-demo).

### Features

Supports:
 * Retrieving the 
 * Showing the Google Mobile Ads SDK consent form and recording the user results in Haxe.
 * Customizable listeners for handling Consent SDK events.

If there is something you would like adding please open an issue. Pull requests welcomed too!

### Install

```bash
haxelib git samcodes-gdpr-consent https://github.com/Tw1ddle/samcodes-gdpr-consent
```

### Example

See the [demo app](https://github.com/Tw1ddle/samcodes-ads-demo) for a complete example.

![Screenshot of demo app](https://github.com/Tw1ddle/samcodes-ads-demo/blob/master/screenshots/gdpr-consent-popup.png?raw=true "Demo app with GDPR consent popup")

### Usage

Usage is a multi-stage process, first is getting the user's current consent status:

```haxe
// Extend ConsentListener yourself to handle the onConsentInfoUpdated and onFailedToUpdateConsentInfo callbacks
// and make the request to determine the status of a user's consent
Consent.requestStatus(new MyConsentUpdateListener());
```

Once we have the current status, next is collecting user consent by displaying a form (if necessary):

```haxe

if(!Consent.isRequestLocationInEeaOrUnknown()) {
    return; // No need to show consent form to users outside EEA
}

// Extend ConsentFormListener yourself to handle the onConsentFormLoaded, onConsentFormOpened, onConsentFormClosed and onConsentFormError callbacks
// Show the Google-rendered consent form
var personalizedAdsOption = true;
var nonPersonalizedAdsOption = true;
var adFreeOption = false;
Consent.showConsentForm("https://www.samcodes.co.uk", new MyConsentFormListener(), personalizedAdsOption, nonPersonalizedAdsOption, adFreeOption);
```

Finally, record the consent information from the onConsentFormClosed event as appropriate for your app.

### Notes

  * Refer to the official [Google Mobile Ads Consent SDK](https://github.com/googleads/googleads-consent-sdk-android) documentation.
  * Use ```#if (android || ios)``` conditionals around your imports and calls to this library for cross platform projects - there is no stub/fallback implementation included in the haxelib.
  * If you need to rebuild the iOS or simulator ndlls, navigate to ```/project``` and run ```rebuild_ndlls.sh```.
  * Got an idea or suggestion? Open an issue on GitHub, or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).
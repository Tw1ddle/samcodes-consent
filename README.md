# Samcodes Consent

[![Travis Build Status](https://img.shields.io/travis/Tw1ddle/samcodes-consent.svg?style=flat-square)](https://travis-ci.org/Tw1ddle/samcodes-consent)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/samcodes-consent/blob/master/LICENSE)

WORK IN PROGRESS

Unofficial Google Mobile Ads Consent SDK support for Haxe OpenFL Android and iOS targets. See the demo app [here](https://github.com/Tw1ddle/samcodes-ads-demo).

### Features

Supports:
 * Retrieving GDPR/ads consent status a user has set for your app.
 * Showing the pre-made Google Mobile Ads SDK consent form.
 * Customizable listeners for handling Consent SDK events.

### Install

```bash
haxelib git samcodes-consent https://github.com/Tw1ddle/samcodes-consent
```

### Example

See the [demo app](https://github.com/Tw1ddle/samcodes-ads-demo) for an example.

![Screenshot of demo app](https://github.com/Tw1ddle/samcodes-ads-demo/blob/master/screenshots/consent-popup.png?raw=true "Demo app with GDPR consent popup")

### Usage

Getting the user's current consent status:

```haxe
// Extend ConsentListener yourself to handle the onConsentInfoUpdated and onFailedToUpdateConsentInfo callbacks
// and make the request to determine the status of a user's consent
Consent.setConsentListener(new MyConsentListener());
Consent.requestStatus("your-publisher-id-from-google-ads-dashboard");
```

Once we have the current status, if necessary we can request consent by displaying a form:

```haxe

if(!Consent.isRequestLocationInEeaOrUnknown()) {
    return; // No need to show a GDPR consent form to users outside EEA
}

// Extend ConsentFormListener yourself to handle the onConsentFormLoaded, onConsentFormOpened, onConsentFormClosed and onConsentFormError callbacks
// Request the Google-rendered consent form
// Note, you need to call Consent.showConsentForm() in the onConsentFormLoaded callback to actually show the form.
Consent.setConsentFormListener(new MyConsentFormListener());
var personalizedAdsOption = true;
var nonPersonalizedAdsOption = true;
var adFreeOption = false;
Consent.requestConsentForm("https://www.samcodes.co.uk", personalizedAdsOption, nonPersonalizedAdsOption, adFreeOption);
```

Remember to record the consent response from the onConsentFormClosed callback to savedata (or whatever is appropriate) so you don't have to show the form every time.

### Notes
 * On iOS you have to drag-drop the consent form from the PersonalizedAdConsent bundle into your Xcode project. I could not find a way to automate that - see this [thread from the OpenFL forums](https://community.openfl.org/t/how-to-include-a-bundle-file-in-the-resources-folder-when-doing-a-extension-ios/916).
 * Refer to the official [Google Mobile Ads Consent SDK](https://github.com/googleads/googleads-consent-sdk-android) documentation.
 * Use ```#if (android || ios)``` conditionals around your imports and calls to this library for cross platform projects - there is no stub/fallback implementation included in the haxelib.
 * If you need to rebuild the iOS or simulator ndlls, navigate to ```/project``` and run ```rebuild_ndlls.sh```.
 * Got an idea or suggestion? Open an issue on GitHub, or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).
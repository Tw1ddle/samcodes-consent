# Samcodes Consent

[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/samcodes-consent/blob/master/LICENSE)

Unofficial Google Mobile Ads Consent SDK bindings for Haxe OpenFL Android and iOS targets. See the demo app [here](https://github.com/Tw1ddle/samcodes-consent-demo).

*This is deprecated* - I am no longer updating it because I do not currently use ads requiring GDPR consent in my projects. Feel free to fork this and bring it up to date though!

### Features

Supports:
 * Retrieving GDPR/ads consent status a user has picked.
 * Displaying pre-made Google Mobile Ads SDK consent form.
 * Customizable listeners for handling Consent SDK events.
 * Checking if a consent request came from within the EEA.

### Install

```bash
haxelib git samcodes-consent https://github.com/Tw1ddle/samcodes-consent
```

### Example

See the [demo app](https://github.com/Tw1ddle/samcodes-consent-demo) for an example.

![Screenshot of demo app](https://github.com/Tw1ddle/samcodes-consent-demo/blob/master/screenshots/prerendered-consent-dialog.png?raw=true "Demo app with consent popup")

### Usage

Getting the user's current consent status:

```haxe
// Extend ConsentListener to handle the onConsentInfoUpdated and onFailedToUpdateConsentInfo callbacks
Consent.setConsentListener(new MyConsentListener());

// Make the request to determine the status of a user's consent
Consent.requestStatus("your-publisher-id-from-ads-dashboard");
```

When we receive the current status, we can check if the request came from within the European Economic Area:

```haxe
// Note this will only return a valid value after the onConsentInfoUpdated callback triggers
if(!Consent.isRequestLocationInEeaOrUnknown()) {
    return; // There is no need to show a consent form to users outside EEA, and the SDK might not let you anyway
}
```

Finally you can load and display the consent form:

```haxe
// Extend ConsentFormListener to handle the onConsentFormLoaded, onConsentFormOpened, onConsentFormClosed and onConsentFormError callbacks
// Note, you need to call Consent.showConsentForm() in the onConsentFormLoaded callback to actually show the form once it loads.
Consent.setConsentFormListener(new MyConsentFormListener());

// Request the Google-rendered consent form
var personalizedAdsOption = true;
var nonPersonalizedAdsOption = true;
var adFreeOption = false;
Consent.requestConsentForm("https://www.samcodes.co.uk", personalizedAdsOption, nonPersonalizedAdsOption, adFreeOption);
```

Finally record the consent response from the onConsentFormClosed callback to game saved data (or whatever is appropriate) so you don't have to show the form every time.

### Notes
 * At time of writing, callbacks on Android run on the wrong thread due to an [issue in lime](https://github.com/openfl/lime/issues/983).
 * At time of writing, the Consent SDK form shows lots of partner privacy policies that [may be irrelevant](https://github.com/googleads/googleads-consent-sdk-android/issues/81) to your app.
 * On iOS you have to drag-drop the consent form from the PersonalizedAdConsent bundle into your Xcode project. See this thread in the [OpenFL forums](https://community.openfl.org/t/how-to-include-a-bundle-file-in-the-resources-folder-when-doing-a-extension-ios/916).
 * Refer to the official Google Mobile Ads Consent SDK documentation for [Android](https://github.com/googleads/googleads-consent-sdk-android) and [iOS](https://developers.google.com/admob/ios/quick-start).
 * Use ```#if (android || ios)``` conditionals around your imports and calls to this library for cross platform projects - there is no stub/fallback implementation included in the haxelib.
 * If you need to rebuild the iOS or simulator ndlls, navigate to ```/project``` and run ```rebuild_ndlls.sh```.
 * Got an idea or suggestion? Open an issue on GitHub, or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).
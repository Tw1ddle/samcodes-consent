package com.samcodes.consent;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import com.google.ads.consent.ConsentForm;
import com.google.ads.consent.ConsentFormListener;
import com.google.ads.consent.ConsentInfoUpdateListener;
import com.google.ads.consent.ConsentInformation;
import com.google.ads.consent.ConsentStatus;

import java.net.MalformedURLException;
import java.net.URL;

public class ConsentExtension extends Extension
{
	private static String TAG = "ConsentExtension";
	
	public static ConsentForm consentForm = null;
	
	public static HaxeObject consentUpdateCallback = null;
	public static void setConsentUpdateListener(HaxeObject haxeCallback) {
		Log.i(TAG, "Setting Haxe GDPR consent update listener delegate object");
		consentUpdateCallback = haxeCallback;
	}
	
	public static int whatThreadIdIsThis() {
		return Long.valueOf(Thread.currentThread().getId()).intValue();
	}
	
	public static HaxeObject consentFormCallback = null;
	public static void setConsentFormListener(HaxeObject haxeCallback) {
		Log.i(TAG, "Setting Haxe GDPR consent form delegate object");
		consentFormCallback = haxeCallback;
	}
	
	public static void requestStatus(String publisherId) {
		ConsentInformation consentInformation = ConsentInformation.getInstance(Extension.mainActivity);
		String[] publisherIds = { publisherId };
		consentInformation.requestConsentInfoUpdate(publisherIds, new ConsentInfoUpdateListener() {
			public void callHaxe(final String name, final Object[] args) {
				if(consentUpdateCallback != null) {
					callbackHandler.post(new Runnable() {
						public void run() {
							Log.d(TAG, "Calling " + name + " from java");
							consentUpdateCallback.call(name, args);
						}
					});
				} else {
					Log.w(TAG, "GDPR consent status listener object is null, ignored a GDPR consent callback");
				}
			}
			
			@Override
			public void onConsentInfoUpdated(ConsentStatus consentStatus) {
				callHaxe("onConsentInfoUpdated", new Object[] {consentStatus}); // User's consent status successfully updated.
			}
			
			@Override
			public void onFailedToUpdateConsentInfo(String errorDescription) {
				callHaxe("onFailedToUpdateConsentInfo", new Object[] {errorDescription}); // User's consent status failed to update.
			}
		});
	}
	
	public static void requestConsentForm(String privacyUrl, boolean personalizedAdsOption, boolean nonPersonalizedAdsOption, boolean adFreeOption) {
		URL privacyUrlObj = null;
		
		try {
			privacyUrlObj = new URL(privacyUrl);
		} catch(MalformedURLException e) {
			Log.e(TAG, "Malformed URL exception, passed a bad privacy URL, will fail to display consent form");
			return;
		}
		
		ConsentForm.Builder builder = new ConsentForm.Builder(Extension.mainActivity, privacyUrlObj).withListener(new ConsentFormListener() {
			public void callHaxe(final String name, final Object[] args) {
				if(consentFormCallback != null) {
					callbackHandler.post(new Runnable() {
						public void run() {
							Log.d(TAG, "Calling " + name + " from java");
							consentFormCallback.call(name, args);
						}
					});
				} else {
					Log.w(TAG, "GDPR consent form listener object is null, ignored a GDPR consent callback");
				}
			}
			
			@Override
			public void onConsentFormLoaded() {
				callHaxe("onConsentFormLoaded", new Object[]{}); // Consent form loaded successfully.
				
				// At this point it is safe to show the form (i.e. call showConsentForm from Haxe)...
			}
			
			@Override
			public void onConsentFormOpened() {
				callHaxe("onConsentFormOpened", new Object[]{}); // Consent form was displayed.
			}
			
			@Override
			public void onConsentFormClosed(ConsentStatus consentStatus, Boolean userPrefersAdFree) {
				// Consent form was closed.
				int consent = consentToInt(consentStatus);
				
				boolean prefersAdFree = Boolean.TRUE.equals(userPrefersAdFree);
				
				callHaxe("onConsentFormClosed", new Object[] { consent, userPrefersAdFree });
				
				setConsentStatus(consentToInt(consentStatus));
			}
			
			@Override
			public void onConsentFormError(String errorDescription) {
				callHaxe("onConsentFormError", new Object[] {errorDescription}); // Consent form error. NOTE this triggers if the user isn't in the EEA.
			}
		});
		
		if(personalizedAdsOption) {
			builder.withPersonalizedAdsOption();
		}
		if(nonPersonalizedAdsOption) {
			builder.withNonPersonalizedAdsOption();
		}
		if(adFreeOption) {
			builder.withAdFreeOption();
		}
		
		try {
			consentForm = builder.build();
			if(consentForm != null) {
				consentForm.load();
			} else {
				Log.e(TAG, "Failed to build the consent form");
			}
		} catch(Exception e) {
			Log.e(TAG, "Something went wrong when building or loading the consent form");
		}
	}
	
	public static boolean displayConsentForm() {
		if(consentForm == null) {
			Log.e(TAG, "Failed to display consent form. You must call requestConsentForm and wait to see if it loads first");
			return false;
		}
		
		try {
			consentForm.show();
		} catch(Exception e) {
			Log.e(TAG, "Something went wrong when trying to show the consent form");
			return false;
		}
		return true;
	}
	
	// NOTE you should only call this after successfully updating the user status
	// There's no point calling this until after requestStatus succeeds on first launch
	public static boolean isRequestLocationInEeaOrUnknown() {
		return ConsentInformation.getInstance(Extension.mainActivity).isRequestLocationInEeaOrUnknown();
	}
	
	public static int getConsentStatus() {
		ConsentStatus c = ConsentInformation.getInstance(Extension.mainActivity).getConsentStatus();
		return consentToInt(c);
	}
	
	public static void setConsentStatus(int consent) {
		Log.i(TAG, "Setting consent status");
		ConsentInformation.getInstance(Extension.mainActivity).setConsentStatus(intToConsent(consent));
	}
	
	// These values correspond to an enum abstract in Haxe
	private static int consentToInt(ConsentStatus consentStatus) {
		int consent = -1;
		if(consentStatus == ConsentStatus.UNKNOWN) {
			consent = -1;
		} else if(consentStatus == ConsentStatus.NON_PERSONALIZED) {
			consent = 0;
		} else if(consentStatus == ConsentStatus.PERSONALIZED) {
			consent = 1;
		}
		return consent;
	}
	private static ConsentStatus intToConsent(int consent) {
		if(consent == -1) {
			return ConsentStatus.UNKNOWN;
		} else if(consent == 0) {
			return ConsentStatus.NON_PERSONALIZED;
		} else if(consent == 1) {
			return ConsentStatus.PERSONALIZED;
		}
		return ConsentStatus.UNKNOWN;
	}
	
	@Override
	public void onCreate (Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	@Override
	public void onStart() {
		super.onStart();
	}
	
	@Override
	public void onResume() {
		super.onResume();
	}
	
	@Override
	public void onPause() {
		super.onPause();
	}
	
	@Override
	public void onStop() {
		super.onStop();
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
	}
}
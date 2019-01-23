package extension.consent;

#if (android || ios)

#if android
import lime.system.JNI;
#end

/**
   The Consent class provides bindings to functions of the Google Mobile Ads Consent SDK on iOS and Android
   See: https://github.com/Tw1ddle/samcodes-consent
**/
class Consent {
	public static function setConsentUpdateListener(listener:ConsentUpdateListener):Void {
		#if android
		set_consent_update_listener(listener);
		#end
		#if ios
		set_consent_update_listener(listener.notify);
		#end
	}
	
	public static function setConsentFormListener(listener:ConsentFormListener):Void {
		#if android
		set_consent_form_listener(listener);
		#end
		#if ios
		set_consent_form_listener(listener.notify);
		#end
	}
	
	public static function requestStatus(publisherId:String):Void {
		request_status(publisherId);
	}
	
	public static function requestConsentForm(privacyUrl:String, personalizedAdsOption:Bool, nonPersonalizedAdsOption:Bool, adFreeOption:Bool):Void {
		request_consent_form(privacyUrl, personalizedAdsOption, nonPersonalizedAdsOption, adFreeOption);
	}
	
	public static function displayConsentForm():Bool {
		return display_consent_form();
	}
	
	public static function isRequestLocationInEeaOrUnknown():Bool {
		return is_request_location_in_eea_or_unknown();
	}
	
	public static function getConsentStatus():ConsentStatus {
		return get_consent_status();
	}
	
	public static function setConsentStatus(consent:ConsentStatus):Void {
		set_consent_status(consent);
	}
	
	public static function whatThreadIdIsThis():Int {
		return what_thread_id_is_this();
	}
	
	#if android
	private static inline var packageName:String = "com/samcodes/consent/ConsentExtension";
	private static inline function bindJNI(jniMethod:String, jniSignature:String) {
		return JNI.createStaticMethod(packageName, jniMethod, jniSignature);
	}
	
	private static var what_thread_id_is_this = bindJNI("whatThreadIdIsThis", "()I");
	private static var set_consent_update_listener = bindJNI("setConsentUpdateListener", "(Lorg/haxe/lime/HaxeObject;)V");
	private static var set_consent_form_listener = bindJNI("setConsentFormListener", "(Lorg/haxe/lime/HaxeObject;)V");
	private static var request_status = bindJNI("requestStatus", "(Ljava/lang/String;)V");
	private static var request_consent_form = bindJNI("requestConsentForm", "(Ljava/lang/String;ZZZ)V");
	private static var display_consent_form = bindJNI("displayConsentForm", "()Z");
	private static var is_request_location_in_eea_or_unknown = bindJNI("isRequestLocationInEeaOrUnknown", "()Z");
	private static var get_consent_status = bindJNI("getConsentStatus", "()I");
	private static var set_consent_status = bindJNI("setConsentStatus", "(I)V");
	#end
	
	#if ios
	private static var set_consent_update_listener = PrimeLoader.load("samcodesconsent_set_consent_update_listener", "ov");
	private static var set_consent_form_listener = PrimeLoader.load("samcodesconsent_set_consent_form_listener", "ov");
	private static var request_status = PrimeLoader.load("samcodesconsent_request_status", "sv");
	private static var request_consent_form = PrimeLoader.load("samcodesconsent_request_consent_form", "sbbbv");
	private static var display_consent_form = PrimeLoader.load("samcodesconsent_display_consent_form", "b");
	private static var is_request_location_in_eea_or_unknown = PrimeLoader.load("samcodesconsent_is_request_location_in_eea_or_unknown", "b");
	private static var get_consent_status = PrimeLoader.load("samcodesconsent_get_consent_status", "i");
	private static var set_consent_status = PrimeLoader.load("samcodesconsent_set_consent_status", "iv");
	#end
}

#end
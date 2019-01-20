package extension.consent;

/**
   Customizable listener for responding to GDPR consent form events.
**/
class ConsentFormListener {
	public function new() {
	}
	
	public function onConsentFormLoaded():Void {
	}
	
	public function onConsentFormOpened():Void {
	}
	
	public function onConsentFormClosed(consentStatus:ConsentStatus, userPrefersAdFree:Bool):Void {
	}
	
	public function onConsentFormError(errorDescription:String):Void {
	}
	
	// NOTE there are far better ways of doing this
	#if ios
	private static inline var ON_CONSENT_FORM_LOADED:String = "onConsentFormLoaded";
	private static inline var ON_CONSENT_FORM_OPENED:String = "onConsentFormOpened";
	private static inline var ON_CONSENT_FORM_CLOSED:String = "onConsentFormClosed";
	private static inline var ON_CONSENT_FORM_ERROR:String = "onConsentFormError";
	
	public function notify(inEvent:Dynamic):Void {
		var type:String = "";
		var error:String = "";
		var consent:ConsentStatus = 0;
		var userPrefersAdFree:Bool = false;

		if (Reflect.hasField(inEvent, "type")) {
			type = Std.string (Reflect.field (inEvent, "type"));
		}
		
		if (Reflect.hasField(inEvent, "consent")) {
			consent = cast (Reflect.field(inEvent, "consent"));
		}
		
		if (Reflect.hasField(inEvent, "error")) {
			error = Std.string (Reflect.field (inEvent, "error"));
		}
		
		if(Reflect.hasField(inEvent, "userprefersadfree")) {
			userPrefersAdFree = cast (Reflect.field(inEvent, "userprefersadfree"));
		}
		
		switch(type) {
			case ON_CONSENT_FORM_LOADED:
				onConsentFormLoaded();
			case ON_CONSENT_FORM_OPENED:
				onConsentFormOpened();
			case ON_CONSENT_FORM_CLOSED:
				onConsentFormClosed(consent, userPrefersAdFree);
			case ON_CONSENT_FORM_ERROR:
				onConsentFormError(error);
			default:
			{
				trace("Unhandled GDPR consent update listener event. There shouldn't be any of these. Event type was [" + type + "]");
			}
		}
	}
	#end
}
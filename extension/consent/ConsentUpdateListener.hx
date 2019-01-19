package extension.consent;

/**
   Customizable listener for responding to GDPR consent update request events.
**/
class ConsentUpdateListener {
	public function new() {
	}
	
	public function onConsentInfoUpdated(consentStatus:ConsentStatus):Void {
	}
	
	public function onFailedToUpdateConsentInfo(errorDescription:String):Void {
	}
	
	// NOTE there are far better ways of doing this
	#if ios
	// Interstitial events
	private static inline var ON_CONSENT_INFO_UPDATED:String = "onConsentInfoUpdated";
	private static inline var ON_FAILED_TO_UPDATE_CONSENT_INFO:String = "onFailedToUpdateConsentInfo";
	
	public function notify(inEvent:Dynamic):Void {
		var type:String = "";
		var error:String = "";
		var consent:ConsentStatus = 0;

		if (Reflect.hasField(inEvent, "type")) {
			type = Std.string (Reflect.field (inEvent, "type"));
		}
		
		if (Reflect.hasField(inEvent, "consent")) {
			consent = cast (Reflect.field(inEvent, "consent"));
		}
		
		if (Reflect.hasField(inEvent, "error")) {
			error = Std.string (Reflect.field (inEvent, "error"));
		}
		
		switch(type) {
			case ON_CONSENT_INFO_UPDATED:
				onConsentInfoUpdated(consent);
			case ON_FAILED_TO_UPDATE_CONSENT_INFO:
				onFailedToUpdateConsentInfo(error);
			default:
			{
				trace("Unhandled GDPR consent form listener event. There shouldn't be any of these. Event type was [" + type + "]");
			}
		}
	}
	#end
}
package extension.consent;

/**
   Enumeration of consent for data use for personalized ads
**/
@:enum abstract ConsentStatus(Int) from Int to Int
{
	var UNKNOWN = -1;
	var NON_PERSONALIZED = 0;
	var PERSONALIZED = 1;
	
	@:to public static function toString(pref:Int):String {
		return switch(pref) {
			case UNKNOWN: "unknown";
			case NON_PERSONALIZED: "non_personalized";
			case PERSONALIZED: "personalized";
		case _: {
			trace ("Tried to stringify invalid consent status, will return 'unknown' instead");
			"unknown";
		}
		};
	}
}
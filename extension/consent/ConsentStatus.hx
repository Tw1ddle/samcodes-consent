package extension.consent;

/**
   Enumeration of consent for data use for personalized ads
**/
@:enum abstract ConsentStatus(Int) from Int to Int
{
	var UNKNOWN = 0;
	var NON_PERSONALIZED = 1;
	var PERSONALIZED = 2;
	
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
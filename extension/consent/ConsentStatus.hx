package extension.consent;

/**
   Enumeration of consent for data use for personalized ads
**/
@:enum abstract ConsentStatus(Int) from Int to Int
{
	var UNKNOWN = -1;
	var NON_PERSONALIZED = 0;
	var PERSONALIZED = 1;
}
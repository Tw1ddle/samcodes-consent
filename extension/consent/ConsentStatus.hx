package extension.consent;

@:enum abstract ConsentStatus(Int) from Int to Int
{
	var UNKNOWN = -1;
	var NON_PERSONALIZED = 0;
	var PERSONALIZED = 1;
}
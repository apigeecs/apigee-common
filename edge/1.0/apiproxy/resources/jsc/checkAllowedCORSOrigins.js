var requestVerb = context.getVariable("requestVerb");
var requestedOrigin = context.getVariable("origin");
var requestedMethod = context.getVariable("corsRequestedMethod");
var allowedOriginsList = context.getVariable("corsAllowedOrigins");

var corsResult = "originNotAllowed";

// if origin or method were not supplied, preflight will return 404
if (requestVerb === "OPTIONS" && (requestedOrigin === "NA" || requestedMethod === "NA"))
{
	corsResult = "invalidInput";
}
else // this check valid for both preflight and regular request
{
	var uri = new URI(requestedOrigin);

	// normalize removes ports when they are default (80/443 for http/https)
	//  and fixes case issues
	var normalized = uri.normalize().toString();

	// trailing slashes are not in the allowedOriginsList string
	if (normalized.substr(-1) === '/')
		normalized = normalized.substr(0, normalized.length - 1);

	// surrounding vertical pipes force a string match in our origins list
	//   to be an exact match for an origin that was supplied in the whitelist
	var searchOrigin = "|" + normalized + "|";

	if (allowedOriginsList.indexOf(searchOrigin) >= 0)
	{
		corsResult = "originAllowed";
	}
}

context.setVariable("corsResult", corsResult);

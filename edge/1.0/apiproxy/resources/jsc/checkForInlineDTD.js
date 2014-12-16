// Checks for inline DTDs.
// Variable inlineDTDFound indicates whether inline DTD was found.
//
// Regular expression explanation:
// <!DOCTYPE     -- matches the string <!DOCTYPE
// \s            -- followed by a whitespace character

var inputContent = context.getVariable("message.content");

var inlineDTDFound = false;

// find DOCTYPE
if (inputContent.search(/<!DOCTYPE\s/im) >= 0)
{
	inlineDTDFound = true;
}

context.setVariable("inlineDTDFound", inlineDTDFound);

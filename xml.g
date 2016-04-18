grammar xml;

@lexer::header {
	
}

@lexer::members {
	enum Modes { OUTSIDE, INSIDE };
	
	Stack<Modes> mode = new Stack();
	{
		mode.push(Modes.OUTSIDE);
		System.out.println("mode size: " + mode.size());
	}
}


document	: element;

element		: empty_elem_tag | stag content etag;
stag		: Open name Close;
etag		: OpenSlash name Close;
content		: char_data? (element char_data?)*;
empty_elem_tag	: Open name SlashClose;

Open		: '<' { mode.push(Modes.INSIDE); };
OpenSlash	: '</' { mode.push(Modes.INSIDE); };
	
char_data	: CharData;
CharData	: {mode.peek() == Modes.OUTSIDE}?=> ~('<' | '&')+;

Close		: {mode.peek() == Modes.INSIDE}?=> '>' { mode.pop(); };
Slash		: {mode.peek() == Modes.INSIDE}?=> '/';
SlashClose	: {mode.peek() == Modes.INSIDE}?=> '/>' { mode.pop(); };

name		: Name;
Name		: {mode.peek() == Modes.OUTSIDE}?=> (Letter | '_' | ':') (Letter | Digit | '.' | '_' | ':')+;

fragment Letter	: ('A'..'Z') | ('a'..'z');
fragment Digit	: ('0'..'9');

/*
test	:	(name | text | t)* EOF;
name	:	Name;
text	:	Text;	
t	:	Open | Close | SlashClose | Slash;
*/
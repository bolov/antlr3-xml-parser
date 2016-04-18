grammar xml;


@lexer::members {
	boolean inside = false;
}


document	: element;

element		: empty_elem_tag | stag content etag;
stag		: Open name Close;
etag		: OpenSlash name Close;
content		: char_data? (element char_data?)*;
empty_elem_tag	: Open name SlashClose;

Open		: '<' { inside = true; };
OpenSlash	: '</' { inside = true; };
	
char_data	: CharData;
CharData	: {!inside}?=> ~('<' | '&')+;

Close		: {inside}?=> '>' { inside = false; };
Slash		: {inside}?=> '/';
SlashClose	: {inside}?=> '/>' { inside = false; };

name		: Name;
Name		: {inside}?=> (Letter | '_' | ':') (Letter | Digit | '.' | '_' | ':')*;

fragment Letter	: ('A'..'Z') | ('a'..'z');
fragment Digit	: ('0'..'9');


test	:	(name | char_data | t)* EOF;
//name	:	Name;
//char_data	:	CharData;
t	:	Open | Close | SlashClose | Slash | OpenSlash;

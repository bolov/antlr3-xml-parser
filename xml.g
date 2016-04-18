grammar xml;

options{
output=AST;
}

tokens {
StartTag;
EndTag;
EmptyTag;
Content;
Element;
}


@lexer::members {
	boolean inside = false;
}


document	: element;

element		: empty_elem_tag -> ^(Element empty_elem_tag) | stag content etag -> ^(Element stag content etag);
stag		: Open name Close -> ^(StartTag name);
etag		: OpenSlash name Close -> ^(EndTag name);
content		: char_data? (element char_data?)* -> ^(Content char_data? (element char_data?)*);
empty_elem_tag	: Open name SlashClose -> ^(EmptyTag name);

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

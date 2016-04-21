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
	boolean inside_tag = false;
}


document	: element;

element		: empty_elem_tag -> ^(Element empty_elem_tag) |
		  stag content etag -> ^(Element stag content etag);
stag		: Open name Close -> ^(StartTag name);
etag		: OpenSlash name Close -> ^(EndTag name);
content		: char_data? (element char_data?)* -> ^(Content char_data? (element char_data?)*);
empty_elem_tag	: Open name SlashClose -> ^(EmptyTag name);

Open		: '<' { inside_tag = true; };
OpenSlash	: '</' { inside_tag = true; };
	
char_data	: CharData;
CharData	: {!inside_tag}?=> ~('<' | '&')+;

Close		: {inside_tag}?=> '>' { inside_tag = false; };
Slash		: {inside_tag}?=> '/';
SlashClose	: {inside_tag}?=> '/>' { inside_tag = false; };

name		: Name;
Name		: {inside_tag}?=> (Letter | '_' | ':') (Letter | Digit | '.' | '-' | '_' | ':')*;

fragment Letter	: ('A'..'Z') | ('a'..'z');
fragment Digit	: ('0'..'9');


test	:	(name | char_data | t)* EOF;
//name	:	Name;
//char_data	:	CharData;
t	:	Open | Close | SlashClose | Slash | OpenSlash;

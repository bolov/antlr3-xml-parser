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
Reference;
}

@lexer::members {
	boolean inside_tag = false;
}

document	: element EOF;

element		: empty_elem_tag -> ^(Element empty_elem_tag) |
		  stag content etag -> ^(Element stag content etag);
stag		: Open name Close -> ^(StartTag name);
etag		: OpenSlash name Close -> ^(EndTag name);
content		: content_impl -> ^(Content content_impl);
content_impl	: char_data? ((element | reference) char_data?)*;

empty_elem_tag	: Open name SlashClose -> ^(EmptyTag name);

Open		: '<' { inside_tag = true; };
OpenSlash	: '</' { inside_tag = true; };

char_data	: CharData;
CharData	: {!inside_tag}?=> ~('<' | '&')+;

Close		: {inside_tag}?=> '>' { inside_tag = false; };
Slash		: {inside_tag}?=> '/';
SlashClose	: {inside_tag}?=> '/>' { inside_tag = false; };

name		: Name;
Name		: {inside_tag}?=> NameHead NameTail;

CharRefDec	: '&#' Digit+ ';';
CharRefHex	: '&#x' HexDigit+ ';';
EntityRef	: '&' NameHead NameTail ';';
reference	: (CharRefDec | CharRefHex  | EntityRef) -> ^(Reference CharRefDec? CharRefHex? EntityRef?);

InvalidRef	: '&#' Digit+ | '&#x' HexDigit+ | '&' NameHead NameTail;


fragment Letter	: ('A'..'Z') | ('a'..'z');
fragment Digit	: ('0'..'9');
fragment
HexDigit	: Digit | ('a'..'f') | ('A'..'F');
fragment
NameHead	: (Letter | '_' | ':');
fragment
NameTail	: (Letter | Digit | '.' | '-' | '_' | ':')*;


test	:	(name | char_data | reference | invalid_ref | t )* EOF;
//name	:	Name;
//char_data	:	CharData;
invalid_ref	: InvalidRef;
t	:	Open | Close | SlashClose | Slash | OpenSlash;

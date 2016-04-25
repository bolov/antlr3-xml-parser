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
CommentNode;
}

@lexer::members {
	boolean inside_tag = false;
	int depth = 0;
	boolean squoted = false;
	boolean dquoted = false;
}

document	: element misc* EOF;

element		: empty_elem_tag -> ^(Element empty_elem_tag) |
		  stag content etag -> ^(Element stag content etag);
stag		: Open name (WS attribute)* WS? Close -> ^(StartTag name attribute*);
attribute	: Name Eq att_value -> ^(Name att_value);
etag		: OpenSlash name WS? Close -> ^(EndTag name);
content		: content_impl -> ^(Content content_impl?);
content_impl	: char_data? ((element | reference | comment) char_data?)*;

empty_elem_tag	: Open name WS? SlashClose -> ^(EmptyTag name);

Open		: '<' { inside_tag = true; depth++; };
OpenSlash	: '</' { inside_tag = true; depth--; };

char_data	: CharData;
CharData	: {!inside_tag && depth > 0}?=> ~('<' | '&')+;

Close		: {inside_tag && !squoted && !dquoted}?=> '>' { inside_tag = false; };
Slash		: {inside_tag && !squoted && !dquoted}?=> '/';
SlashClose	: {inside_tag && !squoted && !dquoted}?=> '/>' { inside_tag = false; depth--; };

name		: Name;
Name		: {inside_tag && !squoted && !dquoted}?=> NameHead NameTail;

Eq		: {inside_tag && !squoted && !dquoted}?=> '=';

SQuotedPart	: {squoted}?=> ~('<' | '&' | '\'')+;
DQuotedPart	: {dquoted}?=> ~('<' | '&' | '\"')+;


att_value	: DQuoteOpen! (DQuotedPart | reference)* DQuoteClose! |
		  SQuoteOpen! (SQuotedPart | reference)* SQuoteClose!;

DQuoteOpen	: {inside_tag && !squoted && !dquoted}?=> '"' {dquoted = true;};
DQuoteClose	: {dquoted}?=> '"' {dquoted = false;};
SQuoteOpen	: {inside_tag && !squoted && !dquoted}?=> '\'' {squoted = true;};
SQuoteClose	: {squoted}?=> '\'' {squoted = false;};

comment		: Comment -> ^(CommentNode Comment);
Comment		: '<!--' (CharNotDash | ('-' CharNotDash))* '-->';

misc		: comment | WS!;

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

fragment
CharNotDash	: '\t' | '\n' | '\r' | ' ' .. '\u002c' | '\u002e'..'\u007f'; // dash `-` is 2d

WS		: (' ' | '\t' | '\r' | '\n')+;
ws		: WS;


test	:	(name | char_data | reference | invalid_ref | t | quote | dquoted_part | squoted_part | Eq | ws )* EOF;
//name	:	Name;
//char_data	:	CharData;
invalid_ref	: InvalidRef;
quote		: DQuoteClose | DQuoteOpen | SQuoteClose | SQuoteOpen;
squoted_part	: SQuotedPart;
dquoted_part	: DQuotedPart;
t	:	Open | Close | SlashClose | Slash | OpenSlash;

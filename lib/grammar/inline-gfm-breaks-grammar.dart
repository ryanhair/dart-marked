part of marked;

class InlineGfmBreaksGrammar extends InlineGfmGrammar {
    RegExp get br => new RegExp(r'^ *\n(?!\s*$)');
    RegExp get text => new RegExp(r'^[\s\S]+?(?=[\\<!\[_*`~]|https?://| *\n|$)');
}

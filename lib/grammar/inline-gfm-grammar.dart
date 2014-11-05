part of marked;

class InlineGfmGrammar extends InlineGrammar {
    RegExp get escape => new RegExp(r'^\\([\\`*{}\[\]()#+\-.!_>~|])');
    RegExp get url => new RegExp(r'^(https?:\/\/[^\s<]+[^<.,:;"' + r"'" + r')\]\s])');
    RegExp get del => new RegExp(r'^~~(?=\S)([\s\S]*?\S)~~');
    RegExp get text => new RegExp(r'^[\s\S]+?(?=[\\<!\[_*`~]|https?://| {2,}\n|$)');
}

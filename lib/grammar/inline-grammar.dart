part of marked;

class InlineGrammar {
    RegExp get escape => new RegExp(r'^\\([\\`*{}\[\]()#+\-.!_>])');
    RegExp get autolink => new RegExp(r'^<([^ >]+(@|:\/)[^ >]+)>');
    RegExp get url => null;
    RegExp get tag => new RegExp(r'^<!--[\s\S]*?-->|^<\/?\w+(?:"[^"]*"|' + r"'[^']*'|[^'" + r'">])*?>');
    RegExp get link => new RegExp(r'^!?\[((?:\[[^\]]*\]|[^\[\]]|\](?=[^\[]*\]))*)\]\(\s*<?([\s\S]*?)>?(?:\s+[' + r"'" + r'"]([\s\S]*?)[' + r"'" + r'"])?\s*\)');
    RegExp get reflink => new RegExp(r'^!?\[((?:\[[^\]]*\]|[^\[\]]|\](?=[^\[]*\]))*)\]\s*\[([^\]]*)\]');
    RegExp get nolink => new RegExp(r'^!?\[((?:\[[^\]]*\]|[^\[\]])*)\]');
    RegExp get strong => new RegExp(r'^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)');
    RegExp get em => new RegExp(r'^\b_((?:__|[\s\S])+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)');
    RegExp get code => new RegExp(r'^(`+)\s*([\s\S]*?[^`])\s*\1(?!`)');
    RegExp get br => new RegExp(r'^ {2,}\n(?!\s*$)');
    RegExp get del => null;
    RegExp get text => new RegExp(r'^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)');
}

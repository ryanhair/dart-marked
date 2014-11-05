part of marked;

class NormalGrammar {
    RegExp get newline => new RegExp(r'^\n+');
    RegExp get code => new RegExp(r'^( {4}[^\n]+\n*)+');
    RegExp get fences => null;
    RegExp get hr => new RegExp(r'^( *[-*_]){3,} *(?:\n+|$)');
    RegExp get heading => new RegExp(r'^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)');
    RegExp get nptable => null;
    RegExp get lheading => new RegExp(r'^([^\n]+)\n *(=|-){2,} *(?:\n+|$)');
    RegExp get blockquote => new RegExp(r'^( *>[^\n]+(\n(?! *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$))[^\n]+)*\n*)+');
    RegExp get html => new RegExp(r'^ *(?:<!--[\s\S]*?--> *(?:\n|\s*$)|<((?!(?:a|em|strong|small|s|cite|q|dfn|abbr|data|time|code|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo|span|br|wbr|ins|del|img)\b)\w+(?!:/|[^\w\s@]*@)\b)[\s\S]+?<\/\1> *(?:\n{2,}|\s*$)|<(?!(?:a|em|strong|small|s|cite|q|dfn|abbr|data|time|code|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo|span|br|wbr|ins|del|img)\b)\w+(?!:/|[^\w\s@]*@)\b(?:"[^"]*"|' + r"'[^']*'|[^'" + r'">])*?> *(?:\n{2,}|\s*$))');
    RegExp get def => new RegExp(r'^ *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)');
    RegExp get table => null;
    RegExp get paragraph => new RegExp(r'^((?:[^\n]+\n?(?!( *[-*_]){3,} *(?:\n+|$)| *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)|([^\n]+)\n *(=|-){2,} *(?:\n+|$)|( *>[^\n]+(\n(?! *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$))[^\n]+)*\n*)+|<(?!(?:a|em|strong|small|s|cite|q|dfn|abbr|data|time|code|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo|span|br|wbr|ins|del|img)\b)\w+(?!:/|[^\w\s@]*@)\b| *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)))+)\n*');
    RegExp get text => new RegExp(r'^[^\n]+');
    RegExp get bullet => new RegExp(r'(?:[*+-]|\d+\.)');
    RegExp get item => new RegExp(r'^( *)((?:[*+-]|\d+\.)) [^\n]*(?:\n(?!\1(?:[*+-]|\d+\.) )[^\n]*)*', multiLine: true); // TODO: Check to make sure: Should only be used as global multiline
    RegExp get list => new RegExp(r'^( *)((?:[*+-]|\d+\.)) [\s\S]+?(?:\n+(?=\1?(?:[-*_] *){3,}(?:\n+|$))|\n+(?= *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$))|\n{2,}(?! )(?!\1(?:[*+-]|\d+\.) )\n*|\s*$)');
}

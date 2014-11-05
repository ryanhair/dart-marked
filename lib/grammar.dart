import 'dart:collection';
import 'dart:convert' show HtmlEscape;
import 'dart:math';
import 'dart:async';

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

class GfmGrammar extends NormalGrammar {
    RegExp get fences => new RegExp(r'^ *(`{3,}|~{3,}) *(\S+)? *\n([\s\S]+?)\s*\1 *(?:\n+|$)');
    RegExp get paragraph => new RegExp(r'^((?:[^\n]+\n?(?! *(`{3,}|~{3,}) *(\S+)? *\n([\s\S]+?)\s*\2 *(?:\n+|$)|( *)((?:[*+-]|\d+\.)) [\s\S]+?(?:\n+(?=\3?(?:[-*_] *){3,}(?:\n+|$))|\n+(?= *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$))|\n{2,}(?! )(?!\1(?:[*+-]|\d+\.) )\n*|\s*$)|( *[-*_]){3,} *(?:\n+|$)| *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)|([^\n]+)\n *(=|-){2,} *(?:\n+|$)|( *>[^\n]+(\n(?! *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$))[^\n]+)*\n*)+|<(?!(?:a|em|strong|small|s|cite|q|dfn|abbr|data|time|code|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo|span|br|wbr|ins|del|img)\b)\w+(?!:/|[^\w\s@]*@)\b| *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)))+)\n*');
}

class GfmTablesGrammar extends GfmGrammar {
    RegExp get nptable => new RegExp(r'^ *(\S.*\|.*)\n *([-:]+ *\|[-| :]*)\n((?:.*\|.*(?:\n|$))*)\n*');
    RegExp get table => new RegExp(r'^ *\|(.+)\n *\|( *[-:]+[-| :]*)\n((?: *\|.*(?:\n|$))*)\n*');
}

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

class InlinePedanticGrammar extends InlineGrammar {
    RegExp get strong => new RegExp(r'^__(?=\S)([\s\S]*?\S)__(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)');
    RegExp get em => new RegExp(r'^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)');
}

class InlineGfmGrammar extends InlineGrammar {
    RegExp get escape => new RegExp(r'^\\([\\`*{}\[\]()#+\-.!_>~|])');
    RegExp get url => new RegExp(r'^(https?:\/\/[^\s<]+[^<.,:;"' + r"'" + r')\]\s])');
    RegExp get del => new RegExp(r'^~~(?=\S)([\s\S]*?\S)~~');
    RegExp get text => new RegExp(r'^[\s\S]+?(?=[\\<!\[_*`~]|https?://| {2,}\n|$)');
}

class InlineGfmBreaksGrammar extends InlineGfmGrammar {
    RegExp get br => new RegExp(r'^ *\n(?!\s*$)');
    RegExp get text => new RegExp(r'^[\s\S]+?(?=[\\<!\[_*`~]|https?://| *\n|$)');
}

class Token {
    String type;
    String text;
    String lang;
    List<String> header;
    List<String> align;
    List<List<String>> cells;
    int depth;
    bool ordered;
    bool pre;
    bool escaped;
    Token(this.type, {this.text: '', this.lang: '', this.depth: 0, this.header: null, this.align: null, this.cells: null, this.ordered: false, this.pre: false});
}

class Link {
    String href;
    String title;

    Link({this.href, this.title});
}

class TokenList extends ListBase<Token> {
    Map<String, Link> links = new Map<String, Link>();
    List innerList;

    int get length => innerList.length;

    void set length(int length) {
        innerList.length = length;
    }

    void operator[]=(int index, Token value) {
        innerList[index] = value;
    }

    Token operator [](int index) => innerList[index];

    void add(Token value) => innerList.add(value);

    void addAll(Iterable<Token> all) => innerList.addAll(all);

    TokenList() {
        innerList = new List();
    }

    TokenList.from(Iterable<Token> other) {
        innerList = new List.from(other);
    }
}

//TODO: defaults (options) need to be passed in, not going to assume using them
class Lexer {
    TokenList tokens;
    MarkedOptions options;
    Lexer(this.options) {
        tokens = new TokenList();
    }

    List<Token> lex(String src) {
        src.replaceAll('\r\n|\r', '\n')
            .replaceAll('\t', '    ')
            .replaceAll('\u00a0', ' ')
            .replaceAll('\u2424', '\n');
        return token(src, true);
    }

    List<Token> token(String initialSrc, bool top, {bool bq: false}) {
        String src = initialSrc.replaceAll(new RegExp(r'^ +$', multiLine: true), '');
        Match cap;

        while (src != '') {
            // newline
            cap = options.rules.newline.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                tokens.add(new Token('space'));
            }

            // code
            cap = options.rules.code.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                var res = cap[0].replaceAll(new RegExp(r'^ {4}', multiLine: true), '');
                this.tokens.add(new Token('code', text: !options.pedantic ? res.replaceFirst(new RegExp(r'\n+$'), '') : res));
                continue;
            }

            // fences (gfm)
            cap = options.rules.fences.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                this.tokens.add(new Token('code', text: cap[3], lang: cap[2]));
                continue;
            }

            // heading
            cap = options.rules.heading.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                this.tokens.add(new Token('heading', depth: cap[1].length, text: cap[2]));
                continue;
            }

            // table no leading pipe (gfm)
            cap = options.rules.nptable.firstMatch(src);
            if (top && cap != null) {
                src = src.substring(cap[0].length);

                var cells = cap[3].replaceFirst(new RegExp(r'\n$'), '').split(new RegExp(r'\n'));

                Token item = new Token('table',
                    header: cap[1].replaceAll(new RegExp(r'^ *| *\| *$'), '')
                                    .split(new RegExp(r' *\| *')),
                    align: cap[2].replaceAll(new RegExp(r'^ *|\| *$'), '')
                                    .split(new RegExp(r' *\| *')));


                for (int i = 0; i < item.align.length; i++) {
                    if (new RegExp(r'^ *-+: *$').hasMatch(item.align[i])) {
                        item.align[i] = 'right';
                    } else if (new RegExp(r'^ *:-+: *$').hasMatch(item.align[i])) {
                        item.align[i] = 'center';
                    } else if (new RegExp(r'^ *:-+ *$').hasMatch(item.align[i])) {
                        item.align[i] = 'left';
                    } else {
                        item.align[i] = null;
                    }
                }

                item.cells = cells.map((c) => c.split(r' *\| *'));

                this.tokens.add(item);

                continue;
            }

            // lheading
            cap = options.rules.lheading.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                tokens.add(new Token('heading', depth: cap[2] == '=' ? 1 : 2, text: cap[1]));
                continue;
            }

            // hr
            cap = options.rules.hr.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                this.tokens.add(new Token('hr'));
                continue;
            }

            // blockquote
            cap = options.rules.blockquote.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);

                tokens.add(new Token('blockquote_start'));

                var result = cap[0].replaceAll(new RegExp(r'^ *> ?', multiLine: true), '');

                // Pass `top` to keep the current
                // "toplevel" state. This is exactly
                // how markdown.pl works.
                this.token(result, top, bq: true);

                this.tokens.add(new Token('blockquote_end'));

                continue;
            }

            // list
            cap = options.rules.list.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                var bull = cap[2];

                tokens.add(new Token('list_start', ordered: bull.length > 1));

                // Get each top-level item.
                var matches = options.rules.item.allMatches(cap[0]).toList();

                var next = false;
                for (var i = 0; i < matches.length; i++) {
                    Match matchm = matches[i];

                    // Remove the list item's bullet
                    // so it is seen as the next token.
                    int space = matchm[0].length;
                    String match = matchm[0].replaceFirst(new RegExp(r'^ *([*+-]|\d+\.) +'), '');

                    // Outdent whatever the
                    // list item contains. Hacky.
                    if ((~match.indexOf('\n ')) == 0) {
                        space -= match.length;
                        if(space > 0) {
                            match = !options.pedantic
                                ? match.replaceAll(new RegExp(r'^ {1,' + space.toString() + r'}', multiLine: true), '')
                                : match.replaceAll(new RegExp(r'^ {1,4}', multiLine: true), '');
                        }
                    }

                    // Determine whether the next list item belongs here.
                    // Backpedal if it does not belong in this list.
                    if (options.smartLists && i != matches.length - 1) {
                        var b = options.rules.bullet.firstMatch(matches[i + 1][0])[0];
                        if (bull != b && !(bull.length > 1 && b.length > 1)) {
                            src = matches.skip(i + 1).join('\n') + src;
                            i = matches.length - 1;
                        }
                    }

                    // Determine whether item is loose or not.
                    // Use: /(^|\n)(?! )[^\n]+\n\n(?!\s*$)/
                    // for discount behavior.
                    var loose = next || new RegExp(r'\n\n(?!\s*$)').hasMatch(match);
                    if (i != matches.length - 1) {
                        next = match[match.length - 1] == '\n';
                        if (!loose) loose = next;
                    }

                    tokens.add(new Token(loose ? 'loose_item_start' : 'list_item_start'));

                    // Recurse.
                    this.token(match, false, bq: bq);

                    tokens.add(new Token('list_item_end'));
                }

                this.tokens.add(new Token('list_end'));

                continue;
            }

            // html
            cap = options.rules.html.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                tokens.add(new Token(this.options.sanitize ? 'paragraph' : 'html',
                    pre: cap[1] == 'pre' || cap[1] == 'script' || cap[1] == 'style',
                    text: cap[0]));
                continue;
            }

            // def
            cap = options.rules.def.firstMatch(src);
            if ((!bq && top) && cap != null) {
                src = src.substring(cap[0].length);
                tokens.links[cap[1].toLowerCase()] = new Link(href: cap[2], title: cap[3]);
                continue;
            }

            // table (gfm)
            cap = options.rules.table.firstMatch(src);
            if (top && cap != null) {
                src = src.substring(cap[0].length);

                var cells = cap[3].replaceFirst(new RegExp(r'(?: *\| *)?\n$'), '').split('\n');
                var item = new Token('table',
                    header: cap[1].replaceAll(new RegExp(r'^ *| *\| *$'), '').split(new RegExp(r' *\| *')),
                    align: cap[2].replaceAll(new RegExp(r'^ *|\| *$'), '').split(new RegExp(r' *\| *')));

                for (var i = 0; i < item.align.length; i++) {
                    if (new RegExp(r'^ *-+: *$').hasMatch(item.align[i])) {
                        item.align[i] = 'right';
                    } else if (new RegExp(r'^ *:-+: *$').hasMatch(item.align[i])) {
                        item.align[i] = 'center';
                    } else if (new RegExp(r'^ *:-+ *$').hasMatch(item.align[i])) {
                        item.align[i] = 'left';
                    } else {
                        item.align[i] = null;
                    }
                }

                for (var i = 0; i < cells.length; i++) {
                    item.cells.add(cells[i]
                        .replaceAll(new RegExp(r'/^ *\| *| *\| *$'), '')
                        .split(new RegExp(r' *\| */')));
                }

                tokens.add(item);

                continue;
            }

            // top-level paragraph
            cap = options.rules.paragraph.firstMatch(src);
            if (top && cap != null) {
                src = src.substring(cap[0].length);
                tokens.add(new Token('paragraph',
                    text: cap[1][cap[1].length - 1] == '\n' ? cap[1].substring(0,  cap[1].length - 1) : cap[1]));
                continue;
            }

            // text
            cap = options.rules.text.firstMatch(src);
            if (cap != null) {
                // Top-level should never reach here.
                src = src.substring(cap[0].length);
                this.tokens.add(new Token('text', text: cap[0]));
                continue;
            }

            if (src.isNotEmpty) {
                throw new Exception('Infinite loop on byte: ' + src.codeUnitAt(0).toString());
            }
        }

        return tokens;
    }


}


class InlineLexer {
    MarkedOptions options;
    TokenList tokens;
    bool inLink = false;
    InlineLexer(this.options, this.tokens);

    String output(String src) {
        Match cap;
        String out = '';
        while (src != '') {
            // escape
            cap = options.inlineRules.escape.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                out += cap[1];
                continue;
            }

            // autolink
            cap = options.inlineRules.autolink.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                String href, text;
                if (cap[2] == '@') {
                    text = cap[1][6] == ':'
                        ? mangle(cap[1].substring(7))
                        : mangle(cap[1]);
                    href = mangle('mailto:') + text;
                } else {
                    var text = escape(cap[1]);
                    href = text;
                }
                out += options.renderer.link(href, null, text);
                continue;
            }

            // url (gfm)
            cap = options.inlineRules.url.firstMatch(src);
            if (!inLink && cap != null) {
                src = src.substring(cap[0].length);
                var text = escape(cap[1]);
                var href = text;
                out += options.renderer.link(href, null, text);
                continue;
            }

            // tag
            cap = options.inlineRules.tag.firstMatch(src);
            if (cap != null) {
                if (!inLink && new RegExp(r'^<a ', caseSensitive: false).hasMatch(cap[0])) {
                    inLink = true;
                } else if (inLink && new RegExp(r'^<\/a>', caseSensitive: false).hasMatch(cap[0])) {
                    inLink = false;
                }
                src = src.substring(cap[0].length);
                out += options.sanitize
                    ? escape(cap[0])
                    : cap[0];
                continue;
            }

            // link
            cap = options.inlineRules.link.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                inLink = true;
                out += outputLink(cap, new Link(href: cap[2], title: cap[3]));
                inLink = false;
                continue;
            }

            // reflink, nolink
            cap = options.inlineRules.reflink.firstMatch(src);
            if(cap == null) {
                cap = options.inlineRules.nolink.firstMatch(src);
            }
            if (cap != null) {
                src = src.substring(cap[0].length);
                var val = cap.groupCount > 1 ? cap[2] : '';
                if(val == null || val == '') {
                    val = cap[1];
                }
                String linkKey = val.replaceAll(new RegExp(r'\s+'), ' ');
                Link link = tokens.links[linkKey.toLowerCase()];
                if (link == null || link.href == null) {
                    out += cap[0][0];
                    src = cap[0].substring(1) + src;
                    continue;
                }
                inLink = true;
                out += outputLink(cap, link);
                inLink = false;
                continue;
            }

            // strong
            cap = options.inlineRules.strong.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                var val = cap[2];
                if(val == null || val.isEmpty) {
                    val = cap[1];
                }
                out += options.renderer.strong(this.output(val));
                continue;
            }

            // em
            cap = options.inlineRules.em.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                var val = cap[2];
                if(val == null || val.isEmpty) {
                    val = cap[1];
                }
                out += options.renderer.em(this.output(val));
                continue;
            }

            // code
            cap = options.inlineRules.code.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                out += options.renderer.codespan(escape(cap[2], true));
                continue;
            }

            // br
            cap = options.inlineRules.br.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                out += options.renderer.br();
                continue;
            }

            // del (gfm)
            cap = options.inlineRules.del.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                out += options.renderer.del(this.output(cap[1]));
                continue;
            }

            // text
            cap = options.inlineRules.text.firstMatch(src);
            if (cap != null) {
                src = src.substring(cap[0].length);
                out += escape(smartypants(cap[0]));
                continue;
            }

            if (src.isNotEmpty) {
                throw new Exception('Infinite loop on byte: ' + src.codeUnitAt(0).toString());
            }
        }

        return out;
    }

    String outputLink(Match cap, Link link) {
        String href = escape(link.href),
            title = link.title != null && link.title.isNotEmpty ? escape(link.title) : null;

        return cap[0][0] != '!'
            ? options.renderer.link(href, title, this.output(cap[1]))
            : options.renderer.image(href, title, escape(cap[1]));
    }

    String smartypants(String text) {
        if (!options.smartypants) return text;
        return text
            // em-dashes
            .replaceAll(new RegExp(r'--'), '\u2014')
            // opening singles
            .replaceAllMapped(new RegExp(r"(^|[-\u2014/(\[{" + '"' + "\s])'"), (match) => '\\${match[1]}u2018')
            // closing singles & apostrophes
            .replaceAll(new RegExp(r"'"), '\u2019')
            // opening doubles
            .replaceAll(new RegExp(r'(^|[-\u2014/(\[{\u2018\s])"'), '\$1\u201c')
            // closing doubles
            .replaceAll(new RegExp(r'"'), '\u201d')
            // ellipses
            .replaceAll(new RegExp(r'\.{3}'), '\u2026');
    }

    static Random rand = new Random();
    String mangle(String text) {
        var out = '';

        for (var i = 0; i < text.length; i++) {
            var ch = text.codeUnitAt(i);
            if (rand.nextDouble() > 0.5) {
                ch = 'x' + ch.toRadixString(16);
            }
            out += '&#' + ch + ';';
        }

        return out;
    }
}

class Renderer {
    MarkedOptions options;
    HtmlEscape sanitizer;
    Renderer() {
        sanitizer = const HtmlEscape();
    }

    void initialize(MarkedOptions options) {
        this.options = options;
    }

    String code(String code, String lang, bool escaped) {
        if (options.highlight != null) {
            var out = this.options.highlight(code, lang);
            if (out != null && out != code) {
                escaped = true;
                code = out;
            }
        }

        if (lang == null) {
            return '<pre><code>'
                + (escaped ? code : escape(code, true))
                + '\n</code></pre>';
        }

        return '<pre><code class="'
            + options.langPrefix
            + escape(lang, true)
            + '">'
            + (escaped ? code : escape(code, true))
            + '\n</code></pre>\n';
    }

    String blockquote(String quote) {
        return '<blockquote>\n' + quote + '</blockquote>\n';
    }

    String html(String html) {
        return html;
    }

    String heading(String text, int level, String raw) {
        return '<h'
            + level.toString()
            + ' id="'
            + options.headerPrefix
            + raw.toLowerCase().replaceAll(new RegExp(r'[^\w]+'), '-')
            + '">'
            + text
            + '</h'
            + level.toString()
            + '>\n';
    }

    String hr() {
        return '<hr />\n';
    }

    String list(body, ordered) {
        var type = ordered ? 'ol' : 'ul';
        return '<' + type + '>\n' + body + '</' + type + '>\n';
    }

    String listitem(text) {
        return '<li>' + text + '</li>\n';
    }

    String paragraph(text) {
        return '<p>' + text + '</p>\n';
    }

    String table(header, body) {
        return '<table>\n'
        + '<thead>\n'
        + header
        + '</thead>\n'
        + '<tbody>\n'
        + body
        + '</tbody>\n'
        + '</table>\n';
    }

    String tablerow(String content) {
        return '<tr>\n' + content + '</tr>\n';
    }

    String tablecell(String content, TableCellFlags flags) {
        var type = flags.header ? 'th' : 'td';
        var tag = flags.align != null
        ? '<' + type + ' style="text-align:' + flags.align + '">'
        : '<' + type + '>';
        return tag + content + '</' + type + '>\n';
    }

    String strong(String text) {
        return '<strong>' + text + '</strong>';
    }

    String em(String text) {
        return '<em>' + text + '</em>';
    }

    String codespan(String text) {
        return '<code>' + text + '</code>';
    }

    String br() {
        return '<br />';
    }

    String del(String text) {
        return '<del>' + text + '</del>';
    }

    String link(String href, String title, String text) {
        if (options.sanitize) {
            try {
                var prot = Uri.decodeComponent(unescape(href))
                    .replaceAll(new RegExp(r'[^\w:]'), '')
                    .toLowerCase();
                if (prot.indexOf('javascript:') == 0) {
                    return '';
                }
            } catch (e) {
                return '';
            }
        }
        var out = '<a href="' + href + '"';
        if (title != null) {
            out += ' title="' + title + '"';
        }
        out += '>' + text + '</a>';
        return out;
    }

    String image(String href, String title, String text) {
        var out = '<img src="' + href + '" alt="' + text + '"';
        if (title != null) {
            out += ' title="' + title + '"';
        }
        out += ' />';
        return out;
    }
}

class TableCellFlags {
    bool header;
    String align;

    TableCellFlags({this.header, this.align});
}

class Parser {
    TokenList tokens;
    Token token;
    MarkedOptions options;
    InlineLexer lexer;
    Parser(MarkedOptions this.options, InlineLexer this.lexer);

    String parse(TokenList src) {
        tokens = new TokenList.from(src.reversed);
        var out = '';
        while(next() != null) {
            out += tok();
        }

        return out;
    }

    Token next() {
        if(tokens.length == 0)
            return null;
        token = tokens.removeLast();
        return token;
    }

    Token peek() {
        return tokens.length > 0 ? tokens.last : null;
    }

    String parseText() {
        var body = token.text;

        var current;
        while((current = peek()) != null && current.type == 'text') {
            body += '\n' + this.next().text;
        }

        return lexer.output(body);
    }

    String tok() {
        switch (this.token.type) {
            case 'space':
                return '';
            case 'hr':
                return options.renderer.hr();
            case 'heading':
                return options.renderer.heading(
                    lexer.output(token.text),
                    token.depth,
                    token.text);
            case 'code':
                return options.renderer.code(token.text,
                    token.lang,
                    token.escaped);
            case 'table':
                // header
                String cell = '',
                    header = '',
                    body = '';
                for (var i = 0; i < this.token.header.length; i++) {
                    var flags = new TableCellFlags(header: true, align: token.align[i]);
                    cell += options.renderer.tablecell(
                        lexer.output(this.token.header[i]),
                        new TableCellFlags(header: true, align: this.token.align[i])
                    );
                }
                header += options.renderer.tablerow(cell);

                for (var i = 0; i < this.token.cells.length; i++) {
                    var row = this.token.cells[i];

                    cell = '';
                    for (var j = 0; j < row.length; j++) {
                        cell += options.renderer.tablecell(
                            lexer.output(row[j]),
                            new TableCellFlags(header: false, align: this.token.align[j])
                        );
                    }

                    body += options.renderer.tablerow(cell);
                }
                return options.renderer.table(header, body);
            case 'blockquote_start':
                var body = '';

                while (next().type != 'blockquote_end') {
                    body += this.tok();
                }

                return options.renderer.blockquote(body);

            case 'list_start':
                var body = '', ordered = this.token.ordered;

                while (next().type != 'list_end') {
                    body += this.tok();
                }

                return options.renderer.list(body, ordered);

            case 'list_item_start':
                var body = '';

                while (this.next().type != 'list_item_end') {
                    body += this.token.type == 'text'
                        ? this.parseText()
                        : this.tok();
                }

                return options.renderer.listitem(body);
            case 'loose_item_start':
                var body = '';

                while (next().type != 'list_item_end') {
                    body += this.tok();
                }

                return options.renderer.listitem(body);

            case 'html':
                var html = !this.token.pre && !this.options.pedantic
                    ? lexer.output(this.token.text)
                    : this.token.text;
                return options.renderer.html(html);

            case 'paragraph':
                return options.renderer.paragraph(lexer.output(token.text));

            case 'text':
                return options.renderer.paragraph(this.parseText());
        }

        return null;
    }
}

escape(String html, [bool encode = false]) {
    return html
        .replaceAll(!encode ? new RegExp(r'&(?!#?\w+;)') : new RegExp(r'&'), '&amp;')
        .replaceAll(new RegExp(r'<'), '&lt;')
        .replaceAll(new RegExp(r'>'), '&gt;')
        .replaceAll(new RegExp(r'"'), '&quot;')
        .replaceAll(new RegExp(r"'"), '&#39;');
}

unescape(String html) {
    return html.replaceAllMapped(new RegExp(r'&([#\w]+);'), (Match match) {
        var n = match[1].toLowerCase();
        if (n == 'colon') return ':';
        if (n[0] == '#') {
            return n[1] == 'x'
                ? new String.fromCharCode(int.parse(n.substring(2), radix: 16))
                : new String.fromCharCode(int.parse(n.substring(1)));
        }
        return '';
    });
}

typedef String HighlightFn(String code, String lang);
class MarkedOptions {
    NormalGrammar rules;
    InlineGrammar inlineRules;
    Renderer renderer;
    bool sanitize;
    bool smartypants;
    bool pedantic;
    bool smartLists;
    HighlightFn highlight;
    String langPrefix;
    String headerPrefix;
    bool silent;

    MarkedOptions(
        this.rules,
        this.inlineRules,
        this.renderer,
    {
        this.sanitize: false,
        this.smartypants: false,
        this.pedantic: false,
        this.smartLists: false,
        this.silent: false,
        this.highlight: null,
        this.langPrefix: 'lang-',
        this.headerPrefix: ''
    });
}

class Marked {
    static Future build(String src, MarkedOptions options) {
        Completer completer = new Completer();
        try {
            var lexer = new Lexer(options);
            var tokens = lexer.lex(src);
            var inlineLexer = new InlineLexer(options, tokens);
            var parser = new Parser(options, inlineLexer);
            completer.complete(parser.parse(tokens));
        } catch (e) {
            var error = {
                'message': '\nPlease report this to https://github.com/chjj/marked.'
            };
            if (options.silent) {
                completer.complete('<p>An error occured:</p><pre>'
                    + escape(e.message + '', true)
                    + '</pre>');
            }
            else {
                completer.completeError(e);
            }
        }

        return completer.future;
    }
}

main() {
    var renderer = new Renderer();
    var options = new MarkedOptions(new GfmTablesGrammar(), new InlineGfmBreaksGrammar(), renderer);
    renderer.initialize(options);
    Marked.build('An h1 header ============ \n\nParagraphs are separated by a blank line. \n\n2nd paragraph. *Italic*, **bold**, and `monospace`. Itemized lists look like: \n\n* this one * that one * the other one \n\nNote that --- not considering the asterisk --- the actual text content starts at 4-columns in. \n\n> Block quotes are > written like so. > > They can span multiple paragraphs, > if you like. \n\nUse 3 dashes for an em-dash. Use 2 dashes for ranges (ex., "it\'s all in chapters 12--14"). Three dots ... will be converted to an ellipsis. Unicode is supported. ☺ \n\nAn h2 header ------------ \n\nHere\'s a numbered list: \n\n1. first item 2. second item 3. third item \n\nNote again how the actual text starts at 4 columns in (4 characters from the left side). Here\'s a code sample: \n\n# Let me re-iterate ... for i in 1 .. 10 { do-something(i) } \n\nAs you probably guessed, indented 4 spaces. By the way, instead of indenting the block, you can use delimited blocks, if you like: \n\n~~~ define foobar() { print "Welcome to flavor country!"; } ~~~ \n\n(which makes copying & pasting easier). You can optionally mark the delimited block for Pandoc to syntax highlight it: \n\n~~~python import time # Quick, count to ten! for i in range(10): # (but not *too* quick) time.sleep(0.5) print i ~~~ \n\n### An h3 header ### \n\nNow a nested list: \n\n1. First, get these ingredients: \n\n* carrots * celery * lentils \n\n2. Boil some water. \n\n3. Dump everything in the pot and follow this algorithm: \n\nfind wooden spoon uncover pot stir cover pot balance wooden spoon precariously on pot handle wait 10 minutes goto first step (or shut off burner when done) \n\nDo not bump wooden spoon or it will fall. \n\nNotice again how text always lines up on 4-space indents (including that last line which continues item 3 above). \n\nHere\'s a link to [a website](http://foo.bar), to a [local doc](local-doc.html), and to a [section heading in the current doc](#an-h2-header). Here\'s a footnote [^1]. \n\n[^1]: Footnote text goes here. \n\nTables can look like this: \n\nsize material color ----  ------------  ------------ 9 leather brown 10 hemp canvas natural 11 glass transparent \n\nTable: Shoes, their sizes, and what they\'re made of \n\n(The above is the caption for the table.) Pandoc also supports multi-line tables: \n\n--------  ----------------------- keyword text --------  ----------------------- red Sunsets, apples, and other red or reddish things. \n\ngreen Leaves, grass, frogs and other things it\'s not easy being. --------  ----------------------- \n\nA horizontal rule follows. \n\n*** \n\nHere\'s a definition list: \n\napples : Good for making applesauce. oranges : Citrus! tomatoes : There\'s no "e" in tomatoe. \n\nAgain, text is indented 4 spaces. (Put a blank line between each term/definition pair to spread things out more.) \n\nHere\'s a "line block": \n\n| Line one |   Line too | Line tree \n\nand images can be specified like so: \n\n![example image](example-image.jpg "An exemplary image")', options).then((val) => print(val));
}

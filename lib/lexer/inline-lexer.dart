part of marked;

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
                    text = escape(cap[1]);
                    href = text;
                }
                out += options.renderer.link(href, null, text);
                continue;
            }

            // url (gfm)
            cap = options.inlineRules.url != null ? options.inlineRules.url.firstMatch(src) : null;
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
            cap = options.inlineRules.del != null ? options.inlineRules.del.firstMatch(src) : null;
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
        ? options.renderer.link(href, title, output(cap[1]))
        : options.renderer.image(href, title, escape(cap[1]));
    }

    String smartypants(String text) {
        if (!options.smartypants) return text;
        return text
        // em-dashes
        .replaceAll(new RegExp(r'--'), '\u2014')
        // opening singles
        .replaceAllMapped(new RegExp(r"(^|[-\u2014/(\[{" + '"' + r"\s])'"), (match) => '${match[1]}\u2018')
        // closing singles & apostrophes
        .replaceAll(new RegExp(r"'"), '\u2019')
        // opening doubles
        .replaceAllMapped(new RegExp(r'(^|[-\u2014/(\[{\u2018\s])"'), (match) => '${match[1]}\u201c')
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

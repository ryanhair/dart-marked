part of marked;

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

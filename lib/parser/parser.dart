part of marked;

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

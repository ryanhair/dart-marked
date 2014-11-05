part of marked;

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
                        if (space > 0) {
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
                text: cap[1][cap[1].length - 1] == '\n' ? cap[1].substring(0, cap[1].length - 1) : cap[1]));
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

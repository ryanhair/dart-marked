library marked;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

part 'marked-options.dart';
part 'grammar/gfm-grammar.dart';
part 'grammar/gfm-tables-grammar.dart';
part 'grammar/inline-gfm-breaks-grammar.dart';
part 'grammar/inline-gfm-grammar.dart';
part 'grammar/inline-grammar.dart';
part 'grammar/inline-pedantic-grammar.dart';
part 'grammar/normal-grammar.dart';
part 'lexer/inline-lexer.dart';
part 'lexer/lexer.dart';
part 'parser/parser.dart';
part 'renderer/renderer.dart';
part 'renderer/table-cell-flags.dart';
part 'token/link.dart';
part 'token/token.dart';
part 'token/token-list.dart';
part 'utils.dart';

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

Future<String> marked(String src, [MarkedOptions options = null]) {
    if(options == null) {
        var renderer = new Renderer();
        options = new MarkedOptions(new GfmTablesGrammar(), new InlineGfmBreaksGrammar(), renderer);
        renderer.initialize(options);
    }
    return Marked.build(src, options);
}

main() {
    marked('#test\n').then((val) => print(val));
}

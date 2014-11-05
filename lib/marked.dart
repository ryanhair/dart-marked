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

main() {
    var renderer = new Renderer();
    var options = new MarkedOptions(new GfmTablesGrammar(), new InlineGfmBreaksGrammar(), renderer);
    renderer.initialize(options);
    Marked.build('An h1 header ============ \n\nParagraphs are separated by a blank line. \n\n2nd paragraph. *Italic*, **bold**, and `monospace`. Itemized lists look like: \n\n* this one * that one * the other one \n\nNote that --- not considering the asterisk --- the actual text content starts at 4-columns in. \n\n> Block quotes are > written like so. > > They can span multiple paragraphs, > if you like. \n\nUse 3 dashes for an em-dash. Use 2 dashes for ranges (ex., "it\'s all in chapters 12--14"). Three dots ... will be converted to an ellipsis. Unicode is supported. ☺ \n\nAn h2 header ------------ \n\nHere\'s a numbered list: \n\n1. first item 2. second item 3. third item \n\nNote again how the actual text starts at 4 columns in (4 characters from the left side). Here\'s a code sample: \n\n# Let me re-iterate ... for i in 1 .. 10 { do-something(i) } \n\nAs you probably guessed, indented 4 spaces. By the way, instead of indenting the block, you can use delimited blocks, if you like: \n\n~~~ define foobar() { print "Welcome to flavor country!"; } ~~~ \n\n(which makes copying & pasting easier). You can optionally mark the delimited block for Pandoc to syntax highlight it: \n\n~~~python import time # Quick, count to ten! for i in range(10): # (but not *too* quick) time.sleep(0.5) print i ~~~ \n\n### An h3 header ### \n\nNow a nested list: \n\n1. First, get these ingredients: \n\n* carrots * celery * lentils \n\n2. Boil some water. \n\n3. Dump everything in the pot and follow this algorithm: \n\nfind wooden spoon uncover pot stir cover pot balance wooden spoon precariously on pot handle wait 10 minutes goto first step (or shut off burner when done) \n\nDo not bump wooden spoon or it will fall. \n\nNotice again how text always lines up on 4-space indents (including that last line which continues item 3 above). \n\nHere\'s a link to [a website](http://foo.bar), to a [local doc](local-doc.html), and to a [section heading in the current doc](#an-h2-header). Here\'s a footnote [^1]. \n\n[^1]: Footnote text goes here. \n\nTables can look like this: \n\nsize material color ----  ------------  ------------ 9 leather brown 10 hemp canvas natural 11 glass transparent \n\nTable: Shoes, their sizes, and what they\'re made of \n\n(The above is the caption for the table.) Pandoc also supports multi-line tables: \n\n--------  ----------------------- keyword text --------  ----------------------- red Sunsets, apples, and other red or reddish things. \n\ngreen Leaves, grass, frogs and other things it\'s not easy being. --------  ----------------------- \n\nA horizontal rule follows. \n\n*** \n\nHere\'s a definition list: \n\napples : Good for making applesauce. oranges : Citrus! tomatoes : There\'s no "e" in tomatoe. \n\nAgain, text is indented 4 spaces. (Put a blank line between each term/definition pair to spread things out more.) \n\nHere\'s a "line block": \n\n| Line one |   Line too | Line tree \n\nand images can be specified like so: \n\n![example image](example-image.jpg "An exemplary image")', options).then((val) => print(val));
}

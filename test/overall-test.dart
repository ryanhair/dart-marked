library marked.test;

import 'package:marked/marked.dart';
import 'package:unittest/unittest.dart';
import 'dart:io';
import 'dart:async';

main() {
    Renderer renderer;
    MarkedOptions options;
    MarkedOptions gfmOptions;
    MarkedOptions enhancedGfmOptions;
    MarkedOptions optionsWithSmartypants;
    //gfm grammar + inline gfm grammar;
    //normal grammar + inline-gramar
    //gfm-tables grammar + inline-gfm-breaks grammar

    Future<bool> compare(MarkedOptions options, String name) {
        var file = new File(Platform.script.toFilePath());
        var dataDir = new Directory(file.parent.path + '/data');
        var ampsAndAnglesHtml = new File(dataDir.path + '/$name.html');
        var ampsAndAnglesText = new File(dataDir.path + '/$name.text');

        return Future.wait([ampsAndAnglesText.readAsString(), ampsAndAnglesHtml.readAsString()]).then((List files) {
            return Marked.build(files[0], options).then((String md) {
                if(md.trim() != files[1].trim()) {
                    print(md.trim());
                }
                return md.trim() == files[1].trim();
            });
        });
    }

    setUp(() {
        renderer = new Renderer();
        gfmOptions = new MarkedOptions(new GfmGrammar(), new InlineGfmGrammar(), renderer);
        enhancedGfmOptions = new MarkedOptions(new GfmTablesGrammar(), new InlineGfmBreaksGrammar(), renderer);
        options = new MarkedOptions(new NormalGrammar(), new InlineGrammar(), renderer);
        optionsWithSmartypants = new MarkedOptions(new NormalGrammar(), new InlineGrammar(), renderer, smartypants: true);
        renderer.initialize(gfmOptions);
    });

    test('amps and angles', () {
        expect(compare(options, 'amps_and_angles_encoding'), completion(equals(true)));
        expect(compare(options, 'escaped_angles'), completion(equals(true)));
    });

    test('links', () {
        expect(compare(options, 'auto_links'), completion(equals(true)));
        expect(compare(options, 'autolink_lines'), completion(equals(true)));
        expect(compare(options, 'double_link'), completion(equals(true)));
        expect(compare(options, 'links_inline_style'), completion(equals(true)));
        expect(compare(options, 'links_reference_style'), completion(equals(true)));
        expect(compare(options, 'links_shortcut_references'), completion(equals(true)));
        expect(compare(options, 'nested_square_link'), completion(equals(true)));
        expect(compare(options, 'not_a_link'), completion(equals(true)));
    });

    test('backslash escapes', () {
        expect(compare(options, 'backslash_escapes'), completion(equals(true)));
    });

    test('blockquotes', () {
        expect(compare(options, 'blockquote_list_item'), completion(equals(true)));
        expect(compare(options, 'blockquotes_with_code_blocks'), completion(equals(true)));
        expect(compare(options, 'lazy_blockquotes'), completion(equals(true)));
        expect(compare(options, 'nested_blockquotes'), completion(equals(true)));
    });

    test('refs', () {
        expect(compare(options, 'case_insensitive_refs'), completion(equals(true)));
        expect(compare(options, 'ref_paren'), completion(equals(true)));
    });

    test('code', () {
        expect(compare(options, 'code_blocks'), completion(equals(true)));
        expect(compare(options, 'code_spans'), completion(equals(true)));
        expect(compare(options, 'nested_code'), completion(equals(true)));
    });

    test('def', () {
        expect(compare(options, 'def_blocks'), completion(equals(true)));
    });

    test('gfm breaks', () {
        expect(compare(enhancedGfmOptions, 'gfm_break.breaks'), completion(equals(true)));
    });

    test('gfm code', () {
        expect(compare(gfmOptions, 'gfm_code'), completion(equals(true)));
        expect(compare(gfmOptions, 'gfm_code_hr_list'), completion(equals(true)));
    });

    test('gfm del', () {
        expect(compare(gfmOptions, 'gfm_del'), completion(equals(true)));
    });

    test('gfm em', () {
        expect(compare(gfmOptions, 'gfm_em'), completion(equals(true)));
    });

    test('gfm links', () {
        expect(compare(gfmOptions, 'gfm_links'), completion(equals(true)));
    });

    test('gfm tables', () {
        expect(compare(enhancedGfmOptions, 'gfm_tables'), completion(equals(true)));
    });

    test('paragraphs', () {
        expect(compare(options, 'hard_wrapped_paragraphs_with_list_like_lines.nogfm'), completion(equals(true)));
        expect(compare(gfmOptions, 'toplevel_paragraphs.gfm'), completion(equals(true)));
    });

    test('horizontal rules', () {
        expect(compare(options, 'horizontal_rules'), completion(equals(true)));
        expect(compare(options, 'hr_list_break'), completion(equals(true)));
    });

    test('inline html', () {
        expect(compare(options, 'inline_html_advanced'), completion(equals(true)));
        expect(compare(options, 'inline_html_comments'), completion(equals(true)));
    });

    test('lists', () {
        expect(compare(options, 'list_item_text'), completion(equals(true)));
        expect(compare(options, 'ordered_and_unordered_lists'), completion(equals(true)));
        expect(compare(options, 'tricky_list'), completion(equals(true)));
    });

    test('literal quotes in titles', () {
        expect(compare(options, 'literal_quotes_in_titles'), completion(equals(true)));
    });

    test('loose lists', () {
        expect(compare(options, 'loose_lists'), completion(equals(true)));
    });

    test('em', () {
        expect(compare(options, 'nested_em'), completion(equals(true)));
    });

    test('bullet', () {
        expect(compare(options, 'same_bullet'), completion(equals(true)));
    });

    test('strong and em together', () {
        expect(compare(options, 'strong_and_em_together'), completion(equals(true)));
    });

    test('tabs', () {
        expect(compare(options, 'tabs'), completion(equals(true)));
    });

    test('smartypants', () {
        expect(compare(optionsWithSmartypants, 'text.smartypants'), completion(equals(true)));
    });

    test('tidyness', () {
        expect(compare(optionsWithSmartypants, 'tidyness'), completion(equals(true)));
    });

    test('overall', () {
        expect(compare(options, 'markdown_documentation_basics'), completion(equals(true)));
    });
}

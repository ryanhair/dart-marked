part of marked;

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

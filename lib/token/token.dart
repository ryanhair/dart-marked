part of marked;

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
    Token(this.type, {this.text: '', this.lang: '', this.depth: 0, this.header: null, this.align: null, this.cells: null, this.ordered: false, this.pre: false, this.escaped: false});
}

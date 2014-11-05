part of marked;

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

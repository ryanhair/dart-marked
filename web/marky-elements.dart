class Delimiter {
    final String start;
    final String end;

    const Delimiter(this.start, this.end);

    toString() {
        return '"$start" - "$end"';
    }
}

abstract class MarkdownElement {
    String text;
    List<Delimiter> get delimiters;
    bool get multiLine;
    void renderEditable();
    String render();

    bool isMatch(String input) {
        for(var delimiter in delimiters) {
            var lim = new RegExp('^${delimiter.start}', multiLine: multiLine);
            if(lim.hasMatch(input)) {
                return true;
            }
        }
        return false;
    }
}

class ParagraphElement extends MarkdownElement {
    final List<Delimiter> delimiters = [
        new Delimiter(r'(  |\n)\n', r'\n\n')
    ];

    String get startDelimiter => '\n\n';
    String get endDelimiter => '\n\n';
    bool get multiLine => true;

    String render() {
        return '<p>${text}</p>';
    }

    void renderEditable() {

    }
}

void main() {
    var p = new ParagraphElement();
    print(p.isMatch('\n\n'));
}

part of marked;

escape(String html, [bool encode = false]) {
    return html
    .replaceAll(!encode ? new RegExp(r'&(?!#?\w+;)') : new RegExp(r'&'), '&amp;')
    .replaceAll(new RegExp(r'<'), '&lt;')
    .replaceAll(new RegExp(r'>'), '&gt;')
    .replaceAll(new RegExp(r'"'), '&quot;')
    .replaceAll(new RegExp(r"'"), '&#39;');
}

unescape(String html) {
    return html.replaceAllMapped(new RegExp(r'&([#\w]+);'), (Match match) {
        var n = match[1].toLowerCase();
        if (n == 'colon') return ':';
        if (n[0] == '#') {
            return n[1] == 'x'
            ? new String.fromCharCode(int.parse(n.substring(2), radix: 16))
            : new String.fromCharCode(int.parse(n.substring(1)));
        }
        return '';
    });
}

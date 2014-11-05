part of marked;

class InlinePedanticGrammar extends InlineGrammar {
    RegExp get strong => new RegExp(r'^__(?=\S)([\s\S]*?\S)__(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)');
    RegExp get em => new RegExp(r'^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)');
}

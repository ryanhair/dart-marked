part of marked;

class GfmTablesGrammar extends GfmGrammar {
    RegExp get nptable => new RegExp(r'^ *(\S.*\|.*)\n *([-:]+ *\|[-| :]*)\n((?:.*\|.*(?:\n|$))*)\n*');
    RegExp get table => new RegExp(r'^ *\|(.+)\n *\|( *[-:]+[-| :]*)\n((?: *\|.*(?:\n|$))*)\n*');
}

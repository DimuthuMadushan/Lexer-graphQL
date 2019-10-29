import ballerina/io;
import ballerina/lang.'array as array;
import ballerina/lang.'float as floats;
import ballerina/stringutils;

public function main() {
    table<Token> t = getTokens("query mutation SUBSCRIPTION get($id:ID,$dir:Boolean!){
                                    person(personID: \"3.3\") {
                                        name
                                        gender
                                        homeworld @skip(if:7.7){
                                        name
                                    }
                                    starshipConnection {
                                        edges {
                                            node {
                                            id
                                            manufacturers
                                            }
                                        }
                                    }
                                }
                                }"
                                );

}

type Token record {
    int lineNum;
    int columnNum;
    string token;
    string tokenType;
    int startIndex;
};

function getTokens(string input) returns table<Token> {
    string str = input.trim();
    var charList = stringutils:split(str, "");
    table<Token> tokenTable = table {
        {startIndex, token, tokenType, lineNum, columnNum},
        []
    };
    int[] lineNumbIndex = [];
    var [i, j, k] = getPunctuationTokens(tokenTable,charList,lineNumbIndex);
    tokenTable = getStringTokens(i, j, k);
    var sortedTbToken = tableSort(tokenTable);
    printToken(sortedTbToken);
    return tokenTable;
}

function getPunctuationTokens(table<Token> tokenTable, string[] charList, int[] newLineIndexes) returns ([table<Token>, string[], int[]]) {
    int lineNumber = 1;
    int columnNumber = 0;
    foreach var char in charList {
        columnNumber = columnNumber + 1;
        match char {
            "\n" => {
                lineNumber = lineNumber + 1;
                columnNumber = 0;
                var i = array:indexOf(charList, "\n");
                if (i is int) {
                    newLineIndexes.push(i);
                    charList[i] = " ";
                } else {
                    io:println("Array index error in ignore character");
                    break;
                }

            }
            "," => {
                var i = 'array:indexOf(charList, ",");
                if (i is int) {
                    charList[i] = " ";
                } else {
                    io:println("Array index error in ignore character");
                    break;
                }
            }
            "!" => {
                var i = 'array:indexOf(charList, "!");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "!", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "$" => {
                var i = 'array:indexOf(charList, "$");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "$", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }


            }
            "(" => {
                var i = 'array:indexOf(charList, "(");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "(", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            ")" => {
                var i = 'array:indexOf(charList, ")");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, ")", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "..." => {
                var i = 'array:indexOf(charList, "...");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "...", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            ":" => {
                var i = 'array:indexOf(charList, ":");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, ":", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "=" => {
                var i = 'array:indexOf(charList, "=");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "=", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "@" => {
                var i = 'array:indexOf(charList, "@");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "@", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "[" => {
                var i = 'array:indexOf(charList, "[");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "[", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "]" => {
                var i = 'array:indexOf(charList, "]");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "]", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }

                }
            }
            "{" => {
                var i = 'array:indexOf(charList, "{");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "{", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }
                }
            }
            "}" => {
                var i = 'array:indexOf(charList, "}");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "}", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }
                }
            }
            "|" => {
                var i = 'array:indexOf(charList, "|");
                if (i is int) {
                    charList[i] = " ";
                    var err = addToTable(tokenTable, lineNumber, columnNumber, "|", "punctuation", i);
                    if (err != ()) {
                        io:println(err.toString());
                        break;
                    }
                }
            }
        }
    }

    return [tokenTable, charList, newLineIndexes];
}

function addToTable(table<Token> tokenTable, int lineNum, int columnNum, string token, string tokenType, int startIndex) returns (error | ()) {
    Token t1 = {
        lineNum: lineNum,
        columnNum: columnNum,
        token: token,
        tokenType: tokenType,
        startIndex: startIndex
    };
    var ret = tokenTable.add(t1);
    return ret;
}

function getStringTokens(table<Token> tokenTable, string[] charList, int[] newLineIndexes) returns table<Token> {
    int tokenStartIndex = 0;
    int numOfChar = 0;
    int lineNumber = 1;
    int columnNumber = 1;
    table<Token> tbToken = tokenTable;
    'array:push(charList, " ");

    foreach var item in charList {
        columnNumber += 1;
        numOfChar += 1;
        match item {
            " " => {
                var spaceIndex = 'array:indexOf(charList, " ");
                if (spaceIndex is int) {
                    charList[spaceIndex] = ".";

                    if (newLineIndexes.length() > lineNumber) {
                        if (newLineIndexes[(lineNumber - 1)] < tokenStartIndex) {
                            lineNumber = lineNumber + 1;
                            columnNumber = 1;
                            numOfChar = 0;
                        }
                    }
                    if ((spaceIndex - tokenStartIndex) >= 1) {
                        string[] temp2 = 'array:slice(charList, tokenStartIndex, spaceIndex);
                        string tempToken = "";
                        foreach var c in temp2 {
                            tempToken = tempToken.concat(c);
                        }
                        var err = addToTable(tokenTable, lineNumber, (columnNumber - numOfChar), tempToken, typeCheck(tempToken), tokenStartIndex);
                        if (err != ()) {
                            io:println(err.toString());
                            break;
                        }
                        tokenStartIndex = spaceIndex + 1;
                    } else {
                        tokenStartIndex = spaceIndex + 1;
                    }
                } else {
                    io:print(spaceIndex.toString());
                }
                numOfChar = 0;
            }
        }
    }
    return tokenTable;
}


function typeCheck(string token) returns string {
    string[] strTokens = ["schema", "scalar", "type", "implements", "interface", "union", "extend",
    "enum", "directive", "QUERY", "MUTATION", "SUBSCRIPTION", "FIELD", "FRAGMENT_DEFINITION", "FRAGMENT_SPREAD",
    "INLINE_FRAGMENT", "SCHEMA", "SCALAR", "OBJECT", "FIELD_DEFINITION",
    "ARGUMENT_DEFINITION", "INTERFACE", "UNION", "ENUM", "ENUM_VALUE", "on", "ON",
    "INPUT_OBJECT", "INPUT_FIELD_DEFINITION", "query", "mutation",
    "subscription", "fragment", "null", "Boolean", "String", "Int", "float"];

    string state = "Name";
    if (token.startsWith("\"") && token.endsWith("\"")) {
        state = "String";
    } else {
        foreach var item in strTokens {
            if (token == item) {
                state = "Identifier";
            } else {
                float | error tempToken = floats:fromString(token);
                if (tempToken is float) {
                    if ((tempToken % 1) == 0.0) {
                        state = "Int";
                    } else {
                        state = "float";
                    }

                }
            }
        }
    }
    return state;
}

function tableSort(table<Token> t) returns table<Token> {
    int[] arr = [];
    table<Token> sortedTokenTb = table {
        {startIndex, token, tokenType, lineNum, columnNum},
        []
    };
    table<Token> tbToken = t;
    foreach var x in tbToken {
        arr.push(x.startIndex);
    }
    arr = arr.sort(function(int x, int y) returns int {
        return x - y;
    });
    int i = 1;
    foreach var item in arr {
        while (t.hasNext()) {
            var ret = t.getNext();
            if (ret is Token) {
                if (ret.startIndex == item) {
                    Token t1 = {
                        lineNum: ret.lineNum,
                        columnNum: ret.columnNum,
                        token: ret.token,
                        tokenType: ret.tokenType,
                        startIndex: i
                    };
                    var re = sortedTokenTb.add(t1);
                    i += 1;
                }
            }
        }
    }
    return sortedTokenTb;
}

function printToken(table<Token> t) {
    foreach var item in t {
        io:print("index : ", item.startIndex);
        io:print("              ");
        io:print("Token : ", item.token);
        io:print("              ");
        io:print("Token type : ", item.tokenType);
        io:print("              ");
        io:print("ln : ", item.lineNum);
        io:print("              ");
        io:print("cn : ", item.columnNum);
        io:print("              ");
        io:println();
    }
}



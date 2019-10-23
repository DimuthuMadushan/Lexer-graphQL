import ballerina/io;
import ballerina/stringutils;
import ballerina/lang.'array as array;
import ballerina/lang.'float as floats;
//import ballerina/lang.'table;
//import ballerina/lang.'int as ints;


type Tokens record{
        int lineNumb;
        int columnNumb;
        string token;
        string tokenType;
        int listIndex;
    };


function typeCheck(string token) returns string{
    string[] strTokens = ["schema","scalar","type","implements","interface", "union","extend", 
			"enum","directive","QUERY","MUTATION","SUBSCRIPTION","FIELD", "FRAGMENT_DEFINITION", "FRAGMENT_SPREAD", 
			"INLINE_FRAGMENT", "SCHEMA", "SCALAR", "OBJECT", "FIELD_DEFINITION", 
			"ARGUMENT_DEFINITION", "INTERFACE", "UNION", "ENUM", "ENUM_VALUE","on","ON", 
			"INPUT_OBJECT", "INPUT_FIELD_DEFINITION", "query", "mutation", 
			"subscription", "fragment", "null","Boolean","String","Int","float"];

    string state ="Name";
    if(token.startsWith("\"") && token.endsWith("\"")){
        state = "String";
    }else{    
        foreach var item in strTokens {
        if(token==item){
            state = "Identifier";
        }else{
            float|error tempToken = floats:fromString(token);
            if(tempToken is float){
                if((tempToken%1)==0.0){
                        state = "Int";
                }else{
                    state="float";
                }
                
            }
        }
            
        
        }
    }
    return state;
}



//...........................................................

  //......................................................................... 
function printToken(table<Tokens> t){ 
    foreach var item in t{
        io:print("index : ",item.listIndex);
        io:print("              ");
        io:print("Token : ",item.token);
        io:print("              ");
        io:print("Token type : ",item.tokenType);
        io:print("              ");
        io:print("ln : ",item.lineNumb);
        io:print("              ");
        io:print("cn : ",item.columnNumb);
        io:print("              ");
        io:println();
    }
}

function TableSort(table<Tokens> t) returns table<Tokens>{
    int[] arr=[];
    table<Tokens> sortedTokenTb = table{{listIndex, token, tokenType, lineNumb, columnNumb},[]};
    table<Tokens> tbToken = t;
    foreach var x in tbToken {
        arr.push(x.listIndex);
    } 
    arr=arr.sort(function(int x,int y) returns int{return x-y;});
    int i = 1;
    foreach var item in arr {
        while(t.hasNext()){
            var ret= t.getNext();
            if(ret is Tokens){
                if(ret.listIndex==item){
                    Tokens t1 = {
                        lineNumb:ret.lineNumb,
                        columnNumb: ret.columnNumb,
                        token:ret.token,
                        tokenType:ret.tokenType,
                        listIndex: i
                    };
                    var re = sortedTokenTb.add(t1);
                    i+=1;
                }
            }
        }
    
        
    }
    return sortedTokenTb;
}

function stringTokenize(table<Tokens> tb,string[] list,int[] index) returns table<Tokens>{
    int k=0;
    int j = 0;
    int l = 0;
    int lineNumber=1;
    int columnNumber =1;

    table<Tokens> tbToken = tb;
    var charList = list;
    var lineNumbIndex = index;
    'array:push(charList," ");
    
    
    foreach var item in charList {
        columnNumber+=1;
        l+=1;
        match item{
            " "=>{   
                    var i= 'array:indexOf(charList," ");

                    if(i is int){
                        charList[i]=".";

                        if(lineNumbIndex.length()>lineNumber){
                            if(lineNumbIndex[(lineNumber-1)]< j){
                                    lineNumber=lineNumber+1;
                                    columnNumber = 1;
                                    l=0;
                            }
                        }
                        if((i-j)>=1){
                            string[] temp2 = 'array:slice(charList,j,i);
                            string tok = "";
                            foreach var c in temp2 {
                                tok = tok.concat(c);
                            }
                            
                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber-l,
                                token:tok,
                                tokenType:typeCheck(tok),
                                listIndex: j
                            };
                            

                            var ret = tbToken.add(t1);
                            j=i+1;
                            k=k+1;
                        }else{
                            j = i+1;
                        }
                    }else{
                        io:print(i.toString());
                    }
                    l=0;
                }
        }
    }
    return tbToken;
}

function getTokens(string input) returns table<Tokens>{
    //string[] punctuators = ["!", "$", "(",	")", "...",	":", "=", "@", "[", "]", "{","}","|"];
    string str = input.trim();
    var charList = stringutils:split(str,"");
    int lineNumber = 1;
    int columnNumber = 0;
    table<Tokens> tbToken = table{{listIndex, token, tokenType, lineNumb, columnNumb},[]};
    int[] lineNumbIndex=[];
    foreach var char in charList {
        columnNumber = columnNumber+1;
        match char {
            "\n" => {
                        lineNumber = lineNumber+1;
                        columnNumber = 0;
                        var i = array:indexOf(charList,"\n");
                        //io:println(i);
                        if(i is int){
                            lineNumbIndex.push(i);
                            charList[i]=" ";
                        }
                        
                    }
            "," => {
                        var i = 'array:indexOf(charList,",");
                        //io:println(i);
                        if(i is int){
                            charList[i]=" ";
                        }
                        
                    }       

            "!" => {
                        var i = 'array:indexOf(charList,"!");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"!",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            "$" => {
                    var i = 'array:indexOf(charList,"$");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"$",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }


                    }
            "(" =>{
                    var i = 'array:indexOf(charList,"(");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"(",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            ")"=>{
                    var i = 'array:indexOf(charList,")");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:")",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }
            "..."=>{var i = 'array:indexOf(charList,"...");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"...",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            ":"=>{var i = 'array:indexOf(charList,":");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:":",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            "="=>{var i = 'array:indexOf(charList,"=");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"=",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            "@"=>{
                var i = 'array:indexOf(charList,"@");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"@",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                    }
            "["=>{
                    var i = 'array:indexOf(charList,"[");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"[",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }
            "]"=>{
                    var i = 'array:indexOf(charList,"]");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"]",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }
            "{"=>{
                    var i = 'array:indexOf(charList,"{");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"{",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }
            "}"=>{
                    var i = 'array:indexOf(charList,"}");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"}",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }

            "|"=>{
                    var i = 'array:indexOf(charList,"|");
                        if(i is int){
                            charList[i]=" ";

                            Tokens t1 = {
                                lineNumb:lineNumber,
                                columnNumb: columnNumber,
                                token:"|",
                                tokenType:"Punctuation",
                                listIndex: i
                            };
                            var ret = tbToken.add(t1);
                            
                        }
                }


        }
    }

    tbToken = stringTokenize(tbToken,charList,lineNumbIndex);
    var sortedTbToken = TableSort(tbToken);
    printToken(sortedTbToken);
    return tbToken;
}

public function main() {
    io:println("Hello World!");
    // tokenize("query {
    //                     allStarships(first: \"7\") {
    //                         edges {
    //                         node  {
    //                             id
    //                             name
    //                             model
    //                             costInCredits
    //                             pilotConnection {
    //                             edges {
    //                                 node {
    //                                 name 
    //                                 homeworld {
    //                                     name
    //                                 }               
    //                                 }
    //                             }
    //                             }
    //                         }
    //                         }
    //                     }
    //                     }");
    table<Tokens> t  = getTokens("query mutation SUBSCRIPTION get($id:ID,$dir:Boolean!){
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
 }");
    string d = "dimuthu madushan34534/,/khjsddc.,sd";

    }


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser-bison.tab.h"
%}

%option noyywrap

%x COMMENT 
%x STRING
%%

"pegar_item" {return SCAN; }
"mostrar_jogo" {return PRINT; }
"personagem" {return INT; }
"se_acao" {return IF; }
"enquanto_vida" {return WHILE; }
"para_cada_nivel" {return FOR; }
"se_nao" {return ELSE; }
"personagens" {return VET; }
"+" {return MAIS; }
"-" {return MENOS; }
"*" {return VEZES; }
"/" {return DIV; }
"%" {return MOD; }
"(" {return LPAR; }
")" {return RPAR; }
"{" {return LCHA; }
"}" {return RCHA; }
"START" {return ATRIB; }
";" {return PEV; }
"MAIOR" {return MAIOR; }
"MENOR" {return MENOR; }
"IGUAL" {return IGUAL; }
"MAIORIGUAL" {return MAIORIGUAL; }
"MENORIGUAL" {return MENORIGUAL; }
"DIFERENTE" {return DIF; }
"!" {return NOT; }
"OR" {return OR; }
"AND" {return AND; }
"++" {return MAISMAIS; }
"--" {return MENOSMENOS; }
"," {return VIRG; }
"#" {
    BEGIN(COMMENT); // Começar reconhecer um comentario
}
<COMMENT>[^\n]* {
    // ^ ignorar * zero ou mais caracteres que não sejam um \n
}
<COMMENT>\n {
    BEGIN(INITIAL); // caso encontre /n volta ao estado inicial do flex
}
\" {
    BEGIN(STRING); // Começar a reconhecer uma string
}
<STRING>[^\n\"]+ { // primeira aspas ignorada
    yylval.str_val = strdup(yytext); // Salvar o texto da string
    return TEXTO;
}
<STRING>\" {
    BEGIN(INITIAL); // Voltar ao estado inicial
    return ASPAS; // retorna a ultima aspas
}
[0-9]+ {
    // coloque em yylval.(campo do union) o texto/valor do token
    yylval.int_val = atoi(yytext);
    return NUM;
}
[a-zA-Z][a-zA-Z0-9_]* {
    yylval.str_val = strdup(yytext); // obs: nao use direto yytext!
    return ID;
}
" " {}
"\n" {}
"\t" {} // ignorar tab para permitir copiar codigos e colar direto no compilador
. {
    printf("erro lexico\n"); 
    exit(1);
}
%%


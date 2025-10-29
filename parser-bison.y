%{
#include <stdio.h>
#include "parser-bison.tab.h"
#include <string.h>

// Um simbolo da tabela de simbolos é um id e seu endereço
typedef struct {
    char *id;
    int end;
} simbolo;

// Vetor de simbolos (a tabela de simbolos em si)
simbolo tabsimb[1000];
int nsimbs = 0;

// Dado um ID, busca na tabela de simbolos o endereço respectivo
int getendereco(char *id) {
    for (int i=0;i<nsimbs;i++)
        if (!strcmp(tabsimb[i].id, id))
            return tabsimb[i].end;
    printf("Erro semantico"); // imprime o erro semantico
    exit(1);
}

int T=0; // Temporario
int R=0; // Temporario para vetores
int label=0;
int labelfinal=1;

char *operadoratual; // string literal ser usada no operador e em comparacoes

%}

/* o union lista os tipos que o texto/valor de um token pode ter */
%union {
    char *str_val;
    int int_val;
}

/* indicação do tipo do texto/valor de um token, conforme o union. */
%token <str_val>ID ATRIB PEV MAIS DIV <int_val>NUM LPAR RPAR INT RCHA LCHA PRINT SCAN IF ELSE IGUAL MAIOR MENOR MAIORIGUAL MENORIGUAL DIF NOT VEZES MENOS WHILE FOR MOD OR AND COMENT MAISMAIS MENOSMENOS ASPAS VET TEXTO VIRG

/* define o tipo do "retorno"/"yylval" dos simbolos nao terminais.
   Aqui, os simbolos irão "retornar" um inteiro indicando em qual
   registrador temporario o resultado de sua (sub)expressao está */
%type <int_val>expr termo fator

/* mostra detalhes do erro de sintaxe */
%define parse.error verbose

%%

/* o código depois de um simbolo será executado quando o simbolo for
   "encontrado" na entrada (reduce) */

/* o texto/valor do primeiro simbolo da produção (neste caso, ID) é $1;
   o do segundo (ATRIB) é $2; do terceiro (expr) seria $3; do quarto (PEV) é $4,
   e assim por diante em todas as produções */

code :  while | for | declarar | atrib  | print | scan | if | declarar code | atrib code | print code | scan code | if code | for code | while code;

// ex: enquanto_vida (j MENORIGUAL 0 AND vetor j MAIOR chave) 
while : WHILE LPAR whilelabel comp RPAR LCHA code RCHA {
        label--;
        printf("jump R0%d\n", label); // desvio para o inicio do loop
        label++;
        printf("label R0%d\n", label); // label do final do loop
        label++;
      };

whilelabel :{
  T--;
  printf("label R0%d\n", label); // label inicial
  label++;
}; // simbolo fantasma, nao gera outro simbolo, só ajuda imprimir assembly na ordem


// todos for possiveis ex: para_cada_nivel(Guerreiro START 1; Guerreiro MENOR 100; Guerreiro++)
for : FOR LPAR foratrib comp PEV ID MAISMAIS RPAR LCHA code RCHA {
        label--;
        printf("add %%r%d, %%r%d, 1\n", getendereco($6), getendereco($6)); // incremento da variavel indice
        printf("jump R0%d\n", label); // desvio para o inicio do loop
        label++;
        printf("label R0%d\n", label); // label do final do loop
        label++;
      } // i++
    | FOR LPAR foratrib comp PEV ID MENOSMENOS RPAR LCHA code RCHA{
        label--;
        printf("sub %%r%d, %%r%d, 1\n", getendereco($6), getendereco($6)); // incremento da variavel indice
        printf("jump R0%d\n", label); // desvio para o inicio do loop
        label++;
        printf("label R0%d\n", label); // label do final do loop
        label++;
      }; // i--

foratrib : atrib {
        T--;
        printf("label R0%d\n", label);  // label inicial
        label++;
      }; // serve para chamar antes de comparacoes

// todos if e if seguido de else 
if : IF LPAR comp RPAR LCHA codeif RCHA{
        printf("label R0%d\n", labelfinal); 
        label++;
        labelfinal--;
      }; 
   | IF NOT LPAR notcomp RPAR LCHA codeif RCHA 
   {
        printf("label R0%d\n", labelfinal); 
        label++;
        labelfinal--;
   } // if com comparacao negada
   | IF LPAR comp RPAR LCHA codeif RCHA ELSE LCHA codeelse RCHA{
        label++;
        labelfinal--;
      }; // if else

codeif : code { 
        labelfinal = label+1;
        printf("jump R0%d\n", labelfinal);
        printf("label R0%d\n", label); 
        label = label+2;
      };

codeelse : code {
        label++;
        printf("label R0%d\n", labelfinal); 
      };

comp : comparacoes{
        T--;
        printf("jf %%t%d, R0%d\n", T, label); // jump false
        T++;
};

notcomp : comparacoes{
        T--;
        printf("jt %%t%d, R0%d\n", T, label+1); // jump true
        T++;
}; // comparacao negada

// todas comparacoes possiveis 
comparacoes : expr operador expr {
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, $1, $3);
                T++;
              } 
            | vetor operador expr{
                T--;
                int primeiro = T-3;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, $3);
                T++;
            } // vetor
            | vetor operador ID expr {
                T--;
                int primeiro = T-3;
                T++;
                int segundo = T;
                printf("load %%t%d, %%t%d(%d)\n", T, $4, getendereco($3));
                T++;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
            } // vetor comparado com vetor
            | expr operador ID expr{
                T--;
                int primeiro = T-3;
                T++;
                int segundo = T;
                printf("load %%t%d, %%t%d(%d)\n", T, $4, getendereco($3));
                T++;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
            } // expr comparado com vetor 
            | comparacoes AND expr operador expr {
                  T--;
                  int primeiro = T-1;
                  T++;
                  int segundo = T-1;
                  printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                  T++;
                  printf("and %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                  T++;
              } // AND
            | comparacoes OR expr operador expr{
                T--;
                int primeiro = T-1;
                T++;
                int segundo = T-1;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
                printf("or %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                T++;
              } // OR
            | comparacoes AND ID expr operador expr{
                T--;
                int primeiro = T-1;
                T++;
                int segundo = T-1;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
                printf("and %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                T++;
              } // vetor AND
            | comparacoes OR ID expr operador expr {
                T--;
                int primeiro = T-1;
                T++;
                int segundo = T-1;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
                printf("or %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                T++;
              }// vetor OR
            | comparacoes AND ID expr operador ID expr {
                T--;
                int primeiro = T-1;
                T++;
                int segundo = T-1;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
                printf("and %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                T++;
              }// vetor AND
            | comparacoes OR ID expr operador ID expr{
                T--;
                int primeiro = T-1;
                T++;
                int segundo = T-1;
                printf("%s %%t%d, %%t%d, %%t%d\n", operadoratual, T, primeiro, segundo);
                T++;
                printf("or %%t%d, %%t%d, %%t%d\n", T, primeiro-1, segundo+1);
                T++;
              }; // vetor OR


vetor : ID expr {
      printf("load %%t%d, %%t%d(%d)\n", T, $2, getendereco($1));
      T++;
} // vetor para ter o load no local correto

// todos operadores
operador : IGUAL { 
          operadoratual = "equal"; // salva o operador pra chamar como string em comparacoes
          }
         | MAIOR {
          operadoratual = "greater"; // salva o operador pra chamar como string em comparacoes
          }
         | MAIORIGUAL {
          operadoratual = "greatereq"; // salva o operador pra chamar como string em comparacoes
          }
         | MENOR {
          operadoratual = "less"; // salva o operador pra chamar como string em comparacoes
          }
         | MENORIGUAL {
          operadoratual = "lesseq"; // salva o operador pra chamar como string em comparacoes
          }
         | DIF {
          operadoratual = "diff"; // salva o operador pra chamar como string em comparacoes
          };

declarar : INT ID ATRIB expr PEV {
            tabsimb[nsimbs] = (simbolo){$2, R+nsimbs};  nsimbs++;
            printf("mov %%r%d, %%t%d\n", getendereco($2), $4);
            }; // declaracao com atrib
         | INT ID PEV{ tabsimb[nsimbs] = (simbolo){$2, R+nsimbs};  nsimbs++; }; // declaracao de inteiro
         | VET ID NUM PEV { 
            tabsimb[nsimbs] = (simbolo){$2, nsimbs}; 
            R = R + ($3) - 1;
            nsimbs++;
         }; // declaracao de vetor
 
print : PRINT todosprint PEV;

todosprint : todosprint VIRG expr {
            printf("printv %%t%d\n", $3);
          }// imprimir alternando entre var e texto
          | todosprint VIRG ID expr {
            printf("load %%t%d %%t%d(%d)\n", T, T-1, getendereco($3));
            printf("printv %%t%d\n", T);
            T++;
          }// qualquer print seguido de imprimir só vetor
          | todosprint VIRG TEXTO ASPAS{
            printf("printf \"%s\"\n", $3);
          } // imprimir alternando entre texto e var
          | expr {
            printf("printv %%t%d\n", $1);
          }// imprimir só expressao
          | ID expr {
            printf("load %%t%d %%t%d(%d)\n", T, $2, getendereco($1));
            printf("printv %%t%d\n", T);
            T++;
          }// imprimir só vetor
          | TEXTO ASPAS {
            printf("printf \"%s\"\n", $1);
          }; // imprimir só texto

scan : SCAN ID PEV {
            printf("read %%r%d\n", getendereco($2));
        } // ler var
     | SCAN ID expr PEV {
            printf("read %%t%d\n", T);
            printf("store %%t%d %%t%d(%d)\n", T, $3, getendereco($2));
            T++;
        }; // ler vetor

atrib : ID ATRIB expr PEV {
            printf("mov %%r%d, %%t%d\n", getendereco($1), $3);
        } // atribuicao de var
      | ID expr ATRIB expr PEV {
            printf("store %%t%d, %%t%d(%d)\n", $4, $2, getendereco($1));
      } // atribuicao de var em vetor
      | ID ATRIB ID expr PEV {
            printf("load %%t%d, %%t%d(%d)\n", T, $4, getendereco($3));
            printf("mov %%r%d, %%t%d\n", getendereco($1), T);
      } // atribuicao de vetor em var
      | ID expr ATRIB ID expr PEV
      {
            printf("load %%t%d, %%t%d(%d)\n", T, $5, getendereco($4));
            printf("store %%t%d, %%t%d(%d)\n", T, $2, getendereco($1));
      }; // atribuicao de vetor em vetor

/* expressoes */
expr : expr MAIS termo {
            printf("add %%t%d, %%t%d, %%t%d\n", T, $1, $3);
            $$ = T++;
        }
     | expr MENOS termo {
            printf("sub %%t%d, %%t%d, %%t%d\n", T, $1, $3);
            $$ = T++;
        }
     | termo { $$ = $1; };

termo : termo DIV fator {
            printf("div %%t%d, %%t%d, %%t%d\n", T, $1, $3);
            $$ = T++;
        }
      | termo VEZES fator {
            printf("mult %%t%d, %%t%d, %%t%d\n", T, $1, $3);
            $$ = T++;
      }
      | termo MOD fator {
            printf("mod %%t%d, %%t%d, %%t%d\n", T, $1, $3);
            $$ = T++;
        }
      | fator {$$ = $1; };
      
fator : ID { 
            /* atribui o conteudo da variavel (registrador r
            definido na tabela de simbolos) a um temporario
            e o "retorna" em $$ */
            int end = getendereco($1);
            printf("mov %%t%d, %%r%d\n", T, end);
            $$ = T++;
        }
      | NUM {
            /* analogo */
            printf("mov %%t%d, %d\n", T, $1);
            $$ = T++;
        }
      | LPAR expr RPAR {
        /* o "retorno" do fator é o mesmo da expr neste caso */
          $$ = $2;
      }
      | LPAR MENOS NUM RPAR {
          /* analogo */
          printf("mov %%t%d, -%d\n", T, $3);
          $$ = T++;
      }; // declarar valores

%%

 extern FILE *yyin;                   // (*) descomente para ler de um arquivo

int main(int argc, char *argv[]) {

    yyin = fopen(argv[1], "r");       // (*)

    yyparse();

    fclose(yyin);                     // (*)

    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }

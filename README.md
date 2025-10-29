# CompiladorRPG
Compilador inspirado em jogos RPG com Flex e Bison

Bugs conhecidos:
Laço dentro de laço não funciona (for e while).

FUNCIONAIS:
contrario
digitos
fibo
for
hello
loop
maior
maior2
maior3
media
teste

NÃO FUNCIONAIS: 
identidade
bubble
insertion
selection

bison -d parser-bison.y
flex lexico-flex.l
gcc -o compilador lex.yy.c parser-bison.tab.c
compilador

compilador > saida.rap

raposeitor saida.rap

Principais substituições:
int (para declaração de variáveis) -> personagem
printf (para imprimir na tela) -> mostrar_jogo
for (para loops) -> para_cada_nivel
while (para loops) -> enquanto_vida
if (para condições) -> se_acao
else (para condições) -> se_nao
scanf (para entrada) -> pegar_item
= (para atribuição) -> START 

#Objetivo inicial (Só uma base, não serve para execução):
personagem Guerreiro START 1;
mostrar_jogo "Bem-vindo ao jogo!\n";
para_cada_nivel(Guerreiro START 1; Guerreiro MENOR 100; Guerreiro++) {
    mostrar_jogo "Nível:" ,Guerreiro, "\n" ;
    se_acao(nivel IGUAL 60) {
        mostrar_jogo "Recompensa!", "\n";
	pegar_item excalibur;
    } se_nao {
        mostrar_jogo "Continue explorando \n";
    }
    enquanto_vida(vida DIFERENTE 0){
    mostrar_jogo "Continue explorando \n";
    }
}

#Exemplo 1 

# Le 3 numeros e imprime o maior (if-else aninhado)

personagem a;
personagem b;
personagem c;
pegar_item a;
pegar_item b;
pegar_item c;

se_acao (a MAIORIGUAL b AND a MAIORIGUAL c){
    mostrar_jogo "O maior eh ", a;
} se_nao {
    se_acao (b MAIORIGUAL a AND b MAIORIGUAL c){
        mostrar_jogo "O maior eh ", b;
    } se_nao {
        mostrar_jogo "O maior eh ", c;
    }
}


#Exemplo 2

    # Calcula e mostra a sequencia de Fibonnaci ate 10000

# Declaracoes
personagem ult;
personagem atu;
personagem prox;

# Inicializacao
ult START 0;
atu START 1;
mostrar_jogo ult, "\n";
enquanto_vida (atu MENORIGUAL 10000){            # Laco principal
    mostrar_jogo atu, "\n";
    prox START ult + atu;
    ult START atu;
    atu START prox;
}


#Exemplo 3

# Le um vetor e o ordena pelo insertion sort

personagens v 1024;
personagem N;
personagem i;
personagem j;
personagem aux;

mostrar_jogo "Tamanho: ";
pegar_item N;
mostrar_jogo "Elementos: ";

para_cada_nivel(i START 0; i MENORIGUAL N-1; i++){
    pegar_item v i;
}

# Repita N vezes...
para_cada_nivel(i START 1; i MENORIGUAL N-1; i++){
    j START i;
    # "Empurra" v[j] para tras ate a posicao certa dele
    enquanto_vida(j MAIOR 0 AND v j MENOR v j-1){
        aux START v j;
        v j START v j-1;
        v j-1 START aux;
        j START j - 1;
    }
}

mostrar_jogo "Ordenado: ";
para_cada_nivel(i START 0; i MENORIGUAL N-1; i++){
    mostrar_jogo v i, " ";
}
mostrar_jogo "\n";


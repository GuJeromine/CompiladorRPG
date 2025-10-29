# Compilador inspirado em Jogo RPG Online

## Bugs Conhecidos
* Laço dentro de laço não funciona (tanto `para_cada_nivel` quanto `enquanto_vida`).


## Status dos Recursos

### Funcionais
* contrario
* digitos
* fibo
* for
* hello
* loop
* maior
* maior2
* maior3
* media
* teste

### Não Funcionais
* identidade
* bubble
* insertion
* selection

---

## Como Compilar e Executar

1.  **Gerar o parser e o léxico:**
    ```bash
    bison -d parser-bison.y
    flex lexico-flex.l
    ```

2.  **Compilar o programa:**
    ```bash
    gcc -o compilador lex.yy.c parser-bison.tab.c
    ```

3.  **Executar o compilador (gerando `saida.rap`):**
    ```bash
    ./compilador > saida.rap
    ```

4.  **Executar o arquivo de saída:**
    ```bash
    raposeitor saida.rap
    ```

---

## Sintaxe da Linguagem (Substituições)

| C Padrão | Nova Sintaxe | Propósito |
| :--- | :--- | :--- |
| `int` | `personagem` | Declaração de variáveis |
| `printf` | `mostrar_jogo` | Imprimir na tela |
| `for` | `para_cada_nivel` | Loops |
| `while` | `enquanto_vida` | Loops |
| `if` | `se_acao` | Condições |
| `else` | `se_nao` | Condições |
| `scanf` | `pegar_item` | Entrada |
| `=` | `START` | Atribuição |

---

## Exemplos de Código

### Exemplo 1: Maior de 3 números
*Le 3 numeros e imprime o maior (if-else aninhado).*

```text
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
```
### Exemplo 2

*Calcula e mostra a sequencia de Fibonnaci ate 10000*

```text

# Declaracoes
personagem ult;
personagem atu;
personagem prox;

# Inicializacao
ult START 0;
atu START 1;
mostrar_jogo ult, "\n";
enquanto_vida (atu MENORIGUAL 10000){        # Laco principal
    mostrar_jogo atu, "\n";
    prox START ult + atu;
    ult START atu;
    atu START prox;
}
```
### Exemplo 3

*Le um vetor e o ordena pelo insertion sort*

```text

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

``` 

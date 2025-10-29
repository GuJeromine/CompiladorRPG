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

### Objetivo inicial (Conceito)
> **Nota:** Este código é apenas uma base conceitual e não serve para execução.

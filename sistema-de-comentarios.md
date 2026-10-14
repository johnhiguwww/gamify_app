# Sistema de Comentários por Marcadores

Método pessoal de comentar código usando **marcadores curtos por tipo**. O marcador diz de relance *o que* o comentário é; o texto diz o que está acontecendo, **inclusive o óbvio**.

---

## 1. Filosofia

1. **Comentar o óbvio.** Até o óbvio precisa ser dito. O que parece evidente hoje para quem escreveu pode não ser amanhã, nem para quem lê pela primeira vez.
2. **Nada fica implícito.** Cada variável, laço, condição e retorno recebe sua nota.
3. **O código passa a ser lido como um texto.** Quem lê acompanha a história do programa em português claro, sem precisar decifrar a sintaxe.
4. **O marcador dá o tipo da nota.** Isso permite escanear e filtrar o código visualmente (ou por busca) por categoria.
5. **Comentar não é redundância, é documentação.** O comentário registra a intenção no momento em que o código foi escrito.

---

## 2. Tabela de marcadores

| Marcador | Significado | Quando usar |
|----------|-------------|-------------|
| `##` | Comentário comum | Explicação geral de qualquer trecho ou linha |
| `#f` | Função | Descrever o propósito de uma função |
| `#!` | Alerta | Avisar sobre um cuidado, armadilha ou efeito colateral |
| `#$` | Classe | Descrever o papel de uma classe |
| `#v` | Variável | Explicar o que a variável guarda |
| `#p` | Parâmetro | Descrever um parâmetro de função ou método |
| `#r` | Retorno | Descrever o que a função retorna |
| `#if` | Condicional (se) | Explicar o que o `if` testa |
| `#elseif` | Condicional (senão se) | Explicar o que o `elif`/`else if` testa |
| `#else` | Condicional (senão) | Explicar o caso padrão do `else` |
| `#wh` | While | Explicar o laço e a condição de parada |
| `#dw` | Do-while | Explicar o laço que executa ao menos uma vez |
| `#!!` | Muito importante | Algo crítico que não pode ser ignorado |
| `#TODO` | Tarefa pendente | TODO: algo ainda a ser feito |
| `#x` | Problema | FIXME: algo quebrado ou que precisa ser corrigido |

---

## 3. Grupos de marcadores

### Estrutura (descrevem blocos)
`#f` função · `#$` classe · `#v` variável

### Contrato de função
`#p` parâmetro · `#r` retorno

### Fluxo de controle
`#if` · `#elseif` · `#else` · `#wh` · `#dw`

### Atenção
`#!` alerta · `#!!` muito importante

### Pendências
`#t` tarefa (TODO) · `#x` problema (FIXME)

### Geral
`##` comentário comum

---

## 4. Exemplos

### 4.1 Função com parâmetros e retorno

```python
#f Calcula o desconto progressivo com base no total acumulado do cliente
#p total: valor acumulado de compras, em reais
#p fidelidade: anos como cliente, usado no bônus extra
#r percentual de desconto entre 0.0 e 0.30
def calcular_desconto(total, fidelidade):
    #v começa em zero e vai acumulando o desconto
    desconto = 0.0

    #if total a partir de 1000 entra na faixa premium
    if total >= 1000:
        ## aplica 15% de desconto
        desconto = 0.15
    #elseif total a partir de 500 entra na faixa intermediária
    elif total >= 500:
        ## aplica 8% de desconto
        desconto = 0.08
    #else abaixo de 500 não tem desconto base
    else:
        ## mantém o desconto zerado
        desconto = 0.0

    ## soma 1% por ano de fidelidade, limitado a 15%
    desconto += min(fidelidade * 0.01, 0.15)

    ## devolve o desconto final
    return desconto
```

### 4.2 Classe e variáveis

```python
#$ Controla o acesso à fila de tarefas e impede duas execuções simultâneas
class Fila:
    def __init__(self):
        #v trava: indica se algum worker já está usando a fila
        self.trava = False
        #v itens: lista das tarefas aguardando execução
        self.itens = []
```

### 4.3 Laços

```python
#v contador de tentativas, começa em zero
tentativas = 0

#wh repete enquanto não estourar o limite de tentativas
while tentativas < MAX_TENTATIVAS:
    ## chama a API e guarda a resposta
    resposta = chamar_api()

    #if a API respondeu com sucesso
    if resposta.ok:
        ## sai do laço, não precisa tentar de novo
        break

    ## soma uma tentativa antes de repetir
    tentativas += 1
```

```javascript
// #dw lê o sensor ao menos uma vez, depois repete até o valor ser válido
do {
    // ## guarda a leitura atual do sensor
    valor = lerSensor();
} while (!valorValido(valor));
```

### 4.4 Alertas, tarefas e problemas

```python
#! esta função altera a lista original em vez de devolver uma cópia
def normalizar(lista):
    ...

#!! nunca remover essa validação: sem ela o usuário acessa dados de outro cliente
validar_dono(registro, usuario)

#t adicionar cache aqui quando o volume passar de 10 mil registros

#x falha com datas anteriores a 1970; timestamp vira negativo
data = converter(timestamp)
```

---

## 5. Comparação: sem comentário e com comentário

### Sem comentário (o óbvio fica implícito)

```python
contador = 0
for item in lista:
    contador += 1
```

### Com comentário (o óbvio é dito)

```python
#v contador: guarda quantos itens foram percorridos
contador = 0

## percorre cada item da lista, um por vez
for item in lista:
    ## soma 1 ao contador a cada item visitado
    contador += 1
```

---

## 6. Regras de uso

1. **Um marcador por comentário**, sempre no início.
2. **Texto curto e direto**: uma linha, no máximo duas.
3. **Comente tudo, inclusive o óbvio.** Variáveis, laços, condições, atribuições e retornos.
4. **Use `#!!` com parcimônia.** Se tudo é muito importante, nada é.
5. **`#t` e `#x` precisam ser acionáveis.** Diga o que fazer ou o que está errado.
6. **Resolveu? Apague o marcador.** `#t` e `#x` não ficam no código depois de resolvidos.
7. **Adapte à sintaxe da linguagem.** Em linguagens que não usam `#` para comentário, o prefixo muda mas o marcador continua:
   - JavaScript, C, Java: `// #f ...`
   - HTML: `<!-- #! ... -->`
   - CSS: `/* #v ... */`

---

## 7. Busca rápida

Como os marcadores são texto simples, dá para filtrar por eles:

```bash
# todas as tarefas pendentes
grep -rn "#t " .

# todos os problemas conhecidos
grep -rn "#x " .

# tudo que é crítico
grep -rn "#!!" .
```

---

## 8. Resumo em uma linha

> **Marcador diz o tipo. Texto diz o que acontece. Até o óbvio precisa ser dito.**

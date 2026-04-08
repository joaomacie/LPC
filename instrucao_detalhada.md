# Documentacao detalhada: conversao de expressao aritmetica em instrucoes de 3 enderecos

## 1. Objetivo do programa

O arquivo [`instrucao.cr`](c:\Users\DELL\OneDrive\Desktop\LPC\LPC\instrucao.cr) pega uma expressao aritmetica recebida como texto e a transforma em instrucoes menores, chamadas de **instrucoes de 3 enderecos**.

Exemplo de entrada:

```text
x = a + b * d - c
```

Saida gerada:

```text
Expressao: x = a + b * d - c
t1 = b * d
t2 = a + t1
t3 = t2 - c
x = t3
```

Esse tipo de representacao e muito usado em compiladores, porque quebra uma conta grande em passos pequenos e organizados.

## 2. O que sao instrucoes de 3 enderecos

Uma instrucao de 3 enderecos geralmente tem esta forma:

```text
resultado = valor1 operador valor2
```

Exemplos:

```text
t1 = b * d
t2 = a + t1
t3 = t2 - c
```

Cada linha faz uma operacao simples. Em vez de resolver tudo de uma vez, o programa resolve por partes.

## 3. Ideia geral do algoritmo

O programa faz 3 etapas principais:

1. Recebe a expressao completa.
2. Converte a parte da conta para o formato posfixo.
3. Usa esse formato para montar as instrucoes temporarias.

## 4. Estrutura do codigo

O arquivo possui 3 partes principais:

1. A funcao `precedencia`
2. A funcao `infixa_para_posfixa`
3. A funcao `tres_enderecos`

No final, ha uma chamada de exemplo:

```crystal
tres_enderecos("x = a + b * d - c")
```

## 5. Explicacao detalhada de cada parte

### 5.1 Funcao `precedencia`

Trecho:

```crystal
def precedencia(operador : String) : Int32
  case operador
  when "+", "-"
    1
  when "*", "/"
    2
  else
    0
  end
end
```

### O que ela faz

Essa funcao informa qual operador tem prioridade maior.

Regras:

- `+` e `-` tem prioridade `1`
- `*` e `/` tem prioridade `2`
- qualquer outro simbolo recebe `0`

### Por que isso e importante

Em matematica:

```text
a + b * d
```

nao e resolvido da esquerda para a direita sem pensar. Primeiro vem a multiplicacao:

```text
b * d
```

depois a soma:

```text
a + resultado
```

Essa funcao ajuda o programa a respeitar essa regra.

## 5.2 Funcao `infixa_para_posfixa`

Trecho:

```crystal
def infixa_para_posfixa(tokens : Array(String)) : Array(String)
  saida = [] of String
  operadores = [] of String

  tokens.each do |token|
    if token =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/ || token =~ /^\d+$/
      saida << token
    elsif token == "("
      operadores << token
    elsif token == ")"
      while !operadores.empty? && operadores.last != "("
        saida << operadores.pop
      end
      operadores.pop if !operadores.empty? && operadores.last == "("
    else
      while !operadores.empty? &&
            precedencia(operadores.last) >= precedencia(token) &&
            operadores.last != "("
        saida << operadores.pop
      end
      operadores << token
    end
  end

  while !operadores.empty?
    saida << operadores.pop
  end

  saida
end
```

### O que significa "infixa"

A forma infixa e a forma normal que as pessoas usam:

```text
a + b * d - c
```

### O que significa "posfixa"

Na forma posfixa, o operador vai depois dos valores:

```text
a b d * + c -
```

### Por que transformar para posfixa

Porque o formato posfixo facilita muito o processamento com pilha.

Em vez de ficar decidindo toda hora o que fazer primeiro, a expressao ja vem organizada na ordem certa.

### Variaveis dessa funcao

- `saida`: guarda os tokens da expressao em posfixa
- `operadores`: funciona como uma pilha para guardar operadores e parenteses temporariamente

### Como ela funciona

O programa percorre cada token da expressao:

#### Caso 1: e uma variavel ou numero

```crystal
if token =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/ || token =~ /^\d+$/
  saida << token
```

Se o token for algo como `a`, `b`, `x1`, `valor` ou `25`, ele vai direto para a lista de saida.

#### Caso 2: e um parentese abrindo

```crystal
elsif token == "("
  operadores << token
```

O parentese `(` e colocado na pilha de operadores.

#### Caso 3: e um parentese fechando

```crystal
elsif token == ")"
  while !operadores.empty? && operadores.last != "("
    saida << operadores.pop
  end
  operadores.pop if !operadores.empty? && operadores.last == "("
```

Quando encontra `)`, o programa tira operadores da pilha e joga na saida ate encontrar `(`.

Depois remove o `(`.

#### Caso 4: e um operador

```crystal
else
  while !operadores.empty? &&
        precedencia(operadores.last) >= precedencia(token) &&
        operadores.last != "("
    saida << operadores.pop
  end
  operadores << token
end
```

Se for um operador como `+`, `-`, `*` ou `/`, o programa compara a prioridade dele com o que ja esta na pilha.

Se o operador da pilha tiver prioridade maior ou igual, ele sai da pilha e vai para a saida.

Depois o operador atual entra na pilha.

#### Final da funcao

```crystal
while !operadores.empty?
  saida << operadores.pop
end
```

No final, tudo o que sobrou na pilha de operadores vai para a saida.

### Exemplo completo dessa conversao

Entrada:

```text
a + b * d - c
```

Tokens:

```text
[a, +, b, *, d, -, c]
```

Passo a passo:

1. Le `a`
   Vai para `saida`
   `saida = [a]`

2. Le `+`
   Vai para `operadores`
   `operadores = [+]`

3. Le `b`
   Vai para `saida`
   `saida = [a, b]`

4. Le `*`
   `*` tem prioridade maior que `+`
   Vai para `operadores`
   `operadores = [+, *]`

5. Le `d`
   Vai para `saida`
   `saida = [a, b, d]`

6. Le `-`
   Antes de colocar `-`, o programa tira operadores da pilha com prioridade maior ou igual
   Sai `*`
   `saida = [a, b, d, *]`
   Sai `+`
   `saida = [a, b, d, *, +]`
   Agora entra `-`
   `operadores = [-]`

7. Le `c`
   Vai para `saida`
   `saida = [a, b, d, *, +, c]`

8. Fim da leitura
   Tira o `-` da pilha
   `saida = [a, b, d, *, +, c, -]`

Resultado final em posfixa:

```text
a b d * + c -
```

## 5.3 Funcao `tres_enderecos`

Trecho:

```crystal
def tres_enderecos(expressao : String)
  partes = expressao.split(" = ")

  if partes.size != 2
    puts "Formato invalido. Use algo como: x = a + b * d - c"
    return
  end

  destino = partes[0].strip
  conta = partes[1].strip

  tokens = conta.gsub("(", " ( ").gsub(")", " ) ").split
  posfixa = infixa_para_posfixa(tokens)

  pilha = [] of String
  instrucoes = [] of String
  contador = 1

  posfixa.each do |token|
    if token.in?({"+", "-", "*", "/"})
      direita = pilha.pop
      esquerda = pilha.pop
      temporario = "t#{contador}"
      instrucoes << "#{temporario} = #{esquerda} #{token} #{direita}"
      pilha << temporario
      contador += 1
    else
      pilha << token
    end
  end

  puts "Expressao: #{expressao}"
  instrucoes.each { |instrucao| puts instrucao }
  puts "#{destino} = #{pilha.last}"
end
```

### O que ela faz

Essa e a funcao principal.

Ela:

1. recebe a expressao completa
2. separa o nome da variavel de destino
3. separa a conta
4. transforma a conta em posfixa
5. cria as instrucoes de 3 enderecos
6. mostra o resultado

### Passo a passo detalhado

#### Separacao da expressao

```crystal
partes = expressao.split(" = ")
```

Se a entrada for:

```text
x = a + b * d - c
```

entao `partes` sera:

```text
["x", "a + b * d - c"]
```

#### Verificacao de formato

```crystal
if partes.size != 2
  puts "Formato invalido. Use algo como: x = a + b * d - c"
  return
end
```

Se a expressao nao tiver exatamente um lado esquerdo e um lado direito, o programa avisa que o formato esta errado.

#### Separando destino e conta

```crystal
destino = partes[0].strip
conta = partes[1].strip
```

No exemplo:

- `destino = "x"`
- `conta = "a + b * d - c"`

#### Preparando os tokens

```crystal
tokens = conta.gsub("(", " ( ").gsub(")", " ) ").split
```

Aqui o programa coloca espacos ao redor dos parenteses para facilitar a divisao em tokens.

Exemplo:

```text
(a + b) * c
```

vira algo como:

```text
" ( a + b ) * c "
```

Depois o `split` separa em partes.

#### Conversao para posfixa

```crystal
posfixa = infixa_para_posfixa(tokens)
```

Agora a conta e reorganizada.

#### Criando estruturas auxiliares

```crystal
pilha = [] of String
instrucoes = [] of String
contador = 1
```

- `pilha`: guarda operandos e temporarios
- `instrucoes`: guarda as linhas finais
- `contador`: cria nomes como `t1`, `t2`, `t3`

#### Percorrendo a expressao posfixa

```crystal
posfixa.each do |token|
```

O programa olha cada token da expressao posfixa.

#### Quando encontra operador

```crystal
if token.in?({"+", "-", "*", "/"})
  direita = pilha.pop
  esquerda = pilha.pop
  temporario = "t#{contador}"
  instrucoes << "#{temporario} = #{esquerda} #{token} #{direita}"
  pilha << temporario
  contador += 1
```

Se o token for um operador:

1. tira da pilha o operando da direita
2. tira da pilha o operando da esquerda
3. cria um temporario
4. monta a instrucao
5. coloca o temporario de volta na pilha

Isso acontece porque o resultado da operacao pode ser usado numa operacao futura.

#### Quando encontra valor comum

```crystal
else
  pilha << token
end
```

Se for uma variavel ou numero, ele apenas entra na pilha.

#### Imprimindo o resultado

```crystal
puts "Expressao: #{expressao}"
instrucoes.each { |instrucao| puts instrucao }
puts "#{destino} = #{pilha.last}"
```

Primeiro mostra a expressao original.

Depois mostra cada instrucao temporaria.

Por fim, pega o ultimo valor da pilha e coloca no destino final.

## 6. Simulacao completa do exemplo

Entrada:

```text
x = a + b * d - c
```

### Etapa 1: separar destino e conta

- destino: `x`
- conta: `a + b * d - c`

### Etapa 2: transformar em posfixa

Resultado:

```text
a b d * + c -
```

### Etapa 3: gerar instrucoes

Lendo a posfixa:

1. token `a`
   coloca na pilha
   pilha = `[a]`

2. token `b`
   coloca na pilha
   pilha = `[a, b]`

3. token `d`
   coloca na pilha
   pilha = `[a, b, d]`

4. token `*`
   tira `d` e `b`
   cria:

```text
t1 = b * d
```

   coloca `t1` na pilha
   pilha = `[a, t1]`

5. token `+`
   tira `t1` e `a`
   cria:

```text
t2 = a + t1
```

   coloca `t2` na pilha
   pilha = `[t2]`

6. token `c`
   coloca na pilha
   pilha = `[t2, c]`

7. token `-`
   tira `c` e `t2`
   cria:

```text
t3 = t2 - c
```

   coloca `t3` na pilha
   pilha = `[t3]`

### Etapa 4: atribuicao final

Como sobrou `t3` na pilha, o resultado final sera:

```text
x = t3
```

## 7. Explicacao simples, estilo 5a serie

Imagine que voce quer resolver uma conta grande, mas prefere fazer em partes pequenas.

Em vez de fazer:

```text
x = a + b * d - c
```

tudo de uma vez, o computador faz assim:

```text
t1 = b * d
t2 = a + t1
t3 = t2 - c
x = t3
```

As letras `t1`, `t2`, `t3` sao como caixinhas temporarias.

E como montar um carrinho de brinquedo:

1. junta duas rodas
2. depois coloca no corpo
3. depois encaixa outra parte
4. no final, o carrinho fica pronto

O computador gosta disso porque fica mais facil de organizar.

## 8. O que esse codigo aceita

Ele funciona bem para expressoes simples com:

- variaveis
- numeros inteiros
- operadores `+`, `-`, `*`, `/`
- parenteses

Exemplos:

```text
x = a + b
y = a + b * c
z = (a + b) * c
k = a * b + c / d
```

## 9. Limitacoes atuais

Este codigo ainda e simples e didatico. Algumas limitacoes:

- espera espacos em torno do `=`, como em `x = a + b`
- nao trata operadores como `%`, `^`
- nao trata numeros decimais
- nao trata operadores unarios, como `-a`
- nao faz validacao profunda de expressoes malformadas

## 10. Como usar

No final do arquivo existe:

```crystal
tres_enderecos("x = a + b * d - c")
```

Voce pode trocar por outros exemplos:

```crystal
tres_enderecos("y = a * b + c")
tres_enderecos("z = ( a + b ) * c")
```

## 11. Resumo final

O programa:

1. le a expressao
2. separa destino e conta
3. organiza a conta em posfixa
4. cria temporarios
5. imprime as instrucoes de 3 enderecos

Ele e um exemplo simples de como compiladores podem transformar uma expressao matematica em passos menores e mais faceis de executar.

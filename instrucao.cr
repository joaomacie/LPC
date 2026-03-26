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

tres_enderecos("x = a + b * d - c")

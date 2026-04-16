PALAVRAS_RESERVADAS = %w[
  abstract alias as asm begin break case class def do else elsif end ensure enum extend false for fun if in include instance_sizeof is_a? lib macro module next nil of out pointerof private protected require rescue return select self sizeof struct super then true type typeof union unless until when while with yield
]

OPERADORES = ["+", "-", "*", "/", "=", "==", "!=", "<", ">", "<=", ">=", "&&", "||", "!", ".", ".."]
DELIMITADORES = ["(", ")", "[", "]", "{", "}", ",", ";", ":"]


def classificar_token(token : String) : String
  return "invalido: token vazio" if token.empty?

  return "palavra reservada" if PALAVRAS_RESERVADAS.includes?(token)
  return "numero inteiro" if token =~ /^\d+$/
  return "numero real" if token =~ /^\d+\.\d+$/
  return "string" if token =~ /^"(?:[^"\\]|\\.)*"$/
  return "operador" if OPERADORES.includes?(token)
  return "delimitador" if DELIMITADORES.includes?(token)

  case token
  when /\A@@[A-Za-z_][A-Za-z0-9_]*\z/
    "identificador de variavel de classe"
  when /\A@[A-Za-z_][A-Za-z0-9_]*\z/
    "identificador de variavel de instancia"
  when /\A\$[A-Za-z_][A-Za-z0-9_]*\z/
    "identificador de variavel global"
  when /\A[A-Z][A-Za-z0-9_]*\z/
    "identificador de constante"
  when /\A[a-z_][A-Za-z0-9_]*[!?]?\z/
    "identificador local ou nome de metodo"
  else
    "invalido"
  end
end


def tokenizar(entrada : String) : Array(String)
  tokens = [] of String
  current = ""
  i = 0

  while i < entrada.size
    char = entrada[i]

    if char =~ /\s/
      tokens << current unless current.empty?
      current = ""
      i += 1
      next
    end

    if char == '"'
      tokens << current unless current.empty?
      current = char.to_s
      i += 1

      while i < entrada.size
        current += entrada[i]
        break if entrada[i] == '"' && entrada[i - 1] != '\\'
        i += 1
      end

      tokens << current
      current = ""
      i += 1
      next
    end

    two_chars = entrada[i, 2]
    if ["==", "!=", "<=", ">=", "&&", "||", ".."].includes?(two_chars)
      tokens << current unless current.empty?
      tokens << two_chars
      current = ""
      i += 2
      next
    end

    if (OPERADORES + DELIMITADORES).any? { |op| op == char.to_s }
      tokens << current unless current.empty?
      tokens << char.to_s
      current = ""
      i += 1
      next
    end

    current += char
    i += 1
  end

  tokens << current unless current.empty?
  tokens.reject(&.empty?)
end


puts "Digite uma expressao :"
entrada = gets.to_s.strip

if entrada.empty?
  puts "Nenhuma entrada foi informada."
else
  tokens = tokenizar(entrada)
  tokens.each do |token|
    puts "#{token} -> #{classificar_token(token)}"
  end
end

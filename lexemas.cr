PALAVRAS_RESERVADAS = %w[
]

def classificar_identificador(lexema : String) : String
  return "invalido: lexema vazio" if lexema.empty?
  return "invalido: palavra reservada" if PALAVRAS_RESERVADAS.includes?(lexema)

  case lexema
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

puts "Classificador de lexemas da classe de identificadores em Crystal"
puts "Digite um ou mais lexemas separados por espaco:"
entrada = gets.to_s.strip

if entrada.empty?
  puts "Nenhum lexema foi informado."
else
  entrada.split.each do |lexema|
    puts "#{lexema} -> #{classificar_identificador(lexema)}"
  end
end

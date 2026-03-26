# Nocoes gerais de Crystal
#
# Para executar este arquivo:
# crystal run comado.cr

# Saida no terminal
puts "Ola Mundo"

# Variaveis
nome = "LPC"
idade = 20
altura = 1.75

puts "Nome: #{nome}"
puts "Idade: #{idade}"
puts "Altura: #{altura}"

# Constante
PI = 3.14
puts "PI: #{PI}"

# Entrada de dados
print "Digite seu curso: "
curso = gets
puts "Curso: #{curso}"

# Condicional
if idade >= 18
  puts "Maior de idade"
else
  puts "Menor de idade"
end

# Repeticao
3.times do |i|
  puts "Repeticao #{i + 1}"
end

# Array
numeros = [1, 2, 3, 4, 5]
puts "Primeiro numero: #{numeros[0]}"

# Metodo
def somar(a, b)
  a + b
end

puts "Soma: #{somar(5, 3)}"



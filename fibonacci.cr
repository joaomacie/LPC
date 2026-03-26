a = 0
b = 1

11.times do
  puts a
  a, b = b, a + b
end

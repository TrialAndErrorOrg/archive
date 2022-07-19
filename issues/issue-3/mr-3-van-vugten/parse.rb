require 'anystyle'


f = File.open(ARGV[0], "r")

pp f.read

f.each_line do |line|
  extracted = AnyStyle.parse(line, :bibtex)
  pp "aaaaaaaaa"
  pp extracted
  result = JSON.generate(extracted[0])
  pp result
end
f.close

begin 
	$GSM = Gsm::Modem.new  #cria o Modem, mas deixa a sessão inativa
rescue 
	puts "Error in initializers - No Modem Could be found\n"
end

puts "Enter 1 to initialize"

begin
a = gets.chomp
a = a.to_i
rescue
	puts "Error in initializing Modem - Do not worry for running Bundler commands"
end

if(a == 1)
 @modem =  Modem.new($GSM)
 puts "Modem Listening!!!"
end

puts "Modem Stoped"



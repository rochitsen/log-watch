#DESCRIPTION: Utility to watch logs and send email whenever an error as per pattern is printed in logs 

#Code for ocra to build exe without running the whole script and just loading the gems
if defined?(Ocra)
require 'file-tail'
require 'Pony'
require 'yaml'
require 'rubygems'
require 'bundler/setup'

Bundler.require
exit
end

#Loading of gems for exe execution
require 'file-tail'
require 'Pony'
require 'yaml'
require 'rubygems'
require 'bundler/setup'

Bundler.require

#Reading the yaml file 
begin
data = YAML.load_file('config.yml') 
@path = data["logfile"]
@servername = data["servername"]
@emailto = data["emailTo"]
@pattern = data["pattern"]

#Setting Pony options for sending email
Pony.options = { :from => 'email@email.com', :via => :smtp, :via_options => { 
			:address => '####.contosco.com', #smptp address of your organisations email server
			:port => '25',
			:enable_starttls_auto => true,
			:user_name => '#####', 
			:password => '#####',
			:authentication => :login, # :plain, :login, :cram_md5, no auth by default
			:domain => 'contosco.corp' #your organisations domain
			}}
			
begin
f = File.new(@path)
puts "Watching log file at - #{@path} on server - #{@servername}"
File.open(@path) do |log|
	log.extend(File::Tail)
	#log.backward
	log.tail do |line|
		f.gets #this will keep a count of the actual log line no. where error is printed and print in email body
		for i in 0..@pattern.length
			if line =~ @pattern[i]
				
				begin
					Pony.mail(:to => "#{@emailto}", :subject => 'Log alert'+" "+"[line no. - #{f.lineno}]"+" "+"[server - #{@servername}]", :body => line + "\n" + "\n" + "Please check log for full details")
				rescue Exception => e
					puts "#{e}"
				end
			end
		end
	end
end
rescue Exception => e
	puts "#{e}"
end
rescue Exception => e
	puts "#{e}"
end


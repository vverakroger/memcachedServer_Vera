require 'socket'        

class Client
   #Getters and Setters
   attr_accessor :client_hostname
   attr_accessor :client_name
   attr_accessor :client_password
   attr_accessor :client_port
   # Constructor Method
   def initialize(name, password)
      @client_hostname = 'localhost'
      @client_name = name
      @client_password = password
      @client_port = 1234
   end
end
#MAIN CLASS
if __FILE__ == $0
   #Autentication
   puts 'Enter User Name: '
   name = gets
   puts 'Enter Server Password: '
   password = gets
   client = Client.new(name, password)
   s = TCPSocket.open('localhost', 1234)           # Start connection
   s.puts ("#{name} #{password}".delete("\n"))     # Send the autentication to the server
   conn = true
   while conn
      moreLines = true
      command = gets
      commands = command.split
      case commands[0]
      when 'get','gets'
         s.puts command                            # Send the command to the server
      when 'set','add','replace','append','prepend','cas'
         value = gets
         s.puts command                            # Send the command to the server
         s.puts value                              # Send the value to the server
      when 'END'
         conn = false
      else     
         puts 'ERROR'
         moreLines = false
      end
      while moreLines do
         line = s.gets                             # Read lines from the socket
         if line.chop == 'FINISHED' then
            moreLines = false
         else
            puts line.chop                         # Print lines on console
         end
      end
   end
   s.close                                         # Close the socket when done
end
require 'socket'               

class Server 
   # Getters and Setters
   attr_accessor :serv_port
   attr_accessor :serv_data
   attr_accessor :serv_password
   # Constructor Method
   def initialize(port)
      @serv_port = port 
      @serv_data = []
      @serv_password = 'abc123'
   end
#RETRIEVAL COMMANDS
   # Reads a value from the server 
   #if the value does not exist return VALUE ''
   def get(aName,aKey)
      i = searchKey(aName,aKey)
      result = serv_data[i].values[0]
      if i != '' then
         return "VALUE #{result.values[0][0]} #{result.keys[0]} #{result.values[0][1]} #{result.values[0][2]} #{result.values[0][3]}"
      else
         return "VALUE"
      end
   end
   # Reads a list of values from the server
   #if a value does not exist return VALUE ''
   def gets(aName,aKeyArray)
      j = 1
      cont = 0
      result = []
      while j < aKeyArray.length do
         i = searchKey(aName,aKeyArray[j])
         if i != '' then
            subResult = serv_data[i].values[0]
            result[cont] = "VALUE #{subResult.values[0][0]} #{subResult.keys[0]} #{subResult.values[0][1]} #{subResult.values[0][2]} #{subResult.values[0][3]}"
         else
            result[cont] = "VALUE"
         end
         cont += 1
         j += 1
      end
      return result
   end
#STORAGE COMMANDS
   # Stores a new value to a new or existing key
   def set(aName,aDataArray,aValue,reply)
      i = searchKey(aName,aDataArray[1])
      if i != '' then
         updateKey(aName,aDataArray,aValue,i)
         returnStorage(reply,true)
      else
         insertKey(aName,aDataArray,aValue)
         returnStorage(reply,true)
      end
   end
   # Stores a new value only if the key does not exist
   def add(aName,aDataArray,aValue,reply)
      i = searchKey(aName,aDataArray[1])
      if i != '' then
         returnStorage(reply,false)
      else
         insertKey(aName,aDataArray,aValue)
         returnStorage(reply,true)
      end
   end
   # Stores a value only if the key exists 
   #replacing the preovious data
   def replace(aName,aDataArray,aValue,reply)
      i = searchKey(aName,aDataArray[1])
      if i != '' then
         updateKey(aName,aDataArray,aValue,i)
         returnStorage(reply,true)
      else
         returnStorage(reply,false)
      end
   end
   #  Stores a value after a piece of data
   def append(aName,aDataArray,aValue,reply)
      i = searchKey(aName,aDataArray[1])
      if i != '' then
         beforeValue = serv_data[i].values[0].values[0][0]
         nowValue = beforeValue + aValue.chop
         updateKey(aName,aDataArray,nowValue,i)
         returnStorage(reply,true)
      else
         returnStorage(reply,false)
      end
   end
   # Stores a piece of data before a piece of data
   def prepend(aName,aDataArray,aValue,reply)
      i = searchKey(aName,aDataArray[1])
      if i != '' then
         beforeValue = serv_data[i].values[0].values[0][0]
         nowValue = aValue.chop + beforeValue
         updateKey(aName,aDataArray,nowValue,i)
         returnStorage(reply,true)
      else
         returnStorage(reply,false)
      end
   end
   #
   def cas()
      #code
   end
# PRIVATES FUNCTIONS   
   # Searchs for an especific key and username
   #returns de key index of server_data
   #if empty returns ''
   private def searchKey(aName,aKey)
      i = 0
      result = ''
      while i < serv_data.length do
         if ((serv_data[i].keys[0] == aName) && (serv_data[i].values[0].keys[0] == aKey)) then
            result = i
            break
         else
            i += 1
         end
      end
      return result
   end
   # Inserts a new key
   private def insertKey(aName,aDataArray,aValue)
      hash1 = {aDataArray[1] => [aValue.chop,aDataArray[2],aDataArray[3],aDataArray[4]]}
      hash2 = {aName => hash1}
      serv_data.push(hash2)
   end
   # Updates a previous inserted key
   private def updateKey(aName,aDataArray,aValue,i)
      hash = {aDataArray[1] => [aValue.chop,aDataArray[2],aDataArray[3],aDataArray[4]]}
      serv_data[i].update(serv_data[i]) { |key, value| value = hash }
   end
   # If reply true returns STORED/NOT_STORED
   #else returns nothing
   private def returnStorage(reply,stored)
      if reply then
         if stored then
            return 'STORED'
         else
            return ' NOT_STORED'
         end
      end
   end
end
#MAIN CLASS
if __FILE__ == $0
   server = Server.new(1234)
   con = TCPServer.open(server.serv_port)                   # Socket to listen on port 
   puts "Listening ..."
   loop {                                                   # Servers run forever
      Thread.start(con.accept) do |client| 
         user = client.gets.split
         userName = user[0]
         userPass = user[1]
         if server.serv_password == userPass then
            while line = client.gets                        # Read lines from the client
               commands = line.split
               case commands[0]
               when 'get'
                  if commands.length == 2 then
                     client.puts server.get(userName,commands[1])
                     client.puts 'END'
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'gets'
                  result = server.gets(userName,commands)
                  puts result
                  if result.any? then
                     for i in 0..(result.length - 1)
                        client.puts result[i]
                     end
                     client.puts 'END'
                     client.puts 'FINISHED'
                  else
                     client.puts 'ERROR'
                     client.puts 'FINISHED'
                  end
                  
               when 'set'
                  value = client.gets 
                  reply = true
                  if commands.length == 6 then
                     reply = !(commands[5] == 'noreply')
                     server.set(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  elsif commands.length == 5 then
                     client.puts server.set(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'add'
                  value = client.gets 
                  reply = true
                  if commands.length == 6 then
                     reply = !(commands[5] == 'noreply')
                     server.add(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  elsif commands.length == 5 then
                     client.puts server.add(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'replace'
                  value = client.gets 
                  reply = true
                  if commands.length == 6 then
                     reply = !(commands[5] == 'noreply')
                     server.replace(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  elsif commands.length == 5 then
                     client.puts server.replace(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'append'
                  value = client.gets 
                  reply = true
                  if commands.length == 6 then
                     reply = !(commands[5] == 'noreply')
                     server.append(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  elsif commands.length == 5 then
                     client.puts server.append(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'prepend'
                  value = client.gets 
                  reply = true
                  if commands.length == 6 then
                     reply = !(commands[5] == 'noreply')
                     server.prepend(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  elsif commands.length == 5 then
                     client.puts server.prepend(userName,commands,value,reply)
                     client.puts 'FINISHED'
                  else 
                     client.puts 'CLIENT_ERROR'
                  end
               when 'cas'
                  client.puts 'cas'
               else
                  client.puts 'CLIENT_ERROR'
               end
            end
            client.puts "Closing the connection. Bye!"
            client.close                                    #Disconnect from the client
         else
            client.puts "User o password incorrect! Closing the connection."
            client.close                                    #Disconnect from the client
         end
      end
   }
end
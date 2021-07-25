if __FILE__ == $0
    value = gets
    values = value.split
    case values[0]
    when 'get','got'
        puts 'g'    
    when 'set' 
        puts 's'                   
    else
        puts 'error'
    end
end
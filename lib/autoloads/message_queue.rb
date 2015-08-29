require 'socket'
require 'json'
class MessageQueue

  def initialize()
    @methods_test = MessageProcessor.setup_positive_methods[1..5]
    @params = MessageProcessor.setup_params
    @methods = MessageProcessor.setup_positive_methods
  end

  public

  def process_redis_messages
    #$redis.rpush("commands", command)
    loop {
      begin
        command = $redis.rpop("commands")
        if command == nil
          break
        end
        puts "command: #{command}"
        #parse 
        command = JSON.parse(command, symbolize_names: true)
        device = command[:device].to_s
        command_id = command[:command_id].to_i
        params = eval(command[:params])  #hash
        puts params
        method_obj = @methods[command_id]
        next if method_obj == nil 

        puts "#{device} call #{method_obj}"
        method_obj.call(device, params)
      rescue Exception => e
        puts e.message
      end
    }
  end

  def process_test_messages(device = nil)
    sock, device = $socket_device.first
    if sock
      @methods_test.each_with_index do | method_obj, index|
        puts "#{device} call #{method_obj}"
        sleep(2.0)
        method_obj.call(device, @params[index])
      end
    else
      puts "not found valid sock or empty message queue"
    end
  end

  def process_test_messages_sock(sock)
    if sock
      @methods_test.each_with_index do | method_obj, index|
        puts "call #{method_obj}"
        sleep(2.0)
        if !sock
          puts "socket exit unexpectedlly"
          break
        end
        #method_obj.call(device, @params[index])
      end
    else
      puts "not valid sock"
    end
  end  
  
end
require 'socket'

class MessageQueue

  def initialize()
    @methods = MessageProcessor.setup_positive_methods
    @params = MessageProcessor.setup_params
  end

  public

  def process_test_messages(device = nil)
    sock, device = $socket_device.first
    if sock
      @methods.each_with_index do | method_obj, index|
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
      @methods.each_with_index do | method_obj, index|
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
class ResqueTestSendMessage
  @queue = :resque_socket # Woeker起動時に指定するQUEUE名

  def self.perform()
    puts  $redis.get("id")
    methods = MessageProcessor.setup_positive_methods
    params = MessageProcessor.setup_params
    sock, device = $socket_device.first
    methods.each_with_index do | method_obj, index|
      puts "call #{method_obj}"
      sleep(2.0)
      method_obj.call(device, params[index])
    end
  end
end


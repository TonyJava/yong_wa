class ResqueSocket
  @queue = :resque_socket # Woeker起動時に指定するQUEUE名

  def self.perform()
    logger = Logger.new(File.join(Rails.root, 'log', 'resque_socket.log'))
    logger.info "start"
    myChatServer = ChatServer.new( 2626 )
    myChatServer.run(logger)
  end

  def self.is_port_open?
    begin
      Timeout::timeout(10) do
        begin
          s = TCPServer.new("", 2626)
          s.close
          return true
        rescue Errno::EADDRINUSE
          return false
        end
    end
    rescue Timeout::Error
    end
    return false
  end

end
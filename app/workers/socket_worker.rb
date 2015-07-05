class SocketWorker
  include Sidekiq::Worker
  #include Sidekiq::Status::Worker # Important!
  sidekiq_options queue: :socket

  def perform
    myChatServer = ChatServer.new( 2626 )
    myChatServer.run
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

  # def self.delete
  #   queue = Sidekiq::Queue.new("Socket")
  #   queue.each do |job|
  #     job.delete
  #   end
  # end

  # def cancelled?
  #   Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  # end

  # def self.cancel!(jid)
  #   Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  # end
    
end
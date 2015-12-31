require "socket"
require "logger"
#load "message_processor.rb"

class ChatServer

  def initialize( port )
    @descriptors = Array.new
    @serverSocket = TCPServer.new( port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("Chatserver started on port %d\n", port)
    @descriptors.push( @serverSocket )

    @message_queue =  MessageQueue.new

  end # initialize


  def run(logger)
    loop { 
      res = select(@descriptors, nil, nil, 5)
      if res != nil
        begin

          for sock in res[0]
            if sock == @serverSocket
              new_sock = @serverSocket.accept
              str = sprintf("Client in %s:%s\n", new_sock.peeraddr[2], new_sock.peeraddr[1])
              puts str
              @descriptors.push(new_sock)
              #new_sock.puts("connected")
              @client = new_sock
            else
              if sock.eof?
                str = sprintf("Client left %s:%s\n", sock.peeraddr[2], sock.peeraddr[1])
                puts(str)
                sock.close
                @descriptors.delete(sock)

                $socket_device.delete(sock)
              else
                str = sock.gets("\r\n").chomp("\r\n")
                puts(str)
                logger.info(str)
                MessageProcessor.in_command(sock, str)

                #echo
                #sock.puts("received: #{str}")
              end
            end
          end

        rescue Exception => e
          puts "exception! : #{e.inspect}"
          if sock != @serverSocket
            sock.close
            @descriptors.delete(sock)
            $socket_device.delete(sock)
          end
        end
      else
        #puts "processing queues..."
        @message_queue.process_redis_messages
      end
     }
  end

  # def run_dep(logger)
  #   loop {
  #     res = select( @descriptors, nil, nil, 3 )
  #     #puts("wait")
  #     puts $socket_device.first
  #     if res != nil then
  #   # Iterate through the tagged read descriptors
  #       for sock in res[0]
  #   # Received a connect to the server (listening) socket
  #         if sock == @serverSocket then
  #           accept_new_connection(logger)
  #         else
  #         # Received something on a client socket
  #           if sock.eof? then
  #             str = sprintf("Client left %s:%s\n",
  #             sock.peeraddr[2], sock.peeraddr[1])
  #           #broadcast_string( str, sock )
  #             logger.info(str)
  #             print(str)
  #             sock.close
  #             @descriptors.delete(sock)
  #             $socket_device.delete(sock)
  #           else
  #             #receive info
              
  #               str = sock.gets()
  #             #binding.pry
  #               print(str)
  #               logger.info(str)
  #             #sock.write(str)

  #               #tt = MessageProcessor.test
  #               #sock.write(MessageProcessor.test)
  #               MessageProcessor.in_command(sock, str)

  #               #sock.write("received")
  #               #str = sprintf("[%s|%s]: %s",sock.peeraddr[2], sock.peeraddr[1], sock.gets())
  #               #broadcast_string( str, sock )
                
  #               # send_message_by_received_string(str, sock)
  #           end

  #         end
  #       end

  #     else
  #       @message_queue.process_test_messages

  #     end

  #   end #while
  # end #run

  private

  def send_message_by_received_string(str, target_sock)
    if str == "SG*8800000015*0002*LK"
      target_sock.write("SG*8800000015*0002*LK")
    end
    target_sock.write "SG*8800000015*0002*LK\n"
  end

  def broadcast_string( str, omit_sock )
    @descriptors.each do |clisock|
      if clisock != @serverSocket && clisock != omit_sock
        clisock.write(str)
      end
    end
    print(str)
  end # broadcast_string
  
  def accept_new_connection(logger)
    newsock = @serverSocket.accept
    @descriptors.push( newsock )
    newsock.write("You're connected to the Yongwa Server\n")
    str = sprintf("Client joined %s:%s\n",
    newsock.peeraddr[2], newsock.peeraddr[1])

    #newsock.write(str)
    logger.info(str)
    #broadcast_string( str, newsock )
    #print(User.all.first.id)
    #print MessageProcessor.in_command("SG*8800000015*0002*LK")
  end # accept_new_connection
end #server

 # logger = Logger.new('resque_socket_test.log')
 # logger.info "start"
 # myChatServer = ChatServer.new( 2628 )
 # myChatServer.run(logger)

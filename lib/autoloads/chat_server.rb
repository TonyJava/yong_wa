require "socket"
class ChatServer

  def initialize( port )
    @descriptors = Array::new
    @serverSocket = TCPServer.new( "", port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("Chatserver started on port %d\n", port)
    @descriptors.push( @serverSocket )  
  end # initialize
  def run(logger)
    while 1
    res = select( @descriptors, nil, nil, nil )
    if res != nil then
    # Iterate through the tagged read descriptors
    for sock in res[0]
    # Received a connect to the server (listening) socket
    if sock == @serverSocket then
      accept_new_connection(logger)
    else
    # Received something on a client socket
    if sock.eof? then
      str = sprintf("Client left %s:%s\n",
      sock.peeraddr[2], sock.peeraddr[1])
      #broadcast_string( str, sock )
      logger.info(str)
      print(str)
      sock.close
      @descriptors.delete(sock)
    else
      #receive info
      #binding.pry
      str = sock.gets()
      print(str)
      logger.info(str)
      #sock.write("received")
      #str = sprintf("[%s|%s]: %s",sock.peeraddr[2], sock.peeraddr[1], sock.gets())
      #broadcast_string( str, sock )
      sock.write(str)
      # send_message_by_received_string(str, sock)
    end

    end
    end
    end
    end
  end #run

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
    newsock.write("You're connected to the Ruby chatserver\n")
    str = sprintf("Client joined %s:%s\n",
    newsock.peeraddr[2], newsock.peeraddr[1])

    newsock.write(str)
    logger.info(str)
    #broadcast_string( str, newsock )
    #print(User.all.first.id)
    #print MessageProcessor.in_command("SG*8800000015*0002*LK")
  end # accept_new_connection
end #server
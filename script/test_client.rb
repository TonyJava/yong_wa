#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end
 
  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets
        puts "#{msg}"
      }
    end
  end
 
  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets
        @server.puts( msg )
      }
    end
  end
end

s = TCPSocket.open( "localhost", 2626 )
#Client.new( server )
s.send("SG*8800000015*0002*LK", 0)
s.close
#==============================================================================#
#                         Online System — WebSocket Client                     #
#==============================================================================#

require 'socket'
require 'openssl'

module WSClient
  WS_HOST = "pokemon-websocket-server.onrender.com"
  WS_PORT = 443
  WS_PATH = "/ws"
  WS_KEY  = "dGhlIHNhbXBsZSBub25jZQ=="

  @ssl         = nil
  @connected   = false
  @read_buffer = ""
  @send_queue  = []
  @messages    = []

  def self.connected?
    @connected && @ssl && !@ssl.closed? rescue false
  end

  #=============================================================================
  # Connect + WebSocket handshake
  #=============================================================================
  def self.connect
    return if connected?
    begin
      tcp          = TCPSocket.new(WS_HOST, WS_PORT)
      ctx          = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ssl          = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
      ssl.hostname = WS_HOST
      ssl.connect

      handshake  = "GET #{WS_PATH} HTTP/1.1\r\n"
      handshake += "Host: #{WS_HOST}\r\n"
      handshake += "Upgrade: websocket\r\n"
      handshake += "Connection: Upgrade\r\n"
      handshake += "Sec-WebSocket-Key: #{WS_KEY}\r\n"
      handshake += "Sec-WebSocket-Version: 13\r\n"
      handshake += "\r\n"
      ssl.write(handshake)

      response = ""
      loop do
        line      = ssl.gets
        response += line.to_s
        break if line.nil? || line.strip.empty?
      end

      unless response.include?("101")
        puts "[WS] Handshake failed"
        ssl.close rescue nil
        return
      end

      @ssl         = ssl
      @connected   = true
      @read_buffer = ""
      @messages    = []
      puts "[WS] Connected"

    rescue => e
      puts "[WS] Connect failed: #{e.message}"
      @connected = false
      @ssl       = nil
    end
  end

  def self.disconnect
    @ssl.close rescue nil
    @ssl       = nil
    @connected = false
    puts "[WS] Disconnected"
  end

  #=============================================================================
  # Send a JSON hash as a WebSocket text frame
  #=============================================================================
  def self.send_json(hash)
    return unless connected?
    begin
      payload = Online.build_json(hash)
      @ssl.write(encode_frame(payload))
    rescue => e
      puts "[WS] Send error: #{e.message}"
      @connected = false
    end
  end

  #=============================================================================
  # Non-blocking poll — read available data and parse frames
  # Returns array of parsed message hashes
  #=============================================================================
  def self.poll
    return [] unless connected?
    begin
      # Use exception: false so no exception is raised when no data available
      chunk = @ssl.read_nonblock(8192, exception: false)
      if chunk && chunk != :wait_readable && chunk != :wait_writable
        @read_buffer += chunk
      end
    rescue => e
      # Silently ignore any other errors
    end

    parse_frames
  end

  private

  def self.parse_frames
    messages = []
    while @read_buffer.length >= 2
      b0          = @read_buffer[0].ord
      b1          = @read_buffer[1].ord
      opcode      = b0 & 0x0F
      payload_len = b1 & 0x7F
      header_size = 2

      if payload_len == 126
        break if @read_buffer.length < 4
        payload_len = (@read_buffer[2].ord << 8) | @read_buffer[3].ord
        header_size = 4
      elsif payload_len == 127
        break if @read_buffer.length < 10
        payload_len = 0
        8.times { |i| payload_len = (payload_len << 8) | @read_buffer[2 + i].ord }
        header_size = 10
      end

      total = header_size + payload_len
      break if @read_buffer.length < total

      payload      = @read_buffer[header_size, payload_len]
      @read_buffer = @read_buffer[total..]

      next if opcode == 0x8  # close
      next if opcode == 0x9  # ping
      next if opcode == 0xA  # pong

      if opcode == 0x1  # text
        begin
          # Quick parse — extract action and key fields
          msg = quick_parse(payload)
          messages << msg if msg
        rescue
        end
      end
    end
    messages
  end

  def self.extract_field(str, key)
    # Match "key": "value" or "key": value
    str[/"#{Regexp.escape(key)}"\s*:\s*"([^"]*)"/, 1] ||
    str[/"#{Regexp.escape(key)}"\s*:\s*([0-9\.\-]+)/, 1]
  end

  def self.quick_parse(str)
    action = extract_field(str, "action")
    return nil unless action
    {
      "action"       => action,
      "trainer_id"   => extract_field(str, "trainer_id"),
      "trainer_name" => extract_field(str, "trainer_name"),
      "session_code" => extract_field(str, "session_code"),
      "map_id"       => extract_field(str, "map_id"),
      "x"            => extract_field(str, "x"),
      "y"            => extract_field(str, "y"),
      "real_x"       => extract_field(str, "real_x"),
      "real_y"       => extract_field(str, "real_y"),
      "direction"    => extract_field(str, "direction"),
      "pattern"      => extract_field(str, "pattern"),
      "move_speed"   => extract_field(str, "move_speed"),
      "opacity"      => extract_field(str, "opacity"),
      "character"    => extract_field(str, "character")
    }
  end

  def self.encode_frame(payload)
    bytes   = payload.bytes.to_a
    len     = bytes.length
    mask    = [rand(256), rand(256), rand(256), rand(256)]
    masked  = bytes.each_with_index.map { |b, i| b ^ mask[i % 4] }
    frame   = [0x81]
    if len < 126
      frame << (len | 0x80)
    elsif len < 65536
      frame << (126 | 0x80)
      frame << ((len >> 8) & 0xFF)
      frame << (len & 0xFF)
    else
      frame << (127 | 0x80)
      8.times { |i| frame << ((len >> (56 - i * 8)) & 0xFF) }
    end
    frame.concat(mask)
    frame.concat(masked)
    frame.pack("C*")
  end

  public

end

#==============================================================================#
# Online module WebSocket helpers
#==============================================================================#
module Online
  def self.ws_connect(session_code, trainer_id)
    WSClient.connect
    return unless WSClient.connected?
    WSClient.send_json({
      "action"       => "join",
      "session_code" => session_code,
      "trainer_id"   => trainer_id.to_s
    })
    puts "[WS] Joined session #{session_code}"
  end

  def self.ws_send_position(data)
    return unless WSClient.connected?
    data["action"] = "position"
    WSClient.send_json(data)
  end

  # Send a movement input — direction the player just moved
  def self.ws_send_input(direction, map_id, x, y, session_code, trainer_id, character)
    return unless WSClient.connected?
    WSClient.send_json({
      "action"       => "input",
      "trainer_id"   => trainer_id.to_s,
      "session_code" => session_code,
      "map_id"       => map_id.to_s,
      "input_dir"    => direction.to_s,
      "x"            => x.to_s,
      "y"            => y.to_s,
      "character"    => character
    })
  end

  def self.ws_poll
    WSClient.poll
  end

  # Send full player state packet
  def self.ws_send_state(data)
    return unless WSClient.connected?
    data["action"] = "state"
    WSClient.send_json(data)
  end

  def self.ws_disconnect
    WSClient.disconnect
  end
end
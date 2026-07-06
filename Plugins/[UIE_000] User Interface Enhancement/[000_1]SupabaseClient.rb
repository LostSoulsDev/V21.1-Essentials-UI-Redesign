#==============================================================================#
#                     Online System — Direct Supabase Client                   #
#==============================================================================#
# Replaces the file-based listener for all Supabase HTTP requests.            #
# Uses Ruby's TCPSocket + OpenSSL directly — no listener.exe needed.          #
#==============================================================================#

require 'socket'
require 'openssl'

module SupabaseClient
  HOST    = "kbnvdjbhisuxcuycfpcn.supabase.co"
  PORT    = 443
  API_KEY = "sb_publishable_qECyTiCz7we__ubHzks0og_QRp41vRd"

  def self.request(method, path, body: nil, params: nil)
    # Build query string
    query = ""
    if params && !params.empty?
      query = "?" + params.map { |k, v| "#{k}=#{v}" }.join("&")
    end

    # Build JSON body
    json_body = body ? Online.build_json(body) : nil

    # Build HTTP request
    req  = "#{method} /rest/v1/#{path}#{query} HTTP/1.1\r\n"
    req += "Host: #{HOST}\r\n"
    req += "apikey: #{API_KEY}\r\n"
    req += "Authorization: Bearer #{API_KEY}\r\n"
    req += "Content-Type: application/json\r\n"
    req += "Accept: application/json\r\n"
    req += "Connection: close\r\n"
    if json_body
      req += "Content-Length: #{json_body.bytesize}\r\n"
    end
    req += "\r\n"
    req += json_body if json_body

    # Make SSL connection
    tcp = TCPSocket.new(HOST, PORT)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ssl = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
    ssl.hostname = HOST
    ssl.connect

    ssl.write(req)
    puts "[Supabase] Request sent: #{method} #{path}"

    # Read headers line by line — avoids sysread EOFError
    headers = {}
    status  = 0
    begin
      status_line = ssl.gets
      status = status_line.to_s[/HTTP\/1\.\d (\d+)/, 1].to_i
      loop do
        line = ssl.gets
        break if line.nil? || line.strip.empty?
        key, val = line.split(": ", 2)
        headers[key.to_s.downcase.strip] = val.to_s.strip
      end
    rescue => e
      puts "[Supabase] Header read error: #{e.message}"
    end

    puts "[Supabase] Status: #{status} Headers: #{headers.inspect}"
    # Read body using Content-Length if available
    body_raw = ""
    begin
      if headers["content-length"]
        puts "[Supabase] Reading #{headers["content-length"]} bytes"
        body_raw = ssl.read(headers["content-length"].to_i) rescue ""
      elsif headers["transfer-encoding"] == "chunked"
        # Read chunked response
        loop do
          chunk_size_line = ssl.gets.to_s.strip
          chunk_size = chunk_size_line.to_i(16)
          break if chunk_size == 0
          body_raw += ssl.read(chunk_size) rescue ""
          ssl.gets  # read trailing CRLF
        end
      end
    rescue => e
      puts "[Supabase] Body read error: #{e.message}"
    ensure
      ssl.close rescue nil
      tcp.close rescue nil
    end

    { "status" => status, "body" => body_raw }

  rescue => e
    puts "[Supabase] Request error: #{e.message}"
    nil
  end

  def self.get(path, params: nil)
    request("GET", path, params: params)
  end

  def self.post(path, body: nil)
    request("POST", path, body: body)
  end

  def self.patch(path, body: nil, params: nil)
    request("PATCH", path, body: body, params: params)
  end

  def self.delete(path, params: nil)
    request("DELETE", path, params: params)
  end

  def self.upsert(path, body: nil, match_key: "trainer_id")
    # Check if row exists first
    check = get(path, params: { match_key => "eq.#{body[match_key]}" })
    if check && check["status"] == 200 && check["body"] && !check["body"].strip.empty? && check["body"] != "[]"
      patch(path, body: body, params: { match_key => "eq.#{body[match_key]}" })
    else
      post(path, body: body)
    end
  end
end

#==============================================================================#
# Replace Online module methods to use SupabaseClient directly
#==============================================================================#
module Online
  # Override request to use SupabaseClient instead of listener files
  def self.request(method, endpoint, body: nil, params: nil)
    $online_blocking = true
    result = case method
             when "GET"    then SupabaseClient.get(endpoint, params: params)
             when "POST"   then SupabaseClient.post(endpoint, body: body)
             when "PATCH"  then SupabaseClient.patch(endpoint, body: body, params: params)
             when "DELETE" then SupabaseClient.delete(endpoint, params: params)
             when "UPSERT" then SupabaseClient.upsert(endpoint, body: body)
             when "UPSERT_POSITION"
               SupabaseClient.upsert(endpoint, body: body,
                 match_key: "trainer_id")
             end
    result ? result["body"] : nil
  ensure
    $online_blocking = false
  end
end
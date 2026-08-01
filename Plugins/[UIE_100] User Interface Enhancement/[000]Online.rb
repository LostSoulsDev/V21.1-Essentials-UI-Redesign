#==============================================================================#
#                         Online System — Listener Bridge                      #
#==============================================================================#

module Online
  REQUEST_FILE        = "listener_request.json"
  RESPONSE_FILE       = "listener_response.json"
  ASYNC_REQUEST_FILE  = "listener_async_request.json"   # position sync — no response
  ASYNC_RESPONSE_FILE = "listener_async_response.json"  # unused
  FETCH_REQUEST_FILE  = "listener_fetch_request.json"   # position fetch request
  FETCH_RESPONSE_FILE = "listener_fetch_response.json"  # position fetch response
  LOCK_FILE     = "listener.lock"
  TIMEOUT       = 5  # seconds before giving up

  #=============================================================================
  # Listener management
  #=============================================================================



  #=============================================================================
  # JSON builder — converts Ruby hash/array to JSON string
  #=============================================================================

  def self.build_json(obj)
    case obj
    when Hash
      pairs = obj.map { |k, v| "#{build_json(k.to_s)}: #{build_json(v)}" }
      "{" + pairs.join(", ") + "}"
    when Array
      "[" + obj.map { |v| build_json(v) }.join(", ") + "]"
    when String
      '"' + obj.gsub('\\', '\\\\').gsub('"', '\\"') + '"'
    when NilClass  then "null"
    when TrueClass  then "true"
    when FalseClass then "false"
    else obj.to_s
    end
  end

  #=============================================================================
  # Core request — writes request file, waits for response file
  #=============================================================================

  def self.request(method, endpoint, body: nil, params: nil)
    payload = build_json({
      "method"   => method,
      "endpoint" => endpoint,
      "body"     => body,
      "params"   => params
    })

    File.open(REQUEST_FILE, "w") { |f| f.write(payload) }

    waited = 0
    until File.exist?(RESPONSE_FILE) || waited >= TIMEOUT * 20
      Graphics.update
      waited += 1
      sleep(0.05)
    end

    return nil unless File.exist?(RESPONSE_FILE)

    raw = File.read(RESPONSE_FILE)
    File.delete(RESPONSE_FILE)
    raw  # return raw string — callers parse what they need
  end

  # Pull status code out of raw response string
  def self.status_of(raw)
    raw.to_s[/"status":\s*(\d+)/, 1].to_i
  end

  #=============================================================================
  # Convenience request methods
  #=============================================================================

  def self.get(endpoint, params: nil)
    request("GET", endpoint, params: params)
  end

  def self.post(endpoint, body: {})
    request("POST", endpoint, body: body)
  end

  def self.patch(endpoint, body: {}, params: nil)
    request("PATCH", endpoint, body: body, params: params)
  end

  def self.delete(endpoint, params: nil)
    request("DELETE", endpoint, params: params)
  end

  def self.upsert(endpoint, body: {})
    request("UPSERT", endpoint, body: body)
  end

  # Fire and forget — write request but don't wait for response
  def self.request_async(method, endpoint, body: nil, params: nil)
    payload = build_json({
      "method"   => method,
      "endpoint" => endpoint,
      "body"     => body,
      "params"   => params
    })
    File.open(ASYNC_REQUEST_FILE, "w") { |f| f.write(payload) }
  end

  # Send an async fetch request
  def self.request_fetch(endpoint, params: nil)
    payload = build_json({
      "method"   => "GET",
      "endpoint" => endpoint,
      "body"     => nil,
      "params"   => params
    })
    File.open(FETCH_REQUEST_FILE, "w") { |f| f.write(payload) }
  end

  # Read the latest fetch response if one exists
  def self.read_fetch_response
    return nil unless File.exist?(FETCH_RESPONSE_FILE)
    raw = File.read(FETCH_RESPONSE_FILE)
    File.delete(FETCH_RESPONSE_FILE)
    raw
  end

  #=============================================================================
  # Trainer presence
  #=============================================================================

  def self.ping
    return unless $player
    upsert("trainers", body: {
      "trainer_name" => $player.name,
      "trainer_id"   => $player.id,
      "secret_id"    => $player.id,
      "last_seen"    => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    })
  end

  def self.online_trainers
    cutoff = (Time.now.utc - 300).strftime("%Y-%m-%dT%H:%M:%SZ")
    raw = get("trainers", params: { "last_seen" => "gte.#{cutoff}" })
    extract_array(raw, ["trainer_name", "trainer_id", "last_seen"])
  end

  #=============================================================================
  # Messaging
  #=============================================================================

  def self.send_message(recipient_id, recipient_name, message)
    return unless $player
    post("messages", body: {
      "sender_id"      => $player.id,
      "sender_name"    => $player.name,
      "recipient_id"   => recipient_id,
      "recipient_name" => recipient_name,
      "message"        => message,
      "read"           => false
    })
  end

  def self.fetch_messages
    return [] unless $player
    raw = get("messages", params: {
      "recipient_id" => "eq.#{$player.id}",
      "order"        => "created_at.asc"
    })
    extract_array(raw, ["id", "sender_id", "sender_name", "recipient_id", "recipient_name", "message", "read", "created_at"])
  end

  # Fetch messages this player sent
  def self.fetch_sent_messages
    return [] unless $player
    raw = get("messages", params: {
      "sender_id" => "eq.#{$player.id}",
      "order"     => "created_at.asc"
    })
    extract_array(raw, ["id", "sender_id", "sender_name", "recipient_id", "recipient_name", "message", "read", "created_at"])
  end

  # Returns a hash of {other_trainer_name => [messages in order]}
  # Each message has a "mine" key indicating if the player sent it
  def self.fetch_conversations
    received = fetch_messages
    sent     = fetch_sent_messages
    convos   = {}

    received.each do |msg|
      other = msg["sender_name"]
      convos[other] ||= { "other_id" => msg["sender_id"], "messages" => [] }
      convos[other]["messages"] << msg.merge("mine" => "false")
    end

    sent.each do |msg|
      other = msg["recipient_name"]
      convos[other] ||= { "other_id" => msg["recipient_id"], "messages" => [] }
      convos[other]["messages"] << msg.merge("mine" => "true")
    end

    # Sort each conversation by created_at
    convos.each do |_, convo|
      convo["messages"].sort_by! { |m| m["created_at"].to_s }
    end

    convos
  end

  def self.mark_read(message_id)
    patch("messages", body: { "read" => true }, params: {
      "id" => "eq.#{message_id}"
    })
  end

  #=============================================================================
  # Trade listings
  #=============================================================================

  def self.post_listing(pokemon, wants_species, wants_level_min: 1, wants_level_max: 100)
    return unless $player
    post("listings", body: {
      "trainer_id"      => $player.id,
      "trainer_name"    => $player.name,
      "pokemon_data"    => pokemon_to_hash(pokemon),
      "wants_species"   => wants_species,
      "wants_level_min" => wants_level_min,
      "wants_level_max" => wants_level_max,
      "status"          => "open"
    })
  end

  def self.fetch_listings(wants_species: nil)
    params = { "status" => "eq.open" }
    params["wants_species"] = "eq.#{wants_species}" if wants_species
    raw = get("listings", params: params)
    extract_array(raw, ["id", "trainer_name", "pokemon_data", "wants_species",
                        "wants_level_min", "wants_level_max", "created_at"])
  end

  def self.cancel_listing(listing_id)
    patch("listings", body: { "status" => "cancelled" }, params: {
      "id" => "eq.#{listing_id}"
    })
  end

  #=============================================================================
  # Trades
  #=============================================================================

  def self.request_trade(trainer_b_id, trainer_b_name)
    return unless $player
    post("trades", body: {
      "trainer_a_id"   => $player.id,
      "trainer_a_name" => $player.name,
      "trainer_b_id"   => trainer_b_id,
      "trainer_b_name" => trainer_b_name,
      "status"         => "pending"
    })
  end

  def self.fetch_pending_trades
    return [] unless $player
    raw = get("trades", params: {
      "trainer_b_id" => "eq.#{$player.id}",
      "status"       => "eq.pending"
    })
    extract_array(raw, ["id", "trainer_a_name", "pokemon_a", "status", "created_at"])
  end

  def self.accept_trade(trade_id, pokemon)
    patch("trades", body: {
      "pokemon_b"  => pokemon_to_hash(pokemon),
      "status"     => "accepted",
      "updated_at" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    }, params: { "id" => "eq.#{trade_id}" })
  end

  def self.complete_trade(trade_id, pokemon)
    patch("trades", body: {
      "pokemon_a"  => pokemon_to_hash(pokemon),
      "status"     => "complete",
      "updated_at" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    }, params: { "id" => "eq.#{trade_id}" })
  end

  #=============================================================================
  # Simple field extractor — pulls named fields from a JSON array string
  # Returns array of hashes e.g. [{"sender_name"=>"A", "message"=>"Hi"}]
  #=============================================================================

  def self.extract_array(raw, fields)
    return [] unless raw
    results = []
    # Split on object boundaries
    raw.scan(/\{[^{}]*\}/).each do |obj|
      hash = {}
      fields.each do |field|
        # Match "field": "string value" or "field": number or "field": boolean
        val = obj[/"#{field}":\s*"([^"]*)"/, 1]       # string
        val ||= obj[/"#{field}":\s*([\d.]+)/, 1]       # number
        val ||= obj[/"#{field}":\s*(true|false|null)/, 1] # bool/null
        hash[field] = val
      end
      results << hash unless hash.values.all?(&:nil?)
    end
    results
  end

  #=============================================================================
  # Pokemon serialisation
  #=============================================================================

  def self.pokemon_to_hash(pkmn)
    {
      "species"   => pkmn.species.to_s,
      "level"     => pkmn.level,
      "name"      => pkmn.name,
      "gender"    => pkmn.gender,
      "shiny"     => pkmn.shiny?,
      "ability"   => pkmn.ability.to_s,
      "nature"    => pkmn.nature.to_s,
      "held_item" => pkmn.item.to_s,
      "moves"     => pkmn.moves.map { |m| m&.id.to_s }
    }
  end
end

#==============================================================================#
# Ping presence on map load and every 5 minutes — no listener needed
#==============================================================================#
class Scene_Map
  alias online_main main
  def main
    Online.ping
    online_main
  end
end

class Game_Player
  alias online_update update
  def update
    online_update
    return unless $player
    @online_ping_timer ||= 1
    @online_ping_timer += 1
    if @online_ping_timer >= 18000
      Online.ping
      @online_ping_timer = 1
    end
  end
end
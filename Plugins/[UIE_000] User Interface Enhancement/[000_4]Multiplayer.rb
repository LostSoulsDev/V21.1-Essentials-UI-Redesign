#==============================================================================#
#                       Online System — Overworld Multiplayer                  #
#==============================================================================#
# Based on VMS plugin architecture — Player class stores state, Rf events     #
# are driven by direct property assignment each frame.                        #
#==============================================================================#

module Online
  #=============================================================================
  # Session management
  #=============================================================================
  def self.current_session
    @current_session
  end

  def self.in_session?
    !@current_session.nil?
  end

  def self.hosting_session?
    @is_session_host == true
  end

  #=============================================================================
  # Opt-in toggle — every single online feature (session browsing/hosting,
  # trades, battles, messaging, presence/online-count) is gated behind this.
  # Off by default; nothing online-related runs at all until a player
  # explicitly enables it from the Settings menu.
  #=============================================================================
  def self.features_enabled?
    return false unless $game_system
    $game_system.online_features_enabled == true
  end

  # Call this from the Settings menu when the player toggles the option ON.
  def self.enable_online_features!
    return if features_enabled?
    $game_system.online_features_enabled = true if $game_system
    ws_connect_presence
    puts "[Online] Online features enabled"
  end

  # Call this from the Settings menu when the player toggles the option OFF.
  def self.disable_online_features!
    return unless features_enabled?
    leave_session if in_session?
    $game_system.online_features_enabled = false if $game_system
    ws_disconnect
    OnlinePlayers.clear
    @online_count = 0
    puts "[Online] Online features disabled"
  end

  #=============================================================================
  # Presence — connects once, independent of being in any session, so the
  # server can track "who currently has online features enabled" separately
  # from session membership (needed for the online-player-count UI, and
  # later for live DM delivery to someone who isn't in a session).
  # host_session/join_session reuse this SAME connection — WSClient.connect
  # is a no-op if already connected — rather than opening a second socket.
  #=============================================================================
  def self.ws_connect_presence
    return unless $player
    WSClient.connect
    return unless WSClient.connected?
    WSClient.send_json({
      "action"     => "presence_join",
      "trainer_id" => $player.id.to_s
    })
    puts "[Online] Presence connected as #{$player.id}"
  end

  def self.online_count
    @online_count || 0
  end

  def self.set_online_count(n)
    @online_count = n
  end

  # Overrides the version in WebSocket.rb — session join now reuses whatever
  # connection ws_connect_presence already opened, and uses the clearer
  # "session_join" action name (server still accepts the old "join" too).
  def self.ws_connect(session_code, trainer_id)
    WSClient.connect
    return unless WSClient.connected?
    WSClient.send_json({
      "action"       => "session_join",
      "session_code" => session_code,
      "trainer_id"   => trainer_id.to_s
    })
    puts "[Online] Joined session #{session_code}"
  end

  def self.generate_session_code
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    code  = ""
    8.times { code += chars[rand(chars.length)] }
    "PKM-#{code[0..3]}-#{code[4..7]}"
  end

  def self.host_session(description: "", visibility: "public", max_players: 8)
    return unless $player
    unless features_enabled?
      puts "[Online] host_session refused — online features are disabled"
      return nil
    end
    code = generate_session_code
    Online.post("sessions", body: {
      "session_code"  => code,
      "host_id"       => $player.id,
      "host_name"     => $player.name,
      "active"        => true,
      "visibility"    => visibility,
      "description"   => description,
      "max_players"   => max_players,
      "player_count"  => 1,
      "player_names"  => $player.name
    })
    @current_session = code
    @is_session_host = true
    Online.ws_connect(code, $player.id)
    puts "[Online] Hosting session #{code}"
    code
  end

  def self.join_session(code)
    return unless $player
    unless features_enabled?
      puts "[Online] join_session refused — online features are disabled"
      return false
    end
    raw = Online.get("sessions", params: { "session_code" => "eq.#{code}" })
    if raw.nil? || !raw.include?(code)
      return false
    end
    # Update player count and names
    results = Online.extract_array(raw, ["player_count", "player_names", "max_players"])
    if results.any?
      current_count = results[0]["player_count"].to_i
      max           = results[0]["max_players"].to_i
      return :full if max > 0 && current_count >= max
      names = results[0]["player_names"].to_s
      names = names.empty? ? $player.name : "#{names}, #{$player.name}"
      Online.patch("sessions", body: {
        "player_count" => current_count + 1,
        "player_names" => names
      }, params: { "session_code" => "eq.#{code}" })
    end
    @current_session = code
    @is_session_host = false
    Online.ws_connect(code, $player.id)
    puts "[Online] Joined session #{code}"
    true
  end

  def self.leave_session
    return unless @current_session && $player
    # Update player count
    raw     = Online.get("sessions", params: { "session_code" => "eq.#{@current_session}" })
    results = Online.extract_array(raw, ["player_count", "player_names", "host_id"])
    if results.any?
      count = [results[0]["player_count"].to_i - 1, 0].max
      names = results[0]["player_names"].to_s.split(", ").reject { |n| n == $player.name }.join(", ")
      if results[0]["host_id"].to_i == $player.id
        # Host left — delete session
        Online.delete("sessions", params: { "session_code" => "eq.#{@current_session}" })
      else
        Online.patch("sessions", body: {
          "player_count" => count,
          "player_names" => names
        }, params: { "session_code" => "eq.#{@current_session}" })
      end
    end
    Online.delete("positions", params: {
      "trainer_id"   => "eq.#{$player.id}",
      "session_code" => "eq.#{@current_session}"
    })
    Online.ws_disconnect
    OnlinePlayers.clear
    puts "[Online] Left session #{@current_session}"
    @current_session = nil
    @is_session_host = false
  end

  # Safety net alongside the relay's immediate cleanup (which fires the
  # instant a session's last connected socket disconnects): catches sessions
  # orphaned by a scenario the relay can't see on its own, e.g. it being
  # restarted/redeployed and losing its in-memory session state entirely.
  # Deactivates anything marked active that hasn't had a heartbeat in a
  # while. Requires an `updated_at` timestamp column on the sessions table,
  # bumped periodically by the host (see the heartbeat timer in
  # Game_Player#update below) — add the column if it doesn't already exist:
  #   alter table sessions add column if not exists updated_at timestamptz default now();
  STALE_SESSION_MINUTES = 10

  def self.cleanup_stale_sessions
    cutoff = (Time.now.utc - (STALE_SESSION_MINUTES * 60)).strftime("%Y-%m-%dT%H:%M:%SZ")
    Online.patch("sessions", body: { "active" => false }, params: {
      "active"     => "eq.true",
      "updated_at" => "lt.#{cutoff}"
    })
  rescue
    nil
  end

  # Fetch public sessions for the browser
  def self.fetch_public_sessions
    cleanup_stale_sessions
    raw = Online.get("sessions", params: {
      "active"     => "eq.true",
      "visibility" => "eq.public",
      "order"      => "player_count.desc"
    })
    Online.extract_array(raw, ["session_code", "host_name", "description",
                                "player_count", "max_players", "player_names"])
  end

  # Fetch sessions hosted by friends
  def self.fetch_friend_sessions
    cleanup_stale_sessions
    friends = fetch_friends
    return [] if friends.empty?
    friend_names = friends.map { |f| f["friend_name"] }
    raw = Online.get("sessions", params: {
      "active"  => "eq.true",
      "order"   => "player_count.desc"
    })
    all = Online.extract_array(raw, ["session_code", "host_name", "description",
                                      "player_count", "max_players", "player_names", "visibility"])
    all.select { |s| friend_names.include?(s["host_name"]) }
  end

  #=============================================================================
  # Friends system
  #=============================================================================

  def self.send_friend_request(friend_name)
    return unless $player
    # Find trainer by name
    raw     = Online.get("trainers", params: { "trainer_name" => "ilike.#{friend_name}" })
    results = Online.extract_array(raw, ["trainer_name", "trainer_id"])
    return :not_found if results.empty?
    friend  = results[0]
    return :self if friend["trainer_id"].to_i == $player.id
    # Check not already friends or pending
    existing = Online.get("friends", params: {
      "player_id"    => "eq.#{$player.id}",
      "recipient_id" => "eq.#{friend["trainer_id"]}"
    })
    return :already_exists if existing && existing.include?(friend["trainer_name"])
    Online.post("friends", body: {
      "player_id"    => $player.id,
      "player_name"  => $player.name,
      "friend_id"    => friend["trainer_id"].to_i,
      "friend_name"  => friend["trainer_name"],
      "recipient_id" => friend["trainer_id"].to_i,
      "status"       => "pending"
    })
    friend["trainer_name"]
  end

  def self.accept_friend_request(request)
    return unless $player
    # Update request to accepted
    Online.patch("friends", body: { "status" => "accepted" }, params: {
      "player_id"    => "eq.#{request["player_id"]}",
      "recipient_id" => "eq.#{$player.id}"
    })
    # Create reverse entry so both players see each other
    Online.post("friends", body: {
      "player_id"    => $player.id,
      "player_name"  => $player.name,
      "friend_id"    => request["player_id"].to_i,
      "friend_name"  => request["player_name"],
      "recipient_id" => request["player_id"].to_i,
      "status"       => "accepted"
    })
  end

  def self.decline_friend_request(request)
    return unless $player
    # Delete the request entirely — no trace left
    Online.delete("friends", params: {
      "player_id"    => "eq.#{request["player_id"]}",
      "recipient_id" => "eq.#{$player.id}"
    })
  end

  def self.remove_friend(friend_id)
    return unless $player
    # Remove both directions
    Online.delete("friends", params: {
      "player_id" => "eq.#{$player.id}",
      "friend_id" => "eq.#{friend_id}"
    })
    Online.delete("friends", params: {
      "player_id" => "eq.#{friend_id}",
      "friend_id" => "eq.#{$player.id}"
    })
  end

  def self.fetch_friends
    return [] unless $player
    raw = Online.get("friends", params: {
      "player_id" => "eq.#{$player.id}",
      "status"    => "eq.accepted"
    })
    Online.extract_array(raw, ["friend_id", "friend_name", "status"])
  end

  def self.fetch_pending_requests
    return [] unless $player
    raw = Online.get("friends", params: {
      "recipient_id" => "eq.#{$player.id}",
      "status"       => "eq.pending"
    })
    Online.extract_array(raw, ["player_id", "player_name", "status", "created_at"])
  end

  def self.fetch_online_friends
    friends    = fetch_friends
    return [] if friends.empty?
    cutoff     = (Time.now.utc - 300).strftime("%Y-%m-%dT%H:%M:%SZ")
    raw        = Online.get("trainers", params: { "last_seen" => "gte.#{cutoff}" })
    online     = Online.extract_array(raw, ["trainer_id", "trainer_name"])
    friend_ids = friends.map { |f| f["friend_id"] }
    online.select { |t| friend_ids.include?(t["trainer_id"]) }
  end

  # Clean up stale pending requests older than 30 days
  def self.cleanup_stale_requests
    return unless $player
    cutoff = (Time.now.utc - (30 * 24 * 60 * 60)).strftime("%Y-%m-%dT%H:%M:%SZ")
    Online.delete("friends", params: {
      "recipient_id" => "eq.#{$player.id}",
      "status"       => "eq.pending",
      "created_at"   => "lt.#{cutoff}"
    })
  end
end

#==============================================================================#
# Patch Game_Character to add writers — same as VMS plugin does
#==============================================================================#
#==============================================================================#
# Persist the online-features opt-in toggle in the save file. Game_System is
# guaranteed to exist and be saved regardless of which Settings menu
# framework this project uses — hook whatever UI toggle you build into
# Online.enable_online_features!/disable_online_features! above.
#==============================================================================#
class Game_System
  attr_accessor :online_features_enabled

  alias online_system_initialize initialize
  def initialize
    online_system_initialize
    @online_features_enabled = false if @online_features_enabled.nil?
  end
end

class Game_Character
  def x=(val);              @x              = val; end
  def y=(val);              @y              = val; end
  def real_x=(val);         @real_x         = val; end
  def real_y=(val);         @real_y         = val; end
  def direction=(val);      @direction      = val; end
  def pattern=(val);        @pattern        = val; end
  def character_name=(val); @character_name = val; end
  def opacity=(val);        @opacity        = val; end
  def step_anime=(val);     @step_anime     = val; end
  def through=(val);        @through        = val; end
  # Note: move_speed= already exists in PE21 with additional logic
  # Use instance_variable_set for move_speed to avoid breaking it
end

#==============================================================================#
# Patch Game_Event to prevent update_move from overwriting our real_x/real_y
#==============================================================================#
class Game_Event
  def online_ghost?
    @online_ghost || false
  end

  alias online_ghost_update_move update_move
  def update_move
    return if @online_ghost  # skip movement update for ghost events
    online_ghost_update_move
  end
end

#==============================================================================#
# OnlinePlayer — mirrors VMS::Player, stores remote player state
#==============================================================================#
class OnlinePlayer
  attr_accessor :id, :name, :map_id
  attr_accessor :x, :y, :real_x, :real_y
  attr_accessor :direction, :pattern, :graphic
  attr_accessor :move_speed, :opacity
  attr_accessor :rf_event

  def initialize(id, name, graphic, x, y, direction, move_speed)
    @id         = id
    @name       = name
    @graphic    = graphic.empty? ? "trchar000" : graphic
    @map_id     = $game_map&.map_id || 0
    @x          = x
    @y          = y
    @real_x     = x * Game_Map::TILE_WIDTH  * Game_Map::X_SUBPIXELS
    @real_y     = y * Game_Map::TILE_HEIGHT * Game_Map::Y_SUBPIXELS
    @direction  = direction
    @pattern    = 0
    @move_speed = move_speed > 0 ? move_speed : 4
    @opacity    = 255
    @rf_event   = nil
  end

  def update_from_packet(packet)
    @map_id     = packet["map_id"].to_i
    @x          = packet["x"].to_i
    @y          = packet["y"].to_i
    @real_x     = packet["real_x"].to_i if packet["real_x"] && packet["real_x"].to_i > 0
    @real_y     = packet["real_y"].to_i if packet["real_y"] && packet["real_y"].to_i > 0
    @direction  = packet["direction"].to_i
    @pattern    = packet["pattern"].to_i
    @move_speed = packet["move_speed"].to_i if packet["move_speed"].to_i > 0
    char        = packet["character"].to_s
    @graphic    = char unless char.empty? || char == "1"
    @opacity    = packet["opacity"].to_i > 0 ? packet["opacity"].to_i : 255
  end
end

#==============================================================================#
# OnlinePlayers — manages OnlinePlayer instances and their Rf events
#==============================================================================#
module OnlinePlayers
  LERP_SPEED    = 0.4    # smoothing factor
  SNAP_DISTANCE = 4      # tiles — snap if further than this

  @players = {}  # id => OnlinePlayer
  @map_id  = nil

  def self.update(messages)
    return unless $game_map && $scene.is_a?(::Scene_Map)

    # Clear on map change
    if @map_id != $game_map.map_id
      clear
      @map_id = $game_map.map_id
    end

    messages.each do |msg|
      next unless msg && msg["action"] == "state"
      id     = msg["trainer_id"]
      next unless id
      map_id = msg["map_id"].to_i
      name   = msg["trainer_name"].to_s
      char   = msg["character"].to_s
      x      = msg["x"].to_i
      y      = msg["y"].to_i
      dir    = msg["direction"].to_i
      speed  = msg["move_speed"].to_i

      if map_id != $game_map.map_id
        remove(id)
        next
      end

      if @players[id]
        @players[id].update_from_packet(msg)
      else
        player          = OnlinePlayer.new(id, name, char, x, y, dir, speed)
        player.rf_event = create_event(player)
        @players[id]    = player
        puts "[Online] Player #{name} appeared"
      end
    end

    # Drive all events every frame
    drive_events
  end

  def self.drive_events
    @players.each do |id, player|
      next unless player.rf_event
      ev = player.rf_event[:event]
      next if ev.instance_variable_get(:@erased)

      # Target real coordinates from tile position
      target_rx = player.x * Game_Map::TILE_WIDTH  * Game_Map::X_SUBPIXELS
      target_ry = player.y * Game_Map::TILE_HEIGHT * Game_Map::Y_SUBPIXELS

      # Use packet real_x/y if available for sub-tile accuracy
      target_rx = player.real_x if player.real_x && player.real_x > 0
      target_ry = player.real_y if player.real_y && player.real_y > 0

      # Read current real coords via instance_variable_get
      cur_rx = ev.instance_variable_get(:@real_x) || target_rx
      cur_ry = ev.instance_variable_get(:@real_y) || target_ry

      # Distance in tiles
      dx   = (ev.instance_variable_get(:@x).to_i - player.x).abs
      dy   = (ev.instance_variable_get(:@y).to_i - player.y).abs
      dist = dx + dy

      if dist > SNAP_DISTANCE
        # Too far — snap directly
        ev.instance_variable_set(:@x,      player.x)
        ev.instance_variable_set(:@y,      player.y)
        ev.instance_variable_set(:@real_x, target_rx)
        ev.instance_variable_set(:@real_y, target_ry)
      else
        # Lerp subpixel coordinates for smooth movement
        new_rx = lerp(cur_rx, target_rx, LERP_SPEED).to_i
        new_ry = lerp(cur_ry, target_ry, LERP_SPEED).to_i
        ev.instance_variable_set(:@real_x, new_rx)
        ev.instance_variable_set(:@real_y, new_ry)
        # Update tile coords to match subpixel position
        ev.instance_variable_set(:@x, new_rx / (Game_Map::TILE_WIDTH  * Game_Map::X_SUBPIXELS))
        ev.instance_variable_set(:@y, new_ry / (Game_Map::TILE_HEIGHT * Game_Map::Y_SUBPIXELS))
      end

      # Apply state directly via instance_variable_set since writers aren't exposed
      ev.instance_variable_set(:@x,              player.x)
      ev.instance_variable_set(:@y,              player.y)
      ev.instance_variable_set(:@direction,      player.direction)     if player.direction > 0
      ev.instance_variable_set(:@pattern,        player.pattern)
      ev.instance_variable_set(:@character_name, player.graphic)
      ev.instance_variable_set(:@move_speed,     player.move_speed)
      ev.instance_variable_set(:@opacity,        player.opacity)
    end
  end

  def self.create_event(player)
    char = player.graphic
    begin
      RPG::Cache.character(char, 0)
    rescue
      char = "trchar000"
    end

    r = Rf.create_event do |e|
      e.name    = "OnlinePlayer_#{player.name}"
      e.x       = player.x
      e.y       = player.y
      e.pages[0].graphic.character_name = char
      e.pages[0].walk_anime  = true
      e.pages[0].step_anime  = false
      e.pages[0].move_type   = 0
      e.pages[0].move_speed  = player.move_speed
      e.pages[0].through     = false
      e.pages[0].trigger     = 0
      e.pages[0].list.clear
      Compiler.push_end(e.pages[0].list)
    end
    # Mark as ghost so update_move doesn't overwrite our real_x/real_y
    r[:event].instance_variable_set(:@online_ghost, true)
    r
  end

  def self.remove(id)
    player = @players.delete(id)
    return unless player
    Rf.delete_event(player.rf_event) rescue nil
  end

  def self.clear
    @players.each { |id, _| remove(id) }
    @players.clear
  end

  def self.lerp(a, b, t)
    a + (b - a) * t
  end
end

#==============================================================================#
# Game_Player — broadcast state every step and periodically
#==============================================================================#
class Game_Player
  alias online_player_move_generic move_generic
  def move_generic(dir, turn_enabled = true)
    online_player_move_generic(dir, turn_enabled)
    broadcast_state if Online.in_session?
  end

  alias online_player_update update
  def update
    online_player_update
    return unless Online.features_enabled?

    # Poll WebSocket ONCE per frame and route messages by action. This runs
    # whenever online features are on at all — NOT just while in a session —
    # so presence_update (online player count) and future live-DM delivery
    # keep working while just wandering the overworld solo.
    messages = Online.ws_poll

    messages.each do |msg|
      next unless msg
      case msg["action"]
      when "presence_update"
        Online.set_online_count(msg["online_count"].to_i)
      when "presence_joined"
        Online.set_online_count(msg["online_count"].to_i)
      end
    end

    return unless Online.in_session?

    position_messages = []
    messages.each do |msg|
      next unless msg
      case msg["action"]
      when "state", "position"
        position_messages << msg
      when "trade_request"
        handle_incoming_trade(msg) if msg["trainer_b_id"].to_i == $player.id
      when "trade_accepted", "trade_declined", "trade_party", "trade_selection", "trade_confirm", "trade_cancel"
        OnlinePlayers.set_pending_trade(msg)
      when "battle_challenge"
        puts "[Battle] battle_challenge received: trainer_b_id=#{msg["trainer_b_id"]} my_id=#{$player.id}"
        handle_incoming_battle_challenge(msg) if msg["trainer_b_id"].to_i == $player.id
      when "battle_accepted", "battle_declined", "battle_cancel", "battle_party",
           "battle_start", "battle_log", "battle_command_request", "battle_action",
           "battle_end", "battle_choice"
        OnlinePlayers.set_pending_trade(msg)
      when "server_ack"
        puts "[Server ACK] original_action=#{msg["original_action"] || msg["action"]} relayed=#{msg["relayed"]} raw=#{msg.inspect}"
      when "presence_update", "presence_joined"
        # already handled above
      else
        puts "[Online] Unhandled WS action arrived: #{msg["action"].inspect}"
      end
    end

    # Update ghost positions
    OnlinePlayers.update(position_messages) unless position_messages.empty?

    # Broadcast position
    if moving?
      broadcast_state
    else
      @online_broadcast_timer = (@online_broadcast_timer || 0) + 1
      if @online_broadcast_timer >= 60
        @online_broadcast_timer = 0
        broadcast_state
      end
    end

    # Session heartbeat — only the host needs to bump this, since it's just
    # keeping the Supabase row's updated_at fresh for cleanup_stale_sessions
    # to check against. Every ~2 minutes is plenty; this is a cheap Supabase
    # write, not something that needs frame-rate precision.
    if Online.hosting_session?
      @online_heartbeat_timer = (@online_heartbeat_timer || 0) + 1
      if @online_heartbeat_timer >= 7200  # ~2 minutes at 60fps
        @online_heartbeat_timer = 0
        Online.patch("sessions", body: {
          "updated_at" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        }, params: { "session_code" => "eq.#{Online.current_session}" }) rescue nil
      end
    end

    # Check for friend requests every 5 minutes
    @friend_request_timer = (@friend_request_timer || 0) + 1
    if @friend_request_timer >= 18000
      @friend_request_timer = 0
      pending = Online.fetch_pending_requests
      if pending.length > 0
        pbMessage("You have #{pending.length} friend request(s)! Check your Friends list.")
      end
    end
  end

  def broadcast_state
    return unless $player && $game_map && WSClient.connected?
    char = self.character_name rescue "trchar000"
    Online.ws_send_state({
      "trainer_id"    => $player.id.to_s,
      "trainer_name"  => $player.name,
      "session_code"  => Online.current_session,
      "map_id"        => $game_map.map_id.to_s,
      "x"             => self.x.to_s,
      "y"             => self.y.to_s,
      "real_x"        => self.real_x.to_s,
      "real_y"        => self.real_y.to_s,
      "direction"     => self.direction.to_s,
      "pattern"       => @pattern.to_s,
      "move_speed"    => @move_speed.to_s,
      "opacity"       => @opacity.to_s,
      "character"     => char || "trchar000"
    })
  end
end

#==============================================================================#
# Clear on map transfer
#==============================================================================#
class Game_Map
  alias online_player_setup setup
  def setup(map_id)
    OnlinePlayers.clear
    online_player_setup(map_id)
  end
end

#==============================================================================#
# Player Interaction — action button on ghost events
#==============================================================================#
class Scene_Map
  alias online_interaction_update update
  def update
    online_interaction_update
    return unless Online.in_session?
    return unless Input.trigger?(Input::USE)
    check_online_player_interaction
  end

  def check_online_player_interaction
    # Get the tile the player is facing
    x = $game_player.x
    y = $game_player.y
    case $game_player.direction
    when 2 then y += 1
    when 4 then x -= 1
    when 6 then x += 1
    when 8 then y -= 1
    end

    # Check if any online player ghost is at that tile
    OnlinePlayers.players.each do |tid, player|
      next unless player.rf_event
      ev = player.rf_event[:event]
      next unless ev.x == x && ev.y == y
      open_player_interaction_menu(player)
      return
    end
  end

  def open_player_interaction_menu(player)
    commands = ["Trade", "Battle", "Message", "View Trainer Card", "Add Friend", "Cancel"]
    choice   = pbShowCommands(nil, commands, 5)
    case choice
    when 0  # Trade
      initiate_trade(player)
    when 1  # Battle
      initiate_battle(player)
    when 2  # Message
      Online.open_compose(player.id.to_i, player.name)
    when 3  # View Trainer Card
      show_online_trainer_card(player)
    when 4  # Add Friend
      result = Online.send_friend_request(player.name)
      case result
      when :not_found      then pbMessage("Could not find trainer.")
      when :self           then pbMessage("That's you!")
      when :already_exists then pbMessage("Already friends or request pending.")
      else pbMessage("Friend request sent to #{player.name}!")
      end
    end
  end

  def initiate_trade(player)
    trade_id = Online.request_direct_trade(player)
    return unless trade_id
    result = Online.wait_for_trade_response(trade_id)
    case result
    when :timeout  then pbMessage("#{player.name} didn't respond in time.")
    when :declined then pbMessage("#{player.name} declined the trade.")
    when :accepted
      # Send our party data
      party_hashes = $player.party.map { |p| Online.pokemon_to_summary(p) }
      WSClient.send_json({
        "action"     => "trade_party",
        "trade_id"   => trade_id,
        "trainer_id" => $player.id.to_s,
        "party_data" => party_hashes
      })
      pbMessage("Waiting for #{player.name}'s party data...")
      # Wait for their party then open trade screen
      $scene.wait_for_trade_party(trade_id, player.name)
    end
  end

  def wait_for_trade_party(trade_id, other_name)
    start       = Time.now
    other_party = nil
    my_index    = nil

    # Check if trade_party arrived already during wait_for_trade_response
    cached = OnlinePlayers.pending_trade("trade_party")
    if cached && cached["trade_id"] == trade_id
      other_party = Online.parse_party_data(cached["party_data"].to_s)
      OnlinePlayers.clear_pending_trade("trade_party")
    end

    loop do
      Graphics.update
      Input.update
      return if Time.now - start > Online::TRADE_TIMEOUT

      WSClient.poll.each do |msg|
        next unless msg && msg["trade_id"] == trade_id
        case msg["action"]
        when "trade_party"
          other_party = Online.parse_party_data(msg["party_data"].to_s)
        when "trade_selection", "trade_confirm"
          OnlinePlayers.set_pending_trade(msg)
        when "trade_cancel"
          pbMessage("#{other_name} cancelled the trade.")
          return
        end
      end

      # Once we have their party, open trade screen
      if other_party && my_index.nil?
        result = Online.open_trade_screen(trade_id, other_name, other_party)
        if result
          my_index = result[0]
          # trade_confirm already sent inside open_trade_screen
          # now wait for their confirm
          wait_for_trade_confirm(trade_id, my_index, other_name)
        else
          WSClient.send_json({ "action" => "trade_cancel", "trade_id" => trade_id, "session_code" => Online.current_session })
        end
        return
      end

      sleep(0.05)
    end
  end

  def wait_for_trade_confirm(trade_id, my_index, other_name)
    # Check if their confirm already arrived
    cached = OnlinePlayers.pending_trade("trade_confirm")
    if cached && cached["trade_id"] == trade_id
      OnlinePlayers.clear_pending_trade("trade_confirm")
      received_hash = Online.parse_pokemon_data(cached["pokemon_data"].to_s)
      Online.execute_trade(trade_id, my_index, received_hash)
      return
    end

    start = Time.now
    loop do
      Graphics.update
      Input.update
      return if Time.now - start > Online::TRADE_TIMEOUT
      WSClient.poll.each do |msg|
        next unless msg && msg["trade_id"] == trade_id
        case msg["action"]
        when "trade_confirm"
          received_hash = Online.parse_pokemon_data(msg["pokemon_data"].to_s)
          Online.execute_trade(trade_id, my_index, received_hash)
          return
        when "trade_cancel", "trade_reselect"
          pbMessage("#{other_name} cancelled the trade.")
          return
        end
      end
      sleep(0.05)
    end
  end

  def show_online_trainer_card(player)
    pbMessage("Trainer: #{player.name}\nSession: #{Online.current_session}")
  end
end

# Expose players hash for Scene_Map interaction check
module OnlinePlayers
  def self.players
    @players
  end
end

#==============================================================================#
# Incoming trade handler on Game_Player
#==============================================================================#
class Game_Player
  def handle_incoming_trade(msg)
    trade_id     = msg["trade_id"]
    other_name   = msg["trainer_a_name"]
    return unless trade_id && other_name

    if pbConfirmMessage("#{other_name} wants to trade! Accept?")
      # Clear stale data from previous trades
      OnlinePlayers.clear_pending_trade
      puts "[Trade] Accepted, connected=#{WSClient.connected?}"
      # Accept
      WSClient.send_json({
        "action"       => "trade_accepted",
        "trade_id"     => trade_id,
        "trainer_id"   => $player.id.to_s,
        "trainer_b_id" => msg["trainer_a_id"],
        "session_code" => Online.current_session
      })
      puts "[Trade] Accepted message sent"
      # Send our party
      party_hashes = $player.party.map { |p| Online.pokemon_to_summary(p) }
      WSClient.send_json({
        "action"       => "trade_party",
        "trade_id"     => trade_id,
        "trainer_id"   => $player.id.to_s,
        "party_data"   => party_hashes,
        "session_code" => Online.current_session
      })
      # Wait for their party and open trade screen
      $scene.wait_for_trade_party(trade_id, other_name)
    else
      # Decline
      WSClient.send_json({
        "action"   => "trade_declined",
        "trade_id" => trade_id
      })
    end
  end
end

#==============================================================================#
# Party and pokemon data parsers
#==============================================================================#
module Online
  # The lightweight per-field regex extractors used elsewhere in this system
  # (extract_field, quick_parse) only pull flat key/value pairs out of a JSON
  # string — they can't handle nested objects/arrays like a Pokemon's
  # "ivs"/"evs" hashes or its "moves" array, and were silently dropping them.
  # For full Pokemon data (trade and battle both depend on this being
  # complete), use Ruby's real JSON parser instead, and only fall back to the
  # old flat parser if 'json' truly isn't available in this build.
  begin
    require 'json'
    JSON_AVAILABLE = true
  rescue LoadError
    JSON_AVAILABLE = false
    puts "[Online] Ruby 'json' library not available — falling back to " \
         "partial parsing (moves/IVs/EVs will NOT survive trade or battle party sync)."
  end

  def self.parse_json_safe(raw)
    return nil if raw.nil? || raw.empty?
    return nil unless JSON_AVAILABLE
    begin
      JSON.parse(raw)
    rescue => e
      puts "[Online] JSON parse error: #{e.message}"
      nil
    end
  end

  def self.parse_party_data(raw)
    return [] if raw.nil? || raw.empty?
    parsed = parse_json_safe(raw)
    return parsed if parsed.is_a?(Array)

    # Fallback: old flat-field regex parser. NOTE: this loses ivs/evs/moves/
    # ribbons/ability_index — only used if JSON_AVAILABLE is false.
    results = []
    raw.scan(/\{[^{}]*\}/).each do |obj|
      hash = {}
      ["species", "level", "name", "gender", "shiny", "ability", "nature",
       "item", "happiness", "hp", "poke_ball", "exp"].each do |field|
        val = obj[/"#{field}"\s*:\s*"([^"]*)"/, 1] ||
              obj[/"#{field}"\s*:\s*([0-9\.\-]+)/, 1] ||
              obj[/"#{field}"\s*:\s*(true|false)/, 1]
        hash[field] = val
      end
      results << hash unless hash["species"].nil?
    end
    results
  end

  def self.parse_pokemon_data(raw)
    return nil if raw.nil? || raw.empty?
    parsed = parse_json_safe(raw)
    return parsed if parsed.is_a?(Hash)

    # Fallback: old flat-field regex parser (see note above).
    hash = {}
    ["species", "level", "name", "gender", "shiny", "ability", "nature",
     "item", "happiness", "hp", "poke_ball", "exp",
     "original_trainer", "original_trainer_id"].each do |field|
      val = raw[/"#{field}"\s*:\s*"([^"]*)"/, 1] ||
            raw[/"#{field}"\s*:\s*([0-9\.\-]+)/, 1] ||
            raw[/"#{field}"\s*:\s*(true|false)/, 1]
      hash[field] = val
    end
    hash
  end
end

#==============================================================================#
# Clear online state on game reset/load
#==============================================================================#
module Online
  def self.reset_state
    OnlinePlayers.clear rescue nil
    @current_session = nil
    WSClient.disconnect rescue nil
    puts "[Online] State reset"
  end
end

# Clear ghosts on every map setup
EventHandlers.add(:on_game_map_setup, :online_reset,
  proc { |map_id, map|
    OnlinePlayers.clear rescue nil
  }
)

# Online state resets on map load via on_game_map_setup handler above
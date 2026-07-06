#==============================================================================#
#                         Online System — Direct Trade                         #
#==============================================================================#
# Handles live direct trading between two players in the same session.        #
# Uses WebSocket for real-time communication and Supabase for trade records.  #
#==============================================================================#

module Online
  TRADE_TIMEOUT = 30  # seconds before request expires

  #=============================================================================
  # Pokemon serialisation — converts Pokemon object to/from JSON-safe hash
  #=============================================================================
  def self.pokemon_to_hash(pkmn)
    return nil unless pkmn
    moves = pkmn.moves.map do |m|
      next nil unless m && m.id
      {
        "id"       => m.id.to_s,
        "pp"       => m.pp,
        "ppup"     => m.ppup,
        "total_pp" => m.total_pp
      }
    end
    {
      "species"       => pkmn.species.to_s,
      "level"         => pkmn.level,
      "name"          => pkmn.name,
      "gender"        => pkmn.gender,
      "shiny"         => pkmn.shiny?,
      "ability"       => pkmn.ability.to_s,
      "ability_index" => pkmn.ability_index,
      "nature"        => pkmn.nature.to_s,
      "item"          => pkmn.item.to_s,
      "moves"         => moves.compact,
      "hp"            => pkmn.hp,
      "totalhp"       => pkmn.totalhp,
      "ivs"           => {
        "hp"  => pkmn.iv[:HP],
        "atk" => pkmn.iv[:ATTACK],
        "def" => pkmn.iv[:DEFENSE],
        "spa" => pkmn.iv[:SPECIAL_ATTACK],
        "spd" => pkmn.iv[:SPECIAL_DEFENSE],
        "spe" => pkmn.iv[:SPEED]
      },
      "evs"           => {
        "hp"  => pkmn.ev[:HP],
        "atk" => pkmn.ev[:ATTACK],
        "def" => pkmn.ev[:DEFENSE],
        "spa" => pkmn.ev[:SPECIAL_ATTACK],
        "spd" => pkmn.ev[:SPECIAL_DEFENSE],
        "spe" => pkmn.ev[:SPEED]
      },
      "happiness"           => (pkmn.happiness rescue 70),
      "poke_ball"           => (pkmn.poke_ball.to_s rescue "POKEBALL"),
      "original_trainer"    => (pkmn.owner&.name rescue $player.name) || $player.name,
      "original_trainer_id" => (pkmn.owner&.id rescue $player.id) || $player.id,
      "exp"                 => (pkmn.exp rescue 0),
      "pokerus_status"      => (pkmn.respond_to?(:pokerus_status) ? pkmn.pokerus_status : 0),
      "ribbons"             => (pkmn.respond_to?(:ribbons) ? pkmn.ribbons.map(&:to_s) : [])
    }
  end

  def self.hash_to_pokemon(hash)
    return nil unless hash && hash["species"]
    species = hash["species"].to_sym rescue nil
    return nil unless species && GameData::Species.exists?(species)

    pkmn       = Pokemon.new(species, hash["level"].to_i)
    pkmn.name  = hash["name"] if hash["name"] && !hash["name"].empty?
    pkmn.exp   = hash["exp"].to_i if hash["exp"]

    # Gender
    pkmn.gender = hash["gender"].to_i

    # Shiny
    pkmn.shiny = true if hash["shiny"] == "true" || hash["shiny"] == true

    # Nature
    if hash["nature"]
      nature = hash["nature"].to_sym rescue nil
      pkmn.nature = nature if nature && GameData::Nature.exists?(nature)
    end

    # Ability
    if hash["ability"]
      ability = hash["ability"].to_sym rescue nil
      if ability && GameData::Ability.exists?(ability)
        pkmn.ability      = ability
        pkmn.ability_index = hash["ability_index"].to_i
      end
    end

    # Item
    if hash["item"] && !hash["item"].empty? && hash["item"] != "nil"
      item = hash["item"].to_sym rescue nil
      pkmn.item = item if item && GameData::Item.exists?(item)
    end

    # IVs
    if hash["ivs"]
      ivs = hash["ivs"]
      pkmn.iv[:HP]              = ivs["hp"].to_i
      pkmn.iv[:ATTACK]          = ivs["atk"].to_i
      pkmn.iv[:DEFENSE]         = ivs["def"].to_i
      pkmn.iv[:SPECIAL_ATTACK]  = ivs["spa"].to_i
      pkmn.iv[:SPECIAL_DEFENSE] = ivs["spd"].to_i
      pkmn.iv[:SPEED]           = ivs["spe"].to_i
    end

    # EVs
    if hash["evs"]
      evs = hash["evs"]
      pkmn.ev[:HP]              = evs["hp"].to_i
      pkmn.ev[:ATTACK]          = evs["atk"].to_i
      pkmn.ev[:DEFENSE]         = evs["def"].to_i
      pkmn.ev[:SPECIAL_ATTACK]  = evs["spa"].to_i
      pkmn.ev[:SPECIAL_DEFENSE] = evs["spd"].to_i
      pkmn.ev[:SPEED]           = evs["spe"].to_i
    end

    # Moves
    if hash["moves"] && hash["moves"].is_a?(Array)
      pkmn.forget_all_moves
      hash["moves"].each do |m|
        next unless m && m["id"]
        move_id = m["id"].to_sym rescue nil
        next unless move_id && GameData::Move.exists?(move_id)
        pkmn.learn_move(move_id)
        # Restore PP
        pkmn.moves.each do |pm|
          if pm.id == move_id
            pm.pp   = m["pp"].to_i
            pm.ppup = m["ppup"].to_i
          end
        end
      end
    end

    # Happiness
    pkmn.happiness = hash["happiness"].to_i if hash["happiness"]

    # Poké Ball
    if hash["poke_ball"] && !hash["poke_ball"].empty?
      ball = hash["poke_ball"].to_sym rescue nil
      pkmn.poke_ball = ball if ball && GameData::Item.exists?(ball)
    end

    # Pokerus
    pkmn.pokerus_status = hash["pokerus_status"].to_i if hash["pokerus_status"]

    # Ribbons
    if hash["ribbons"] && hash["ribbons"].is_a?(Array)
      hash["ribbons"].each do |r|
        ribbon = r.to_sym rescue nil
        pkmn.give_ribbon(ribbon) if ribbon && GameData::Ribbon.exists?(ribbon)
      end
    end

    # Original trainer
    pkmn.owner = Pokemon::Owner.new(
      hash["original_trainer_id"].to_i,
      hash["original_trainer"] || "",
      $player.gender,
      $player.language
    ) rescue nil

    pkmn.calc_stats
    pkmn
  end

  # Lightweight party summary for trade selection screen
  def self.pokemon_to_summary(pkmn)
    return nil unless pkmn
    {
      "species" => pkmn.species.to_s,
      "level"   => pkmn.level,
      "name"    => pkmn.name,
      "gender"  => pkmn.gender,
      "shiny"   => pkmn.shiny?,
      "item"    => (pkmn.item.to_s rescue "")
    }
  end

  #=============================================================================
  # Direct trade request
  #=============================================================================
  def self.request_direct_trade(target_player)
    return unless $player && @current_session
    # Clear any stale trade data from previous trades
    OnlinePlayers.clear_pending_trade
    trade_id = "#{$player.id}_#{target_player.id}_#{Time.now.to_i}"

    # Log trade to Supabase (non-critical — ignore failures)
    begin
      Online.post("trades", body: {
        "trade_id"       => trade_id,
        "trade_type"     => "direct",
        "trainer_a_id"   => $player.id,
        "trainer_a_name" => $player.name,
        "trainer_b_id"   => target_player.id.to_i,
        "trainer_b_name" => target_player.name,
        "status"         => "pending",
        "session_code"   => Online.current_session,
        "updated_at"     => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      })
    rescue
      nil  # trade proceeds even if logging fails
    end

    # Send WebSocket notification to target player
    WSClient.send_json({
      "action"         => "trade_request",
      "trade_id"       => trade_id,
      "trainer_a_id"   => $player.id.to_s,
      "trainer_a_name" => $player.name,
      "trainer_b_id"   => target_player.id.to_s,
      "session_code"   => Online.current_session
    })

    puts "[Trade] Request sent to #{target_player.name}, trade_id=#{trade_id}"
    trade_id
  end

  #=============================================================================
  # Wait for trade response with timeout
  #=============================================================================
  def self.wait_for_trade_response(trade_id)
    start_time = Time.now
    puts "[Trade] Waiting for response..."
    loop do
      Graphics.update
      Input.update

      if Time.now - start_time > TRADE_TIMEOUT
        Online.patch("trades", body: { "status" => "cancelled" },
                     params: { "trade_id" => "eq.#{trade_id}" })
        return :timeout
      end

      # Poll directly — update loop is frozen during pbMessage
      messages = WSClient.poll
      messages.each do |msg|
        next unless msg && msg["trade_id"] == trade_id
        case msg["action"]
        when "trade_accepted"
          # Stash any party data that arrives with or after accept
          return :accepted
        when "trade_declined" then return :declined
        when "trade_cancel"   then return :cancelled
        when "trade_party", "trade_selection", "trade_confirm"
          # Store for use in subsequent wait methods
          OnlinePlayers.set_pending_trade(msg)
        end
      end

      sleep(0.05)
    end
  end

  #=============================================================================
  # Open the trade party selection screen
  #=============================================================================
  # other_party is the OTHER player's full party (for browsing/display only —
  # you still don't know which one of THEIRS they'll actually offer until
  # their trade_selection message arrives).
  #
  # Flow:
  #   1. Pick one of MY pokemon to offer.
  #   2. Send a lightweight trade_selection (name/level/species only).
  #   3. Wait for THEIR trade_selection.
  #   4. Show the real proposed trade (mine vs theirs) and confirm.
  #   5. Only now send the full serialized pokemon_data via trade_confirm.
  #
  # Returns [my_index] on success, or nil if cancelled/timed out.
  def self.open_trade_screen(trade_id, other_trainer_name, other_party)
    selected_index = nil

    loop do
      commands = $player.party.map.with_index { |pkmn, i| "#{pkmn.name} Lv.#{pkmn.level}" }
      commands << "View #{other_trainer_name}'s Party"
      commands << "Cancel"

      pbMessage("Choose a Pokémon to offer #{other_trainer_name}:")
      choice = pbShowCommands(nil, commands, commands.length - 1)
      return nil if choice < 0 || choice == commands.length - 1

      if choice == commands.length - 2
        list = other_party.empty? ? "(unknown)" : other_party.map { |p| "#{p.name} Lv.#{p.level}" }.join("\n")
        pbMessage("#{other_trainer_name}'s party:\n#{list}")
        next
      end

      my_pkmn = $player.party[choice]
      if pbConfirmMessage("Offer #{my_pkmn.name} for trade?")
        selected_index = choice
        break
      end
    end

    my_pkmn = $player.party[selected_index]

    # Bail out if they already cancelled while we were choosing
    if OnlinePlayers.pending_trade("trade_cancel")
      OnlinePlayers.clear_pending_trade("trade_cancel")
      pbMessage("#{other_trainer_name} cancelled the trade.")
      return nil
    end

    # Announce our selection (lightweight — no full pokemon data yet)
    WSClient.send_json({
      "action"       => "trade_selection",
      "trade_id"     => trade_id,
      "trainer_id"   => $player.id.to_s,
      "session_code" => Online.current_session,
      "selection"    => pokemon_to_summary(my_pkmn)
    })

    # Wait for their selection
    other_selection = wait_for_trade_selection(trade_id, other_trainer_name)
    return nil unless other_selection

    other_label = "#{other_selection["name"] || other_selection["species"]} Lv.#{other_selection["level"]}"
    pbMessage("You offer: #{my_pkmn.name}\n#{other_trainer_name} offers: #{other_label}")

    unless pbConfirmMessage("Confirm this trade?")
      WSClient.send_json({
        "action"       => "trade_cancel",
        "trade_id"     => trade_id,
        "session_code" => Online.current_session
      })
      return nil
    end

    # They might have cancelled while we were reading the confirm dialog
    if OnlinePlayers.pending_trade("trade_cancel")
      OnlinePlayers.clear_pending_trade("trade_cancel")
      pbMessage("#{other_trainer_name} cancelled the trade.")
      return nil
    end

    # Send the real, full Pokémon data now that both sides have committed
    WSClient.send_json({
      "action"       => "trade_confirm",
      "trade_id"     => trade_id,
      "trainer_id"   => $player.id.to_s,
      "session_code" => Online.current_session,
      "pokemon_data" => pokemon_to_hash(my_pkmn)
    })

    [selected_index]
  end

  #=============================================================================
  # Wait for the other player's lightweight trade_selection
  #=============================================================================
  def self.wait_for_trade_selection(trade_id, other_name)
    # Did it arrive while we were blocked in a pbMessage/pbConfirmMessage call?
    cached = OnlinePlayers.pending_trade("trade_selection")
    if cached && cached["trade_id"] == trade_id
      OnlinePlayers.clear_pending_trade("trade_selection")
      return parse_pokemon_data(cached["selection"].to_s)
    end

    start_time = Time.now
    loop do
      Graphics.update
      Input.update
      return nil if Time.now - start_time > TRADE_TIMEOUT

      WSClient.poll.each do |msg|
        next unless msg && msg["trade_id"] == trade_id
        case msg["action"]
        when "trade_selection"
          return parse_pokemon_data(msg["selection"].to_s)
        when "trade_cancel"
          pbMessage("#{other_name} cancelled the trade.")
          return nil
        end
      end

      sleep(0.05)
    end
  end

  #=============================================================================
  # Execute the trade
  #=============================================================================
  # Delegates to the built-in pbStartTrade helper (same one NPC trade events
  # use) instead of hand-driving PokemonTrade_Scene / PokemonEvolutionScene
  # ourselves. pbStartTrade accepts a full Pokemon object (not just a species
  # symbol) as its 2nd argument, and internally handles, in order:
  #   1. the trade animation
  #   2. swapping $player.party[idxParty] for the new Pokemon
  #   3. the trade-evolution check and evolution scene, if applicable
  # so we don't need to reimplement any of that by hand.
  #=============================================================================
  def self.execute_trade(trade_id, my_index, received_hash)
    received_pkmn = hash_to_pokemon(received_hash)
    return unless received_pkmn

    my_pkmn = $player.party[my_index]
    return unless my_pkmn

    # Clear any stale pending trade data
    OnlinePlayers.clear_pending_trade

    # NOTE: unlike an NPC trade, we deliberately do NOT force
    # received_pkmn.level to match my_pkmn.level — the level came from the
    # real other player's actual Pokemon and should be preserved as-is.

    nickname          = received_pkmn.name
    other_trainer_name = received_hash["original_trainer"].to_s
    other_trainer_name = "Online Trainer" if other_trainer_name.empty?
    other_trainer_id   = received_hash["original_trainer_id"].to_i

    trade_ok = true
    begin
      # pbStartTrade plays the animation, performs the party swap, and runs
      # the trade-evolution check/scene all on its own.
      pbStartTrade(my_index, received_pkmn, nickname, other_trainer_name, other_trainer_id)
    rescue => e
      puts "[Trade] pbStartTrade error: #{e.message}"
      trade_ok = false
      # Fallback: make sure the swap happens even if the built-in helper
      # blew up before it could do so itself.
      unless $player.party[my_index] && $player.party[my_index].species == received_pkmn.species
        $player.party[my_index] = received_pkmn
      end
      # Best-effort fallback evolution check, in case pbStartTrade failed
      # before reaching its own evolution logic.
      begin
        traded_in = $player.party[my_index]
        evo = traded_in.check_evolution_on_trade(my_pkmn)
        if evo
          pbFadeOutIn do
            escene  = PokemonEvolutionScene.new
            escreen = PokemonEvolutionScreen.new(escene)
            escreen.pbEvolution(traded_in, evo)
          end
          traded_in.species = evo
          traded_in.calc_stats
          $player.party[my_index] = traded_in
        end
      rescue => e2
        puts "[Trade] Fallback evolution error: #{e2.message}"
      end
    end

    pbMessage(trade_ok ? "Trade complete!" : "Trade complete! (fallback path used)")

    # Update the trade record last, after everything above has actually
    # succeeded, so a crash mid-trade doesn't mark it complete.
    begin
      Online.patch("trades", body: {
        "status"     => "complete",
        "updated_at" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      }, params: { "trade_id" => "eq.#{trade_id}" })
    rescue
      nil
    end
  end
end

#==============================================================================#
# Update WebSocket message handler to handle trade packets
#==============================================================================#
module WSClient
  def self.quick_parse(str)
    action = extract_field(str, "action")
    return nil unless action
    {
      "action"         => action,
      "trainer_id"     => extract_field(str, "trainer_id"),
      "trainer_name"   => extract_field(str, "trainer_name"),
      "trainer_a_id"   => extract_field(str, "trainer_a_id"),
      "trainer_a_name" => extract_field(str, "trainer_a_name"),
      "trainer_b_id"   => extract_field(str, "trainer_b_id"),
      "session_code"   => extract_field(str, "session_code"),
      "map_id"         => extract_field(str, "map_id"),
      "x"              => extract_field(str, "x"),
      "y"              => extract_field(str, "y"),
      "real_x"         => extract_field(str, "real_x"),
      "real_y"         => extract_field(str, "real_y"),
      "direction"      => extract_field(str, "direction"),
      "pattern"        => extract_field(str, "pattern"),
      "move_speed"     => extract_field(str, "move_speed"),
      "opacity"        => extract_field(str, "opacity"),
      "character"      => extract_field(str, "character"),
      "trade_id"       => extract_field(str, "trade_id"),
      "party_data"     => str[/"party_data"\s*:\s*(\[.*?\])/m, 1],
      "pokemon_data"   => str[/"pokemon_data"\s*:\s*(\{.*?\})/m, 1],
      "selection"      => str[/"selection"\s*:\s*(\{.*?\})/m, 1],
      "my_index"       => extract_field(str, "my_index")
    }
  end
end

#==============================================================================#
# Handle incoming trade packets in Game_Player update
#==============================================================================#
module OnlinePlayers
  @pending_by_action = {}

  # Stash any trade-related message, keyed by its action. This is what lets a
  # message that arrives while we're stuck inside a blocking pbMessage /
  # pbConfirmMessage / pbShowCommands call still get picked up by the wait
  # loop that resumes right after — without a fast-arriving message of a
  # different action clobbering it first.
  def self.set_pending_trade(msg)
    return unless msg && msg["action"]
    @pending_by_action[msg["action"]] = msg
  end

  # Pass the specific action you're expecting, e.g. pending_trade("trade_confirm")
  def self.pending_trade(action = nil)
    return nil unless action
    @pending_by_action[action]
  end

  def self.clear_pending_trade(action = nil)
    if action
      @pending_by_action.delete(action)
    else
      @pending_by_action.clear
    end
  end
end
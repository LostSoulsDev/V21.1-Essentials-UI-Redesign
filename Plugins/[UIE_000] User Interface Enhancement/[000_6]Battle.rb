#==============================================================================#
# Online System — Live Battle                         
#==============================================================================#
puts "[Battle] Battle.rb LOADED — version marker 2026-07-07-lockstep"
#==============================================================================#

module Online
  BATTLE_TIMEOUT = 30  # seconds before challenge/setup step expires

  #=============================================================================
  # Send a battle challenge to another player in the same session
  #=============================================================================
  def self.request_battle_challenge(target_player, matchmaking: false)
    return unless $player && @current_session
    OnlinePlayers.clear_pending_trade("battle_accepted")
    OnlinePlayers.clear_pending_trade("battle_declined")
    OnlinePlayers.clear_pending_trade("battle_cancel")

    battle_id = "battle_#{$player.id}_#{target_player.id}_#{Time.now.to_i}"

    WSClient.send_json({
      "action"         => "battle_challenge",
      "battle_id"      => battle_id,
      "trainer_a_id"   => $player.id.to_s,
      "trainer_a_name" => $player.name,
      "trainer_b_id"   => target_player.id.to_s,
      "session_code"   => Online.current_session,
      "matchmaking"    => matchmaking
    })

    puts "[Battle] Challenge sent to #{target_player.name}, battle_id=#{battle_id} matchmaking=#{matchmaking}"
    battle_id
  end

  #=============================================================================
  # Wait for the other player to accept/decline, with timeout
  #=============================================================================
  def self.wait_for_battle_response(battle_id)
    %w[battle_accepted battle_declined battle_cancel].each do |action|
      cached = OnlinePlayers.pending_trade(action)
      if cached && cached["battle_id"] == battle_id
        OnlinePlayers.clear_pending_trade(action)
        case action
        when "battle_accepted" then return :accepted
        when "battle_declined" then return :declined
        when "battle_cancel"   then return :cancelled
        end
      end
    end

    start_time = Time.now
    puts "[Battle] Waiting for response..."
    loop do
      Graphics.update
      Input.update
      return :timeout if Time.now - start_time > BATTLE_TIMEOUT

      result = nil
      WSClient.poll.each do |msg|
        next unless msg && msg["battle_id"] == battle_id
        case msg["action"]
        when "battle_accepted" then result ||= :accepted
        when "battle_declined" then result ||= :declined
        when "battle_cancel"   then result ||= :cancelled
        else
          # Not what we're waiting for right now — almost certainly the
          # accepting side's battle_party, sent immediately after
          # battle_accepted and very plausibly arriving in this SAME poll
          # batch. Returning mid-iteration (the old behavior) would silently
          # discard it here, and whoever later calls
          # wait_for_opponent_battle_party would then wait forever for a
          # message that already arrived and was thrown away. Cache it
          # instead so nothing gets lost.
          OnlinePlayers.set_pending_trade(msg)
        end
      end
      return result if result

      sleep(0.05)
    end
  end

  #=============================================================================
  # Send MY OWN party to the other side. If I'm the challenger (host role for
  # the purposes of seed generation only — otherwise fully symmetric), also
  # generate and include the shared RNG seed.
  #=============================================================================
  def self.send_my_battle_party(battle_id, seed: nil)
    party_hashes = []
    $player.party.each_with_index do |p, i|
      begin
        h = pokemon_to_hash(p)
        party_hashes << h if h
      rescue => e
        puts "[Battle] pokemon_to_hash error on party slot #{i} (#{p&.name}): #{e.message}"
      end
    end
    puts "[Battle] Built #{party_hashes.length}/#{$player.party.length} party hashes for battle_party"

    payload = {
      "action"       => "battle_party",
      "battle_id"    => battle_id,
      "trainer_id"   => $player.id.to_s,
      "party_data"   => party_hashes,
      "session_code" => Online.current_session
    }
    payload["seed"] = seed if seed

    WSClient.send_json(payload)
    puts "[Battle] battle_party sent (seed=#{seed.inspect})"
  end

  #=============================================================================
  # Wait for the OTHER side's party (and seed, if they included one — only
  # the challenger sends a seed). Returns [party_hashes, seed_or_nil] or
  # [nil, nil] on timeout/cancel.
  #=============================================================================
  def self.wait_for_opponent_battle_party(battle_id)
    cached = OnlinePlayers.pending_trade("battle_party")
    if cached && cached["battle_id"] == battle_id
      OnlinePlayers.clear_pending_trade("battle_party")
      parsed = parse_json_safe(cached["party_data"].to_s)
      seed   = cached["seed"] ? cached["seed"].to_i : nil
      puts "[Battle] wait_for_opponent_battle_party found CACHED, entries=#{parsed.respond_to?(:length) ? parsed.length : "n/a"} seed=#{seed.inspect}"
      return [parsed, seed]
    end

    start_time = Time.now
    loop do
      Graphics.update
      Input.update
      return [nil, nil] if Time.now - start_time > BATTLE_TIMEOUT

      result = nil
      WSClient.poll.each do |msg|
        next unless msg && msg["battle_id"] == battle_id
        case msg["action"]
        when "battle_party"
          parsed = parse_json_safe(msg["party_data"].to_s)
          seed   = msg["seed"] ? msg["seed"].to_i : nil
          puts "[Battle] wait_for_opponent_battle_party received, entries=#{parsed.respond_to?(:length) ? parsed.length : "n/a"} seed=#{seed.inspect}"
          result ||= [parsed, seed]
        when "battle_cancel"
          result ||= [nil, nil]
        else
          OnlinePlayers.set_pending_trade(msg)
        end
      end
      return result if result

      sleep(0.05)
    end
  end
end

#==============================================================================#
# Battle patches
#==============================================================================#
class Battle
  attr_accessor :online_battle_id
  attr_accessor :online_rng
  attr_accessor :online_round   # round counter, used to tag/match exchanged choices

  def online_battle?
    !@online_battle_id.nil?
  end
end

# Route every internal random roll through a shared, seeded RNG once one is
# set — this is what makes two independent local simulations (one per
# client) produce identical results given the same inputs. Guarded with
# method_defined? in case this version calls it something else, in which
# case online battles would still run but could visually desync over a long
# battle (worth checking if that's ever observed).
if Battle.method_defined?(:pbRandom)
  class Battle
    alias online_battle_pb_random pbRandom
    def pbRandom(x)
      return @online_rng.rand(x) if @online_rng
      online_battle_pb_random(x)
    end
  end
else
  puts "[Battle] WARNING: pbRandom not found on Battle — RNG cannot be synced between clients, online battles may visually desync over time."
end

#==============================================================================#
# Forfeit sync — trainer battles normally disable running entirely, and there
# isn't a dedicated "forfeit" button in the native battle UI to hook instead.
# Mirrors this project's own Cable Club plugin, which uses the same
# technique: Run is the forfeit mechanism for a live online battle
# specifically, and the OTHER side gets notified so their local simulation
# ends the match instead of timing out into pbAutoChooseMove indefinitely
# (which looks exactly like "battling AI" once your actual opponent has quit).
#==============================================================================#
if Battle.method_defined?(:pbCanRun?)
  class Battle
    alias online_battle_pb_can_run pbCanRun?
    def pbCanRun?(idxBattler)
      return true if online_battle?
      online_battle_pb_can_run(idxBattler)
    end
  end
else
  puts "[Battle] WARNING: pbCanRun? not found on Battle — forfeiting via Run may not be available in online battles. If your engine gates running under a different method name, let me know and I'll adjust this."
end

if Battle.method_defined?(:pbRun)
  class Battle
    alias online_battle_pb_run pbRun
    def pbRun(idxBattler, duringBattle = false)
      ret = online_battle_pb_run(idxBattler, duringBattle)
      if ret == 1 && online_battle? && (pbOwnedByPlayer?(idxBattler) rescue true)
        Online.pbSendForfeit(self)
      end
      ret
    end
  end
else
  puts "[Battle] WARNING: pbRun not found on Battle — a local forfeit will not notify the opponent, so their client will time out instead of ending cleanly."
end

module Online
  def self.pbSendForfeit(battle)
    return unless battle.online_battle_id
    WSClient.send_json({
      "action"       => "battle_forfeit",
      "battle_id"    => battle.online_battle_id,
      "session_code" => Online.current_session
    })
    puts "[Battle] Sent forfeit for #{battle.online_battle_id}"
  end
end

module Online
  #=============================================================================
  # Patches whatever class is ACTUALLY being used as this battle's AI
  # (discovered dynamically via @battleAI — confirmed as the real ivar name
  # from this project's own Cable Club plugin: @battleAI = AI_X.new(self)).
  # Re-applied fresh at the start of every online battle so it's always the
  # last patch applied, regardless of what other plugins do at load time.
  #=============================================================================
  def self.ensure_online_ai_hook_installed(battle)
    ai_instance = battle.instance_variable_get(:@battleAI)
    unless ai_instance
      puts "[Battle] WARNING: no @battleAI found — online AI hook NOT installed, opponent will be plain AI-controlled."
      return
    end
    ai_class = ai_instance.class
    puts "[Battle] Detected battle AI class: #{ai_class}"

    unless ai_class.method_defined?(:online_battle_default_choose_enemy_command)
      ai_class.class_eval do
        alias_method :online_battle_default_choose_enemy_command, :pbDefaultChooseEnemyCommand
      end
    end

    ai_class.class_eval do
      define_method(:pbDefaultChooseEnemyCommand) do |idxBattler|
        if @battle.online_battle?
          Online.pb_exchange_choice(@battle, idxBattler)
          next
        end
        online_battle_default_choose_enemy_command(idxBattler)
      end
    end
    puts "[Battle] Online AI hook installed on #{ai_class}"
  end

  #=============================================================================
  # THE actual sync point, mirroring Cable Club's own AI hook: send MY
  # already-decided choice for MY OWN battler (index 0 — chosen moments ago
  # via the normal interactive menu), then wait to receive the other side's
  # already-decided choice for THEIRS, and write it directly into
  # battle.choices[idxBattler] the same way Cable Club does.
  #=============================================================================
  def self.pb_exchange_choice(battle, idxBattler)
    battle.online_round = (battle.online_round || 0) + 1
    round = battle.online_round

    my_choice = battle.choices[0]  # [type_symbol, index, move_obj_or_nil, target_index]
    type_sym  = my_choice[0]
    index_val = my_choice[1]
    target    = my_choice[3]

    my_battler = battle.battlers[0]
    my_hp      = (my_battler.hp rescue nil)
    my_fainted = (my_battler.fainted? rescue false)

    puts "[Battle] Round #{round}: sending my choice type=#{type_sym.inspect} index=#{index_val.inspect} " \
         "target=#{target.inspect} my_hp=#{my_hp.inspect}"

    WSClient.send_json({
      "action"        => "battle_choice",
      "battle_id"     => battle.online_battle_id,
      "session_code"  => Online.current_session,
      "round"         => round,
      "choice_type"   => type_sym.to_s,
      "choice_index"  => index_val,
      "choice_target" => target.nil? ? -1 : target,
      "my_hp"         => my_hp,
      "my_fainted"    => my_fainted
    })

    received = wait_for_battle_choice(battle.online_battle_id, round)

    if received == :forfeit
      puts "[Battle] Opponent forfeited — ending battle"
      battle.pbDisplay(_INTL("The opposing trainer forfeited the match!")) rescue nil
      battle.decision = 1  # I win by default, since they quit
      battle.pbAbort rescue nil
      return
    end

    unless received
      puts "[Battle] Round #{round}: no response from opponent — auto-choosing"
      battle.pbAutoChooseMove(idxBattler) rescue nil
      return
    end

    apply_received_choice(battle, idxBattler, received)
    apply_authoritative_hp(battle, idxBattler, received)
  end

  #=============================================================================
  # Self-healing HP sync: the OWNER of a Pokemon is always the authority for
  # its real HP. Every round, force our local copy of the opponent's battler
  # to match what they report for themselves — this corrects any drift from
  # a subtly desynced RNG roll within one round, instead of letting it
  # compound silently for the rest of the battle.
  #=============================================================================
  def self.apply_authoritative_hp(battle, idxBattler, received)
    return unless received["my_hp"]
    battler = battle.battlers[idxBattler]
    return unless battler
    reported_hp = received["my_hp"].to_i
    begin
      current_hp = (battler.hp rescue nil)
      if current_hp != reported_hp
        puts "[Battle] HP correction for idxBattler=#{idxBattler}: local=#{current_hp.inspect} authoritative=#{reported_hp}"
        battler.hp = reported_hp
      end
    rescue => e
      puts "[Battle] HP correction failed: #{e.message}"
    end
  end

  def self.wait_for_battle_choice(battle_id, round)
    cached = OnlinePlayers.pending_trade("battle_choice")
    if cached && cached["battle_id"] == battle_id && cached["round"].to_i == round
      OnlinePlayers.clear_pending_trade("battle_choice")
      return cached
    end

    forfeit_cached = OnlinePlayers.pending_trade("battle_forfeit")
    if forfeit_cached && forfeit_cached["battle_id"] == battle_id
      OnlinePlayers.clear_pending_trade("battle_forfeit")
      return :forfeit
    end

    start_time = Time.now
    loop do
      Graphics.update
      Input.update
      return nil if Time.now - start_time > BATTLE_TIMEOUT

      result = nil
      WSClient.poll.each do |msg|
        next unless msg && msg["battle_id"] == battle_id
        case msg["action"]
        when "battle_choice"
          result ||= msg if msg["round"].to_i == round
        when "battle_forfeit"
          result ||= :forfeit
        when "battle_cancel"
          result ||= :cancel_sentinel
        else
          OnlinePlayers.set_pending_trade(msg)
        end
      end
      if result
        return nil if result == :cancel_sentinel
        return result
      end
      sleep(0.05)
    end
  end

  #=============================================================================
  # Writes a received choice directly into battle.choices[idxBattler], the
  # same raw-array approach Cable Club uses (rather than going through
  # pbRegisterMove/pbRegisterSwitch), reconstructing the move object exactly
  # as Cable Club does: struggle if index < 0, otherwise the battler's own
  # move at that index.
  #=============================================================================
  def self.apply_received_choice(battle, idxBattler, received)
    battler   = battle.battlers[idxBattler]
    type_sym  = (received["choice_type"] || "UseMove").to_sym
    index_val = received["choice_index"].to_i
    target    = received["choice_target"].to_i

    move_obj =
      if type_sym == :UseMove
        (index_val < 0) ? (battle.struggle rescue nil) : battler.moves[index_val]
      else
        nil
      end

    begin
      battle.choices[idxBattler][0] = type_sym
      battle.choices[idxBattler][1] = index_val
      battle.choices[idxBattler][2] = move_obj
      battle.choices[idxBattler][3] = target
      puts "[Battle] Applied received choice for idxBattler=#{idxBattler}: type=#{type_sym} index=#{index_val} target=#{target}"
    rescue => e
      puts "[Battle] apply_received_choice error: #{e.message} — falling back to pbRegister* methods"
      begin
        if type_sym == :UseMove
          if battle.pbRegisterMove(idxBattler, index_val, false)
            battle.pbRegisterTarget(idxBattler, target) if target >= 0
          else
            battle.pbAutoChooseMove(idxBattler) rescue nil
          end
        elsif type_sym == :SwitchOut
          battle.pbAutoChooseMove(idxBattler) rescue nil unless battle.pbRegisterSwitch(idxBattler, index_val)
        else
          battle.pbAutoChooseMove(idxBattler) rescue nil
        end
      rescue => e2
        puts "[Battle] Fallback registration also failed: #{e2.message}"
        battle.pbAutoChooseMove(idxBattler) rescue nil
      end
    end
  end

  #=============================================================================
  # Shared battle-runner — IDENTICAL for both the challenger and the
  # accepter, since the architecture is now fully symmetric. Constructs a
  # real local Battle with my own party (side 0, driven interactively as
  # normal) and the other player's party (side 1, driven via the AI hook
  # above), seeded with the shared RNG value, and runs it.
  #=============================================================================
  def self.run_local_online_battle(battle_id, other_party_hashes, other_name, seed)
    other_party = other_party_hashes.map { |h| hash_to_pokemon(h) }.compact
    if other_party.empty?
      pbMessage("Couldn't read #{other_name}'s party data.")
      return
    end
    puts "[Battle] Reconstructed #{other_party.length} of #{other_name}'s Pokemon, constructing local Battle..."

    scene        = BattleCreationHelperMethods.create_battle_scene
    otherTrainer = NPCTrainer.new(other_name, :COOLTRAINER_M)  # VERIFY trainer type symbol if this errors
    battle       = Battle.new(scene, $player.party, other_party, [$player], [otherTrainer])
    battle.items = []
    battle.internalBattle = false

    battle.online_battle_id = battle_id
    battle.online_rng       = Random.new(seed)
    battle.online_round     = 0

    Online.ensure_online_ai_hook_installed(battle)

    puts "[Battle] Battler layout at start:"
    battle.battlers.each_with_index do |b, i|
      next unless b
      owned = (battle.pbOwnedByPlayer?(i) rescue :error)
      pkmn_name = (b.pokemon&.name rescue nil) || (b.name rescue "?")
      puts "[Battle]   idx=#{i} name=#{pkmn_name} pbOwnedByPlayer?=#{owned}"
    end

    outcome = nil
    begin
      trainerbgm = pbGetTrainerBattleBGM(otherTrainer) rescue nil
      is_single  = (battle.singleBattle? rescue true)
      pbBattleAnimation(trainerbgm, is_single ? 1 : 3, [otherTrainer]) do
        pbSceneStandby do
          outcome = battle.pbStartBattle
        end
      end
    rescue => e
      puts "[Battle] Local battle error: #{e.class}: #{e.message}"
      puts e.backtrace.first(10).join("\n")
      pbMessage("The battle ended unexpectedly.")
    end

    winner = case outcome
             when 1 then $player.name
             when 2 then other_name
             else "nobody"
             end

    WSClient.send_json({
      "action"       => "battle_end",
      "battle_id"    => battle_id,
      "session_code" => Online.current_session,
      "winner"       => winner
    })

    pbMessage(outcome == 1 ? "You won the battle!" : (outcome == 2 ? "You lost the battle!" : "The battle ended."))
  end
end

#==============================================================================#
# Entry points — both now converge on the same symmetric setup + shared
# run_local_online_battle, unlike the old host/guest split.
#==============================================================================#

class Game_Player
  def handle_incoming_battle_challenge(msg)
    battle_id  = msg["battle_id"]
    other_name = msg["trainer_a_name"]
    return unless battle_id && other_name

    # Matchmaking-originated challenges skip the confirm dialog — joining
    # the matchmaking queue already was the consent, and both sides are
    # already sitting in the same synthetic session waiting for exactly
    # this to happen.
    is_matchmaking = (msg["matchmaking"] == "true" || msg["matchmaking"] == true)
    accept = is_matchmaking || pbConfirmMessage("#{other_name} wants to battle! Accept?")

    if accept
      WSClient.send_json({
        "action"       => "battle_accepted",
        "battle_id"    => battle_id,
        "trainer_id"   => $player.id.to_s,
        "trainer_b_id" => msg["trainer_a_id"],
        "session_code" => Online.current_session
      })
      puts "[Battle] battle_accepted sent for #{battle_id} (matchmaking=#{is_matchmaking})"

      # I did not initiate this challenge, so I don't send a seed — the
      # challenger generates and sends the shared seed alongside their party.
      Online.send_my_battle_party(battle_id)

      pbMessage("Waiting for #{other_name}'s party...") unless is_matchmaking
      other_party_hashes, seed = Online.wait_for_opponent_battle_party(battle_id)
      if other_party_hashes.nil? || seed.nil?
        pbMessage("#{other_name} didn't send their party/seed in time.")
        Online.leave_matchmaking_session if is_matchmaking
        return
      end

      Online.run_local_online_battle(battle_id, other_party_hashes, other_name, seed)
      Online.leave_matchmaking_session if is_matchmaking
    else
      WSClient.send_json({
        "action"    => "battle_declined",
        "battle_id" => battle_id
      })
    end
  end
end

class Scene_Map
  def initiate_battle(player)
    battle_id = Online.request_battle_challenge(player)
    return unless battle_id

    result = Online.wait_for_battle_response(battle_id)
    case result
    when :timeout   then pbMessage("#{player.name} didn't respond in time.")
    when :declined  then pbMessage("#{player.name} declined the battle.")
    when :cancelled then pbMessage("Battle challenge cancelled.")
    when :accepted
      # I initiated the challenge, so I generate and send the shared seed.
      seed = rand(2**31)
      Online.send_my_battle_party(battle_id, seed: seed)

      pbMessage("Waiting for #{player.name}'s party...")
      other_party_hashes, _ = Online.wait_for_opponent_battle_party(battle_id)
      if other_party_hashes.nil?
        pbMessage("#{player.name} didn't send their party in time.")
        return
      end

      Online.run_local_online_battle(battle_id, other_party_hashes, player.name, seed)
    end
  end
end
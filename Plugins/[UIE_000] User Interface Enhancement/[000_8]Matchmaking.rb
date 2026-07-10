#==============================================================================#
#                    Online System — Live Matchmaking                          #
#==============================================================================#
MatchmakingOpponent = Struct.new(:id, :name)

module Online
  MATCHMAKING_TIMEOUT = 60  # seconds to wait for an opponent before giving up

  #=============================================================================
  # Join the matchmaking queue and block until either a match is found, the
  # player cancels, or it times out. Sends matchmaking_join immediately;
  # caller is responsible for calling leave_matchmaking_queue on timeout
  # (cancel already does this internally).
  #=============================================================================
  def self.wait_for_match_found
    WSClient.send_json({
      "action"       => "matchmaking_join",
      "trainer_id"   => $player.id.to_s,
      "trainer_name" => $player.name
    })
    puts "[Matchmaking] Joined queue as #{$player.id}"

    start_time = Time.now
    loop do
      Graphics.update
      Input.update

      if Time.now - start_time > MATCHMAKING_TIMEOUT
        return :timeout
      end

      # Cancel with the same button used to back out of other online waits.
      if Input.trigger?(Input::BACK)
        leave_matchmaking_queue
        return :cancelled
      end

      result = nil
      WSClient.poll.each do |msg|
        next unless msg
        if msg["action"] == "match_found"
          result ||= msg
        else
          OnlinePlayers.set_pending_trade(msg)
        end
      end
      return result if result

      sleep(0.05)
    end
  end

  def self.leave_matchmaking_queue
    WSClient.send_json({
      "action"     => "matchmaking_leave",
      "trainer_id" => $player.id.to_s
    })
    puts "[Matchmaking] Left queue"
  end

  #=============================================================================
  # Join the synthetic matchmaking session — WS-only, no Supabase session row
  # (this pairing is ephemeral and was never meant to be browsable). Reuses
  # the exact same ws_connect used by host_session/join_session.
  #=============================================================================
  def self.join_matchmaking_session(session_code, is_host:)
    @current_session      = session_code
    @is_session_host      = is_host
    @is_matchmaking_session = true
    Online.ws_connect(session_code, $player.id)
    puts "[Matchmaking] Joined synthetic session #{session_code} as #{is_host ? "challenger" : "opponent"}"
  end

  def self.matchmaking_session?
    @is_matchmaking_session == true
  end

  # Teardown counterpart — deliberately skips leave_session's Supabase calls,
  # since there was never a Supabase row for this session to begin with.
  # Uses the same lightweight ws_leave_session as a normal session leave —
  # NOT a full disconnect, which would kill the presence connection and
  # silently break the next matchmaking_join (this was the actual cause of
  # "can't find a match after finishing a battle": the socket was already
  # closed by the time the next queue attempt tried to use it).
  def self.leave_matchmaking_session
    return unless in_session?
    Online.ws_leave_session(@current_session, $player.id)
    OnlinePlayers.clear
    puts "[Matchmaking] Left synthetic session #{@current_session}"
    @current_session         = nil
    @is_session_host         = false
    @is_matchmaking_session  = false
  end

  #=============================================================================
  # Entry point — call this to start looking for a live opponent. Handles
  # the whole flow: queue -> pairing -> synthetic session -> battle -> cleanup.
  #=============================================================================
  def self.start_quick_match
    unless features_enabled?
      pbMessage("Enable online features first.")
      return
    end
    if in_session?
      pbMessage("Leave your current session before starting a quick match.")
      return
    end

    pbMessage("Searching for an opponent...")
    result = wait_for_match_found

    case result
    when :cancelled
      pbMessage("Matchmaking cancelled.")
    when :timeout
      leave_matchmaking_queue
      pbMessage("No opponent found. Try again later.")
    else
      opponent_id   = result["opponent_id"]
      opponent_name = result["opponent_name"]
      session_code  = result["session_code"]
      is_challenger = result["role"] == "challenger"

      join_matchmaking_session(session_code, is_host: is_challenger)

      if is_challenger
        pbMessage("Match found! Challenging #{opponent_name}...")
        $scene.start_matchmaking_battle(opponent_id, opponent_name)
      else
        # Nothing else to do here — the challenger's (auto-accepted)
        # battle_challenge will arrive and get handled automatically by the
        # normal Game_Player#update routing, the same way any other
        # incoming challenge does, while the player just keeps playing.
        pbMessage("Match found! Waiting for #{opponent_name} to start the battle...")
      end
    end
  end
end

#==============================================================================#
# Challenger-side flow for a matched quick battle — mirrors initiate_battle,
# but skips straight to sending the (matchmaking-tagged, auto-accepted)
# challenge instead of waiting on a ghost-menu interaction first, since the
# opponent is already known and already consented by queuing up.
#==============================================================================#
class Scene_Map
  def start_matchmaking_battle(opponent_id, opponent_name)
    opponent  = MatchmakingOpponent.new(opponent_id, opponent_name)
    battle_id = Online.request_battle_challenge(opponent, matchmaking: true)
    unless battle_id
      Online.leave_matchmaking_session
      return
    end

    result = Online.wait_for_battle_response(battle_id)
    case result
    when :timeout   then pbMessage("#{opponent_name} didn't respond in time.")
    when :declined  then pbMessage("#{opponent_name} declined the battle.")
    when :cancelled then pbMessage("Battle challenge cancelled.")
    when :accepted
      seed = rand(2**31)
      Online.send_my_battle_party(battle_id, seed: seed)

      other_party_hashes, _ = Online.wait_for_opponent_battle_party(battle_id)
      if other_party_hashes.nil?
        pbMessage("#{opponent_name} didn't send their party in time.")
        Online.leave_matchmaking_session
        return
      end

      Online.run_local_online_battle(battle_id, other_party_hashes, opponent_name, seed)
    end

    Online.leave_matchmaking_session
  end
end
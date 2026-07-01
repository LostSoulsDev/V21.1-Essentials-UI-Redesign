def pbGenerateOverworldEncounters(water = false)
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if !$PokemonEncounters
  return if $player.able_pokemon_count == 0

  if VOESettings.current_encounters < VOESettings.get_max
    enc_type = nil

    # ---------------------------
    # Decide land vs water spawn
    # ---------------------------
    water = false

    if $PokemonEncounters.find_valid_encounter_type_for_time(:Water, pbGetTimeNow)
      # 25% chance to try a water spawn
      water = true if rand(100) < 25
    end

    # Ask the tile picker for what we want
    tile = get_grass_tile(water)

    # If we tried for water but no valid water tiles exist, fall back to land
    if tile == [] && water
      water = false
      tile = get_grass_tile(false)
    end

    # Still nothing? Just bail
    return if tile == []

    # Use terrain_tag, not pbGetTileID, to decide water vs land
    terrain_id = $game_map.terrain_tag(tile[0], tile[1]).id
    water = VOESettings::WATER_TILES.include?(terrain_id)

    echoln "# --------------------------------------------------------------- #" if VOESettings::LOG_SPAWNS
    echoln "[generateOWEncounter] terrain=#{terrain_id} tile=#{tile} [Water? #{water}]" if VOESettings::LOG_SPAWNS

if water
  enc_type = nil
  # Try the time-based water variants first
  [:WaterMorning, :WaterDay, :WaterEvening, :WaterNight, :Water].each do |try|
    next unless $PokemonEncounters.has_encounter_type?(try)
    enc_type = try
    break
  end
else
  enc_type = nil
  # Try time-based land variants first
  [:LandMorning, :LandDay, :LandEvening, :LandNight, :Land, :Cave].each do |try|
    next unless $PokemonEncounters.has_encounter_type?(try)
    enc_type = try
    break
  end
end

if enc_type.nil?
  echoln "[VOE] No valid encounter type found for this terrain/time."
  return
end

if voe_repel_active?
  px = $game_player.x
  py = $game_player.y
  if ((tile[0] - px).abs + (tile[1] - py).abs) <= 5
    return   # skip spawning too close during repel
  end
end

#if water
#  enc_type = $PokemonEncounters.find_valid_encounter_type_for_time(:Water, pbGetTimeNow)
#else
#  enc_type = $PokemonEncounters.find_valid_encounter_type_for_time(:Land, pbGetTimeNow)
#  if enc_type.nil?
#    enc_type = $PokemonEncounters.has_cave_encounters? ? $PokemonEncounters.find_valid_encounter_type_for_time(:Cave, pbGetTimeNow) : $PokemonEncounters.encounter_type
#  end
#end

#echoln "[generateOWEncounter line 26] #{enc_type}" if VOESettings::LOG_SPAWNS
#return if enc_type.nil?

    # ========================
    # Create Pokemon Routine
    # ========================

    if VOESettings::DIFFERENT_ENCOUNTERS
      pkmn = pbChooseWildPokemonByVersion($game_map.map_id, enc_type, VOESettings::ENCOUNTER_TABLE)
    else
      pkmn = $PokemonEncounters.choose_wild_pokemon_for_map($game_map.map_id, enc_type)
    end

    pkmn = Pokemon.new(pkmn[0], pkmn[1])

    echoln "# --------------------------------------------------------------- #" if VOESettings::LOG_SPAWNS

    if [:SCATTERBUG, :SPEWPA, :VIVILLON].include?(pkmn.species)
      debug = true
      region = pbGetCurrentRegion

      v_form = case region
        when 0; 3 # Creatia: Garden Pattern
        else; 0         end
      pkmn.form = v_form
      echoln "Vivillon family changed to form #{v_form}" if debug
    end

    echoln "Spawning #{pkmn.name} (Water? #{water})" if VOESettings::LOG_SPAWNS

    pkmn.level = (pkmn.level + rand(-2..2)).clamp(2, GameData::GrowthRate.max_level)
    pkmn.calc_stats
    pkmn.reset_moves
    #pkmn.shiny = rand(VOESettings::SHINY_RATE) == 1
	if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
	  pkmn.shiny = true
	else
	  pkmn.shiny = rand(VOESettings::SHINY_RATE) == 1
	end

    echoln "#{pkmn.name} nature: #{pkmn.nature.id} (#{pkmn.nature.id.class.to_s})" if VOESettings::LOG_SPAWNS

    # ========================
    # Create Event Routine
    # ========================
    r_event = Rf.create_event do |e|
      # Event Name
      e.name = water ? "OverworldPkmn_Swim" : "OverworldPkmn"
      e.name = e.name + " Reflection" if VOESettings::REFLECTION_MAP_IDS.include?($game_map.map_id)
      e.name = e.name + " (Shiny)" if pkmn.shiny?

      # Event position
      e.x = tile[0]
      e.y = tile[1]

      # Event Page
      e.pages[0].step_anime = true
      e.pages[0].trigger = 0
      e.pages[0].list.clear
      e.pages[0].move_speed = 2
      e.pages[0].move_frequency = 2

	  move_data = VOEMovement::Poke_Move[pkmn.species] || VOEMovement::Poke_Move[pkmn.species.to_sym]
	  move_data = VOEMovement::Nature_Move[pkmn.nature.id] unless move_data

	  is_aggressive = false
	  species = pkmn.species
	  
	if voe_repel_active?
	  is_aggressive = false
	else
	  if VOESettings::AGGRESSIVE_SPECIES.include?(species)
	    chance = VOESettings::SPECIFIC_AGGRESSION_CHANCE[species] || 30
	    is_aggressive = rand(100) < chance
	  else
	    is_aggressive = rand(100) < VOESettings::BASE_AGGRESSION_CHANCE
  	  end
	end
	  
	if is_aggressive
	  base = water ? "OverworldPkmn_Swim" : "OverworldPkmn"
	  tags = []
	  tags << "Reflection" if VOESettings::REFLECTION_MAP_IDS.include?($game_map.map_id)
	  tags << "Shiny" if pkmn.shiny?
	  tags << "Aggressive"
	  e.name = "#{base} #{tags.map { |t| "(#{t})" }.join(' ')}"
	end

	if move_data
		route = RPG::MoveRoute.new
		route.repeat = true
		route.skippable = true
		route.list = pbConvertMoveCommands(move_data[:move_route])

		e.pages[0].move_speed = move_data[:move_speed]     if move_data.has_key?(:move_speed)
		e.pages[0].move_frequency = move_data[:move_frequency] if move_data.has_key?(:move_frequency)
		e.pages[0].move_type = 3
		e.pages[0].move_route = route

		# Trigger by touch if aggressive or explicitly requested
		if is_aggressive || (move_data.has_key?(:touch) && move_data[:touch] == true)
		  e.pages[0].trigger = 2
		else
		  e.pages[0].trigger = 0
	    end
	  end

	  Compiler.push_script(e.pages[0].list, "pbInteractOverworldEncounter")
	  Compiler.push_end(e.pages[0].list)
	  e.pages[0].trigger = 2 #Added perm event touch trigger
    end

    event = r_event[:event]
	echoln "[generateOWEncounter] Spawned #{event.name} (#{pkmn.species}) for #{enc_type}" if VOESettings::LOG_SPAWNS
	
    event.setVariable([pkmn, r_event])
    echoln "Spawned Event Name: #{event.name}" if VOESettings::LOG_SPAWNS

    spriteset = $scene.spriteset($game_map.map_id)
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    if pkmn.shiny?
      pbSEPlay(VOESettings::SHINY_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 100) if dist <= 6 && dist >= 0 unless VOESettings::DISABLE_VOE_SOUNDS
      spriteset&.addUserAnimation(VOESettings::SHINY_ANIMATION, event.x, event.y, true, 1)
    end
    pbChangeEventSprite(event, pkmn, water)
    event.direction = rand(1..4) * 2
    event.through = false
    spriteset&.addUserAnimation(VOESettings::SPAWN_ANIMATION, event.x, event.y, true, 1)
    GameData::Species.play_cry_from_pokemon(pkmn, [75, 65, 55, 40, 27, 22, 15][dist]) if dist <= 6 && dist >= 0 && rand(20) == 1 unless dist.nil?
    VOESettings.current_encounters += 1
  end
end
#ADDED
def pbAggressiveRush(evt)
  return if voe_repel_active?
  return if evt.nil?
  return if evt.respond_to?(:erased?) ? evt.erased? : (evt.instance_variable_defined?(:@erased) && evt.instance_variable_get(:@erased))
  return unless evt.name[/Aggressive/i]
  return if evt.move_route_forcing   # already mid-action
  return if pbDistanceToPlayer(evt) > 5  # only rush when nearby

  # 10% chance per update to rush
  return unless rand(100) < 10

  # Optional warning animation (!)
  spriteset = $scene.spriteset($game_map.map_id)
  spriteset&.addUserAnimation(1, evt.x, evt.y, true, 1) # animation ID 1 is usually "!"

  # Optional warning sound
  pbSEPlay("Player run", 80, 120) if rand(2) == 0 unless VOESettings::DISABLE_VOE_SOUNDS

  # Rush toward player at high speed for 4 steps
  route = RPG::MoveRoute.new
  route.repeat = false
  route.skippable = true
  route.list = [
    RPG::MoveCommand.new(29, [5]),  # change_speed: 5
    RPG::MoveCommand.new(10),       # move_toward_player
    RPG::MoveCommand.new(10),
    RPG::MoveCommand.new(10),
    RPG::MoveCommand.new(10),
    RPG::MoveCommand.new(29, [3]),  # reset to normal speed
    RPG::MoveCommand.new(0)
  ]
  evt.force_move_route(route)
end

EventHandlers.add(:on_enter_map, :clear_previous_overworld_encounters,
  proc { |old_map_id|
    next if VOESettings::BLACK_LIST_MAPS.include?($game_map.map_id)
    next if $game_map.map_id < 2
    next if old_map_id.nil? || old_map_id < 2
    next unless $map_factory

    # ----------------------------------------------------
    # NEW: Skip map-change despawn entirely if disabled
    # ----------------------------------------------------
    unless VOESettings::DEV_DISABLE_MAP_DESPAWN
      map = $map_factory.getMapNoAdd(old_map_id)
      map.events.each_value do |event|
        next unless event.name[/OverworldPkmn/i]
        pbDestroyOverworldEncounter(event, true, false)
      end
      VOESettings.current_encounters = 0
    end

    pbGenerateOverworldEncounters
  }
)

EventHandlers.add(:on_new_spriteset_map, :fix_exisitng_overworld_encounters,
  proc {
    # Blacklist
    next if VOESettings::BLACK_LIST_MAPS.include?($game_map.map_id)
    next if $game_map.map_id < 2
    next if !$PokemonEncounters

    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?
      pkmn = event.variable[0]
      next if pkmn.nil?

      terrain_id = $game_map.terrain_tag(event.x, event.y).id
      water = VOESettings::WATER_TILES.include?(terrain_id)

      pbChangeEventSprite(event, pkmn, water)
    end
  }
)

EventHandlers.add(:on_frame_update, :move_overworld_encounters,
  proc {
    # --- Safety & early-outs (keep these) ---
    next if VOESettings::BLACK_LIST_MAPS.include?($game_map.map_id)
    next if $game_map.map_id < 2
    next if VOESettings::DISABLE_SETTINGS || $PokemonSystem.owpkmnenabled == 1
    next if $game_temp.in_menu
    next if !$PokemonEncounters

    # --- Time tracking in seconds (not frames) ---
    $game_temp.frames_updated += 1
    seconds_passed = $game_temp.frames_updated / Graphics.frame_rate.to_f

    # Ask settings for the current interval (seconds) and burst size (count)
    eff_interval, eff_spawns = VOESettings.effective_spawn_params

    # Not time yet? bail out
    next if seconds_passed < eff_interval

    # Time reached → reset the counter
    $game_temp.frames_updated = 0

    # -------------------------------------------------
    # 1. UPDATE EXISTING OVERWORLD POKÉMON (THROTTLED)
    #    This runs once per interval, not every frame,
    #    so they don't zoom around.
    # -------------------------------------------------
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?
      pbPokemonIdle(event)
    end

    # -------------------------------------------------
    # 2. DURING AN OVERWORLD BATTLE:
    #    - Keep AI frozen via pbPokemonIdle's guard
    #    - BUT don't spawn new Pokémon
    # -------------------------------------------------
    if $game_temp.overworld_encounter
      next
    end

    # -------------------------------------------------
    # 3. SPAWN NEW POKÉMON (RESPECTS MAX_PER_MAP INTERNALLY)
    #    Only once per interval; no double-spawns.
    # -------------------------------------------------
    max_spawn_per_frame = VOESettings::MAX_SPAWNS_PER_FRAME
    eff_spawns.times do |i|
      break if i >= max_spawn_per_frame
      pbGenerateOverworldEncounters
    end
  }
)



# --- Spawn new Pokémon only on interval ---
#if seconds_passed >= eff_interval
#  $game_temp.frames_updated = 0
#
#  max_spawn_per_frame = VOESettings::MAX_SPAWNS_PER_FRAME
#  eff_spawns.times do |i|
#    break if i >= max_spawn_per_frame
#    pbGenerateOverworldEncounters
#  end
#end

    # --- Spawn new Pokémon this tick (respects max-per-map internally) ---
    #eff_spawns.times { pbGenerateOverworldEncounters }


EventHandlers.add(:on_step_taken, :despawn_on_trainer,
                  proc { |event|
  # Blacklist
  next if VOESettings::BLACK_LIST_MAPS.include?($game_map.map_id)

  next if $game_map.map_id < 2
  next if !$scene.is_a?(Scene_Map)
  next if VOESettings::DISABLE_SETTINGS || $PokemonSystem.owpkmnenabled == 1
  next if $game_temp.in_menu
  next if !$PokemonEncounters
  next if voe_repel_active?   # NEW: trainers don't cull OW Pokémon under repel
  $game_map.events.each_value do |event|
    next unless event.name[/OverworldPkmn/i]
    next if event.variable.nil?
    next if VOESettings::AGGRESSIVE_PERSIST && voe_aggressive_event?(event)
    pbDestroyOverworldEncounter(event) if pbTrainersSeePkmn(event)
  end
})

EventHandlers.add(:on_new_spriteset_map, :voe_cleanup_invalid_events,
  proc {
    next unless VOESettings::AUTO_CLEANUP_INVALID
    next if $game_map.map_id < 2

    removed = 0

    $game_map.events.each_value do |ev|
      # Only look at VOE-generated events
      next unless ev.name[/OverworldPkmn/i]

      # Determine if the event is invalid
      invalid = ev.variable.nil? || !ev.variable.is_a?(Array) || ev.variable[0].nil?

      if VOESettings::CLEANUP_STRICT
        # Extra sanity checks (optional but recommended)
        invalid ||= !ev.respond_to?(:x) || !ev.respond_to?(:y)
		if ev.respond_to?(:erased?)
		  invalid ||= ev.erased?
		elsif ev.instance_variables.include?(:@erased)
		  invalid ||= ev.instance_variable_get(:@erased)
		end
        invalid ||= (ev.character_name.nil? || ev.character_name == "")
      end

      next unless invalid

      # Try to delete via VOE's stored reference if available
      begin
        if ev.variable.is_a?(Array) && ev.variable[1]
          # When r_event was kept, VOE deletes with Rf.delete_event(r_event)
          Rf.delete_event(ev.variable[1]) rescue nil
        else
          # Fallback: hide/erase event safely for this session
          ev.setVariable(nil) if ev.respond_to?(:setVariable)
          ev.through = true   if ev.respond_to?(:through=)
          ev.character_name = "" rescue nil
          ev.erase rescue nil
        end
        removed += 1
      rescue
        # Swallow any odd errors and continue cleaning
      end
    end

    # Recount active VOE encounters so spawner logic stays accurate
    count = 0
    $game_map.events.each_value do |ev|
      next unless ev.name[/OverworldPkmn/i]
      next if ev.variable.nil? || !ev.variable.is_a?(Array) || ev.variable[0].nil?
      count += 1
    end
    VOESettings.current_encounters = count

    echoln "[VOE] Cleanup removed #{removed} invalid OW encounters; #{count} remain." if VOESettings::CLEANUP_LOG
  }
)

EventHandlers.add(:on_frame_update, :voe_fast_repel_flee,
  proc {
    next unless voe_repel_active?
    next if $game_map.map_id < 2
    next if !$PokemonEncounters
    next if $game_temp.in_menu

    # Fast flee update (every frame while repel active)
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?

      # If too close → force immediate flee
      if voe_player_within?(event, 5)   # 5 tiles is good; adjust if needed
        route = RPG::MoveRoute.new
        route.repeat    = false
        route.skippable = true
        route.list      = [
          pbConvertMoveCommands([:move_away_from_player])[0],
		  pbConvertMoveCommands([:move_forward])[0],
          RPG::MoveCommand.new(0)
        ]
        event.force_move_route(route)
      end
    end
  }
)
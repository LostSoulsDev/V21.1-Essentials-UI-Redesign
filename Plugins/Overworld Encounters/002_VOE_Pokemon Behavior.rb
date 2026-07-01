# ===========================================
# Overworld interaction → battle launcher
# - Supports optional double battles.
# - Robust safety checks.
# - Always clears $game_temp.overworld_encounter.
# ===========================================
def pbInteractOverworldEncounter
  # Early safety: cancel if not a valid event or map
  return if !$game_map || !$game_temp
  return if $PokemonGlobal.bridge > 0

  $game_temp.overworld_encounter = true
  begin
    # Try to get the calling event
    evt = pbMapInterpreter.get_self rescue nil
    if evt.nil?
      echoln "[VOE] pbInteractOverworldEncounter called with no event context."
      return
    end

    # Lock the event so it doesn’t move mid-interaction
    evt.lock if evt.respond_to?(:lock)
	pbFreezeEvent(evt)    # <--- freezes main Pokémon immediately

    # Verify the event has variable data
    if evt.variable.nil? || !evt.variable.is_a?(Array) || evt.variable[0].nil?
      echoln "[VOE] Invalid event (ID #{evt.id}) missing variable data – removing safely."
      pbDestroyOverworldEncounter(evt) if defined?(pbDestroyOverworldEncounter)
      return
    end

    # Retrieve the Pokémon object
    pkmn = evt.variable[0]
    if pkmn.nil?
      echoln "[VOE] Event (ID #{evt.id}) had nil Pokémon variable – cleaning up."
      pbDestroyOverworldEncounter(evt)
      return
    end

    # --- Everything validated, proceed with interaction ---
    GameData::Species.play_cry_from_pokemon(pkmn)
    name = pkmn.name
    textcol = ""
    if VOESettings::COLORFUL_TEXT
      textcol = "\\b" if pkmn.male?
      textcol = "\\r" if pkmn.female?
    end
    pbMessage(_INTL("{1}{2}!", textcol, name))

    # --- Double battle (optional) ---
    if VOESettings::ALLOW_DOUBLE_BATTLES
      touching = []
      $game_map.events.each_value do |ev|
        next unless ev.name[/OverworldPkmn/i]
        next if ev == evt
        next if ev.variable.nil? || ev.variable[0].nil?
        dx = (ev.x - $game_player.x).abs
        dy = (ev.y - $game_player.y).abs
        touching << ev if dx <= 1 && dy <= 1
      end

      if touching.length >= 1
        other_evt  = touching.first
        other_pkmn = other_evt.variable[0]
		pbFreezeEvent(other_evt)
		pbFreezeEvent(evt)

        pbMessage(_INTL("A wild {1} and {2} appeared!", pkmn.name, other_pkmn.name))
        decision = WildBattle.start(pkmn, other_pkmn)

        # Clean up both Pokémon after battle
        pbDestroyOverworldEncounter(evt,       decision == 4, decision != 4)
        pbDestroyOverworldEncounter(other_evt, decision == 4, decision != 4)
        return
      end
    end

    # --- Normal single battle fallback ---
    decision = WildBattle.start(pkmn)
    pbDestroyOverworldEncounter(evt, decision == 4, decision != 4)
  ensure
    # Always clear, even if something raises
    $game_temp.overworld_encounter = false
  end
end

# ===========================================
# Trainers see OW Pokémon?
# ===========================================
def pbTrainersSeePkmn(evt)
  result = false
  return result if $game_system.map_interpreter.running? # event running
  $game_map.events.each_value do |event|
    next if !event.name[/trainer\((\d+)\)/i] && !event.name[/sight\((\d+)\)/i]
    distance = $~[1].to_i
    next if !pbEventCanReachPlayer?(event, evt, distance)
    next if event.jumping? || event.over_trigger?
    result = true
  end
  return result
end

# ===========================================
# Tile picker around player (supports land/water)
# - force_water: true  -> only water tiles
#               false -> only grass/cave tiles (never water)
# Respects WATER_SPAWNS_ONLY_SURFING correctly.
# ===========================================
def get_grass_tile(force_water = false)
  possible_tiles = []
  possible_distance = (VOESettings::MAX_DISTANCE * 0.75).round

  (($game_player.x - possible_distance)..($game_player.x + possible_distance)).each do |x|
    next if x < 0 || x >= $game_map.width
    (($game_player.y - possible_distance)..($game_player.y + possible_distance)).each do |y|
      next if y < 0 || y >= $game_map.height
      next if x == $game_player.x && y == $game_player.y

      terrain_id = $game_map.terrain_tag(x, y).id

      # Block impassable tiles for land; allow water tiles even if impassable for player
      unless VOESettings::WATER_TILES.include?(terrain_id)
        next if !$game_map.passable?(x, y, 0)
      end

      # Don't spawn if on top of an event
      on_top = false
      $game_map.events.each_value do |event|
        next unless event.at_coordinate?(x, y)
        on_top = true
        break
      end
      next if on_top

      # Don't spawn if a trainer can see it
      next if pbTrainersSeePkmn(Temp_Event.new(x, y, $game_map.map_id))

      # --- Terrain gating by requested kind ---
      if force_water
        # Only water tiles are valid
        next unless VOESettings::WATER_TILES.include?(terrain_id)
      else
        # Land: only grass/cave-ish tiles (and explicitly not water)
        next unless (
          VOESettings::GRASS_TILES.include?(terrain_id) ||
          ($PokemonEncounters.has_cave_encounters? && !VOESettings::WATER_TILES.include?(terrain_id))
        )
      end

      # Optional dev rule: water spawns only when surfing
      if VOESettings::WATER_SPAWNS_ONLY_SURFING && !force_water
        # If we're selecting land tiles, leave them alone.
        # If someone mistakenly passed force_water=false on water tiles, the test above already excluded them.
      elsif VOESettings::WATER_SPAWNS_ONLY_SURFING && force_water
        # We are selecting water tiles; enforce surfing requirement
        next unless $PokemonGlobal.surfing
      end

      # Optional water blacklist per-map
      if VOESettings::BLACK_LIST_WATER.include?($game_map.map_id) &&
         VOESettings::WATER_TILES.include?(terrain_id)
        next
      end

      possible_tiles << [x, y]
    end
  end

  return (possible_tiles.empty? ? [] : possible_tiles.sample)
end

# ===========================================
# Safe despawn
# ===========================================
def pbDestroyOverworldEncounter(event, animation = true, play_sound = false)
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if !event || event.variable.nil?
  return if !event.variable.is_a?(Array) || event.variable[0].nil?

  unless $game_variables[1] == 1 || $game_variables[1] == 4
    #return if event.variable[0].shiny? && VOESettings::DELETE_SHINY == false
	if event.variable[0].shiny? && !VOESettings::DELETE_SHINY
	  battled = play_sound
	  return unless battled
	end
  end

  echoln "Despawning #{event.variable[0].name}" if VOESettings::LOG_SPAWNS

  if play_sound
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    pbSEPlay(VOESettings::FLEE_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 150) if dist && dist.between?(0,6) unless VOESettings::DISABLE_VOE_SOUNDS
  end

  spriteset = $scene.spriteset($game_map.map_id)
  spriteset&.addUserAnimation(VOESettings::SPAWN_ANIMATION, event.x, event.y, true, 1) if animation

  if VOESettings::DELETE_EVENTS
    Rf.delete_event(event.variable[1]) rescue nil
  else
    event.setVariable(nil) rescue nil
    event.moveto(0, 0)     rescue nil
    event.through = true   rescue nil
    event.character_name = "" rescue nil
    event.erase            rescue nil
  end

  # Clamp to 0 to avoid negatives when multiple cleanups happen
  VOESettings.current_encounters = [VOESettings.current_encounters - 1, 0].max
  $game_variables[1] = 0
end

# ===========================================
# Distance helper
# ===========================================
def pbDistanceToPlayer(evt)
  return nil if !evt
  dx = evt.x - $game_player.x
  dy = evt.y - $game_player.y
  return Math.sqrt(dx * dx + dy * dy).round
end

def voe_player_within?(evt, max_tiles)
  return false if !evt || !$game_player
  dx = $game_player.x - evt.x
  dy = $game_player.y - evt.y
  distance = Math.sqrt(dx * dx + dy * dy)
  return distance <= max_tiles
end

# ===========================================
# Repel helper
# ===========================================
def voe_repel_active?
  repel = $PokemonGlobal&.repel
  return false if repel.nil?
  repel > 0
end

# ===========================================
# Idle tick for OW Pokémon
# - Respects AGGRESSIVE_PERSIST
# - Self-despawn if too far / invalid terrain (except aggressive/shiny)
# - Aggressive rush + proximity auto-battle
# ===========================================
# ===========================================
# Idle tick for OW Pokémon
# - Respects AGGRESSIVE_PERSIST
# - Self-despawn if too far / invalid terrain (except aggressive/shiny)
# - Aggressive rush + proximity auto-battle
# - Repel: Pokémon flee instead of despawning
# ===========================================
def pbPokemonIdle(evt)
  echoln "REPEL CHECK: #{$PokemonGlobal.repel} -> #{voe_repel_active?}"
  # Don't run any OW AI during an overworld battle
  return if $game_temp.overworld_encounter
  return if !evt
  return pbDestroyOverworldEncounter(evt) if evt.variable.nil?

  # ===========================================
  # REPEL ACTIVE → ALWAYS FLEE, EVEN IF LOCKED
  # ===========================================
  if voe_repel_active?
    # Cancel any existing forced route so repel always wins
    if evt.move_route_forcing
      empty = RPG::MoveRoute.new
      empty.repeat    = false
      empty.skippable = true
      empty.list      = [RPG::MoveCommand.new(0)]
      evt.force_move_route(empty)
    end

    # If close to player → use dedicated flee route
    if voe_player_within?(evt, 5)
      if VOEMovement::RepelFlee && VOEMovement::RepelFlee[:move_route]
        route = RPG::MoveRoute.new
        route.repeat    = false
        route.skippable = true
        route.list      = pbConvertMoveCommands(VOEMovement::RepelFlee[:move_route])
        evt.force_move_route(route)
      else
        # Fallback: just move away from player
        route = RPG::MoveRoute.new
        route.repeat    = false
        route.skippable = true
        route.list      = [
          pbConvertMoveCommands([:move_away_from_player])[0],
          RPG::MoveCommand.new(0)
        ]
        evt.force_move_route(route)
      end
    else
      # Far away → wander but NEVER toward player
      safe_moves = [:move_away_from_player, :move_random]
      cmd = pbConvertMoveCommands([safe_moves.sample])[0]
      route = RPG::MoveRoute.new
      route.repeat    = false
      route.skippable = true
      route.list      = [cmd, RPG::MoveCommand.new(0)]
      evt.force_move_route(route)
    end

    # IMPORTANT: skip all normal logic (no despawn, no aggression)
    return
  end

  # ===========================================
  # Normal behaviour (only when NOT under repel)
  # ===========================================

  # For normal AI, DO respect event lock
  return if evt.lock?

  # Throttle idle AI a bit
  return if rand(3) == 1

  # Cull if on invalid terrain or random fade, unless shiny/aggressive-persist
  invalid_terrain = (
    !VOESettings::GRASS_TILES.include?($game_map.terrain_tag(evt.x, evt.y).id) &&
    !VOESettings::WATER_TILES.include?($game_map.terrain_tag(evt.x, evt.y).id) &&
    (!$PokemonEncounters.has_cave_encounters? && !$PokemonGlobal.diving)
  )
  random_fade = (rand(225) == 1)
  if random_fade || invalid_terrain ||
     ($PokemonGlobal.diving && $game_map.terrain_tag(evt.x, evt.y).id != :UnderwaterGrass)
    unless evt.variable[0].shiny? || (VOESettings::AGGRESSIVE_PERSIST && voe_aggressive_event?(evt))
      pbDestroyOverworldEncounter(evt)
      return
    end
  end

  # Simple wander
  evt.move_random

  # Too far away → despawn unless shiny/aggressive-persist
  if (dist = pbDistanceToPlayer(evt))
    if dist > VOESettings::MAX_DISTANCE &&
       !evt.variable[0].shiny? &&
       !(VOESettings::AGGRESSIVE_PERSIST && voe_aggressive_event?(evt))
      pbDestroyOverworldEncounter(evt)
      return
    end
    # Occasional cry if nearby
    vol = [75, 65, 55, 40, 27, 22, 15][((evt.x - $game_player.x).abs + (evt.y - $game_player.y).abs) / 4]
    GameData::Species.play_cry_from_pokemon(evt.variable[0], vol) if dist <= 6 && dist >= 0 && rand(20) == 1 && vol
  end

  # Aggressive behavior (only when NOT under repel)
  if evt.name[/\(Aggressive\)/i]
    pbAggressiveRush(evt) # short rush burst (separate helper)

    # Auto-battle trigger on touch
    if (d = pbDistanceToPlayer(evt)) && d <= 1
      pbFreezeEvent(evt)
      pbMessage(_INTL("{1} attacked!", evt.variable[0].name))
      pbInteractOverworldEncounter
    end
  end
end



# ===========================================
# Apply OW sprite to event
# ===========================================
def pbChangeEventSprite(event, pkmn, water = false)
  shiny = pkmn.shiny?
  shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.super_shiny?)

  fname = pbOWSpriteFilename(pkmn.species, pkmn.form, pkmn.gender, shiny, pkmn.shadow, water)
  fname = pbOWSpriteFilename(pkmn.species, 0, pkmn.gender, shiny, pkmn.shadow, water) if pkmn.species == :MINIOR

  raise "Following Pokémon sprites were not found." if nil_or_empty?(fname)
  fname.gsub!("Graphics/Characters/", "")
  event.character_name = fname
  if event.move_route_forcing
    hue = (pkmn.respond_to?(:superHue) && pkmn.super_shiny?) ? pkmn.superHue : 0
    event.character_hue = hue
  end
end

# ===========================================
# Game_Temp extensions
# ===========================================
class Game_Temp
  attr_accessor :overworld_encounter
  attr_accessor :frames_updated

  def overworld_encounter
    @overworld_encounter = false if !@overworld_encounter
    return @overworld_encounter
  end

  def overworld_encounter=(val); @overworld_encounter = val; end

  def frames_updated
    @frames_updated = 0 if !@frames_updated
    return @frames_updated
  end

  def frames_updated=(val); @frames_updated = val; end
end

# ===========================================
# Minimal struct for LOS checks without real event
# ===========================================
class Temp_Event
  attr_reader :x, :y, :map_id
  def initialize(x, y, map_id)
    @x = x
    @y = y
    @map_id = map_id
  end
end

def pbFreezeEvent(ev)
  return if !ev

  route = RPG::MoveRoute.new
  route.repeat     = false
  route.skippable  = true

  route.list = [
    RPG::MoveCommand.new(29, [3]),   # change_speed (safe value)
    RPG::MoveCommand.new(30, [3]),   # change_freq  (safe value)
    RPG::MoveCommand.new(33),        # step_anime_on (prevents visual jitter)
    RPG::MoveCommand.new(35),        # direction_fix_on
    RPG::MoveCommand.new(15, [1]),   # wait 1 frame (forces RM to accept route)
    RPG::MoveCommand.new(0)          # end
  ]

  ev.force_move_route(route)
end
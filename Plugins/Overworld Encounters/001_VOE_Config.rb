# IMPORTANT!!
# If you are using Roaming Pokémon, it is necessary to add
# next if $game_temp.overworld_encounter
# after each mention of: next if $PokemonGlobal.roamedAlready
# otherwise Overworld Encounters can trigger Roaming Battles

class VOESettings
  BLACK_LIST_MAPS = [61, 62, 63, 64, 65, 66]
  BLACK_LIST_WATER = [0]
  REFLECTION_MAP_IDS = [70, 103, 105]
  AGGRESSIVE_SPECIES = [:MIGHTYENA] #Always aggressive species
  BASE_AGGRESSION_CHANCE = 5
  SPECIFIC_AGGRESSION_CHANCE = {
    MIGHTYENA: 30
  }
  AGGRESSIVE_PERSIST = true   # Aggressive overworld Pokémon don't auto-despawn on distance/terrain/sight checks
  DISABLE_VOE_SOUNDS = false
  
  GRASS_TILES = [
    :Grass, :TallGrass, :DeepSand, :SpringGrass, :SpringTallGrass, :SummerGrass, :SummerTallGrass,
    :AutumnGrass, :AutumnTallGrass, :WinterGrass, :WinterTallGrass, :SpringRockyGrass, :SummerRockyGrass,
    :AutumnRockyGrass, :WinterRockyGrass, :SpringForestGrass, :SummerForestGrass, :AutumnForestGrass,
    :WinterForestGrass,
  ]
  WATER_TILES = [
  :Water,        # MovingWater environment
  :StillWater,   # StillWater environment (reflections)
  :DeepWater,    # Dive-capable water
  # Optional custom water types if your tileset adds them:
  :Dirty_Water, :SpringWater, :SummerWater, :AutumnWater, :WinterWater
  ]

  SPAWN_ANIMATION = 2
  SHINY_ANIMATION = 53
  FLEE_SOUND = "Door exit"
  SHINY_SOUND = "Mining reveal"
  LOG_SPAWNS = true
  DISABLE_SETTINGS = false
  MAX_DISTANCE = 20
  DEV_DISABLE_MAP_DESPAWN = true
  DELETE_EVENTS = true
  DELETE_SHINY = false
  BRIGHT_SHINY = true # Shinies won't be affected by DayNight Tone
  COLORFUL_TEXT = true
  WATER_SPAWNS_ONLY_SURFING = false
  
  SPAWNS_PER_TICK = 1 # How many can appear each update
  SPAWN_INTERVAL  = 5 # Time in seconds for each spawn 
  MAX_SPAWNS_PER_FRAME = 2 # Limit amount of spawns per frame for performance
  ALLOW_DOUBLE_BATTLES = true   # If true, two Pokémon touching the player trigger a double wild battle
  
  # Randomized spawning mode
  RANDOM_SPAWN_MODE        = false # true = fully random between min/max
  SPAWN_RANDOM_MIN         = 8.0   # Minimum time in seconds
  SPAWN_RANDOM_MAX         = 15.0   # Maximum time in seconds
  SPAWNS_RANDOM_MIN        = 1     # Minimum number of Pokémon
  SPAWNS_RANDOM_MAX        = 4     # Maximum number of Pokémon
  #Optional cap for random spawn chance (0 = always use random if enabled)
  RANDOM_SPAWN_CHANCE      = 100 # % change to apply randomness each update
  
  
  # --- Dynamic spawn scaling ---
  DYNAMIC_SPAWN       = true # true = enable auto-scaling spawn behaviour
  SPAWN_INTERVAL_MIN  = 3 # fastest spawn interval (seconds) when map is empty
  SPAWN_INTERVAL_MAX  = 20 # slowest spawn interval (seconds) when map is full
  SPAWNS_PER_TICK_MIN = 1 # minimum number of spawns per cycle (when full)
  SPAWNS_PER_TICK_MAX = 4 # maximum number of spawns per cycle (when empty)
  
  # --- Optional "easing" value
  # Controls how quickly spawning slows down as the map fills up.
  # 0.0 = perfectly linear (simple ratio)
  # 0.5 = slows down earlier (reaches max interval sooner)
  # 1.0+ = very steep curve (spawn rate drops sharply as few Pokémon appear)
  
  OCCUPANCY_BIAS      = 0.5 # fine-tune spawn slowdown behaviour
  DEV_DISABLE_TERRAIN_ENCOUNTERS = {
    land:       true,
	cave:       true,
	water:      true,
	fishing:    false,
	rock_smash: false
  }
  
  AUTO_CLEANUP_INVALID      = true # run thh cleanup when a map loads
  CLEANUP_STRICT            = true # extra checks beyond vaiable is nil
  CLEANUP_LOG               = true # console for clean up debug
  
  DIFFERENT_ENCOUNTERS = false
  ENCOUNTER_TABLE = 1

  # Use 0 to disable overworld shinies. Set to (SETTINGS::SHINY_POKEMON_CHANCE / 65536) for normal odds.
  SHINY_RATE = 8192

  # How many encounters will be spawned on each map (mapId => numberOfEvents) (0 = default)
  MAX_PER_MAP = {
    # 42 => 0,
    # 57 => 3,
    0 => 40,
	139 => 10,
  }

  # The amount of encounters currently on the map
  def self.current_encounters
    return 0 unless $game_map

    unless @current_encounters
      count = 0
      $game_map.events.each_value do |event|
        next unless event.name[/OverworldPkmn/i]

        count += 1
      end
      @current_encounters = count
    end
    @current_encounters
  end

  # Setter for the current encounters
  class << self
    attr_writer :current_encounters
  end

  # Get the max amount of encounters for this map
  def self.get_max
    return MAX_PER_MAP[$game_map.map_id] if MAX_PER_MAP[$game_map.map_id]

    MAX_PER_MAP[0]
  end
  
def self.effective_spawn_params
  #--------------------------------------------------
  # 1. Random spawn mode
  #--------------------------------------------------
  if defined?(RANDOM_SPAWN_MODE) && RANDOM_SPAWN_MODE
    if rand(100) < (RANDOM_SPAWN_CHANCE || 100)
      interval = rand(SPAWN_RANDOM_MIN..SPAWN_RANDOM_MAX).to_f
      spawns   = rand(SPAWNS_RANDOM_MIN..SPAWNS_RANDOM_MAX).to_i
      return [interval, spawns]
    else
      # fallback to base values
      return [SPAWN_INTERVAL.to_f, SPAWNS_PER_TICK.to_i]
    end
  end

  #--------------------------------------------------
  # 2. Dynamic spawn scaling mode
  #--------------------------------------------------
  if defined?(DYNAMIC_SPAWN) && DYNAMIC_SPAWN
    cur = current_encounters
    max = [get_max, 1].max
    occ = (cur.to_f / max).clamp(0.0, 1.0)

    # Optional easing (slows earlier if OCCUPANCY_BIAS > 0)
    if defined?(OCCUPANCY_BIAS) && OCCUPANCY_BIAS > 0.0
      occ = (1.0 - (1.0 - occ)**(1.0 + OCCUPANCY_BIAS)).clamp(0.0, 1.0)
    end

    # Interval grows from MIN (empty) → MAX (full)
    interval = SPAWN_INTERVAL_MIN + (SPAWN_INTERVAL_MAX - SPAWN_INTERVAL_MIN) * occ
    interval = interval.clamp(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)

    # Spawn count shrinks from MAX (empty) → MIN (full)
    spawns_f = SPAWNS_PER_TICK_MIN + (SPAWNS_PER_TICK_MAX - SPAWNS_PER_TICK_MIN) * (1.0 - occ)
    spawns = spawns_f.round.clamp(SPAWNS_PER_TICK_MIN, SPAWNS_PER_TICK_MAX)

    return [interval, spawns]
  end

  #--------------------------------------------------
  # 3. Fixed fallback
  #--------------------------------------------------
  return [SPAWN_INTERVAL.to_f, SPAWNS_PER_TICK.to_i]
end
  
end

MenuHandlers.add(
  :options_menu, :owpkmnenabled,
  {
    "name" => _INTL("Overworld Encounters"),
    "order" => 100,
    "type" => EnumOption,
    "parameters" => [_INTL("On"), _INTL("Off")],
    "description" => _INTL("Enable/disable overworld encounters."),
    "condition" => proc { next !VOESettings::DISABLE_SETTINGS },
    "get_proc" => proc { next $PokemonSystem.owpkmnenabled },
    "set_proc" => proc { |value, _scene| $PokemonSystem.owpkmnenabled = value },
  }
)

class Spriteset_Map
  alias voe_update update

  def update
    voe_update

    @character_sprites.each do |sprite|
      next unless sprite.character
      next unless VOESettings::BRIGHT_SHINY
      if sprite.character.name&.include?("(Shiny)")
        sprite.tone.set(0, 0, 0, 0)
      end
    end
  end
end

class PokemonSystem
  attr_accessor :owpkmnenabled # Whether Overworld Pokémon appear (0=on, 1=off)

  def owpkmnenabled=(val); @owpkmnenabled = val; end
  def owpkmnenabled; @owpkmnenabled; end
end

class PokemonOption_Scene
  alias owpkmn_pbEndScene pbEndScene unless method_defined?(:owpkmn_pbEndScene)

  def pbEndScene
    owpkmn_pbEndScene
    if $PokemonSystem.owpkmnenabled == 1 || $PokemonEncounters && VOESettings::DISABLE_SETTINGS
      $game_map.events.each_value do |event|
        next unless event.name[/OverworldPkmn/i]

        pbDestroyOverworldEncounter(event, true, false)
      end
    end
  end
end

# --------------------------------------------------------
# Method from Followers EX Plugin
# --------------------------------------------------------
def pbOWSpriteFilename(species, form = 0, gender = 0, shiny = false, shadow = false, swimming = false)
  # Check for swimming sprites first if swimming
  if swimming
    folder = shiny ? "Swimming Shiny" : "Swimming"
    ret = GameData::Species.check_graphic_file(
      "Graphics/Characters/", species, form,
      gender, shiny, shadow, folder
    )
    return ret if !nil_or_empty?(ret)

    # If no swimming sprite, check for levitate sprites (for airborne Pokemon)
    folder = shiny ? "Levitates Shiny" : "Levitates"
    ret = GameData::Species.check_graphic_file(
      "Graphics/Characters/", species, form,
      gender, shiny, shadow, folder
    )
    return ret if !nil_or_empty?(ret)
  end

  # Fall back to regular follower sprites
  ret = GameData::Species.check_graphic_file(
    "Graphics/Characters/", species, form,
    gender, shiny, shadow, "Followers"
  )
  ret = "Graphics/Characters/Followers/" if nil_or_empty?(ret)
  return ret
end

def pbChooseWildPokemonByVersion(map_ID, enc_type, version)
  # Get the encounter table
  encounter_data = GameData::Encounter.get(map_ID, version)
  enc_list = encounter_data.types[enc_type]

  # Calculate the total probability value
  chance_total = 0

  return [:DITTO, 69] if enc_list.nil?
  enc_list.each { |a| chance_total += a[0] }

  # Escolhe o Pokémon aleatoriamente a partir da Tabela de Encontro
  rnd = rand(chance_total)
  encounter = nil
  enc_list.each do |enc|
    rnd -= enc[0]
    next if rnd >= 0

    encounter = enc
    break
  end

  # Return [species, level]
  level = rand(encounter[2]..encounter[3])
  [encounter[1], level]
end

#def pbGetTileID(map_id, x, y)
#  return 0 if (x == 0 || y == 0) || (x.nil? || y.nil?)
#  debug = false

#  echoln "[getTileID] #{map_id}, #{x}, #{y}" if debug
#  thistile = $map_factory.getRealTilePos(map_id, x, y)
#  map = $map_factory.getMap(thistile[0])
#  tile_id = map.data[thistile[1], thistile[2], 0]

#  echoln "[getTileID] #{tile_id}" if debug
#  return 0 if tile_id == nil
#  return GameData::TerrainTag.try_get(map.terrain_tags[tile_id]).id
#end

def pbGetTileID(map_id, x, y)
  return 0 if x.nil? || y.nil?
  thistile = $map_factory.getRealTilePos(map_id, x, y)
  map = $map_factory.getMap(thistile[0])
  return 0 if !map || !map.data

  # Scan all layers, top-down, and return the first valid terrain tag
  2.downto(0) do |layer|
    tile_id = map.data[thistile[1], thistile[2], layer]
    next if tile_id.nil? || tile_id == 0
    tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id])
    return tag.id if tag
  end
  return 0
end

def pbConvertMoveCommands(list)
  list.map do |entry|
    if entry.is_a?(Symbol)
      # Ex: :move_down
      code = VOE_MOVE_COMMANDS[entry]
      RPG::MoveCommand.new(code)
    elsif entry.is_a?(Array)
      # Ex: [:wait, 30] ou [:jump, 1, -1]
      cmd, *params = entry
      code = VOE_MOVE_COMMANDS[cmd]
      RPG::MoveCommand.new(code, params)
    elsif entry.is_a?(Hash)
      # Ex: { :switch_on => 5 }
      cmd = entry.keys.first
      args = [entry[cmd]].flatten
      code = VOE_MOVE_COMMANDS[cmd]
      RPG::MoveCommand.new(code, args)
    else
      entry
    end
  end
end

# Checks if an event is an aggressive Pokémon
def voe_aggressive_event?(evt)
  return false if evt.nil? || evt.variable.nil? || evt.variable[0].nil?
  return !!(evt.name[/\(Aggressive\)/i])   # true if "(Aggressive)" is in the event's name
end

VOE_MOVE_COMMANDS = {
  move_down: 1,
  move_left: 2,
  move_right: 3,
  move_up: 4,

  move_lower_left: 5,
  move_lower_right: 6,
  move_upper_left: 7,
  move_upper_right: 8,

  move_random: 9,
  move_toward_player: 10,
  move_away_from_player: 11,
  move_forward: 12,
  move_backward: 13,

  jump: 14,                  # Ex: [:jump, 2, 1]
  wait: 15,                  # Ex: [:wait, 60]

  turn_down: 16,
  turn_left: 17,
  turn_right: 18,
  turn_up: 19,

  turn_right_90: 20,
  turn_left_90: 21,
  turn_180: 22,
  turn_90_random: 23,

  turn_random: 24,
  turn_toward_player: 25,
  turn_away_from_player: 26,

  switch_on: 27,             # Ex: { switch_on: "A" }
  switch_off: 28,            # Ex: { switch_off: "A" }
  change_speed: 29,          # Ex: [:change_speed, 4]
  change_freq: 30,           # Ex: [:change_freq, 3]

  walk_anime_on: 31,
  walk_anime_off: 32,
  step_anime_on: 33,
  step_anime_off: 34,
  direction_fix_on: 35,
  direction_fix_off: 36,
  through_on: 37,
  through_off: 38,
  always_on_top_on: 39,
  always_on_top_off: 40,

  change_graphic: 41,        # Ex: [:change_graphic, "Trainer", 2, 1]
  change_opacity: 42,        # Ex: [:change_opacity, 128]
  change_blend: 43,          # Ex: [:change_blend, 1]
  play_se: 44,               # Ex: [:play_se, RPG::AudioFile.new("Jump", 80, 100)]

  script: 45,                # Ex: [:script, "echoln('test!')"]
  end: 0,
}

if defined?(VOESettings) && defined?(PokemonEncounters)
  class PokemonEncounters
    alias voe_encounter_triggered? encounter_triggered? if method_defined?(:encounter_triggered?)

    # Determines whether a random terrain-based encounter should happen.
    # Used by Essentials walking/surfing/fishing code — NOT by VOE.
    def encounter_triggered?(*args)
      flags = VOESettings::DEV_DISABLE_TERRAIN_ENCOUNTERS
      return voe_encounter_triggered?(*args) unless flags.is_a?(Hash)

      etype = encounter_type rescue nil
      return false if etype.nil?

      # -------------------------------
      # Terrain-specific encounter control
      # -------------------------------
      case etype
	  when :Land, :LandMorning, :LandDay, :LandEvening, :LandNight
		if flags[:land]
		  echoln "[VOE SETTINGS] Standard land encounters disabled."
		  return false
	    end

	  when :Cave
	  if flags[:cave]
		echoln "[VOE SETTINGS] Standard cave encounters disabled."
		return false
	  end

	when :Water, :WaterMorning, :WaterDay, :WaterEvening, :WaterNight
	if flags[:water]
		echoln "[VOE SETTINGS] Standard surf encounters disabled."
		return false
	end

	when :OldRod, :GoodRod, :SuperRod
	if flags[:fishing]
		echoln "[VOE SETTINGS] Standard fishing encounters disabled."
		return false
	end

	when :RockSmash
	if flags[:rock_smash]
		echoln "[VOE SETTINGS] Standard Rock Smash encounters disabled."
		return false
	  end
	end

      # Fallback: use default Essentials logic
      return voe_encounter_triggered?(*args)
    end if method_defined?(:encounter_triggered?)
  end
end
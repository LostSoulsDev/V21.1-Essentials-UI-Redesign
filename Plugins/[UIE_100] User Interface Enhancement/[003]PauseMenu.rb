#===============================================================================
#                          Custom Pause Menu
#                               V 1.0.3
#                        Developed by Carmaniac
#===============================================================================

#-------------------------------------------------------------------------------
# Extend PokemonSystem to store menu colour preference
#-------------------------------------------------------------------------------
class PokemonSystem
  attr_accessor :menu_color

  alias custom_pause_menu_initialize initialize
  def initialize
    custom_pause_menu_initialize
    @menu_color = "blue"
  end
end

#-------------------------------------------------------------------------------
# Custom Pause Menu Scene
#-------------------------------------------------------------------------------
class PokemonPauseMenu_Scene

  PAUSE_FOLDER   = "Graphics/Custom UI/Pause Menu/"
  GRID_SCROLL_SPEED = 1   # pixels per frame
  SCROLL_FRAMES     = 15  # frames for bars to slide in/out
  COLORS = ["blue", "green", "orange", "pink", "purple", "red"]

  # Bar layout
  TOPBAR_REST_Y    = 0
  BOTTOMBAR_REST_Y = 314
  BAR_H            = 168

  # Grid layout
  TOPGRID_REST_Y    = 0
  BOTTOMGRID_REST_Y = 352
  GRID_W            = 1600
  GRID_SCROLL_W     = GRID_W / 2   # wrap at half width

  #-----------------------------------------------------------------------------
  # Helper — current colour from system, defaults to blue
  #-----------------------------------------------------------------------------
  def menuColor
    color = $PokemonSystem&.menu_color || "blue"
    return COLORS.include?(color) ? color : "blue"
  end

  #-----------------------------------------------------------------------------
  # Build topbar bitmap with map name text baked in
  #-----------------------------------------------------------------------------
  def pbBuildTopBarBitmap
    base = Bitmap.new(PAUSE_FOLDER + "topbar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    mapname = $game_map ? pbGetMapNameFromId($game_map.map_id) : ""
    mapname.gsub!(/\\PN/, $player&.name || "")
    pbDrawTextPositions(bmp, [[mapname, 18, 136, :left, Color.new(0, 0, 0), Color.new(136, 136, 136)]])
    return bmp
  end

  # Party icon layout
  PARTY_SLOT_W   = 76
  PARTY_SLOT_H   = 76
  PARTY_SLOT_GAP = 12
  PARTY_SLOTS    = 6
  PARTY_REST_Y   = 30
  PARTY_OPACITY  = 100
  PARTY_ICON_X   = 6   # relative to slot
  PARTY_ICON_Y   = 6   # relative to slot
  PARTY_START_X  = (800 - ((PARTY_SLOT_W * PARTY_SLOTS) + (PARTY_SLOT_GAP * (PARTY_SLOTS - 1)))) / 2

  #-----------------------------------------------------------------------------
  # Build party icon sprites — boxes + animated pokemon icons
  #-----------------------------------------------------------------------------
  def pbBuildPartyIcons
    @party_boxes  = []
    @party_icons  = []
    @party_icon_frames = []
    @party_icon_tick   = 0

    PARTY_SLOTS.times do |i|
      x = PARTY_START_X + (i * (PARTY_SLOT_W + PARTY_SLOT_GAP))
      y = @sprites["topbar"].y + PARTY_REST_Y

      # Determine which box graphic to use
      pkmn = $player&.party[i]
      if pkmn.nil?
        box_file = "PKMNNo.png"
      elsif pkmn.fainted?
        box_file = "PKMNFaint.png"
      else
        box_file = "PKMNAlive.png"
      end

      box = IconSprite.new(@vp_bars)
      box.setBitmap(PAUSE_FOLDER + box_file)
      box.x       = x
      box.y       = y
      box.z       = 2
      box.opacity = PARTY_OPACITY
      @party_boxes << box

      # Animated Pokémon icon if slot has a Pokémon
      if pkmn
        icon = PokemonIconSprite.new(pkmn, @vp_bars)
        icon.x       = x + PARTY_ICON_X
        icon.y       = y + PARTY_ICON_Y
        icon.z       = 3
        icon.opacity = 160
        @party_icons << icon
      else
        @party_icons << nil
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Update party box and icon positions to follow topbar Y
  #-----------------------------------------------------------------------------
  def pbUpdatePartyIcons
    return if !@party_boxes || !@sprites["topbar"]
    PARTY_SLOTS.times do |i|
      box  = @party_boxes[i]
      icon = @party_icons[i]
      next if !box
      x = PARTY_START_X + (i * (PARTY_SLOT_W + PARTY_SLOT_GAP))
      y = @sprites["topbar"].y + PARTY_REST_Y
      box.x  = x
      box.y  = y
      if icon
        icon.x = x + PARTY_ICON_X
        icon.y = y + PARTY_ICON_Y
        icon.update
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Refresh party boxes if party state has changed (faint/heal etc)
  #-----------------------------------------------------------------------------
  def pbRefreshPartyBoxes
    return if !@party_boxes
    PARTY_SLOTS.times do |i|
      box  = @party_boxes[i]
      next if !box
      pkmn = $player&.party[i]
      if pkmn.nil?
        box_file = "PKMNNo.png"
      elsif pkmn.fainted?
        box_file = "PKMNFaint.png"
      else
        box_file = "PKMNAlive.png"
      end
      box.setBitmap(PAUSE_FOLDER + box_file)
    end
  end

  #-----------------------------------------------------------------------------
  # Dispose party sprites
  #-----------------------------------------------------------------------------
  def pbDisposePartyIcons
    @party_boxes&.each(&:dispose)
    @party_icons&.each { |s| s&.dispose }
    @party_boxes  = nil
    @party_icons  = nil
  end

  # Menu icon layout
  ICON_W             = 58
  ICON_H             = 58
  ICON_GAP           = 4
  ICON_REST_Y        = 394
  ICON_ACTIVE_OFFSET = 6

  # Icon definitions — key, graphic, condition
  ICON_DEFS = [
    { key: "dex",     file: "dex.png",     condition: proc { $player&.has_pokedex && $player.pokedex.accessible_dexes.length > 0 } },
    { key: "pokemon", file: "pokemon.png",  condition: proc { $player&.party_count.to_i > 0 } },
    { key: "bag",     file: nil,            condition: proc { !pbInBugContest? } },
    { key: "trainer", file: "trainer.png",  condition: proc { true } },
    { key: "save",    file: "save.png",     condition: proc { $game_system && !$game_system.save_disabled && !pbInSafari? && !pbInBugContest? } },
    { key: "options", file: "options.png",  condition: proc { true } }
  ]

  #-----------------------------------------------------------------------------
  # Build active icon list based on conditions
  #-----------------------------------------------------------------------------
  def pbGetActiveIcons
    icons = []
    ICON_DEFS.each do |defn|
      next if !defn[:condition].call
      file = defn[:file]
      file = $player&.female? ? "bag_f.png" : "bag_m.png" if defn[:key] == "bag"
      icons << { key: defn[:key], file: file }
    end
    return icons
  end

  #-----------------------------------------------------------------------------
  # Calculate starting X to center icons on screen
  #-----------------------------------------------------------------------------
  def pbIconStartX(count)
    total_w = (count * ICON_W) + ((count - 1) * ICON_GAP)
    return (Graphics.width - total_w) / 2
  end

  #-----------------------------------------------------------------------------
  # Build menu icon sprites — created before slide in so they scroll with bar
  #-----------------------------------------------------------------------------
  def pbBuildMenuIcons
    @menu_icons      = []
    @menu_icon_defs  = pbGetActiveIcons
    @menu_icon_index = 0
    count   = @menu_icon_defs.length
    start_x = pbIconStartX(count)
    @menu_icon_defs.each_with_index do |defn, i|
      icon = IconSprite.new(@vp_bars)
      icon.setBitmap(PAUSE_FOLDER + defn[:file])
      icon.x = start_x + (i * (ICON_W + ICON_GAP))
      icon.y = @sprites["bottombar"].y + (ICON_REST_Y - BOTTOMBAR_REST_Y)
      icon.z = 2
      @menu_icons << icon
    end
  end

  #-----------------------------------------------------------------------------
  # Update menu icon positions — follow bottombar, active snaps up 6px
  #-----------------------------------------------------------------------------
  def pbUpdateMenuIcons
    return if !@menu_icons || !@sprites["bottombar"]
    count   = @menu_icon_defs.length
    start_x = pbIconStartX(count)
    bar_offset = @sprites["bottombar"].y - BOTTOMBAR_REST_Y
    @menu_icons.each_with_index do |icon, i|
      next if !icon
      icon.x = start_x + (i * (ICON_W + ICON_GAP))
      active_offset = (@menu_icon_index == i) ? -ICON_ACTIVE_OFFSET : 0
      icon.y = ICON_REST_Y + bar_offset + active_offset
    end
  end

  #-----------------------------------------------------------------------------
  # Dispose menu icon sprites
  #-----------------------------------------------------------------------------
  def pbDisposeMenuIcons
    @menu_icons&.each(&:dispose)
    @menu_icons = nil
  end

  HIGHLIGHT_W      = 56
  HIGHLIGHT_H      = 56
  HIGHLIGHT_FRAMES = 4
  HIGHLIGHT_SPEED  = 7

  # Maps Essentials pause menu command keys to our icon keys
  CMD_TO_ICON = {
    "pokedex"      => "dex",
    "party"        => "pokemon",
    "bag"          => "bag",
    "trainer_card" => "trainer",
    "save"         => "save",
    "options"      => "options"
  }

  #-----------------------------------------------------------------------------
  # Get icon index from Essentials command index
  #-----------------------------------------------------------------------------
  def pbCommandToIconIndex(cmd_index, commands)
    return 0 if !commands || cmd_index < 0
    # Try to match by command key name via MenuHandlers
    cmd_keys = []
    MenuHandlers.each_available(:pause_menu) { |key, hash, name| cmd_keys << key.to_s }
    cmd_key = cmd_keys[cmd_index]
    icon_key = CMD_TO_ICON[cmd_key]
    return 0 if !icon_key
    idx = @menu_icon_defs&.index { |d| d[:key] == icon_key }
    return idx || 0
  end
  def pbBuildMenuHighlight
    @vp_highlight       = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_highlight.z     = @vp_bars.z + 1
    @sprites["highlight"] = Sprite.new(@vp_highlight)
    @sprites["highlight"].bitmap = Bitmap.new(PAUSE_FOLDER + "highlight.png")
    @sprites["highlight"].src_rect.set(0, 0, HIGHLIGHT_W, HIGHLIGHT_H)
    @sprites["highlight"].z = 0
    @highlight_frame = 0
    @highlight_tick  = 0
  end

  #-----------------------------------------------------------------------------
  # Update highlight position and animation
  #-----------------------------------------------------------------------------
  def pbUpdateMenuHighlight
    return if !@sprites["highlight"] || !@menu_icons || @menu_icons.empty?
    icon = @menu_icons[@menu_icon_index]
    return if !icon
    @sprites["highlight"].x = icon.x - 2
    @sprites["highlight"].y = icon.y - 2
    # Animate frames
    @highlight_tick += 1
    if @highlight_tick >= HIGHLIGHT_SPEED
      @highlight_tick  = 0
      @highlight_frame = (@highlight_frame + 1) % HIGHLIGHT_FRAMES
      @sprites["highlight"].src_rect.y = @highlight_frame * HIGHLIGHT_H
    end
  end

  #-----------------------------------------------------------------------------
  # Build bottombar bitmap with money and time text baked in
  #-----------------------------------------------------------------------------
  def pbBuildBottomBarBitmap
    base = Bitmap.new(PAUSE_FOLDER + "bottombar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    textColor   = Color.new(255, 255, 255)
    shadowColor = Color.new(153, 153, 153)
    # y relative to bottombar (434 - 314 = 120)
    bar_text_y = 434 - BOTTOMBAR_REST_Y
    # Money — left aligned at x=46
    money = $player ? "£#{$player.money.to_s}" : "£0"
    # Time — right aligned, 46px from right edge
    time_str = Time.now.strftime("%H:%M")
    time_x = bmp.width - 46
    textPos = [
      [money,    46,     bar_text_y, :left,  textColor, shadowColor],
      [time_str, time_x, bar_text_y, :right, textColor, shadowColor]
    ]
    pbDrawTextPositions(bmp, textPos)
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Reload grid bitmaps when colour changes — called from update loop
  #-----------------------------------------------------------------------------
  def pbUpdateGridColor
    color = menuColor
    return if @last_menu_color == color
    @last_menu_color = color
    @sprites["topgrid"].setBitmap(PAUSE_FOLDER + "top#{color}.png")    if @sprites["topgrid"]
    @sprites["bottomgrid"].setBitmap(PAUSE_FOLDER + "bottom#{color}.png") if @sprites["bottomgrid"]
  end

  #-----------------------------------------------------------------------------
  # Rebuild bottombar bitmap — called periodically to update time/money
  #-----------------------------------------------------------------------------
  def pbRefreshBottomBar
    return if !@sprites["bottombar"]
    @sprites["bottombar"].bitmap&.dispose
    @sprites["bottombar"].bitmap = pbBuildBottomBarBitmap
  end
  alias custom_pause_pbStartScene pbStartScene
  def pbStartScene
    # Capture screenshot before loading any UI — saved for load screen use
    # Ensure folder exists in game directory then capture screenshot
    folder = "Graphics/Custom UI/Load/"
    FileUtils.mkdir_p(folder) unless Dir.exist?(folder)
    Graphics.screenshot(folder + "temp1.png")
    custom_pause_pbStartScene

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {} if !@sprites

    @vp_grid = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_grid.z = @viewport.z - 2
    @vp_bars = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_bars.z = @viewport.z - 1

    color = menuColor

    # Top grid
    @sprites["topgrid"] = IconSprite.new(@vp_grid)
    @sprites["topgrid"].setBitmap(PAUSE_FOLDER + "top#{color}.png")
    @sprites["topgrid"].x = 0
    @sprites["topgrid"].y = TOPGRID_REST_Y - BAR_H
    @sprites["topgrid"].z = 0

    # Bottom grid
    @sprites["bottomgrid"] = IconSprite.new(@vp_grid)
    @sprites["bottomgrid"].setBitmap(PAUSE_FOLDER + "bottom#{color}.png")
    @sprites["bottomgrid"].x = 0
    @sprites["bottomgrid"].y = Graphics.height
    @sprites["bottomgrid"].z = 0

    # Top bar — with map name baked in
    @sprites["topbar"] = Sprite.new(@vp_bars)
    @sprites["topbar"].bitmap = pbBuildTopBarBitmap
    @sprites["topbar"].x = 0
    @sprites["topbar"].y = -BAR_H
    @sprites["topbar"].z = 1

    # Bottom bar — with money and time baked in
    @sprites["bottombar"] = Sprite.new(@vp_bars)
    @sprites["bottombar"].bitmap = pbBuildBottomBarBitmap
    @sprites["bottombar"].x = 0
    @sprites["bottombar"].y = Graphics.height
    @sprites["bottombar"].z = 1

    @grid_x = 0
    @last_menu_color = menuColor
    @last_minute = Time.now.min
    pbBuildPartyIcons
    pbBuildMenuIcons
    pbBuildMenuHighlight
    pbSlideBarsIn
  end

  #-----------------------------------------------------------------------------
  # Slide bars and grids in from off screen — progress based, no overshoot
  #-----------------------------------------------------------------------------
  def pbSlideBarsIn
    SCROLL_FRAMES.times do |frame|
      t        = (frame + 1) / SCROLL_FRAMES.to_f
      progress = 1 - (1 - t) ** 2   # ease-out — fast start, slow finish
      @sprites["topbar"].y    = -BAR_H + (BAR_H * progress).to_i
      @sprites["topgrid"].y   = -BAR_H + (BAR_H * progress).to_i
      @sprites["bottombar"].y  = Graphics.height - ((Graphics.height - BOTTOMBAR_REST_Y) * progress).to_i
      @sprites["bottomgrid"].y = Graphics.height - ((Graphics.height - BOTTOMGRID_REST_Y) * progress).to_i
      pbUpdatePartyIcons
      pbUpdateGrid
      Graphics.update
      Input.update
    end
    @sprites["topbar"].y     = TOPBAR_REST_Y
    @sprites["topgrid"].y    = TOPGRID_REST_Y
    @sprites["bottombar"].y  = BOTTOMBAR_REST_Y
    @sprites["bottomgrid"].y = BOTTOMGRID_REST_Y
  end

  def pbSlideBarsOut
    SCROLL_FRAMES.times do |frame|
      t        = (frame + 1) / SCROLL_FRAMES.to_f
      progress = t ** 2   # ease-in — slow start, fast finish
      @sprites["topbar"].y    = TOPBAR_REST_Y - (BAR_H * progress).to_i
      @sprites["topgrid"].y   = TOPGRID_REST_Y - (BAR_H * progress).to_i
      @sprites["bottombar"].y  = BOTTOMBAR_REST_Y + ((Graphics.height - BOTTOMBAR_REST_Y) * progress).to_i
      @sprites["bottomgrid"].y = BOTTOMGRID_REST_Y + ((Graphics.height - BOTTOMGRID_REST_Y) * progress).to_i
      pbUpdatePartyIcons
      pbUpdateGrid
      Graphics.update
      Input.update
    end
  end

  #-----------------------------------------------------------------------------
  # Update grid scroll, live colour change, and time refresh
  #-----------------------------------------------------------------------------
  def pbUpdateGrid
    @grid_x = (@grid_x || 0) - GRID_SCROLL_SPEED
    @grid_x = 0 if @grid_x <= -GRID_SCROLL_W
    @sprites["topgrid"].x    = @grid_x if @sprites["topgrid"]
    @sprites["bottomgrid"].x = @grid_x if @sprites["bottomgrid"]
    # Update party icons to follow topbar
    pbUpdatePartyIcons
    # Update menu icons to follow bottombar
    pbUpdateMenuIcons
    # Update highlight position and animation
    pbUpdateMenuHighlight
    # Refresh party boxes if party state changed
    pbRefreshPartyBoxes
    # Live colour update
    pbUpdateGridColor
    # Refresh bottombar every minute for time update
    current_min = Time.now.min
    if current_min != @last_minute
      @last_minute = current_min
      pbRefreshBottomBar
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbShowCommands — update grid while waiting for input
  #-----------------------------------------------------------------------------
  alias custom_pause_pbShowCommands pbShowCommands
  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = commands
    cmdwindow.index    = $game_temp.menu_last_choice rescue 0
    cmdwindow.visible  = false
    # Sync icon index to last choice using key matching
    last_choice = ($game_temp.menu_last_choice.to_i rescue 0)
    @menu_icon_index = pbCommandToIconIndex(last_choice, commands)
    @last_mouse_x = Input.mouse_x
    @last_mouse_y = Input.mouse_y
    @mouse_moved  = false
    loop do
      pbUpdateGrid
      Graphics.update
      Input.update
      pbUpdateSceneMap
      # Detect mouse movement
      cur_x = Input.mouse_x
      cur_y = Input.mouse_y
      @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
      @last_mouse_x = cur_x
      @last_mouse_y = cur_y
      # Keyboard left/right — wraps
      if Input.trigger?(Input::LEFT)
        @menu_icon_index = (@menu_icon_index - 1) % @menu_icon_defs.length
        @mouse_moved = false
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT)
        @menu_icon_index = (@menu_icon_index + 1) % @menu_icon_defs.length
        @mouse_moved = false
        pbPlayCursorSE
      end
      # Confirm via keyboard or mouse click
      if Input.trigger?(Input::USE)
        icon_key  = @menu_icon_defs[@menu_icon_index][:key]
        cmd_keys  = []
        MenuHandlers.each_available(:pause_menu) { |key, hash, name| cmd_keys << key.to_s }
        cmd_key   = CMD_TO_ICON.key(icon_key)
        ret       = cmd_keys.index(cmd_key) || @menu_icon_index
        $game_temp.menu_last_choice = ret
        pbPlayDecisionSE
        break
      end
      @menu_icons&.each_with_index do |icon, i|
        next if !icon
        @menu_icon_index = i if @mouse_moved && Mouse.over?(icon)
        if Mouse.over?(icon) && Mouse.click?
          @menu_icon_index = i
          icon_key  = @menu_icon_defs[i][:key]
          cmd_keys  = []
          MenuHandlers.each_available(:pause_menu) { |key, hash, name| cmd_keys << key.to_s }
          cmd_key   = CMD_TO_ICON.key(icon_key)
          ret       = cmd_keys.index(cmd_key) || i
          $game_temp.menu_last_choice = ret
          pbPlayDecisionSE
          break
        end
      end
      break if ret >= 0
      # Back/cancel
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        ret = -1
        break
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Override pbEndScene — slide out then dispose
  #-----------------------------------------------------------------------------
  alias custom_pause_pbEndScene pbEndScene
  def pbEndScene
    pbSlideBarsOut
    pbDisposePartyIcons
    pbDisposeMenuIcons
    @sprites["highlight"]&.bitmap&.dispose
    @sprites["highlight"]&.dispose
    @vp_highlight&.dispose
    @sprites["topbar"]&.bitmap&.dispose
    @sprites["topbar"]&.dispose
    @sprites["bottombar"]&.bitmap&.dispose
    @sprites["bottombar"]&.dispose
    @sprites["topgrid"]&.dispose
    @sprites["bottomgrid"]&.dispose
    @vp_grid&.dispose
    @vp_bars&.dispose
    custom_pause_pbEndScene
  end

end

#-------------------------------------------------------------------------------
# Add menu colour option to Options menu
#-------------------------------------------------------------------------------
MenuHandlers.add(:options_menu, :menu_color, {
  "name"        => _INTL("Menu Colour"),
  "order"       => 130,
  "type"        => EnumOption,
  "parameters"  => ["Blue", "Green", "Orange", "Pink", "Purple", "Red"],
  "description" => _INTL("Choose the colour of the pause menu animated bars."),
  "get_proc"    => proc {
    colors = ["blue", "green", "orange", "pink", "purple", "red"]
    next [colors.index($PokemonSystem.menu_color || "blue") || 0, 0].max
  },
  "set_proc"    => proc { |value, _scene|
    colors = ["blue", "green", "orange", "pink", "purple", "red"]
    $PokemonSystem.menu_color = colors[value]
  }
})
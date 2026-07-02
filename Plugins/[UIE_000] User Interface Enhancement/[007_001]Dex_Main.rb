#===============================================================================
#                        Custom Dex Main Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonPokedex_Scene

  DEX_FOLDER  = "Graphics/Custom UI/Dex/"
  MAIN_FOLDER = "Graphics/Custom UI/Dex/Main Page/"

  GRID_SCROLL_W = 800

  TEXT_COLOR  = Color.new(255, 255, 255)
  TEXT_SHADOW = Color.new(156, 156, 156)

  # Grid layout
  GRID_COLS     = 4
  GRID_ROWS     = 3
  GRID_CELL_W   = 112
  GRID_CELL_H   = 118
  GRID_X_GAP    = 6
  GRID_Y_GAP    = 6
  GRID_X_STRIDE = GRID_CELL_W + GRID_X_GAP
  GRID_Y_STRIDE = GRID_CELL_H + GRID_Y_GAP
  GRID_START_X  = 284
  GRID_START_Y  = 56

  #-----------------------------------------------------------------------------
  # Build grid cell sprites
  #-----------------------------------------------------------------------------
  def pbBuildGrid
    pbDisposeGrid
    @grid_cells  = []
    @grid_scroll = 0
    @last_mouse_x = Input.mouse_x
    @last_mouse_y = Input.mouse_y
    @mouse_moved  = false
    (GRID_ROWS * GRID_COLS).times do |i|
      row = i / GRID_COLS
      col = i % GRID_COLS
      x   = GRID_START_X + (col * GRID_X_STRIDE)
      y   = GRID_START_Y + (row * GRID_Y_STRIDE)
      x  -= 1 if x.odd?
      y  -= 1 if y.odd?
      spr = IconSprite.new(@viewport)
      spr.setBitmap(MAIN_FOLDER + "box.png")
      spr.x = x
      spr.y = y
      spr.z = 4
      @grid_cells << spr
    end
  end

  def pbDisposeGrid
    @grid_cells&.each(&:dispose)
    @grid_cells = nil
  end

  #-----------------------------------------------------------------------------
  # Update grid cell positions and mouse hover
  #-----------------------------------------------------------------------------
  def pbUpdateGrid
    return if !@grid_cells || !@dexlist
    @grid_cells.each_with_index do |spr, i|
      next if !spr
      row = i / GRID_COLS
      col = i % GRID_COLS
      x   = GRID_START_X + (col * GRID_X_STRIDE)
      y   = GRID_START_Y + (row * GRID_Y_STRIDE)
      x  -= 1 if x.odd?
      y  -= 1 if y.odd?
      spr.x = x
      spr.y = y
      if @mouse_moved && Mouse.over?(spr)
        dex_idx = (@grid_scroll * GRID_COLS) + i
        if dex_idx < @dexlist.length
          @sprites["pokedex"].index = dex_idx
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Ensure scroll keeps current index visible
  #-----------------------------------------------------------------------------
  def pbUpdateGridScroll
    return if !@dexlist
    idx      = @sprites["pokedex"].index
    row      = idx / GRID_COLS
    max_rows = [(@dexlist.length.to_f / GRID_COLS).ceil - GRID_ROWS, 0].max
    if row < @grid_scroll
      @grid_scroll = row
    elsif row >= @grid_scroll + GRID_ROWS
      @grid_scroll = row - GRID_ROWS + 1
    end
    @grid_scroll = @grid_scroll.clamp(0, max_rows)
  end

  #-----------------------------------------------------------------------------
  # Handle grid keyboard/mouse input
  #-----------------------------------------------------------------------------
  def pbHandleGridInput
    return if !@dexlist || @dexlist.empty?
    idx      = @sprites["pokedex"].index
    max_idx  = @dexlist.length - 1
    col      = idx % GRID_COLS
    row      = idx / GRID_COLS
    max_rows = [(@dexlist.length.to_f / GRID_COLS).ceil - 1, 0].max
    changed  = false

    # Mouse movement tracking
    cur_x         = Input.mouse_x
    cur_y         = Input.mouse_y
    @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y

    if Input.trigger?(Input::LEFT)
      idx -= 1 if idx > 0
      @mouse_moved = false
      changed = true
    elsif Input.trigger?(Input::RIGHT)
      idx += 1 if idx < max_idx
      @mouse_moved = false
      changed = true
    elsif Input.trigger?(Input::UP)
      idx = [idx - GRID_COLS, 0].max if row > 0
      @mouse_moved = false
      changed = true
    elsif Input.trigger?(Input::DOWN)
      idx = [idx + GRID_COLS, max_idx].min if row < max_rows
      @mouse_moved = false
      changed = true
    end

    # Mouse wheel scroll — list scrolls, index pushed only if out of bounds
    max_scroll = [(@dexlist.length.to_f / GRID_COLS).ceil - GRID_ROWS, 0].max
    if Mouse.scroll_up? && @grid_scroll > 0
      @grid_scroll -= 1
      min_visible = @grid_scroll * GRID_COLS
      if idx < min_visible
        idx = min_visible
        changed = true
      end
    elsif Mouse.scroll_down? && @grid_scroll < max_scroll
      @grid_scroll += 1
      max_visible = [(@grid_scroll + GRID_ROWS) * GRID_COLS - 1, max_idx].min
      if idx > max_visible
        idx = max_visible
        changed = true
      end
    end

    idx = idx.clamp(0, max_idx)
    if idx != @sprites["pokedex"].index || changed
      @sprites["pokedex"].index = idx
      pbUpdateGridScroll
      pbUpdateGrid
      pbRefresh
    end
  end
  alias custom_dex_main_pbUpdate pbUpdate
  def pbUpdate
    if @sprites["custom_grid"]
      @sprites["custom_grid"].x -= 1
      @sprites["custom_grid"].x = 0 if @sprites["custom_grid"].x <= -GRID_SCROLL_W
    end
    custom_dex_main_pbUpdate
  end

  #-----------------------------------------------------------------------------
  # Position Pokemon sprite centered at 138,240 using frame 1 center
  #-----------------------------------------------------------------------------
  def pbUpdateCustomPokemonSprite
    return if !@sprites["custom_pokemon"]
    species = @sprites["pokedex"]&.species
    if !species || species == 0 || !$player.seen?(species)
      @sprites["custom_pokemon"].visible = false
      return
    end
    return if species == @last_dex_species
    @last_dex_species = species
    gender, form, _shiny = $player.pokedex.last_form_seen(species)
    @sprites["custom_pokemon"].setSpeciesBitmap(species, gender, form, false)
    bmp = @sprites["custom_pokemon"].bitmap
    if bmp && !bmp.disposed?
      # PokemonSprite bitmap is already a single frame
      ox = bmp.width / 2
      oy = bmp.height / 2
      ox -= 1 if ox.odd?
      oy -= 1 if oy.odd?
      @sprites["custom_pokemon"].ox = ox
      @sprites["custom_pokemon"].oy = oy
      @sprites["custom_pokemon"].x  = 138
      @sprites["custom_pokemon"].y  = 240
    end
    @sprites["custom_pokemon"].visible = true
  end
  def pbBuildStatsOverlay
    @sprites["custom_statsoverlay"]&.bitmap&.dispose
    @sprites["custom_statsoverlay"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    region       = pbGetPokedexRegion
    seen_count   = $player.pokedex.seen_count(region)
    caught_count = $player.pokedex.owned_count(region)
    textPos = [
      ["#{caught_count} Caught", 46,  8, :left, TEXT_COLOR, TEXT_SHADOW],
      ["#{seen_count} Seen",     228, 8, :left, TEXT_COLOR, TEXT_SHADOW]
    ]
    pbDrawTextPositions(bmp, textPos)
    @sprites["custom_statsoverlay"] = Sprite.new(@viewport)
    @sprites["custom_statsoverlay"].bitmap = bmp
    @sprites["custom_statsoverlay"].z      = 10
  end

  #-----------------------------------------------------------------------------
  # Build pokemon name overlay — updates when highlighted species changes
  #-----------------------------------------------------------------------------
  def pbBuildNameOverlay
    @sprites["custom_nameoverlay"]&.bitmap&.dispose
    @sprites["custom_nameoverlay"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    species = @sprites["pokedex"]&.species
    if species && species != 0 && $player.seen?(species)
      name = GameData::Species.get(species).name
      pbDrawTextPositions(bmp, [[name, 38, 82, :left, TEXT_COLOR, TEXT_SHADOW]])
    end
    @sprites["custom_nameoverlay"] = Sprite.new(@viewport)
    @sprites["custom_nameoverlay"].bitmap = bmp
    @sprites["custom_nameoverlay"].z      = 11
  end

  #-----------------------------------------------------------------------------
  # Override pbStartScene — full takeover, no vanilla visuals
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbStartScene pbStartScene
  def pbStartScene
    # Set up vanilla support objects needed for logic
    @sliderbitmap       = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_slider")
    @typebitmap         = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @shapebitmap        = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_shapes")
    @hwbitmap           = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_hw"))
    @selbitmap          = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_searchslider"))
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Hidden vanilla sprites needed for internal logic
    @sprites["pokedex"] = Window_Pokedex.new(206, 30, 276, 364, @viewport)
    @sprites["pokedex"].visible = false
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Pokedex/bg_list")
    @sprites["background"].visible = false
    @sprites["searchbg"] = IconSprite.new(0, 0, @viewport)
    @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search")
    @sprites["searchbg"].visible = false
    @sprites["overlay"]      = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].visible = false
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    @sprites["searchcursor"].visible = false
    @sprites["icon"]         = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::CENTER)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["icon"].visible = false

    # Search state
    @searchResults = false
    @searchParams  = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)

    # Scrolling grid
    @sprites["custom_grid"] = IconSprite.new(@viewport)
    @sprites["custom_grid"].setBitmap(DEX_FOLDER + "Grid.png")
    @sprites["custom_grid"].x = 0
    @sprites["custom_grid"].y = 0
    @sprites["custom_grid"].z = 0

    # Static overlay
    @sprites["custom_overlay"] = IconSprite.new(@viewport)
    @sprites["custom_overlay"].setBitmap(MAIN_FOLDER + "overlay.png")
    @sprites["custom_overlay"].x = 0
    @sprites["custom_overlay"].y = 0
    @sprites["custom_overlay"].z = 1

    # Caught icon
    @sprites["custom_caughticon"] = IconSprite.new(@viewport)
    @sprites["custom_caughticon"].setBitmap(DEX_FOLDER + "caughticon.png")
    @sprites["custom_caughticon"].x = 4
    @sprites["custom_caughticon"].y = 2
    @sprites["custom_caughticon"].z = 2

    # Seen icon
    @sprites["custom_seenicon"] = IconSprite.new(@viewport)
    @sprites["custom_seenicon"].setBitmap(DEX_FOLDER + "seenicon.png")
    @sprites["custom_seenicon"].x = 186
    @sprites["custom_seenicon"].y = 2
    @sprites["custom_seenicon"].z = 2

    # List window graphic
    @sprites["custom_window"] = IconSprite.new(@viewport)
    @sprites["custom_window"].setBitmap(MAIN_FOLDER + "window.png")
    @sprites["custom_window"].x = 12
    @sprites["custom_window"].y = 58
    @sprites["custom_window"].z = 3

    # Grid cells
    pbBuildGrid

    # Stats text
    pbBuildStatsOverlay

    # Pokémon sprite — centered at 138,240 based on frame 1
    @sprites["custom_pokemon"] = PokemonSprite.new(@viewport)
    @sprites["custom_pokemon"].z = 5
    @last_dex_species = nil
    pbUpdateCustomPokemonSprite

    # Pokémon name text
    @last_dex_index = nil
    pbBuildNameOverlay

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # Override pbRefresh — rebuild name overlay when index changes
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbRefresh pbRefresh
  def pbRefresh
    custom_dex_main_pbRefresh
    current_index = @sprites["pokedex"]&.index
    if current_index != @last_dex_index
      @last_dex_index = current_index
      pbBuildNameOverlay
      pbUpdateCustomPokemonSprite
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbPokedex — use grid navigation
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbPokedex pbPokedex
  def pbPokedex
    pbActivateWindow(@sprites, "pokedex") do
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        pbHandleGridInput
        if oldindex != @sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbSEPlay("GUI pokedex open")
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          if @searchResults
            pbCloseSearch
          else
            break
          end
        elsif Input.trigger?(Input::USE)
          if $player.seen?(@sprites["pokedex"].species)
            pbSEPlay("GUI pokedex open")
            pbDexEntry(@sprites["pokedex"].index)
          end
        end
      end
    end
  end
  alias custom_dex_main_pbEndScene pbEndScene
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeGrid
    @sprites["custom_statsoverlay"]&.bitmap&.dispose
    @sprites["custom_statsoverlay"]&.dispose
    @sprites["custom_nameoverlay"]&.bitmap&.dispose
    @sprites["custom_nameoverlay"]&.dispose
    @sprites["custom_pokemon"]&.dispose
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @typebitmap.dispose
    @shapebitmap.dispose
    @hwbitmap.dispose
    @selbitmap.dispose
    @searchsliderbitmap.dispose
    @viewport.dispose
  end

end
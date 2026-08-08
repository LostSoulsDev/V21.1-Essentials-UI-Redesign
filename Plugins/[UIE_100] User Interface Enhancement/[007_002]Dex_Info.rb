#===============================================================================
#                        Custom Dex Info Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonPokedexInfo_Scene

  DEX_FOLDER = "Graphics/Custom UI/Dex/"

  GRID_SCROLL_W     = 800
  GRID_SCROLL_SPEED = 2

  # Buttons
  LEFTARROW_X  = 10
  LEFTARROW_Y  = 448
  RIGHTARROW_X = 70
  RIGHTARROW_Y = 448
  CANCEL_X     = 118
  CANCEL_Y     = 448

  # "Next" button — shown only on the brief (just caught) popup
  NEXT_BTN_X = 680
  NEXT_BTN_Y = 444
  NEXT_BTN_W = 106
  NEXT_BTN_H = 34

  # Text colours (used for every text element on this page)
  TEXT_COLOR  = Color.new(0, 0, 0)
  TEXT_SHADOW = Color.new(173, 189, 189)

  # Info page layout
  CAUGHT_ICON_X = 276
  CAUGHT_ICON_Y = 56
  TYPE_ICON_X   = 594
  TYPE_ICON_Y   = 56
  NAME_TEXT_X   = 316
  NAME_TEXT_Y   = 62
  CATEGORY_CENTER_X = 344 + (340 / 2)   # midpoint of the original 344,340-wide box
  CATEGORY_TEXT_Y   = 110
  SHAPE_ICON_X  = 454
  SHAPE_ICON_Y  = 170
  HW_BOX_X = 526
  HW_BOX_W = 224
  HW_TEXT_Y = 174
  DESC_TEXT_X   = 44
  DESC_TEXT_Y   = 344

  #-----------------------------------------------------------------------------
  # Override pbStartScene — full takeover so everything (background, grid,
  # Pokémon sprite) fades in together as one scene
  #-----------------------------------------------------------------------------
  def pbStartScene(dexlist, index, region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @show_battled_count = false
    @typebitmap  = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @shapebitmap = AnimatedBitmap.new(DEX_FOLDER + "icon_shapes")
    @sprites = {}

    # Scrolling background grid
    @sprites["custom_infogrid"] = IconSprite.new(@viewport)
    @sprites["custom_infogrid"].setBitmap(DEX_FOLDER + "infogrid.png")
    @sprites["custom_infogrid"].x = 0
    @sprites["custom_infogrid"].y = 0
    @sprites["custom_infogrid"].z = -1

    # Custom background — swapped per page in drawPage
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(DEX_FOLDER + "bg_info")
    @sprites["background"].z = 0

    # Area page — town map + encounter highlight squares
    @sprites["areamap"] = IconSprite.new(0, 0, @viewport)
    @sprites["areamap"].z = 1
    @sprites["areamap"].visible = false
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["areahighlight"].z = 2
    @sprites["areahighlight"].visible = false
    @sprites["areaoverlay"] = IconSprite.new(144, 30, @viewport)
    @sprites["areaoverlay"].setBitmap(DEX_FOLDER + "overlay_area")
    @sprites["areaoverlay"].z = 3
    @sprites["areaoverlay"].visible = false

    # Pokémon sprite for the info page
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["infosprite"].z = 5

    # Forms page — front/back sprites, species icon, form list arrows
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::CENTER)
    @sprites["formfront"].x = 120
    @sprites["formfront"].y = 172
    @sprites["formfront"].z = 5
    @sprites["formfront"].visible = false
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::BOTTOM)
    @sprites["formback"].x = 346
    @sprites["formback"].z = 5
    @sprites["formback"].visible = false
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::CENTER)
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
    @sprites["formicon"].z = 5
    @sprites["formicon"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/UI/up_arrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 268
    @sprites["uparrow"].z = 8
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/UI/down_arrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 348
    @sprites["downarrow"].z = 8
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false

    mappos = $game_map.metadata&.town_map_position
    if @region < 0
      @region = (mappos) ? mappos[0] : 0
    end
    @mapdata = GameData::TownMap.get(@region)
    @sprites["areamap"].setBitmap("Graphics/UI/Town Map/#{@mapdata.filename}")
    @sprites["areamap"].x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
    @sprites["areamap"].y += (Graphics.height + 32 - @sprites["areamap"].bitmap.height) / 2
    @sprites["areamap"].y -= 18
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
      pbDrawImagePositions(
        @sprites["areamap"].bitmap,
        [["Graphics/UI/Town Map/#{hidden[4]}",
          hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
          hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
      )
    end

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 10
    pbSetSystemFont(@sprites["overlay"].bitmap)

    pbUpdateDummyPokemon
    @available = pbGetAvailableForms

    pbBuildInfoButtons
    drawPage(@page)

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  # For standalone access, shows first page only.
  def pbStartSceneBrief(species)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      if species_data
        nationalDexList = [:NONE]
        GameData::Species.each_species { |s| nationalDexList.push(s.species) }
        dexnum = nationalDexList.index(species_data.species) || 0
        dexnumshift = true if dexnum > 0 && Settings::DEXES_WITH_OFFSETS.include?(-1)
      end
    else
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [{
      :species => species,
      :name    => "",
      :height  => 0,
      :weight  => 0,
      :number  => dexnum,
      :shift   => dexnumshift
    }]
    @index = 0
    @page = 1
    @brief = true
    @typebitmap  = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @shapebitmap = AnimatedBitmap.new(DEX_FOLDER + "icon_shapes")
    @sprites = {}

    @sprites["custom_infogrid"] = IconSprite.new(@viewport)
    @sprites["custom_infogrid"].setBitmap(DEX_FOLDER + "infogrid.png")
    @sprites["custom_infogrid"].x = 0
    @sprites["custom_infogrid"].y = 0
    @sprites["custom_infogrid"].z = -1

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(DEX_FOLDER + "bg_info")
    @sprites["background"].z = 0

    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    @sprites["infosprite"].x = 104
    @sprites["infosprite"].y = 136
    @sprites["infosprite"].z = 5

    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 10
    pbSetSystemFont(@sprites["overlay"].bitmap)

    pbUpdateDummyPokemon
    pbBuildBriefButtons
    @next_btn_was_pressed = false
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # Override pbUpdate — scrolls the grid 2px a frame, wrapping at half the
  # image width so the loop is seamless. Also pulses the area encounter
  # highlight while page 2 is showing, same as vanilla.
  #-----------------------------------------------------------------------------
  def pbUpdate
    if @sprites["custom_infogrid"]
      @sprites["custom_infogrid"].x -= GRID_SCROLL_SPEED
      @sprites["custom_infogrid"].x = 0 if @sprites["custom_infogrid"].x <= -GRID_SCROLL_W
    end
    if @page == 2 && @sprites["areahighlight"]
      intensity_time = System.uptime % 1.0
      if intensity_time >= 0.5
        intensity = lerp(64, 256 + 64, 0.5, intensity_time - 0.5)
      else
        intensity = lerp(256 + 64, 64, 0.5, intensity_time)
      end
      @sprites["areahighlight"].opacity = intensity
    end
    pbUpdateSpriteHash(@sprites)
  end

  #-----------------------------------------------------------------------------
  # Override pbEndScene — full takeover, fades everything out together
  #-----------------------------------------------------------------------------
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @shapebitmap.dispose
    @viewport.dispose
  end

  #-----------------------------------------------------------------------------
  # Left/right page arrows + cancel button — used on the full info screen
  #-----------------------------------------------------------------------------
  def pbBuildInfoButtons
    @sprites["custom_leftarrow"] = IconSprite.new(@viewport)
    @sprites["custom_leftarrow"].setBitmap(DEX_FOLDER + "leftarrow.png")
    @sprites["custom_leftarrow"].x = LEFTARROW_X
    @sprites["custom_leftarrow"].y = LEFTARROW_Y
    @sprites["custom_leftarrow"].z = 8

    @sprites["custom_rightarrow"] = IconSprite.new(@viewport)
    @sprites["custom_rightarrow"].setBitmap(DEX_FOLDER + "rightarrow.png")
    @sprites["custom_rightarrow"].x = RIGHTARROW_X
    @sprites["custom_rightarrow"].y = RIGHTARROW_Y
    @sprites["custom_rightarrow"].z = 8

    @sprites["custom_cancel"] = IconSprite.new(@viewport)
    @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel.png")
    @sprites["custom_cancel"].x = CANCEL_X
    @sprites["custom_cancel"].y = CANCEL_Y
    @sprites["custom_cancel"].z = 8
  end

  #-----------------------------------------------------------------------------
  # "Next" button — only used on the brief (just caught) popup, same graphic
  # swap + flash + text overlay approach as the main dex screen's Search button
  #-----------------------------------------------------------------------------
  def pbBuildBriefButtons
    @sprites["custom_next"] = IconSprite.new(@viewport)
    pbDrawNextButtonBase(false)
    @sprites["custom_next"].x = NEXT_BTN_X
    @sprites["custom_next"].y = NEXT_BTN_Y
    @sprites["custom_next"].z = 8

    @sprites["custom_nexttext"] = Sprite.new(@viewport)
    @sprites["custom_nexttext"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(@sprites["custom_nexttext"].bitmap)
    @sprites["custom_nexttext"].z = 9
    pbDrawNextButtonText
  end

  def pbDrawNextButtonBase(pressed)
    file = pressed ? (DEX_FOLDER + "button_small_p.png") : (DEX_FOLDER + "button_small.png")
    @sprites["custom_next"].setBitmap(file)
  end

  def pbDrawNextButtonText
    bmp = @sprites["custom_nexttext"].bitmap
    bmp.clear
    center_x = NEXT_BTN_X + (NEXT_BTN_W / 2)
    text_y   = NEXT_BTN_Y + [(NEXT_BTN_H - bmp.font.size) / 2, 0].max + 4
    textpos = [[_INTL("Next"), center_x, text_y, :center, TEXT_COLOR, TEXT_SHADOW]]
    pbDrawTextPositions(bmp, textpos)
  end

  def pbFlashNextButton
    2.times do
      pbDrawNextButtonBase(true)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      pbDrawNextButtonBase(false)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  # Checked every frame. Returns true if the Next button was clicked.
  def pbHandleBriefButtons
    next_clicked = false
    if @sprites["custom_next"]
      pressed = @sprites["custom_next"].over? && @sprites["custom_next"].press?
      if pressed != @next_btn_was_pressed
        pbDrawNextButtonBase(pressed)
        @next_btn_was_pressed = pressed
      end
      next_clicked = true if @sprites["custom_next"].click?
    end
    return next_clicked
  end

  def pbFlashLeftArrow
    2.times do
      @sprites["custom_leftarrow"].setBitmap(DEX_FOLDER + "leftarrow_p.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      @sprites["custom_leftarrow"].setBitmap(DEX_FOLDER + "leftarrow.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  def pbFlashRightArrow
    2.times do
      @sprites["custom_rightarrow"].setBitmap(DEX_FOLDER + "rightarrow_p.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      @sprites["custom_rightarrow"].setBitmap(DEX_FOLDER + "rightarrow.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  def pbFlashCancelButton
    2.times do
      @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel_p.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  # Checked every frame. Returns [left_clicked, right_clicked, cancel_clicked]
  def pbHandleInfoButtons
    left_clicked   = false
    right_clicked  = false
    cancel_clicked = false

    if @sprites["custom_leftarrow"]
      if @sprites["custom_leftarrow"].over? && @sprites["custom_leftarrow"].press?
        @sprites["custom_leftarrow"].setBitmap(DEX_FOLDER + "leftarrow_p.png")
      else
        @sprites["custom_leftarrow"].setBitmap(DEX_FOLDER + "leftarrow.png")
      end
      left_clicked = true if @sprites["custom_leftarrow"].click?
    end

    if @sprites["custom_rightarrow"]
      if @sprites["custom_rightarrow"].over? && @sprites["custom_rightarrow"].press?
        @sprites["custom_rightarrow"].setBitmap(DEX_FOLDER + "rightarrow_p.png")
      else
        @sprites["custom_rightarrow"].setBitmap(DEX_FOLDER + "rightarrow.png")
      end
      right_clicked = true if @sprites["custom_rightarrow"].click?
    end

    cancel_clicked = true if @sprites["custom_cancel"] && @sprites["custom_cancel"].click?

    return [left_clicked, right_clicked, cancel_clicked]
  end

  #-----------------------------------------------------------------------------
  # Override drawPage / drawPageInfo — background and visible sprites swap
  # per page, positions here match the custom backgrounds rather than
  # vanilla's layout
  #-----------------------------------------------------------------------------
  def drawPage(page)
    overlay = @sprites["overlay"].bitmap
    overlay.clear

    @sprites["infosprite"].visible     = (page == 1)
    @sprites["areamap"].visible        = (page == 2)
    @sprites["areahighlight"].visible  = (page == 2)
    @sprites["areaoverlay"].visible    = (page == 2)
    @sprites["formfront"].visible      = (page == 3)
    @sprites["formback"].visible       = (page == 3)
    @sprites["formicon"].visible       = (page == 3)

    case page
    when 1
      @sprites["background"].setBitmap(DEX_FOLDER + "bg_info")
      drawPageInfo
    when 2
      @sprites["background"].setBitmap(DEX_FOLDER + "bg_area")
      drawPageArea
    when 3
      @sprites["background"].setBitmap(DEX_FOLDER + "bg_forms")
      drawPageForms
    end
  end

  # Returns an X that centers the given text around a fixed midpoint,
  # snapped to an even pixel to avoid sub-pixel rendering at 0.5 scale,
  # and clamped so it can never land on a negative position.
  def pbCenteredTextX(overlay, text, center_x)
    text_w = overlay.text_size(text).width
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    return left_x
  end

  # Centers a label+value row (e.g. "Height ... 1.2 m") as one combined
  # block within a box of the given width, keeping label-left/value-right.
  # Returns [label_x, value_right_x].
  def pbCenteredRowX(overlay, label_text, value_text, box_x, box_w, gap = 8)
    label_w = overlay.text_size(label_text).width
    value_w = overlay.text_size(value_text).width
    row_w   = label_w + gap + value_w
    left_x  = box_x + ((box_w - row_w) / 2)
    left_x -= 1 if left_x.odd?
    left_x  = box_x if left_x < box_x
    value_right_x = left_x + row_w
    return [left_x, value_right_x]
  end

  def drawPageInfo
    overlay = @sprites["overlay"].bitmap
    base   = TEXT_COLOR
    shadow = TEXT_SHADOW
    imagepos = []
    imagepos.push([DEX_FOLDER + "info_overlay", 0, 0]) if @brief
    species_data = GameData::Species.get_species_form(@species, @form)

    indexText = "???"
    if @dexlist[@index][:number] > 0
      indexNumber = @dexlist[@index][:number]
      indexNumber -= 1 if @dexlist[@index][:shift]
      indexText = sprintf("%03d", indexNumber)
    end
    textpos = [
      [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
       NAME_TEXT_X, NAME_TEXT_Y, :left, base, shadow]
    ]

    # Caught/seen icon — always shown once seen, caught.png if owned,
    # seenicon.png otherwise, so this part of the layout is never empty
    caught_icon_file = $player.owned?(@species) ? "caughticon.png" : "seenicon.png"
    imagepos.push([DEX_FOLDER + caught_icon_file, CAUGHT_ICON_X, CAUGHT_ICON_Y])

    if @show_battled_count
      label = _INTL("Number Battled")
      value = $player.pokedex.battled_count(@species).to_s
      label_x, value_right_x = pbCenteredRowX(overlay, label, value, HW_BOX_X, HW_BOX_W)
      textpos.push([label, label_x, HW_TEXT_Y, :left, base, shadow])
      textpos.push([value, value_right_x, HW_TEXT_Y + 32, :right, base, shadow])
    end

    if $player.owned?(@species)
      category_text = _INTL("{1} Pokémon", species_data.category)
      category_x = pbCenteredTextX(overlay, category_text, CATEGORY_CENTER_X)
      textpos.push([category_text, category_x, CATEGORY_TEXT_Y, :left, base, shadow])
      if !@show_battled_count
        height = species_data.height
        weight = species_data.weight
        if System.user_language[3..4] == "US"
          inches = (height / 0.254).round
          pounds = (weight / 0.45359).round
          height_val = _ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12)
          weight_val = _ISPRINTF("{1:4.1f} lbs.", pounds / 10.0)
        else
          height_val = _ISPRINTF("{1:.1f} m", height / 10.0)
          weight_val = _ISPRINTF("{1:.1f} kg", weight / 10.0)
        end
        height_label_x, height_value_x = pbCenteredRowX(overlay, _INTL("Height"), height_val, HW_BOX_X, HW_BOX_W)
        weight_label_x, weight_value_x = pbCenteredRowX(overlay, _INTL("Weight"), weight_val, HW_BOX_X, HW_BOX_W)
        textpos.push([_INTL("Height"), height_label_x, HW_TEXT_Y, :left, base, shadow])
        textpos.push([height_val, height_value_x, HW_TEXT_Y, :right, base, shadow])
        textpos.push([_INTL("Weight"), weight_label_x, HW_TEXT_Y + 32, :left, base, shadow])
        textpos.push([weight_val, weight_value_x, HW_TEXT_Y + 32, :right, base, shadow])
      end
      drawTextEx(overlay, DESC_TEXT_X, DESC_TEXT_Y, Graphics.width - (DESC_TEXT_X * 2), 4,
                 species_data.pokedex_entry, base, shadow)

      species_data.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 32, 96, 32)
        overlay.blt(TYPE_ICON_X + (100 * i), TYPE_ICON_Y, @typebitmap.bitmap, type_rect)
      end

      shape_number = GameData::BodyShape.get(species_data.shape).icon_position
      shape_rect = Rect.new(0, shape_number * 60, 60, 60)
      overlay.blt(SHAPE_ICON_X, SHAPE_ICON_Y, @shapebitmap.bitmap, shape_rect)
    else
      category_text = _INTL("????? Pokémon")
      category_x = pbCenteredTextX(overlay, category_text, CATEGORY_CENTER_X)
      textpos.push([category_text, category_x, CATEGORY_TEXT_Y, :left, base, shadow])
      if !@show_battled_count
        if System.user_language[3..4] == "US"
          height_val = _INTL("???'??\"")
          weight_val = _INTL("????.? lbs.")
        else
          height_val = _INTL("????.? m")
          weight_val = _INTL("????.? kg")
        end
        height_label_x, height_value_x = pbCenteredRowX(overlay, _INTL("Height"), height_val, HW_BOX_X, HW_BOX_W)
        weight_label_x, weight_value_x = pbCenteredRowX(overlay, _INTL("Weight"), weight_val, HW_BOX_X, HW_BOX_W)
        textpos.push([_INTL("Height"), height_label_x, HW_TEXT_Y, :left, base, shadow])
        textpos.push([height_val, height_value_x, HW_TEXT_Y, :right, base, shadow])
        textpos.push([_INTL("Weight"), weight_label_x, HW_TEXT_Y + 32, :left, base, shadow])
        textpos.push([weight_val, weight_value_x, HW_TEXT_Y + 32, :right, base, shadow])
      end
    end

    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
  end

  # Returns a 1D array of values corresponding to points on the Town Map.
  # Each value is true or false.
  def pbGetEncounterPoints
    visible_points = []
    @mapdata.point.each do |loc|
      next if loc[7] && !$game_switches[loc[7]]
      visible_points.push([loc[0], loc[1]])
    end
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    ret = []
    GameData::Encounter.each_of_version($PokemonGlobal.encounter_version) do |enc_data|
      next if !pbFindEncounter(enc_data.types, @species)
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
      mappos = map_metadata.town_map_position
      next if mappos[0] != @region
      map_size = map_metadata.town_map_size
      map_width = 1
      map_height = 1
      map_shape = "1"
      if map_size && map_size[0] && map_size[0] > 0
        map_width = map_size[0]
        map_shape = map_size[1]
        map_height = (map_shape.length.to_f / map_width).ceil
      end
      map_width.times do |i|
        map_height.times do |j|
          next if map_shape[i + (j * map_width), 1].to_i == 0
          next if !visible_points.include?([mappos[1] + i, mappos[2] + j])
          ret[mappos[1] + i + ((mappos[2] + j) * town_map_width)] = true
        end
      end
    end
    return ret
  end

  def drawPageArea
    overlay = @sprites["overlay"].bitmap
    base   = TEXT_COLOR
    shadow = TEXT_SHADOW
    @sprites["areahighlight"].bitmap.clear
    points = pbGetEncounterPoints
    pointcolor   = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    sqwidth  = PokemonRegionMap_Scene::SQUARE_WIDTH
    sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
    points.length.times do |j|
      next if !points[j]
      x = (j % town_map_width) * sqwidth
      x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
      y = (j / town_map_width) * sqheight
      y += (Graphics.height + 32 - @sprites["areamap"].bitmap.height) / 2
      y -= 18
      @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
      if j - town_map_width < 0 || !points[j - town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
      end
      if j + town_map_width >= points.length || !points[j + town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
      end
      if j % town_map_width == 0 || !points[j - 1]
        @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
      end
      if (j + 1) % town_map_width == 0 || !points[j + 1]
        @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
      end
    end
    textpos = []
    if points.length == 0
      pbDrawImagePositions(overlay, [[DEX_FOLDER + "overlay_areanone", 252, 238]])
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, (Graphics.height / 2) + 6, :center, base, shadow])
    end
    textpos.push([@mapdata.name, 414 + 144, 50 + 30, :center, base, shadow])
    textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                  Graphics.width / 2, 358 + 30, :center, base, shadow])
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageForms
    overlay = @sprites["overlay"].bitmap
    base   = TEXT_COLOR
    shadow = TEXT_SHADOW
    formname = ""
    @available.each do |i|
      if i[1] == @gender && i[2] == @form
        formname = i[0]
        break
      end
    end
    textpos = [
      [GameData::Species.get(@species).name, Graphics.width / 2, Graphics.height - 82, :center, base, shadow],
      [formname, Graphics.width / 2, Graphics.height - 50, :center, base, shadow]
    ]
    pbDrawTextPositions(overlay, textpos)
  end

  #-----------------------------------------------------------------------------
  # Override pbUpdateDummyPokemon — same as vanilla, but formback's Y is set
  # as one flat value (base + per-species offset) instead of two chained
  # assignments
  #-----------------------------------------------------------------------------
  def pbUpdateDummyPokemon
    @species = @dexlist[@index][:species]
    @gender, @form, _shiny = $player.pokedex.last_form_seen(@species)
    @shiny = false
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species, @gender, @form, @shiny)
    @sprites["formfront"]&.setSpeciesBitmap(@species, @gender, @form, @shiny)
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species, @gender, @form, @shiny, false, true)
      @sprites["formback"].y = 270 + (metrics_data.back_sprite[1] * 2)
    end
    @sprites["formicon"]&.pbSetParams(@species, @gender, @form, @shiny)
  end

  #-----------------------------------------------------------------------------
  # Override pbScene — same page-flip/cry/USE behaviour as vanilla, with the
  # arrow/cancel buttons wired in for mouse and flashed on keyboard press
  #-----------------------------------------------------------------------------
  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      left_clicked, right_clicked, cancel_clicked = pbHandleInfoButtons
      dorefresh = false
      if cancel_clicked
        pbPlayCloseMenuSE
        pbFlashCancelButton
        break
      elsif Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        pbFlashCancelButton
        break
      elsif Input.trigger?(Input::USE)
        case @page
        when 1   # Info
          pbPlayDecisionSE
          @show_battled_count = !@show_battled_count
          dorefresh = true
        when 2   # Area
#          dorefresh = true
        when 3   # Forms
          if @available.length > 1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index != oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
          dorefresh = true
        end
      elsif left_clicked || Input.trigger?(Input::LEFT)
        pbFlashLeftArrow if Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif right_clicked || Input.trigger?(Input::RIGHT)
        pbFlashRightArrow if Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 3 if @page > 3
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      drawPage(@page) if dorefresh
    end
    return @index
  end

  #-----------------------------------------------------------------------------
  # Override pbSceneBrief — "just caught" popup. No cancel/left/right arrows,
  # just the Next button, wired for mouse and flashed on keyboard press.
  #-----------------------------------------------------------------------------
  def pbSceneBrief
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      next_clicked = pbHandleBriefButtons
      if next_clicked
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form)
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
        pbPlayCloseMenuSE
        pbFlashNextButton
        break
      end
    end
  end

end
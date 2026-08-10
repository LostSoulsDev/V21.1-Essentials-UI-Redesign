#===============================================================================
#                        Custom Party Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonParty_Scene

  attr_accessor :screen_owner

  PARTY_FOLDER = "Graphics/Custom UI/Party/"

  GRID_SCROLL_W = 800

  # Decor bar/overlay rest positions and slide animation
  BAR_REST_X     = 0
  BAR_REST_Y     = 342
  OVERLAY_REST_X = 0
  OVERLAY_REST_Y = 450
  SLIDE_FRAMES        = 15
  OVERLAY_SLIDE_DELAY = 5   # frames bg_overlay waits before it starts sliding

  # name_bar / button_bg / pokemon_base — all slide in together, in sync
  NAME_BAR_REST_X = 0
  NAME_BAR_REST_Y = 14
  NAME_BAR_W      = 384
  NAME_BAR_H      = 78

  BUTTON_BG_REST_X = 418
  BUTTON_BG_REST_Y = 8

  POKEMON_BASE_REST_X = 28
  POKEMON_BASE_REST_Y = 208
  POKEMON_BASE_W      = 252
  POKEMON_BASE_H      = 66
  POKEMON_SPRITE_Y_OFFSET = -20

  # Base party panel (icon_box.png) — one per slot, always shown regardless
  # of whether that slot has a Pokémon in it
  BOX_REST_Y = 362
  BOX_X_POSITIONS = [70, 180, 290, 400, 510, 620]

  # icon_bar_overlay.png — only shown if that slot has a Pokémon, position
  # relative to its box, and moves in lockstep with it
  BAR_OVERLAY_OFFSET_X = 2
  BAR_OVERLAY_OFFSET_Y = 80

  # icon_overlay_hp.png — the HP bar, on top of icon_bar_overlay.png,
  # relative to it. 100x12 total, 3 colour zones stacked vertically.
  HP_OVERLAY_OFFSET_X = 2
  HP_OVERLAY_OFFSET_Y = 2
  HP_OVERLAY_W        = 100
  HP_OVERLAY_H        = 12

  # Animated species icon, relative to icon_box.png
  SPECIES_ICON_OFFSET_X = 22
  SPECIES_ICON_OFFSET_Y = 12

  # icon_exp.png — single bar, 100x4, relative to icon_bar_overlay.png
  EXP_OVERLAY_OFFSET_X = 2
  EXP_OVERLAY_OFFSET_Y = 8
  EXP_OVERLAY_W        = 100
  EXP_OVERLAY_H        = 4

  # name_bar.png — text/icons bound to it, in relative position
  NAME_BAR_TEXT_COLOR  = Color.new(255, 255, 255)
  NAME_BAR_TEXT_SHADOW = Color.new(33, 33, 33)
  NAME_BAR_NAME_X = 22
  NAME_BAR_NAME_Y = 10
  NAME_BAR_GENDER_X = 226
  NAME_BAR_GENDER_Y = 10
  NAME_BAR_LV_X = 244
  NAME_BAR_LV_Y = 14
  NAME_BAR_MEGA_X = 303
  NAME_BAR_MEGA_Y = 8
  NAME_BAR_ITEM_X = 332
  NAME_BAR_ITEM_Y = 22
  NAME_BAR_MAIL_X = 350
  NAME_BAR_MAIL_Y = 22

  # name_bar.png — second row: HP label/value, status icon, HP bar
  NAME_BAR_HP_LABEL_X = 22
  NAME_BAR_HP_LABEL_Y = 50
  NAME_BAR_HP_VALUE_CENTER_X = 180
  NAME_BAR_HP_VALUE_Y        = 50
  NAME_BAR_STATUS_X = 14
  NAME_BAR_STATUS_Y = 80
  NAME_BAR_HPBAR_OVERLAY_X = 70
  NAME_BAR_HPBAR_OVERLAY_Y = 80
  NAME_BAR_HP_FILL_OFFSET_X = 30
  NAME_BAR_HP_FILL_OFFSET_Y = 4
  NAME_BAR_HP_FILL_W = 176
  NAME_BAR_HP_FILL_H = 30

  # name_box_selector.png — follows the selected box, baked-in name text
  NAME_SELECTOR_W = 184
  NAME_SELECTOR_H = 56
  NAME_SELECTOR_Y = 480 - 118
  NAME_SELECTOR_OFFSET_X = -38
  NAME_SELECTOR_TEXT_Y_OFFSET = -44
  NAME_SELECTOR_TEXT_COLOR  = Color.new(255, 255, 255)
  NAME_SELECTOR_TEXT_SHADOW = Color.new(33, 33, 33)
  NAME_SELECTOR_ZOOM_FRAMES = 12

  # Command button list — bound to button_bg.png's x scroll, always visible
  # (not gated behind ACTION like vanilla). Vertically scrolling window.
  CMD_BTN_OFFSET_X   = 24
  CMD_BTN_START_Y    = 40   # relative to button_bg.png
  CMD_BTN_AREA_W     = 264
  CMD_BTN_AREA_H     = 236
  CMD_BTN_W          = 264
  CMD_BTN_H          = 44
  CMD_BTN_GAP        = 4
  CMD_BTN_STRIDE     = CMD_BTN_H + CMD_BTN_GAP
  CMD_BTN_VISIBLE    = (CMD_BTN_AREA_H + CMD_BTN_GAP) / CMD_BTN_STRIDE   # 5
  CMD_BTN_TEXT_COLOR  = Color.new(0, 0, 0)
  CMD_BTN_TEXT_SHADOW = Color.new(173, 189, 189)
  CMD_BTN_TEXT_Y      = 12

  # button_bg.png header text — "Do what with X?" / "X selected" etc
  BUTTON_BG_W = 312
  BUTTON_BG_H = 300
  BUTTON_BG_TEXT_Y = 10
  BUTTON_BG_TEXT_COLOR  = Color.new(255, 255, 255)
  BUTTON_BG_TEXT_SHADOW = Color.new(40, 40, 40)

  # highlight.png — animated, 4 frames stacked vertically, 272x208 total
  CMD_HIGHLIGHT_W      = 272
  CMD_HIGHLIGHT_H      = 208
  CMD_HIGHLIGHT_FRAMES = 4
  CMD_HIGHLIGHT_SPEED  = 7
  CMD_HIGHLIGHT_OFFSET_X = -4
  CMD_HIGHLIGHT_OFFSET_Y = -4

  def pbStartScene(party, starthelptext, annotations = nil, multiselect = false, can_access_storage = false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    @can_access_storage = can_access_storage

    @sprites["custom_grid"] = IconSprite.new(@viewport)
    @sprites["custom_grid"].setBitmap(PARTY_FOLDER + "grid.png")
    @sprites["custom_grid"].x = 0
    @sprites["custom_grid"].y = 0
    @sprites["custom_grid"].z = 0

    @sprites["bg_bar"] = IconSprite.new(@viewport)
    @sprites["bg_bar"].setBitmap(PARTY_FOLDER + "bg_bar.png")
    @sprites["bg_bar"].x = BAR_REST_X
    @sprites["bg_bar"].y = Graphics.height
    @sprites["bg_bar"].z = 1

    @sprites["bg_overlay"] = IconSprite.new(@viewport)
    @sprites["bg_overlay"].setBitmap(PARTY_FOLDER + "bg_overlay.png")
    @sprites["bg_overlay"].x = OVERLAY_REST_X
    @sprites["bg_overlay"].y = Graphics.height
    @sprites["bg_overlay"].z = 3

    @sprites["name_bar"] = Sprite.new(@viewport)
    base_name_bar = Bitmap.new(PARTY_FOLDER + "name_bar.png")
    @sprites["name_bar"].bitmap = Bitmap.new(base_name_bar.width, base_name_bar.height)
    @sprites["name_bar"].bitmap.blt(0, 0, base_name_bar, base_name_bar.rect)
    base_name_bar.dispose
    @sprites["name_bar"].x = -NAME_BAR_W
    @sprites["name_bar"].y = NAME_BAR_REST_Y
    @sprites["name_bar"].z = 4

    @sprites["namebar_mega"] = IconSprite.new(@viewport)
    @sprites["namebar_mega"].setBitmap(PARTY_FOLDER + "icon_mega.png")
    @sprites["namebar_mega"].z = 5
    @sprites["namebar_mega"].visible = false

    @sprites["namebar_item"] = IconSprite.new(@viewport)
    @sprites["namebar_item"].setBitmap(PARTY_FOLDER + "icon_item.png")
    @sprites["namebar_item"].z = 5
    @sprites["namebar_item"].visible = false

    @sprites["namebar_mail"] = IconSprite.new(@viewport)
    @sprites["namebar_mail"].setBitmap(PARTY_FOLDER + "icon_mail.png")
    @sprites["namebar_mail"].z = 5
    @sprites["namebar_mail"].visible = false

    @sprites["namebar_status"] = IconSprite.new(@viewport)
    @sprites["namebar_status"].setBitmap(_INTL("Graphics/UI/statuses"))
    @sprites["namebar_status"].z = 5
    @sprites["namebar_status"].visible = false

    @sprites["namebar_hpbaroverlay"] = IconSprite.new(@viewport)
    @sprites["namebar_hpbaroverlay"].setBitmap(PARTY_FOLDER + "hp_bar_overlay.png")
    @sprites["namebar_hpbaroverlay"].z = 5
    @sprites["namebar_hpbaroverlay"].visible = false

    @sprites["namebar_hpfill"] = IconSprite.new(@viewport)
    @sprites["namebar_hpfill"].setBitmap(PARTY_FOLDER + "overlay_hp.png")
    @sprites["namebar_hpfill"].src_rect.set(0, 0, NAME_BAR_HP_FILL_W, NAME_BAR_HP_FILL_H / 3)
    @sprites["namebar_hpfill"].z = 6
    @sprites["namebar_hpfill"].visible = false

    @sprites["button_bg"] = Sprite.new(@viewport)
    base_button_bg = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    @sprites["button_bg"].bitmap = Bitmap.new(base_button_bg.width, base_button_bg.height)
    @sprites["button_bg"].bitmap.blt(0, 0, base_button_bg, base_button_bg.rect)
    base_button_bg.dispose
    @sprites["button_bg"].x = Graphics.width
    @sprites["button_bg"].y = BUTTON_BG_REST_Y
    @sprites["button_bg"].z = 4

    @sprites["pokemon_base"] = IconSprite.new(@viewport)
    @sprites["pokemon_base"].setBitmap(PARTY_FOLDER + "pokemon_base.png")
    @sprites["pokemon_base"].x = -POKEMON_BASE_W
    @sprites["pokemon_base"].y = POKEMON_BASE_REST_Y
    @sprites["pokemon_base"].z = 4

    @sprites["party_pokemon_sprite"] = PokemonSprite.new(@viewport)
    @sprites["party_pokemon_sprite"].z = 5
    @last_party_sprite_species = nil

    6.times do |i|
      spr = IconSprite.new(@viewport)
      spr.setBitmap(PARTY_FOLDER + "icon_box.png")
      spr.x = BOX_X_POSITIONS[i]
      spr.y = Graphics.height
      spr.z = 2
      @sprites["box#{i}"] = spr

      bar_spr = IconSprite.new(@viewport)
      bar_spr.setBitmap(PARTY_FOLDER + "icon_bar_overlay.png")
      bar_spr.x = spr.x + BAR_OVERLAY_OFFSET_X
      bar_spr.y = spr.y + BAR_OVERLAY_OFFSET_Y
      bar_spr.z = 3
      bar_spr.visible = false
      @sprites["barover#{i}"] = bar_spr

      hp_spr = IconSprite.new(@viewport)
      hp_spr.setBitmap(PARTY_FOLDER + "icon_overlay_hp.png")
      hp_spr.src_rect.set(0, 0, HP_OVERLAY_W, HP_OVERLAY_H / 3)
      hp_spr.x = bar_spr.x + HP_OVERLAY_OFFSET_X
      hp_spr.y = bar_spr.y + HP_OVERLAY_OFFSET_Y
      hp_spr.z = 4
      hp_spr.visible = false
      @sprites["hpover#{i}"] = hp_spr

      exp_spr = IconSprite.new(@viewport)
      exp_spr.setBitmap(PARTY_FOLDER + "icon_exp.png")
      exp_spr.src_rect.set(0, 0, 0, EXP_OVERLAY_H)
      exp_spr.x = bar_spr.x + EXP_OVERLAY_OFFSET_X
      exp_spr.y = bar_spr.y + EXP_OVERLAY_OFFSET_Y
      exp_spr.z = 4
      exp_spr.visible = false
      @sprites["expover#{i}"] = exp_spr

      species_spr = PokemonIconSprite.new(nil, @viewport)
      species_spr.x = spr.x + SPECIES_ICON_OFFSET_X
      species_spr.y = spr.y + SPECIES_ICON_OFFSET_Y
      species_spr.z = 3
      species_spr.visible = false
      @sprites["speciesicon#{i}"] = species_spr
    end

    @activecmd = 0
    @sprites["name_selector"] = Sprite.new(@viewport)
    base_selector = Bitmap.new(PARTY_FOLDER + "name_box_selector.png")
    @sprites["name_selector"].bitmap = Bitmap.new(base_selector.width, base_selector.height)
    @sprites["name_selector"].bitmap.blt(0, 0, base_selector, base_selector.rect)
    base_selector.dispose
    @sprites["name_selector"].oy = NAME_SELECTOR_H   # anchor from the bottom
    @sprites["name_selector"].y  = NAME_SELECTOR_Y
    @sprites["name_selector"].x  = BOX_X_POSITIONS[0] + NAME_SELECTOR_OFFSET_X
    @sprites["name_selector"].zoom_y = 0
    @sprites["name_selector"].z  = 5
    pbDrawNameSelectorText

    pbUpdatePartyIcons
    pbUpdateBoxSelection

    @cmdindex     = 0
    @cmdscroll    = 0
    @command_list = []
    @command_data = []
    @menu_mode    = :main
    @highlight_frame = 0
    @highlight_tick  = 0
    @sprites["cmd_highlight"] = IconSprite.new(@viewport)
    @sprites["cmd_highlight"].setBitmap(PARTY_FOLDER + "highlight.png")
    @sprites["cmd_highlight"].src_rect.set(0, 0, CMD_HIGHLIGHT_W, CMD_HIGHLIGHT_H / CMD_HIGHLIGHT_FRAMES)
    @sprites["cmd_highlight"].z = 6
    pbBuildCommandList
    pbUpdateCommandButtons(true)
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[@activecmd])

    pbFadeInAndShow(@sprites) { update }
    pbSlideDecorIn
    pbZoomNameSelectorIn
  end

  #-----------------------------------------------------------------------------
  # Builds whichever command list matches @menu_mode, and bakes the matching
  # header text onto button_bg. Dispatches to the mode-specific builder.
  #-----------------------------------------------------------------------------
  def pbBuildCommandList
    @menu_mode ||= :main
    case @menu_mode
    when :item
      pbBuildItemCommandList
    when :move
      pbBuildMoveCommandList
    else
      pbBuildMainCommandList
    end
    @cmdindex  = 0
    @cmdscroll = 0
    pbDrawButtonBgHeader
  end

  #-----------------------------------------------------------------------------
  # Main list — same dynamic vanilla list (Summary, Debug, Switch, Mail,
  # Item, hidden move field commands), plus a Cancel entry at the end.
  # "Do what with X?" header.
  #-----------------------------------------------------------------------------
  def pbBuildMainCommandList
    @command_list = []
    @command_data = []
    pkmn = @party[@activecmd]
    return if !pkmn

    MenuHandlers.each_available(:party_menu, self, @party, @activecmd) do |option, hash, name|
      @command_list.push(name)
      @command_data.push(hash)
    end

    if !pkmn.egg?
      insert_index = ($DEBUG) ? 2 : 1
      pkmn.moves.each_with_index do |move, i|
        next if !HiddenMoveHandlers.hasHandler(move.id) &&
                ![:MILKDRINK, :SOFTBOILED].include?(move.id)
        @command_list.insert(insert_index, move.name)
        @command_data.insert(insert_index, [:move, i])
        insert_index += 1
      end
    end

    @command_list.push(_INTL("Cancel"))
    @command_data.push(:cancel)
  end

  #-----------------------------------------------------------------------------
  # Item sub-menu — Give / Take / Back. "Do what with X?" header.
  #-----------------------------------------------------------------------------
  def pbBuildItemCommandList
    pkmn = @party[@activecmd]
    @command_list = [_INTL("Give")]
    @command_data = [:item_give]
    if pkmn && pkmn.hasItem?
      @command_list.push(_INTL("Take"))
      @command_data.push(:item_take)
    end
    @command_list.push(_INTL("Back"))
    @command_data.push(:back)
  end

  #-----------------------------------------------------------------------------
  # Move sub-menu (a hidden-move field command was picked) — Use / Back.
  # "Do what with X?" header.
  #-----------------------------------------------------------------------------
  def pbBuildMoveCommandList
    @command_list = [_INTL("Use"), _INTL("Back")]
    @command_data = [:move_use, :back]
  end

  #-----------------------------------------------------------------------------
  # Bakes the contextual header text onto button_bg — "Do what with X?" for
  # the main/item/move lists, "X selected" for the switch list.
  #-----------------------------------------------------------------------------
  def pbDrawButtonBgHeader
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)

    pkmn = @party[@activecmd]
    name = pkmn ? pkmn.name : ""
    text = (@menu_mode == :switch_target) ? _INTL("{1} selected", name) : _INTL("Do what with {1}?", name)

    text_w = bmp.text_size(text).width
    left_x = (BUTTON_BG_W / 2) - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])

    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
  end



  #-----------------------------------------------------------------------------
  # Eases name_selector's zoom_y from 0 to 1, expanding it into view from
  # its bottom-anchored origin
  #-----------------------------------------------------------------------------
  def pbZoomNameSelectorIn
    spr = @sprites["name_selector"]
    return if !spr
    NAME_SELECTOR_ZOOM_FRAMES.times do |frame|
      t = (frame + 1) / NAME_SELECTOR_ZOOM_FRAMES.to_f
      spr.zoom_y = 1 - (1 - t) ** 2   # ease out
      update
      Graphics.update
      Input.update
    end
    spr.zoom_y = 1
  end

  #-----------------------------------------------------------------------------
  # Eases name_selector's zoom_y from 1 back to 0, collapsing it back down
  # into its bottom-anchored origin
  #-----------------------------------------------------------------------------
  def pbZoomNameSelectorOut
    spr = @sprites["name_selector"]
    return if !spr
    NAME_SELECTOR_ZOOM_FRAMES.times do |frame|
      t = (frame + 1) / NAME_SELECTOR_ZOOM_FRAMES.to_f
      spr.zoom_y = 1 - (t ** 2)   # ease in
      update
      Graphics.update
      Input.update
    end
    spr.zoom_y = 0
  end

  #-----------------------------------------------------------------------------
  # Draws the selected Pokémon's name baked directly onto the selector
  # graphic's own bitmap, so zoom_y scales the text along with the graphic.
  # Horizontally centred in the selector's width, offset vertically as given.
  #-----------------------------------------------------------------------------
  def pbDrawNameSelectorText
    spr = @sprites["name_selector"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "name_box_selector.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    pkmn = @party[@activecmd]
    if pkmn
      text_y = NAME_SELECTOR_H + NAME_SELECTOR_TEXT_Y_OFFSET
      center_x = NAME_SELECTOR_W / 2
      text_w = bmp.text_size(pkmn.name).width
      left_x = center_x - (text_w / 2)
      left_x -= 1 if left_x.odd?
      left_x = 0 if left_x < 0
      pbDrawTextPositions(bmp, [[pkmn.name, left_x, text_y, :left,
                                  NAME_SELECTOR_TEXT_COLOR, NAME_SELECTOR_TEXT_SHADOW]])
    end
    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
    spr.oy = NAME_SELECTOR_H
  end

  #-----------------------------------------------------------------------------
  # Bakes the selected Pokémon's name and level onto name_bar's own bitmap
  # (so they move with it during the slide), and positions/shows the
  # gender symbol and mega/item/mail icons as separate sprites bound to
  # name_bar's current position.
  #-----------------------------------------------------------------------------
  def pbDrawNameBarContent
    spr = @sprites["name_bar"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "name_bar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)

    pkmn = @party[@activecmd]
    textpos = []
    if pkmn
      textpos.push([pkmn.name, NAME_BAR_NAME_X, NAME_BAR_NAME_Y, :left,
                     NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])

      if !pkmn.egg? && !pkmn.genderless?
        gender_text  = pkmn.male? ? _INTL("♂") : _INTL("♀")
        base_color   = pkmn.male? ? Color.new(0, 112, 248) : Color.new(232, 32, 16)
        shadow_color = pkmn.male? ? Color.new(120, 184, 232) : Color.new(248, 168, 184)
        textpos.push([gender_text, NAME_BAR_GENDER_X, NAME_BAR_GENDER_Y, :left, base_color, shadow_color])
      end

      if !pkmn.egg?
        pbDrawImagePositions(bmp, [[PARTY_FOLDER + "overlay_lv", NAME_BAR_LV_X, NAME_BAR_LV_Y, 0, 0, 22, 14]])
        pbSetSmallFont(bmp)
        textpos.push([pkmn.level.to_s, NAME_BAR_LV_X + 22, NAME_BAR_LV_Y - 2, :left,
                       NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])
        pbSetSystemFont(bmp)
      end

      textpos.push(["HP", NAME_BAR_HP_LABEL_X, NAME_BAR_HP_LABEL_Y, :left,
                     NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])

      if !pkmn.egg?
        hp_text = sprintf("%d/%d", pkmn.hp, pkmn.totalhp)
        hp_text_w = bmp.text_size(hp_text).width
        hp_left_x = NAME_BAR_HP_VALUE_CENTER_X - (hp_text_w / 2)
        hp_left_x -= 1 if hp_left_x.odd?
        hp_left_x = 0 if hp_left_x < 0
        textpos.push([hp_text, hp_left_x, NAME_BAR_HP_VALUE_Y, :left,
                       NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])
      end
    end
    pbDrawTextPositions(bmp, textpos)

    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp

    pbUpdateNameBarIcons(pkmn)
  end

  #-----------------------------------------------------------------------------
  # Shows/hides the mega/item/mail icons for the selected Pokémon
  #-----------------------------------------------------------------------------
  def pbUpdateNameBarIcons(pkmn)
    mega_spr = @sprites["namebar_mega"]
    item_spr = @sprites["namebar_item"]
    mail_spr = @sprites["namebar_mail"]
    status_spr  = @sprites["namebar_status"]
    hpbar_spr   = @sprites["namebar_hpbaroverlay"]
    hpfill_spr  = @sprites["namebar_hpfill"]

    can_mega = pkmn && !pkmn.egg? && pkmn.respond_to?(:hasMegaRing?) &&
               $player.has_mega_ring? && pkmn.mega_stone_exists?
    mega_spr.visible = !!can_mega if mega_spr

    has_item = pkmn && !pkmn.egg? && pkmn.hasItem? && !(pkmn.item && pkmn.item.is_mail?)
    item_spr.visible = !!has_item if item_spr

    has_mail = pkmn && !pkmn.egg? && pkmn.mail
    mail_spr.visible = !!has_mail if mail_spr

    if status_spr
      status = -1
      if pkmn && !pkmn.egg?
        if pkmn.fainted?
          status = GameData::Status.count - 1
        elsif pkmn.status != :NONE
          status = GameData::Status.get(pkmn.status).icon_position
        elsif pkmn.pokerusStage == 1
          status = GameData::Status.count
        end
      end
      if status >= 0
        status_spr.visible = true
        status_spr.src_rect.set(0, 16 * status, 44, 16)
      else
        status_spr.visible = false
      end
    end

    if hpbar_spr && hpfill_spr
      if pkmn && !pkmn.egg?
        hpbar_spr.visible  = true
        hpfill_spr.visible = true
        zone_h = NAME_BAR_HP_FILL_H / 3
        zone = 0
        zone = 1 if pkmn.hp <= (pkmn.totalhp / 2.0).floor
        zone = 2 if pkmn.hp <= (pkmn.totalhp / 4.0).floor
        target_w = pkmn.totalhp > 0 ? (pkmn.hp * NAME_BAR_HP_FILL_W / pkmn.totalhp.to_f).round : 0
        target_w = target_w.clamp(0, NAME_BAR_HP_FILL_W)
        pbStartHPBarAnim("namebar", hpfill_spr, target_w, zone, zone_h, NAME_BAR_HP_FILL_W, pkmn.object_id)
      else
        hpbar_spr.visible  = false
        hpfill_spr.visible = false
      end
    end

    pbSyncNameBarIconPositions
  end

  #-----------------------------------------------------------------------------
  # Starts (or updates the target of) a width animation for one HP bar.
  # If no animation is running and the width already matches, applies it
  # immediately with no tween — only actual changes animate.
  #-----------------------------------------------------------------------------
  def pbStartHPBarAnim(key, spr, target_w, zone, zone_h, max_w, identity = nil)
    @hp_bar_anim ||= {}
    entry = @hp_bar_anim[key]
    identity_changed = entry && identity && entry[:identity] != identity
    current_w = entry ? entry[:current_w] : target_w
    if entry.nil? || identity_changed
      # New bar, or now showing a different Pokémon than last time (e.g.
      # switched selection) — snap instantly, don't animate between two
      # different Pokémon's HP values
      current_w = target_w
    end
    @hp_bar_anim[key] = {
      sprite: spr, current_w: current_w, target_w: target_w,
      zone: zone, zone_h: zone_h, max_w: max_w, identity: identity,
      start_w: current_w, start_time: System.uptime
    }
    spr.src_rect.set(0, zone * zone_h, current_w.clamp(0, max_w), zone_h)
  end

  #-----------------------------------------------------------------------------
  # Eases every active HP bar's displayed width toward its target — called
  # every frame from update. Zone (colour) always reflects the live target
  # immediately; only the width itself is what animates.
  #-----------------------------------------------------------------------------
  def pbAnimateHPBars
    return if !@hp_bar_anim
    @hp_bar_anim.each_value do |entry|
      spr = entry[:sprite]
      next if !spr || spr.disposed?
      next if entry[:current_w] == entry[:target_w]
      t = (System.uptime - entry[:start_time]) / HP_BAR_ANIM_SECONDS
      t = t.clamp(0.0, 1.0)
      entry[:current_w] = (entry[:start_w] + ((entry[:target_w] - entry[:start_w]) * t)).round
      w = entry[:current_w].clamp(0, entry[:max_w])
      # Colour reflects the bar's own current on-screen width, not the
      # final target, so it visibly passes through yellow as it drains
      # rather than snapping straight to the destination colour.
      fraction = entry[:max_w] > 0 ? w.to_f / entry[:max_w] : 0
      zone = 0
      zone = 1 if fraction <= 0.5
      zone = 2 if fraction <= 0.25
      spr.src_rect.set(0, zone * entry[:zone_h], w, entry[:zone_h])
    end
  end

  #-----------------------------------------------------------------------------
  # Keeps the gender/mega/item/mail icons locked to name_bar's current x/y —
  # call every frame during the slide animations so they move together
  #-----------------------------------------------------------------------------
  def pbSyncNameBarIconPositions
    bar = @sprites["name_bar"]
    return if !bar
    if @sprites["namebar_mega"]
      @sprites["namebar_mega"].x = bar.x + NAME_BAR_MEGA_X
      @sprites["namebar_mega"].y = bar.y + NAME_BAR_MEGA_Y
    end
    if @sprites["namebar_item"]
      @sprites["namebar_item"].x = bar.x + NAME_BAR_ITEM_X
      @sprites["namebar_item"].y = bar.y + NAME_BAR_ITEM_Y
    end
    if @sprites["namebar_mail"]
      @sprites["namebar_mail"].x = bar.x + NAME_BAR_MAIL_X
      @sprites["namebar_mail"].y = bar.y + NAME_BAR_MAIL_Y
    end
    if @sprites["namebar_status"]
      @sprites["namebar_status"].x = bar.x + NAME_BAR_STATUS_X
      @sprites["namebar_status"].y = bar.y + NAME_BAR_STATUS_Y
    end
    if @sprites["namebar_hpbaroverlay"]
      @sprites["namebar_hpbaroverlay"].x = bar.x + NAME_BAR_HPBAR_OVERLAY_X
      @sprites["namebar_hpbaroverlay"].y = bar.y + NAME_BAR_HPBAR_OVERLAY_Y
    end
    if @sprites["namebar_hpfill"]
      hpbar_x = bar.x + NAME_BAR_HPBAR_OVERLAY_X
      hpbar_y = bar.y + NAME_BAR_HPBAR_OVERLAY_Y
      @sprites["namebar_hpfill"].x = hpbar_x + NAME_BAR_HP_FILL_OFFSET_X
      @sprites["namebar_hpfill"].y = hpbar_y + NAME_BAR_HP_FILL_OFFSET_Y
    end
  end

  #-----------------------------------------------------------------------------
  # Swaps the selected Pokémon's front sprite when the selection changes.
  # Same centering approach as the dex screen: ox/oy derived from the
  # bitmap's own size, with a parity nudge so the rendered edge (x - ox)
  # always lands on an even pixel — avoiding sub-pixel blur.
  #-----------------------------------------------------------------------------
  def pbUpdatePartySpriteGraphic(pkmn)
    spr = @sprites["party_pokemon_sprite"]
    return if !spr
    if !pkmn
      spr.visible = false
      @last_party_sprite_species = nil
      return
    end
    display_key = pkmn.species
    if display_key != @last_party_sprite_species
      @last_party_sprite_species = display_key
      gender = pkmn.gender
      form   = pkmn.form
      shiny  = pkmn.shiny?
      spr.setSpeciesBitmap(pkmn.species, gender, form, shiny)
    end
    bmp = spr.bitmap
    if bmp && !bmp.disposed?
      ox = bmp.width / 2
      oy = bmp.height / 2
      spr.ox = ox
      spr.oy = oy
    end
    spr.visible = true
    pbSyncPartySpritePosition
  end

  #-----------------------------------------------------------------------------
  # Centres the front sprite within pokemon_base.png's current x/y, using
  # the same even-pixel-safe nudge as the dex screen
  #-----------------------------------------------------------------------------
  def pbSyncPartySpritePosition
    spr  = @sprites["party_pokemon_sprite"]
    base = @sprites["pokemon_base"]
    return if !spr || !base || !spr.visible
    ox = spr.ox
    oy = spr.oy
    target_x = base.x + (POKEMON_BASE_W / 2)
    target_y = base.y + (POKEMON_BASE_H / 2) + POKEMON_SPRITE_Y_OFFSET
    target_x += 1 if (target_x - ox).odd?
    target_y += 1 if (target_y - oy).odd?
    spr.x = target_x
    spr.y = target_y
  end

  #-----------------------------------------------------------------------------
  # Shows/hides icon_bar_overlay, icon_overlay_hp, icon_exp, and the species
  # icon per slot depending on whether that party slot actually has a
  # Pokémon in it, and updates their fill/frame to match that Pokémon
  #-----------------------------------------------------------------------------
  HP_BAR_ANIM_SECONDS = 0.5

  #-----------------------------------------------------------------------------
  # Sets each slot's target HP bar width/zone from the Pokémon's real HP,
  # but only starts an animation if the value actually changed — the
  # width itself eases toward the target every frame via
  # pbAnimateHPBars, called from update.
  #-----------------------------------------------------------------------------
  def pbUpdatePartyIcons
    @hp_bar_anim ||= {}
    6.times do |i|
      pkmn = @party[i]
      bar_spr     = @sprites["barover#{i}"]
      hp_spr      = @sprites["hpover#{i}"]
      exp_spr     = @sprites["expover#{i}"]
      species_spr = @sprites["speciesicon#{i}"]
      next if !bar_spr

      if pkmn
        bar_spr.visible = true

        if hp_spr
          hp_spr.visible = true
          zone_h = HP_OVERLAY_H / 3
          zone = 0
          zone = 1 if pkmn.hp <= (pkmn.totalhp / 2.0).floor
          zone = 2 if pkmn.hp <= (pkmn.totalhp / 4.0).floor
          target_w = pkmn.totalhp > 0 ? (pkmn.hp * HP_OVERLAY_W / pkmn.totalhp.to_f).round : 0
          target_w = target_w.clamp(0, HP_OVERLAY_W)
          pbStartHPBarAnim("box#{i}", hp_spr, target_w, zone, zone_h, HP_OVERLAY_W, pkmn.object_id)
        end

        if exp_spr
          # Same calculation vanilla uses for its own exp gauge: how far
          # through the current level's exp range the Pokémon currently is
          if pkmn.egg? || pkmn.level >= GameData::GrowthRate.max_level
            exp_fraction = 0
          else
            cur_level_exp  = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
            next_level_exp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
            range = next_level_exp - cur_level_exp
            exp_fraction = (range > 0) ? (pkmn.exp - cur_level_exp).to_f / range : 0
          end
          exp_fraction = exp_fraction.clamp(0.0, 1.0)
          exp_w = (EXP_OVERLAY_W * exp_fraction).to_i
          exp_spr.visible = true
          exp_spr.src_rect.set(0, 0, exp_w, EXP_OVERLAY_H)
        end

        if species_spr
          begin
            species_spr.pokemon = pkmn
            species_spr.visible = true
          rescue StandardError => e
            Console.echo_warn("Party screen: couldn't load box icon for #{pkmn.species}: #{e.message}") rescue nil
            species_spr.visible = false
          end
        end
      else
        bar_spr.visible = false
        hp_spr.visible      = false if hp_spr
        exp_spr.visible     = false if exp_spr
        species_spr.visible = false if species_spr
      end
    end
  end

  def pbEndScene
    return if @scene_already_ended
    @scene_already_ended = true
    pbZoomNameSelectorOut
    pbSlideDecorOut
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # If a field move was selected, run it now — right after our own
    # closing animation has fully finished, so it plays at the same point
    # vanilla would naturally reach it once this scene ends
    if @move_to_trigger
      move_id = @move_to_trigger
      pkmn = @pokemon_for_move
      @move_to_trigger = nil
      @pokemon_for_move = nil
      HiddenMoveHandlers.triggerUseMove(move_id, pkmn)
    end
  end

  #-----------------------------------------------------------------------------
  # Slides bg_bar up from below the screen to its rest position, with
  # bg_overlay following the same distance a few frames later. name_bar,
  # button_bg, and pokemon_base slide in from the side in sync with each
  # other, over the same overall timeline as bg_bar/bg_overlay.
  #-----------------------------------------------------------------------------
  def pbSlideDecorIn
    bar_start = Graphics.height
    bar_dist  = bar_start - BAR_REST_Y
    overlay_start = Graphics.height
    overlay_dist  = overlay_start - OVERLAY_REST_Y
    box_start = Graphics.height
    box_dist  = box_start - BOX_REST_Y

    name_bar_start = -NAME_BAR_W
    name_bar_dist  = NAME_BAR_REST_X - name_bar_start
    button_bg_start = Graphics.width
    button_bg_dist  = button_bg_start - BUTTON_BG_REST_X
    pokemon_base_start = -POKEMON_BASE_W
    pokemon_base_dist  = POKEMON_BASE_REST_X - pokemon_base_start

    total_frames = SLIDE_FRAMES + OVERLAY_SLIDE_DELAY
    total_frames.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = 1 - (1 - t) ** 2   # ease out
      @sprites["bg_bar"].y = bar_start - (bar_dist * progress).to_i
      @sprites["name_bar"].x     = name_bar_start + (name_bar_dist * progress).to_i
      @sprites["button_bg"].x    = button_bg_start - (button_bg_dist * progress).to_i
      @sprites["pokemon_base"].x = pokemon_base_start + (pokemon_base_dist * progress).to_i

      overlay_frame = frame - OVERLAY_SLIDE_DELAY
      if overlay_frame >= 0
        ot = [(overlay_frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
        oprogress = 1 - (1 - ot) ** 2
        @sprites["bg_overlay"].y = overlay_start - (overlay_dist * oprogress).to_i
        6.times do |i|
          @sprites["box#{i}"].y = box_start - (box_dist * oprogress).to_i
          pbSyncBarOverlayToBox(i)
        end
      end

      update
      Graphics.update
      Input.update
    end
    @sprites["bg_bar"].y     = BAR_REST_Y
    @sprites["bg_overlay"].y = OVERLAY_REST_Y
    @sprites["name_bar"].x     = NAME_BAR_REST_X
    @sprites["button_bg"].x    = BUTTON_BG_REST_X
    @sprites["pokemon_base"].x = POKEMON_BASE_REST_X
    6.times do |i|
      @sprites["box#{i}"].y = BOX_REST_Y
      pbSyncBarOverlayToBox(i)
    end
  end

  #-----------------------------------------------------------------------------
  # Keeps icon_bar_overlay/icon_overlay_hp locked to their box's current
  # position, so they mirror the box's movement exactly during animation
  #-----------------------------------------------------------------------------
  def pbSyncBarOverlayToBox(i)
    box = @sprites["box#{i}"]
    bar = @sprites["barover#{i}"]
    hp  = @sprites["hpover#{i}"]
    exp = @sprites["expover#{i}"]
    species_spr = @sprites["speciesicon#{i}"]
    return if !box || !bar
    bar.x = box.x + BAR_OVERLAY_OFFSET_X
    bar.y = box.y + BAR_OVERLAY_OFFSET_Y
    if hp
      hp.x = bar.x + HP_OVERLAY_OFFSET_X
      hp.y = bar.y + HP_OVERLAY_OFFSET_Y
    end
    if exp
      exp.x = bar.x + EXP_OVERLAY_OFFSET_X
      exp.y = bar.y + EXP_OVERLAY_OFFSET_Y
    end
    if species_spr
      species_spr.x = box.x + SPECIES_ICON_OFFSET_X
      species_spr.y = box.y + SPECIES_ICON_OFFSET_Y
    end
  end

  #-----------------------------------------------------------------------------
  # Creates/repositions/retexts the CMD_BTN_VISIBLE button sprites to show
  # whichever slice of @command_list is currently scrolled into view.
  # Buttons are bound to button_bg.png's x, so they scroll with it.
  # force: rebuild every button's baked text even if the visible slice
  # hasn't changed (used after pbBuildCommandList swaps the whole list).
  #-----------------------------------------------------------------------------
  def pbUpdateCommandButtons(force = false)
    return if !@sprites["button_bg"]
    base_x = @sprites["button_bg"].x + CMD_BTN_OFFSET_X
    base_y = @sprites["button_bg"].y + CMD_BTN_START_Y

    CMD_BTN_VISIBLE.times do |slot|
      cmd_idx = @cmdscroll + slot
      key = "cmdbtn#{slot}"
      btn = @sprites[key]
      if !btn
        btn = Sprite.new(@viewport)
        btn.z = 5
        @sprites[key] = btn
      end
      btn.x = base_x
      btn.y = base_y + (slot * CMD_BTN_STRIDE)

      if cmd_idx < @command_list.length
        btn.visible = true
        btn.bitmap&.dispose
        btn.bitmap = pbDrawCommandButtonBitmap(@command_list[cmd_idx])
      else
        btn.visible = false
      end
    end

    pbUpdateCommandHighlight
  end

  #-----------------------------------------------------------------------------
  # Bakes one command button's background + centred label text
  #-----------------------------------------------------------------------------
  def pbDrawCommandButtonBitmap(text)
    base = Bitmap.new(PARTY_FOLDER + "button_base.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    center_x = CMD_BTN_W / 2
    text_w = bmp.text_size(text).width
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, CMD_BTN_TEXT_Y, :left,
                                CMD_BTN_TEXT_COLOR, CMD_BTN_TEXT_SHADOW]])
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Moves the highlight sprite onto whichever button row @cmdindex is
  # currently on (relative to the scrolled window), hiding it if that
  # command has scrolled out of view
  #-----------------------------------------------------------------------------
  def pbUpdateCommandHighlight
    return if !@sprites["cmd_highlight"]
    slot = @cmdindex - @cmdscroll
    if slot < 0 || slot >= CMD_BTN_VISIBLE || !@sprites["cmdbtn#{slot}"]
      @sprites["cmd_highlight"].visible = false
      return
    end
    btn = @sprites["cmdbtn#{slot}"]
    @sprites["cmd_highlight"].visible = true
    @sprites["cmd_highlight"].x = btn.x + CMD_HIGHLIGHT_OFFSET_X
    @sprites["cmd_highlight"].y = btn.y + CMD_HIGHLIGHT_OFFSET_Y
  end

  #-----------------------------------------------------------------------------
  # Steps the highlight's animation frame — called every update tick
  #-----------------------------------------------------------------------------
  def pbUpdateCommandHighlightAnim
    return if !@sprites["cmd_highlight"] || !@sprites["cmd_highlight"].visible
    @highlight_tick += 1
    return if @highlight_tick < CMD_HIGHLIGHT_SPEED
    @highlight_tick = 0
    @highlight_frame = (@highlight_frame + 1) % CMD_HIGHLIGHT_FRAMES
    frame_h = CMD_HIGHLIGHT_H / CMD_HIGHLIGHT_FRAMES
    @sprites["cmd_highlight"].src_rect.y = @highlight_frame * frame_h
  end

  #-----------------------------------------------------------------------------
  # Moves @cmdindex up/down within @command_list, scrolling the visible
  # window as needed. Wraps at the top/bottom of the whole list.
  #-----------------------------------------------------------------------------
  def pbMoveCommandSelection(delta)
    return if @command_list.empty?
    @cmdindex = (@cmdindex + delta) % @command_list.length
    if @cmdindex < @cmdscroll
      @cmdscroll = @cmdindex
    elsif @cmdindex >= @cmdscroll + CMD_BTN_VISIBLE
      @cmdscroll = @cmdindex - CMD_BTN_VISIBLE + 1
    end
    max_scroll = [@command_list.length - CMD_BTN_VISIBLE, 0].max
    @cmdscroll = @cmdscroll.clamp(0, max_scroll)
    pbUpdateCommandButtons
  end

  #-----------------------------------------------------------------------------
  # Slides everything back out the way it came in — bg_overlay leads since
  # it was in front, bg_bar follows; name_bar/button_bg/pokemon_base/boxes
  # retreat off-screen in sync with bg_bar's own timeline
  #-----------------------------------------------------------------------------
  def pbSlideDecorOut
    bar_dist     = Graphics.height - BAR_REST_Y
    overlay_dist = Graphics.height - OVERLAY_REST_Y
    box_dist     = Graphics.height - BOX_REST_Y
    name_bar_dist     = NAME_BAR_REST_X - (-NAME_BAR_W)
    button_bg_dist    = Graphics.width - BUTTON_BG_REST_X
    pokemon_base_dist = POKEMON_BASE_REST_X - (-POKEMON_BASE_W)

    total_frames = SLIDE_FRAMES + OVERLAY_SLIDE_DELAY
    total_frames.times do |frame|
      ot = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      oprogress = ot ** 2   # ease in
      @sprites["bg_overlay"].y = OVERLAY_REST_Y + (overlay_dist * oprogress).to_i
      @sprites["name_bar"].x     = NAME_BAR_REST_X - (name_bar_dist * oprogress).to_i
      @sprites["button_bg"].x    = BUTTON_BG_REST_X + (button_bg_dist * oprogress).to_i
      @sprites["pokemon_base"].x = POKEMON_BASE_REST_X - (pokemon_base_dist * oprogress).to_i
      6.times do |i|
        @sprites["box#{i}"].y = BOX_REST_Y + (box_dist * oprogress).to_i
        pbSyncBarOverlayToBox(i)
      end

      bar_frame = frame - OVERLAY_SLIDE_DELAY
      if bar_frame >= 0
        t = [(bar_frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
        progress = t ** 2
        @sprites["bg_bar"].y = BAR_REST_Y + (bar_dist * progress).to_i
      end

      update
      Graphics.update
      Input.update
    end
  end

  #-----------------------------------------------------------------------------
  # Repositions the existing command buttons/highlight to follow
  # button_bg.x — cheap, no bitmap rebuilding, safe to call every frame
  #-----------------------------------------------------------------------------
  def pbSyncCommandButtonsToBg
    return if !@sprites["button_bg"]
    base_x = @sprites["button_bg"].x + CMD_BTN_OFFSET_X
    base_y = @sprites["button_bg"].y + CMD_BTN_START_Y
    CMD_BTN_VISIBLE.times do |slot|
      btn = @sprites["cmdbtn#{slot}"]
      next if !btn
      btn.x = base_x
      btn.y = base_y + (slot * CMD_BTN_STRIDE)
    end
    pbUpdateCommandHighlight
  end

  def update
    if @sprites["custom_grid"]
      @sprites["custom_grid"].x -= 1
      @sprites["custom_grid"].x = 0 if @sprites["custom_grid"].x <= -GRID_SCROLL_W
    end
    pbSyncCommandButtonsToBg
    pbSyncNameBarIconPositions
    pbSyncPartySpritePosition
    pbUpdateCommandHighlightAnim
    pbAnimateHPBars
    pbUpdateSpriteHash(@sprites)
  end

  #-----------------------------------------------------------------------------
  # No-op stubs for vanilla hooks not used by this UI (help text display,
  # annotation labels) — kept so calls from elsewhere in the party flow
  # don't error, without any visible effect here.
  #-----------------------------------------------------------------------------
  def pbSetHelpText(helptext); end
  def pbHasAnnotations?; return false; end
  def pbAnnotate(annot); end

  #-----------------------------------------------------------------------------
  # Override pbShowCommands — renders through the same dynamic button list
  # (button_base graphics, highlight, scrolling window) as the main command
  # list, so Debug menus and anything else that calls into this (Mail's
  # Read/Take choice, etc.) look and behave consistently with the rest of
  # the custom UI.
  #-----------------------------------------------------------------------------
  def pbShowCommands(helptext, commands, index = 0)
    saved_list      = @command_list
    saved_data      = @command_data
    saved_cmdindex  = @cmdindex
    saved_cmdscroll = @cmdscroll
    saved_mode      = @menu_mode

    # Guarantee a clickable way out for mouse users — most vanilla lists
    # already end with Cancel/Back, only append one if none is present
    commands = commands.dup
    last = commands.last.to_s.downcase
    added_back = false
    if !["cancel", "back"].include?(last)
      commands.push(_INTL("Back"))
      added_back = true
    end

    @command_list = commands
    @command_data = commands.map { |c| c }   # plain values; index is the answer we want back
    @cmdindex     = index.clamp(0, [commands.length - 1, 0].max)
    @cmdscroll    = 0
    max_scroll = [@command_list.length - CMD_BTN_VISIBLE, 0].max
    if @cmdindex >= CMD_BTN_VISIBLE
      @cmdscroll = [@cmdindex - CMD_BTN_VISIBLE + 1, max_scroll].min
    end
    pbDrawButtonBgHeaderText(helptext)
    pbUpdateCommandButtons(true)

    ret = -1
    clicked_index = nil
    loop do
      Graphics.update
      Input.update
      update

      CMD_BTN_VISIBLE.times do |slot|
        btn = @sprites["cmdbtn#{slot}"]
        next if !btn || !btn.visible
        if Mouse.over?(btn) && Mouse.click?
          cmd_idx = @cmdscroll + slot
          next if cmd_idx >= @command_list.length
          clicked_index = cmd_idx
        end
      end
      if clicked_index
        @cmdindex = clicked_index
        pbUpdateCommandHighlight
        pbPlayDecisionSE
        ret = (added_back && @cmdindex == commands.length - 1) ? -1 : @cmdindex
        break
      end
      if Mouse.scroll_up?
        pbMoveCommandSelection(-1)
      elsif Mouse.scroll_down?
        pbMoveCommandSelection(1)
      end

      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        pbMoveCommandSelection(-1)
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        pbMoveCommandSelection(1)
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = (added_back && @cmdindex == commands.length - 1) ? -1 : @cmdindex
        break
      end
    end

    @command_list = saved_list
    @command_data = saved_data
    @cmdindex     = saved_cmdindex
    @cmdscroll    = saved_cmdscroll
    @menu_mode    = saved_mode
    pbBuildCommandList
    pbUpdateCommandButtons(true)
    return ret
  end

  #-----------------------------------------------------------------------------
  # Draws arbitrary header text (not the standard "Do what with X?"/"X
  # selected" pattern) onto button_bg — used by pbShowCommands for whatever
  # helptext the caller passed in
  #-----------------------------------------------------------------------------
  def pbDrawButtonBgHeaderText(text)
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    text_w = bmp.text_size(text).width
    left_x = (BUTTON_BG_W / 2) - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])
    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
  end

  #-----------------------------------------------------------------------------
  # Override pbDisplay/pbConfirm/pbDisplayConfirm — vanilla's versions rely
  # on a message box window this scene doesn't create. These route through
  # pbShowCommands instead, so messages and confirmations render using the
  # same themed button list and header text as the rest of the UI.
  #-----------------------------------------------------------------------------
  def pbDisplay(text)
    pbShowCommands(text, [_INTL("OK")], 0)
  end

  def pbConfirm(text)
    return pbDisplayConfirm(text)
  end

  def pbDisplayConfirm(text)
    ret = pbShowCommands(text, [_INTL("Yes"), _INTL("No")], 0)
    return ret == 0
  end

  def pbSelect(item)
    @activecmd = item
    pbUpdateBoxSelection
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[@activecmd] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[@activecmd])
    @menu_mode = :main
    pbBuildCommandList
    pbUpdateCommandButtons(true)
  end

  def pbPreSelect(item); @activecmd = item; end
  def pbRefresh
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent
  end

  def pbRefreshSingle(i)
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent if i == @activecmd
  end
  def pbHardRefresh; pbUpdatePartyIcons; pbUpdateBoxSelection; end
  def pbClearSwitching; end

  #-----------------------------------------------------------------------------
  # Sets each box to icon_box_sel (if it's the selected slot), icon_box_faint
  # (if that Pokémon has fainted), or plain icon_box otherwise. Selected
  # always overrides fainted. Also freezes the species icon's animation
  # while its Pokémon is fainted.
  #-----------------------------------------------------------------------------
  def pbUpdateBoxSelection
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box
      pkmn = @party[i]
      fainted = pkmn && pkmn.fainted?
      file = if i == @activecmd
               "icon_box_sel.png"
             elsif fainted
               "icon_box_faint.png"
             else
               "icon_box.png"
             end
      box.setBitmap(PARTY_FOLDER + file)

      species_spr = @sprites["speciesicon#{i}"]
      species_spr.active = !fainted if species_spr && species_spr.respond_to?(:active=)
    end
  end

  #-----------------------------------------------------------------------------
  # Mouse: clicking a party box selects that member. Clicking a command
  # button selects and immediately executes that command (matching a
  # keyboard UP/DOWN-then-USE in one click). Mouse wheel scrolls the
  # command list. Returns pbExecuteCommand's result if a button was
  # clicked and executed, otherwise nil.
  #-----------------------------------------------------------------------------
  def pbHandleMouseInput
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box || !box.visible
      if Mouse.over?(box) && Mouse.click? && @party[i]
        pbPlayCursorSE
        pbSelect(i)
        return nil
      end
    end

    CMD_BTN_VISIBLE.times do |slot|
      btn = @sprites["cmdbtn#{slot}"]
      next if !btn || !btn.visible
      if Mouse.over?(btn) && Mouse.click?
        cmd_idx = @cmdscroll + slot
        next if cmd_idx >= @command_list.length
        @cmdindex = cmd_idx
        pbUpdateCommandHighlight
        pbPlayDecisionSE
        return pbExecuteCommand
      end
    end

    if Mouse.scroll_up?
      pbMoveCommandSelection(-1)
    elsif Mouse.scroll_down?
      pbMoveCommandSelection(1)
    end
    return nil
  end

  def pbChoosePokemon(switching = false, initialsel = -1, canswitch = 0)
    @activecmd = initialsel if initialsel >= 0
    @activecmd = 0 if !@party[@activecmd]
    pbSelect(@activecmd)
    loop do
      Graphics.update
      Input.update
      update
      ret = pbHandleMouseInput
      return ret if ret
      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        pbSelect(pbPrevPartyIndex(@activecmd))
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        pbSelect(pbNextPartyIndex(@activecmd))
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE
        pbMoveCommandSelection(-1)
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        pbMoveCommandSelection(1)
      elsif Input.trigger?(Input::USE)
        ret = pbExecuteCommand
        return ret if ret
      elsif Input.trigger?(Input::BACK)
        if @menu_mode != :main
          pbPlayCancelSE
          @menu_mode = :main
          pbBuildCommandList
          pbUpdateCommandButtons(true)
        else
          return -1
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Runs whatever the currently highlighted command does. Returns nil to
  # keep the loop going (e.g. entered a sub-menu), or a value to hand back
  # to pbChoosePokemon's caller (matching vanilla's return contract: -1 for
  # cancel, an index/array for an actual selection).
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # Give: opens the bag (vanilla's own PokemonBagScreen#pbChooseItemScreen)
  # filtered to holdable items, gives the chosen one to the selected
  # Pokémon (swapping out any currently-held item back into the bag first,
  # matching vanilla's own Give behaviour), then refreshes.
  #-----------------------------------------------------------------------------
  def pbPerformItemGive(screen)
    pkmn = @party[@activecmd]
    return if !pkmn
    bagscene  = PokemonBag_Scene.new
    bagscreen = PokemonBagScreen.new(bagscene, $bag)
    item = nil
    pbFadeOutIn do
      item = bagscreen.pbChooseItemScreen(proc { |i| GameData::Item.get(i).can_hold? })
    end
    return if !item
    if pkmn.hasItem?
      if !$bag.can_add?(pkmn.item, 1)
        pbDisplay(_INTL("The Bag is full. The {1} couldn't be taken.", GameData::Item.get(pkmn.item).name))
        return
      end
      $bag.add(pkmn.item, 1)
      pkmn.item = nil
    end
    pkmn.item = item
    $bag.remove(item, 1)
    pbRefreshSingle(@activecmd)
    pbDisplay(_INTL("Gave {1} {2}.", pkmn.name, GameData::Item.get(item).name))
  end

  #-----------------------------------------------------------------------------
  # Take: moves the selected Pokémon's held item back into the bag
  #-----------------------------------------------------------------------------
  def pbPerformItemTake(screen)
    pkmn = @party[@activecmd]
    return if !pkmn || !pkmn.hasItem?
    item = pkmn.item
    if !$bag.can_add?(item, 1)
      pbDisplay(_INTL("The Bag is full. The item couldn't be taken."))
      return
    end
    $bag.add(item, 1)
    pkmn.item = nil
    pbRefreshSingle(@activecmd)
    pbDisplay(_INTL("Took away {1}.", GameData::Item.get(item).name))
  end

  #-----------------------------------------------------------------------------
  # Use: runs the hidden-move field effect for whichever move was picked
  # from the main list (see @pending_move_index, set when that entry was
  # selected). Falls back safely if there's no matching handler.
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # Use: runs the hidden-move field effect for whichever move was picked
  # from the main list (see @pending_move_index, set when that entry was
  # selected). Field move animations (Surf, Cut, etc.) expect to play on
  # the overworld map, not with this screen still open on top — so the
  # screen fades out first, exactly like vanilla's own party menu does
  # before running these effects. Returns true if the whole screen should
  # now close (the caller is expected to break its loop and return -1).
  #-----------------------------------------------------------------------------
  def pbPerformMoveUse(screen)
    pkmn = @party[@activecmd]
    return false if !pkmn || @pending_move_index.nil?
    move = pkmn.moves[@pending_move_index]
    return false if !move

    if HiddenMoveHandlers.hasHandler(move.id)
      if HiddenMoveHandlers.triggerCanUseMove(move.id, pkmn, true)
        # Don't close the scene ourselves here — just signal that a move
        # is pending and let it run once we've returned all the way back
        # up through pbChoosePokemon/pbPokemonScreen. pbPokemonScreen's
        # own outer pbFadeOutIn (called from the pause menu) will then
        # handle closing this scene properly and in the right order, the
        # same as it does for any other menu exit. triggerUseMove sets
        # $game_temp.in_menu = false itself, which the pause menu's loop
        # checks right after pbFadeOutIn finishes to decide whether to
        # close itself too.
        @move_to_trigger = move.id
        @pokemon_for_move = pkmn
        return true
      end
    elsif [:MILKDRINK, :SOFTBOILED].include?(move.id)
      # These restore HP rather than doing a field effect — no need to
      # close the screen for this one
      if pkmn.hp == pkmn.totalhp
        pbDisplay(_INTL("It won't have any effect."))
      else
        pkmn.hp = pkmn.totalhp
        pbSEPlay("Player heal")
        pbRefreshSingle(@activecmd)
      end
    end
    @pending_move_index = nil
    return false
  end

  #-----------------------------------------------------------------------------
  # Self-contained switch flow. Box for the originally-picked Pokémon stays
  # on icon_box_sel throughout; LEFT/RIGHT moves a target cursor (shown via
  # the normal box highlight) between the other slots. Button list shows
  # just Back while sitting on the original slot, Select+Back once moved to
  # a different one. Header always reads "X selected" for the original
  # pick. Confirming with Select on a different slot slides both affected
  # boxes (and the shared name/HP/front-sprite display) off-screen using
  # their normal slide animation, swaps the data, then slides back in.
  #-----------------------------------------------------------------------------
  def pbPerformSwitch(screen)
    old_idx = @activecmd
    target  = @activecmd
    @menu_mode = :switch_target
    pbRefreshSwitchTargetUI(old_idx, target)

    loop do
      Graphics.update
      Input.update
      update

      clicked_box = nil
      6.times do |i|
        box = @sprites["box#{i}"]
        next if !box || !box.visible
        if Mouse.over?(box) && Mouse.click? && @party[i]
          clicked_box = i
        end
      end
      if clicked_box && clicked_box != target
        pbPlayCursorSE
        target = clicked_box
        pbRefreshSwitchTargetUI(old_idx, target)
        next
      end

      clicked_confirm = false
      clicked_cancel  = false
      CMD_BTN_VISIBLE.times do |slot|
        btn = @sprites["cmdbtn#{slot}"]
        next if !btn || !btn.visible
        if Mouse.over?(btn) && Mouse.click?
          cmd_idx = @cmdscroll + slot
          next if cmd_idx >= @command_data.length
          case @command_data[cmd_idx]
          when :switch_confirm then clicked_confirm = true
          when :back then clicked_cancel = true
          end
        end
      end

      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        target = pbPrevPartyIndex(target)
        pbRefreshSwitchTargetUI(old_idx, target)
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        target = pbNextPartyIndex(target)
        pbRefreshSwitchTargetUI(old_idx, target)
      elsif Input.trigger?(Input::BACK) || clicked_cancel
        pbPlayCancelSE
        @activecmd = old_idx
        break
      elsif Input.trigger?(Input::USE) || clicked_confirm
        if target != old_idx
          pbPlayDecisionSE
          pbAnimateSwitch(old_idx, target, screen)
          @activecmd = target
        else
          @activecmd = old_idx
        end
        break
      end
    end

    @menu_mode = :main
    pbSelect(@activecmd)
  end

  #-----------------------------------------------------------------------------
  # Redraws the box highlight (original pick stays sel, target slot is
  # shown via the same highlight box normally uses for the cursor), header
  # text, and button list (Back only vs Select+Back) for the current
  # target during the picking phase.
  #-----------------------------------------------------------------------------
  def pbRefreshSwitchTargetUI(old_idx, target)
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box
      pkmn = @party[i]
      fainted = pkmn && pkmn.fainted?
      file = if i == old_idx || i == target
               "icon_box_sel.png"
             elsif fainted
               "icon_box_faint.png"
             else
               "icon_box.png"
             end
      box.setBitmap(PARTY_FOLDER + file)
    end
    @sprites["cmd_highlight"].visible = false if @sprites["cmd_highlight"]

    # Preview the target slot's Pokémon on the shared display (name bar,
    # HP, level, front sprite, and the name_box_selector) while scrolling
    # — @activecmd drives all of that, so point it at whichever slot is
    # under the cursor. The original pick's box stays on sel regardless,
    # set alongside the target's own sel state above.
    @activecmd = target
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[target] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[target])

    @command_list = (target == old_idx) ? [_INTL("Back")] : [_INTL("Select"), _INTL("Back")]
    @command_data = (target == old_idx) ? [:back] : [:switch_confirm, :back]
    @cmdindex  = 0
    @cmdscroll = 0
    pbDrawSwitchHeader(old_idx)
    pbUpdateCommandButtons(true)
  end

  #-----------------------------------------------------------------------------
  # Positions the command highlight over the target's box while picking
  # (skipped when target == old_idx, since that's the original pick's own
  # box, already shown via sel)
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # Header always reads "X selected" using the ORIGINAL pick's name, not
  # whichever slot the cursor is currently previewing
  #-----------------------------------------------------------------------------
  def pbDrawSwitchHeader(old_idx)
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    pkmn = @party[old_idx]
    text = _INTL("{1} selected", pkmn ? pkmn.name : "")
    text_w = bmp.text_size(text).width
    left_x = (BUTTON_BG_W / 2) - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])
    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
  end

  #-----------------------------------------------------------------------------
  # Slides the two affected boxes (and the shared name/HP/front-sprite
  # display, since it only ever shows @activecmd) off-screen using their
  # normal slide-out motion, swaps the underlying party data, then slides
  # everything back in the normal way.
  #-----------------------------------------------------------------------------
  def pbAnimateSwitch(old_idx, target, screen)
    pbSEPlay("GUI party switch") rescue nil
    pbZoomNameSelectorOut

    box_dist  = Graphics.height - BOX_REST_Y
    name_bar_dist     = NAME_BAR_REST_X - (-NAME_BAR_W)
    pokemon_base_dist = POKEMON_BASE_REST_X - (-POKEMON_BASE_W)

    SLIDE_FRAMES.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = t ** 2   # ease in, same as the normal slide-out
      [old_idx, target].each do |i|
        @sprites["box#{i}"].y = BOX_REST_Y + (box_dist * progress).to_i
        pbSyncBarOverlayToBox(i)
      end
      @sprites["name_bar"].x     = NAME_BAR_REST_X - (name_bar_dist * progress).to_i
      @sprites["pokemon_base"].x = POKEMON_BASE_REST_X - (pokemon_base_dist * progress).to_i
      update
      Graphics.update
      Input.update
    end

    # Data swap while off-screen. Done directly here rather than via
    # PokemonPartyScreen#pbSwitch, since that calls scene.pbSwitchBegin/
    # pbSwitchEnd, which reference sprite names from vanilla's panel
    # layout that this custom scene doesn't use.
    @party[old_idx], @party[target] = @party[target], @party[old_idx]
    @activecmd = target
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[target])
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[target] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]

    SLIDE_FRAMES.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = 1 - (1 - t) ** 2   # ease out, same as the normal slide-in
      [old_idx, target].each do |i|
        @sprites["box#{i}"].y = Graphics.height - ((Graphics.height - BOX_REST_Y) * progress).to_i
        pbSyncBarOverlayToBox(i)
      end
      @sprites["name_bar"].x     = -NAME_BAR_W + (name_bar_dist * progress).to_i
      @sprites["pokemon_base"].x = -POKEMON_BASE_W + (pokemon_base_dist * progress).to_i
      update
      Graphics.update
      Input.update
    end
    [old_idx, target].each { |i| @sprites["box#{i}"].y = BOX_REST_Y }
    @sprites["name_bar"].x     = NAME_BAR_REST_X
    @sprites["pokemon_base"].x = POKEMON_BASE_REST_X
    6.times { |i| pbSyncBarOverlayToBox(i) }

    pbZoomNameSelectorIn
  end

  #-----------------------------------------------------------------------------
  # Returns the real PokemonPartyScreen object if PokemonPartyScreen has
  # been patched to hand it to us (see the class reopen at the bottom of
  # this file); falls back to self so a call chain that only ever does
  # screen.scene.xxx still resolves, even though screen.some_other_method
  # would still fail without the real owner.
  #-----------------------------------------------------------------------------
  def pbGetPartyScreenOwner
    @screen_owner || self
  end

  def pbExecuteCommand
    return nil if @command_data.empty?
    data = @command_data[@cmdindex]
    pkmn = @party[@activecmd]
    screen = pbGetPartyScreenOwner

    case data
    when :cancel
      pbPlayCloseMenuSE
      return -1

    when :back
      pbPlayCancelSE
      @menu_mode = :main
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when :item_give
      pbPlayDecisionSE
      @menu_mode = :main
      pbPerformItemGive(screen)
      return nil

    when :item_take
      pbPlayDecisionSE
      @menu_mode = :main
      pbPerformItemTake(screen)
      return nil

    when :move_use
      pbPlayDecisionSE
      @menu_mode = :main
      closed = pbPerformMoveUse(screen)
      return -1 if closed
      return nil

    when Hash
      # Switch/Item get redirected to our own sub-menus instead of running
      # their vanilla effect (which opens vanilla's own nested chooser/list)
      name = data["name"]
      if name == _INTL("Switch")
        pbPlayDecisionSE
        pbPerformSwitch(screen)
        return nil
      elsif name == _INTL("Item")
        pbPlayDecisionSE
        @menu_mode = :item
        pbBuildCommandList
        pbUpdateCommandButtons(true)
        return nil
      end
      # Everything else (Summary, Debug, Mail) uses vanilla's own effect
      pbPlayDecisionSE
      data["effect"].call(screen, @party, @activecmd)
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when Array
      # [:move, move_index] — a hidden move field command was picked from
      # the main list; open the Use/Back sub-menu for it
      if data[0] == :move
        @pending_move_index = data[1]
        pbPlayDecisionSE
        @menu_mode = :move
        pbBuildCommandList
        pbUpdateCommandButtons(true)
      end
      return nil

    else
      return nil
    end
  end

  #-----------------------------------------------------------------------------
  # Steps to the previous/next slot that actually has a Pokémon in it,
  # wrapping around, so empty slots are never selectable
  #-----------------------------------------------------------------------------
  def pbPrevPartyIndex(from)
    idx = from
    6.times do
      idx = (idx - 1) % 6
      return idx if @party[idx]
    end
    return from
  end

  def pbNextPartyIndex(from)
    idx = from
    6.times do
      idx = (idx + 1) % 6
      return idx if @party[idx]
    end
    return from
  end

  # Fallback so screen.scene.xxx resolves even if pbGetPartyScreenOwner had
  # to fall back to self (no real PokemonPartyScreen owner was set)
  def scene
    self
  end

end

#===============================================================================
# Hands the scene a back-reference to the real PokemonPartyScreen object, so
# vanilla MenuHandlers effect procs (which expect screen.scene.xxx and
# screen.some_method calls) work correctly when triggered from inside the
# scene's own always-visible command list, instead of only from
# PokemonPartyScreen#pbPokemonScreen like vanilla assumes.
#===============================================================================
class PokemonPartyScreen
  alias custom_party_screen_initialize initialize
  def initialize(scene, party)
    custom_party_screen_initialize(scene, party)
    scene.screen_owner = self if scene.respond_to?(:screen_owner=)
  end
end
#===============================================================================
#                        Custom Battle Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
module Settings
  CUSTOM_BATTLE_UI_GRAPHICS_PATH = "Graphics/Custom UI/Battle System/"
end

class Battle::Scene
  alias customUI_pbInitSprites pbInitSprites
  def pbInitSprites
    customUI_pbInitSprites
    return if pbInSafari?
    if @sprites["messageBox"]
      @sprites["messageBox"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "overlay_message.png")
    end
    @sprites["cmdBar_bg"].visible = false if @sprites["cmdBar_bg"]
    if @sprites["messageWindow"]
      @sprites["messageWindow"].baseColor   = Color.new(255, 255, 255)
      @sprites["messageWindow"].shadowColor = Color.new(33, 33, 33)
    end
  end

  #=============================================================================
  # Fully replaces pbShowWindow rather than calling the base version first, so
  # fightWindow/commandWindow are never set visible even for one frame.
  #=============================================================================
  alias customUI_pbShowWindow pbShowWindow
  def pbShowWindow(windowType)
    @sprites["messageBox"].visible    = (windowType == MESSAGE_BOX) if @sprites["messageBox"]
    @sprites["messageWindow"].visible = (windowType == MESSAGE_BOX) if @sprites["messageWindow"]
    @sprites["commandWindow"].visible = false if @sprites["commandWindow"]
    @sprites["fightWindow"].visible   = false if @sprites["fightWindow"]
    @sprites["targetWindow"].visible  = (windowType == TARGET_BOX) if @sprites["targetWindow"]
  end
end

#===============================================================================
# Animation::Intro's default createProcesses adds a full-opacity "black_bar"
# sprite over the command bar area which only fades out 3/4 of the way through
# the intro - the source of a solid black rectangle at battle start. Skips
# creating that specific sprite; everything else is untouched.
#===============================================================================
class Battle::Scene::Animation::Intro
  alias customUI_createProcesses createProcesses
  def createProcesses
    appearTime = 20
    if @sprites["battle_bg2"]
      makeSlideSprite("battle_bg", 0.5, appearTime)
      makeSlideSprite("battle_bg2", 0.5, appearTime)
    end
    makeSlideSprite("base_0", 1, appearTime, PictureOrigin::BOTTOM)
    makeSlideSprite("base_1", -1, appearTime, PictureOrigin::CENTER)
    @battle.player.each_with_index do |_p, i|
      makeSlideSprite("player_#{i + 1}", 1, appearTime, PictureOrigin::BOTTOM)
    end
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |_p, i|
        makeSlideSprite("trainer_#{i + 1}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    else
      @battle.pbParty(1).each_with_index do |_pkmn, i|
        idxBattler = (2 * i) + 1
        makeSlideSprite("pokemon_#{idxBattler}", -1, appearTime, PictureOrigin::BOTTOM)
      end
    end
    @battle.battlers.length.times do |i|
      makeSlideSprite("shadow_#{i}", (i.even?) ? 1 : -1, appearTime, PictureOrigin::CENTER)
    end
    blackScreen = addNewSprite(0, 0, "Graphics/Battle animations/black_screen")
    blackScreen.setZ(0, 999)
    blackScreen.moveOpacity(0, 8, 0)
    # NOTE: "blackBar" over the command bar area intentionally removed.
  end
end

#===============================================================================
# FOCUSUSER_Y/FOCUSTARGET_Y are fixed animation-authoring anchors (not screen
# coordinates) - shifting them breaks PBAnimationPlayerX's line transform math,
# so only PLAYER_BASE_Y/FOE_BASE_Y (actual screen positions) are changed.
#===============================================================================
class Battle::Scene
  remove_const(:PLAYER_BASE_Y)
  PLAYER_BASE_Y = Settings::SCREEN_HEIGHT - 80 - 96

  remove_const(:FOE_BASE_Y)
  FOE_BASE_Y = (Settings::SCREEN_HEIGHT * 3 / 4) - 112 - 96
end

class Battle::Scene::PokemonDataBox
  alias customUI_initializeDataBoxGraphic initializeDataBoxGraphic
  def initializeDataBoxGraphic(sideSize)
    customUI_initializeDataBoxGraphic(sideSize)
    return if !@battler.index.even?   # Player's side only
    @spriteY -= 96
  end
end

#===============================================================================
# All panel elements share one set of rest/off-screen Y coordinates and scroll
# together as a group: scroll up into position when a panel is shown, scroll
# down off-screen before switching to a different panel or closing.
#===============================================================================
class Battle::Scene
  # Panel layout constants (rest Y = on-screen position, offset = scroll distance)
  PANEL_SCROLL_FRAMES = 10
  PANEL_SCROLL_OFFSET = 160   # how far below the screen elements start/end at

  OVERLAY_REST_Y      = 320
  PROMPT_REST_Y        = 340
  PARTY_BALL_REST_Y    = 336
  CMD_BUTTON_REST_Y    = 400
  FIGHT_BUTTON_REST_Y  = 390

  CMD_BUTTON_KEYS    = ["btn_fight", "btn_bag", "btn_poke", "btn_run"]
  CMD_BUTTON_WIDTH   = 136
  CMD_BUTTON_START_X = 80
  CMD_BUTTON_SPACING = 32

  FIGHT_BUTTON_KEYS = ["move_0", "move_1", "move_2", "move_3"]
  FIGHT_BUTTON_X = {
    "move_0" => 34, "move_1" => 220, "move_2" => 406, "move_3" => 592
  }
  CANCEL_BUTTON_X = 692
  CANCEL_BUTTON_Y = 342
  CANCEL_FLASH_FRAMES = 4   # how many frames the cancel/cancel_p swap lasts

  PARTY_BALL_SIZE    = 30
  PARTY_BALL_START_X = 4
  PARTY_BALL_SPACING = 4

  CMD_BUTTON_OPACITY_NORMAL   = 100
  CMD_BUTTON_OPACITY_SELECTED = 255

  CUSTOM_TEXT_BASE_COLOR   = Color.new(80, 80, 88)
  CUSTOM_TEXT_SHADOW_COLOR = Color.new(160, 160, 168)

  #-----------------------------------------------------------------------------
  # Sprite keys belonging to the shared panel base (overlay, prompt, party
  # balls) - always part of any scroll in/out, regardless of which button set
  # is showing.
  #-----------------------------------------------------------------------------
  def panel_base_sprite_rest_y
    rest = {}
    rest["customTextBox"] = OVERLAY_REST_Y
    rest["customPromptText"] = PROMPT_REST_Y
    Settings::MAX_PARTY_SIZE.times { |i| rest["customPartyBall_#{i}"] = PARTY_BALL_REST_Y }
    return rest
  end

  #-----------------------------------------------------------------------------
  # Ensures the overlay/prompt/party ball sprites exist with correct content,
  # without touching their Y position (that's handled by the scroll animation).
  #-----------------------------------------------------------------------------
  def pbBuildCustomOverlay
    if !@sprites["customTextBox"]
      @sprites["customTextBox"] = IconSprite.new(@viewport)
      @sprites["customTextBox"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "textboxoverlay.png")
      @sprites["customTextBox"].x = 0
      @sprites["customTextBox"].z = 999999
    end
  end

  def pbBuildCustomPromptText(text)
    if !@sprites["customPromptText"]
      @sprites["customPromptText"] = BitmapSprite.new(Graphics.width, 32, @viewport)
      @sprites["customPromptText"].x = 0
      @sprites["customPromptText"].z = 999999
      pbSetSystemFont(@sprites["customPromptText"].bitmap)
    end
    bmp = @sprites["customPromptText"].bitmap
    bmp.clear
    pbDrawTextPositions(bmp, [[text, Graphics.width / 2, 0, :center,
                              Color.new(255, 255, 255), Color.new(33, 33, 33)]])
  end

  def pbBuildCustomPartyBalls
    party = @battle.pbParty(0)
    Settings::MAX_PARTY_SIZE.times do |i|
      key = "customPartyBall_#{i}"
      if !@sprites[key]
        @sprites[key] = IconSprite.new(@viewport)
        @sprites[key].x = PARTY_BALL_START_X + (i * (PARTY_BALL_SIZE + PARTY_BALL_SPACING))
        @sprites[key].z = 999999
      end
      pkmn = party[i]
      graphicFilename = "icon_ball_empty"
      if pkmn
        if !pkmn.able?
          graphicFilename = "icon_ball_faint"
        elsif pkmn.status != :NONE
          graphicFilename = "icon_ball_status"
        else
          graphicFilename = "icon_ball"
        end
      end
      @sprites[key].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + graphicFilename + ".png")
    end
  end

  #-----------------------------------------------------------------------------
  # Command button bitmaps (built once, content doesn't change per-frame).
  #-----------------------------------------------------------------------------
  def pbBuildCustomCommandButtons
    CMD_BUTTON_KEYS.each_with_index do |key, i|
      next if @sprites[key]
      @sprites[key] = IconSprite.new(@viewport)
      @sprites[key].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "#{key}.png")
      @sprites[key].x = CMD_BUTTON_START_X + (i * (CMD_BUTTON_WIDTH + CMD_BUTTON_SPACING))
      @sprites[key].z = 999999
    end
  end

  def pbUpdateCustomCommandOpacity(index)
    CMD_BUTTON_KEYS.each_with_index do |key, i|
      next if !@sprites[key]
      @sprites[key].opacity = (index == i) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
  end

  #-----------------------------------------------------------------------------
  # Move button bitmaps (rebuilt each time - move data can change: PP, etc).
  #-----------------------------------------------------------------------------
  def pbBuildMoveButtonBitmap(battler, idx)
    folder = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH
    move = battler.moves[idx]
    if move&.id
      type_symbol = move.type.to_s.downcase
      path = folder + type_symbol
      path = folder + "unknown" if !FileTest.exist?(path + ".png")
    else
      path = folder + "empty"
    end
    base = Bitmap.new(path)
    bitmap = Bitmap.new(base.width, base.height)
    bitmap.blt(0, 0, base, base.rect)
    base.dispose
    if move&.id
      pbSetNarrowFont(bitmap)
      textPos = []
      textPos.push([move.name, bitmap.width / 2, 12, :center, CUSTOM_TEXT_BASE_COLOR, CUSTOM_TEXT_SHADOW_COLOR])
      pp_text = _INTL("PP: {1}/{2}", move.pp, battler.pokemon.moves[idx].totalpp)
      textPos.push([pp_text, 82, 44, :left, CUSTOM_TEXT_BASE_COLOR, CUSTOM_TEXT_SHADOW_COLOR])
      pbDrawTextPositions(bitmap, textPos)
    end
    return bitmap
  end

  def pbBuildCustomFightButtons(battler)
    FIGHT_BUTTON_KEYS.each_with_index do |key, idx|
      @sprites[key]&.bitmap&.dispose
      @sprites[key] = Sprite.new(@viewport) if !@sprites[key]
      @sprites[key].bitmap = pbBuildMoveButtonBitmap(battler, idx)
      @sprites[key].x = FIGHT_BUTTON_X[key]
      @sprites[key].z = 999999
    end
    if !@sprites["cancelButton"]
      @sprites["cancelButton"] = IconSprite.new(@viewport)
      @sprites["cancelButton"].x = CANCEL_BUTTON_X
      @sprites["cancelButton"].z = 999999
    end
    @sprites["cancelButton"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "cancel.png")
  end

  #-----------------------------------------------------------------------------
  # Briefly swaps the cancel button's graphic to its pressed state, then back,
  # before returning to the Command menu.
  #-----------------------------------------------------------------------------
  def pbFlashCancelButton
    return if !@sprites["cancelButton"]
    2.times do
      @sprites["cancelButton"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "cancel_p.png")
      CANCEL_FLASH_FRAMES.times { pbUpdate }
      @sprites["cancelButton"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "cancel.png")
      CANCEL_FLASH_FRAMES.times { pbUpdate }
    end
  end

  def pbUpdateCustomFightOpacity(index)
    FIGHT_BUTTON_KEYS.each_with_index do |key, i|
      next if !@sprites[key]
      @sprites[key].opacity = (index == i) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
  end

  #-----------------------------------------------------------------------------
  # Pauses briefly to let the most recently played SE finish before continuing,
  # so slide sound effects don't overlap with the animation or with each other.
  #-----------------------------------------------------------------------------
  def pbWaitForSE
    timer_start = System.uptime
    loop do
      Graphics.update
      Input.update
      break if System.uptime - timer_start >= 0.5
    end
  end

  #-----------------------------------------------------------------------------
  # Scrolls the given {sprite_key => rest_y} set up from off-screen (below) into
  # position, fading opacity in from 0 to its target (button sets fade in to
  # CMD_BUTTON_OPACITY_NORMAL, non-button sprites fade straight to 255).
  #-----------------------------------------------------------------------------
  def pbScrollPanelIn(rest_ys, button_keys = [])
    pbSEPlay("SlideUp", 60)
    rest_ys.each do |key, rest_y|
      next if !@sprites[key]
      @sprites[key].y = rest_y + PANEL_SCROLL_OFFSET
      @sprites[key].opacity = 0
      @sprites[key].visible = true
    end
    PANEL_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / PANEL_SCROLL_FRAMES.to_f
      rest_ys.each do |key, rest_y|
        next if !@sprites[key]
        @sprites[key].y = rest_y + (PANEL_SCROLL_OFFSET * (1 - progress))
        target_opacity = button_keys.include?(key) ? CMD_BUTTON_OPACITY_NORMAL : 255
        @sprites[key].opacity = (target_opacity * progress).to_i
      end
      pbUpdate
    end
    rest_ys.each do |key, rest_y|
      next if !@sprites[key]
      @sprites[key].y = rest_y
      @sprites[key].opacity = button_keys.include?(key) ? CMD_BUTTON_OPACITY_NORMAL : 255
    end
  end

  #-----------------------------------------------------------------------------
  # Scrolls the given {sprite_key => rest_y} set down off-screen, fading out.
  #-----------------------------------------------------------------------------
  def pbScrollPanelOut(rest_ys)
    pbSEPlay("SlideDown", 60)
    start_opacity = {}
    rest_ys.each { |key, _| start_opacity[key] = @sprites[key].opacity if @sprites[key] }
    PANEL_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / PANEL_SCROLL_FRAMES.to_f
      rest_ys.each do |key, rest_y|
        next if !@sprites[key]
        @sprites[key].y = rest_y + (PANEL_SCROLL_OFFSET * progress)
        @sprites[key].opacity = (start_opacity[key] * (1 - progress)).to_i
      end
      pbUpdate
    end
    rest_ys.each do |key, _|
      @sprites[key].visible = false if @sprites[key]
    end
  end

  #-----------------------------------------------------------------------------
  # Full rest-Y map for the Command panel (base elements + command buttons).
  #-----------------------------------------------------------------------------
  def command_panel_rest_ys
    rest = panel_base_sprite_rest_y
    CMD_BUTTON_KEYS.each { |key| rest[key] = CMD_BUTTON_REST_Y }
    return rest
  end

  #-----------------------------------------------------------------------------
  # Full rest-Y map for the Fight panel (base elements + move buttons).
  #-----------------------------------------------------------------------------
  def fight_panel_rest_ys
    rest = panel_base_sprite_rest_y
    FIGHT_BUTTON_KEYS.each { |key| rest[key] = FIGHT_BUTTON_REST_Y }
    rest["cancelButton"] = CANCEL_BUTTON_Y
    return rest
  end

  #-----------------------------------------------------------------------------
  # Overridden Command menu loop: scrolls the Command panel in on entry, and
  # out again before returning (whether confirming, cancelling, or moving to
  # the Fight panel).
  #-----------------------------------------------------------------------------
  alias customUI_pbCommandMenuEx pbCommandMenuEx
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)
    pbBuildCustomOverlay
    pbBuildCustomPromptText(texts[0].gsub("\n", " "))
    pbBuildCustomPartyBalls
    pbBuildCustomCommandButtons
    pbScrollPanelIn(command_panel_rest_ys, CMD_BUTTON_KEYS)
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      mouseChanged = false
      mouseOverButton = false
      if Mouse.active?
        oldMouseIndex = cw.index
        CMD_BUTTON_KEYS.each_with_index do |key, i|
          next if !Mouse.over?(@sprites[key])
          cw.index = i
          mouseOverButton = true
        end
        mouseChanged = (cw.index != oldMouseIndex)
      end
      pbUpdateCustomCommandOpacity(cw.index)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if cw.index > 0
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if cw.index < CMD_BUTTON_KEYS.length - 1
      end
      pbPlayCursorSE if cw.index != oldIndex && !mouseChanged
      if Input.trigger?(Input::USE) || (Mouse.click? && mouseOverButton)
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && mode == 1
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    pbScrollPanelOut(command_panel_rest_ys)
    return ret
  end

  #-----------------------------------------------------------------------------
  # Overridden Fight menu loop: scrolls the Fight panel in on entry, and out
  # again before returning (whether confirming a move, cancelling back to the
  # Command panel, or toggling mega/shift).
  #-----------------------------------------------------------------------------
  alias customUI_pbFightMenu pbFightMenu
  def pbFightMenu(idxBattler, megaEvoPossible = false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]]&.id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    cw.setIndexAndMode(moveIndex, (megaEvoPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        pbBuildCustomOverlay
        pbBuildCustomPromptText(_INTL("What will {1} do?", battler.name))
        pbBuildCustomPartyBalls
        pbBuildCustomFightButtons(battler)
        pbScrollPanelIn(fight_panel_rest_ys, FIGHT_BUTTON_KEYS)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode != cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      pbUpdate(cw)
      mouseChanged = false
      mouseOverButton = false
      mouseOverCancel = false
      if Mouse.active?
        oldMouseIndex = cw.index
        FIGHT_BUTTON_KEYS.each_with_index do |key, i|
          next if !battler.moves[i]&.id
          next if !Mouse.over?(@sprites[key])
          cw.index = i
          mouseOverButton = true
        end
        mouseOverCancel = true if @sprites["cancelButton"] && Mouse.over?(@sprites["cancelButton"])
        mouseChanged = (cw.index != oldMouseIndex)
      end
      pbUpdateCustomFightOpacity(cw.index)
      if Input.trigger?(Input::LEFT)
        newIndex = (cw.index - 1) % 4
        newIndex = (newIndex - 1) % 4 while !battler.moves[newIndex]&.id
        cw.index = newIndex
      elsif Input.trigger?(Input::RIGHT)
        newIndex = (cw.index + 1) % 4
        newIndex = (newIndex + 1) % 4 while !battler.moves[newIndex]&.id
        cw.index = newIndex
      end
      pbPlayCursorSE if cw.index != oldIndex && !mouseChanged
      mouseClicked = Mouse.click?
      if Input.trigger?(Input::USE) || (mouseClicked && mouseOverButton)
        pbPlayDecisionSE
        pbScrollPanelOut(fight_panel_rest_ys)
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
      elsif Input.trigger?(Input::BACK) || (mouseClicked && mouseOverCancel)
        pbPlayCancelSE
        pbFlashCancelButton
        pbScrollPanelOut(fight_panel_rest_ys)
        break if yield :cancel
        needFullRefresh = true
        needRefresh = true
      elsif Input.trigger?(Input::ACTION)
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
      elsif Input.trigger?(Input::SPECIAL)
        if cw.shiftMode > 0
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end
end
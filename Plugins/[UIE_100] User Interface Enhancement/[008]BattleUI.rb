#===============================================================================
#                        Custom Battle Screen
#                               V 1.0.46
#                        Developed by Carmaniac
#===============================================================================
module Settings
  CUSTOM_BATTLE_UI_GRAPHICS_PATH = "Graphics/Custom UI/Battle System/"
end

class Battle::Scene
  # Rest position for the message box overlay (screen is 800x480).
  MESSAGE_REST_Y      = 394
  MESSAGE_SCROLL_FRAMES = 10
  MESSAGE_SCROLL_OFFSET = 160   # how far below the screen it starts/ends at

  # z-order, low to high. Left big gaps on purpose so new layers can slot in
  # later without renumbering everything.
  Z_SHADOW_OVERLAY   = 100
  Z_BALL_OVERLAY     = 150
  Z_SUMMARY_PANEL    = 175   # party_summary_panel.png/party_moves_panel.png + their icon/overlay - sit above shadow/ball_overlay, below ball_bar/icon_ball
  Z_BALL_BAR_OVERLAY = 200
  Z_PARTY_BALL       = 250
  Z_COMMAND_BUTTON   = 300
  Z_COMMAND_SELECTOR = 310
  Z_BATTLER_ICON     = 350
  Z_BAG_UI           = 400
  Z_BAG_UI_SEL       = 410
  Z_BAG_ITEM_BUTTON  = 420
  Z_BAG_ITEM_SEL     = 430
  Z_USE_ITEM_DESC    = 440   # item_description.png, Use Item page
  Z_MESSAGE_BOX    = 900_000
  Z_MESSAGE_WINDOW = 900_001
  Z_BAG_POCKET_ARROW = 900_002   # above the message box - it doubles as the pocket header

  # Command page (Fight/Bag/Pokémon/Run) background - shadow + spinning ball
  # behind the prompt text.
  BALL_OVERLAY_X    = 270
  BALL_OVERLAY_Y    = 110
  BALL_SPIN_SPEED   = 1.5   # degrees/frame, clockwise
  COMMAND_BG_FADE_FRAMES = 6   # keep in sync with the other panel fade/scroll frame counts below

  # Ball bar scrolls down from above; party balls only start cascading in
  # once it's fully in place (see pbScrollBallBarIn / pbShowPartyBalls).
  BALL_BAR_REST_Y      = 0
  BALL_BAR_SCROLL_OFFSET = 52   # = graphic height, 800x52
  BALL_BAR_SCROLL_FRAMES = 6

  # Party ball row, both sides - reuses the icon_ball_* graphics.
  PARTY_BALL_SIZE           = 30
  PARTY_BALL_SPACING        = 6
  PLAYER_BALL_START_X       = 6
  ENEMY_BALL_START_X        = 586
  PARTY_BALL_Y               = 10
  PLAYER_BALL_SLIDE_START_X = -30   # off left edge
  ENEMY_BALL_SLIDE_START_X  = 800   # off right edge
  PARTY_BALL_FRAMES_PER_SLOT = 3     # each ball's own slide duration; slots cascade one after another

  # Command page buttons.
  CMD_BUTTON_GRAPHICS_PATH = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "Fight Buttons/"
  CMD_BUTTON_FILES = { "fight" => "Fight", "bag" => "Bag", "run" => "Run", "pokemon" => "Pokemon" }
  CMD_BUTTON_POS = {
    "fight"   => [222, 100],
    "bag"     => [132, 276],
    "run"     => [314, 296],
    "pokemon" => [496, 276],
  }
  CMD_INDEX_TO_KEY = { 0 => "fight", 1 => "bag", 2 => "pokemon", 3 => "run" }
  CMD_KEY_TO_INDEX = CMD_INDEX_TO_KEY.invert
  CMD_ROW = ["bag", "run", "pokemon"]   # left/right cycle order - matches on-screen left-to-right x order
  CMD_BUTTON_OPACITY_NORMAL   = 220
  CMD_BUTTON_OPACITY_SELECTED = 255
  COMMAND_BUTTON_FADE_FRAMES = 6

  # Selection highlight over the Command buttons
  # is selected.
  SEL_LARGE_FILE   = "sel_large"
  SEL_LARGE_W      = 336
  SEL_LARGE_H      = 704
  SEL_LARGE_FRAMES = 4
  SEL_LARGE_OFFSET_X = 10
  SEL_LARGE_OFFSET_Y = -8

  SEL_MEDIUM_FILE   = "sel_medium"
  SEL_MEDIUM_W      = 172
  SEL_MEDIUM_H      = 320
  SEL_MEDIUM_FRAMES = 4
  SEL_MEDIUM_OFFSET_X = 0
  SEL_MEDIUM_OFFSET_Y = -8

  SEL_ANIM_SPEED = 7   # ticks per frame step - same pacing as the Party screen's highlight

  # Battler name/status icon boxes - icon_party.png for the player's side,
  # icon_foe.png for the enemy's side. Only compatible with single and
  # double battles (party slots 3+ get no box at all).
  PLAYER_ICON_POS = [[18, 84], [18, 172]]
  ENEMY_ICON_POS  = [[608, 84], [608, 172]]
  BATTLER_ICON_WIDTH        = 176   # icon_party.png/icon_foe.png width, used to center the name text
  BATTLER_NAME_Y_OFFSET     = 6
  BATTLER_NAME_TEXT_COLOR   = Color.new(255, 255, 255)   # same as the message window
  BATTLER_NAME_SHADOW_COLOR = Color.new(33, 33, 33)       # same as the message window
  BATTLER_STATUS_OFFSET_X   = 128
  BATTLER_STATUS_OFFSET_Y   = 46

  # Idle bob for whichever player battler is actually active right now
  BATTLER_BOB_MAX_OFFSET = 10   # how far up it rises before reversing
  BATTLER_BOB_STEP       = 2    # even steps only
  BATTLER_BOB_TICKS      = 2    # frames between each step - lower = faster bob

  # Bag page - self-contained, doesn't touch the base engine's pbBagScreen.
  BAG_UI_FILES = {
    "hp"      => "icon_item_hp",
    "restore" => "icon_item_restore",
    "balls"   => "icon_item_balls",
    "battle"  => "icon_item_battle",
    "command" => "item_command",
    "cancel"  => "icon_cancel",
  }
  BAG_UI_POS = {
    "hp"      => [0, 108],
    "restore" => [0, 246],
    "balls"   => [500, 108],
    "battle"  => [500, 246],
    "command" => [174, 410],
    "cancel"  => [692, 402],
  }
  BAG_UI_SIZE = {
    "hp"      => [300, 108],
    "restore" => [300, 108],
    "balls"   => [300, 108],
    "battle"  => [300, 108],
    "command" => [450, 62],
    "cancel"  => [108, 78],
  }
  # Which direction each button slides in from - left/right slide on X,
  # bottom slides on Y. All run in the same synced loop (BAG_UI_SLIDE_FRAMES).
  BAG_UI_SLIDE_FROM = {
    "hp"      => :left,
    "restore" => :left,
    "balls"   => :right,
    "battle"  => :right,
    "cancel"  => :right,
    "command" => :bottom,
  }
  BAG_UI_SLIDE_FRAMES = 12
  BAG_UI_OPACITY_NO_LAST_ITEM = 140   # item_command's opacity when there's no saved last-used item yet

  # Text baked onto the Bag buttons
  BAG_UI_TEXT = {
    "hp"      => [["HP/PP", 158, 24], ["RESTORE", 158, 56]],
    "restore" => [["STATUS", 158, 26], ["RESTORE", 158, 58]],
    "balls"   => [["POKÉBALLS", 60, 42]],
    "battle"  => [["BATTLE ITEMS", 60, 42]],
  }
  BAG_UI_COMMAND_TEXT = "LAST ITEM USED"
  BAG_UI_COMMAND_TEXT_Y = 18
  BAG_UI_COMMAND_ICON_POS = [36, 4]   # last-used item's icon, relative to item_command.png, once one's actually saved
  BAG_UI_TEXT_COLOR        = Color.new(255, 255, 255)   # same as the message window
  BAG_UI_TEXT_SHADOW_COLOR = Color.new(33, 33, 33)       # same as the message window

  BAG_GRID = [
    ["hp",      "balls"],
    ["restore", "battle"],
    ["command", "cancel"],
  ]
  BAG_CANCEL_FLASH_FRAMES = 4   # how long each icon_cancel/icon_cancel_p swap holds

  # Highlight over whichever Bag button is selected
  BAG_SEL_FRAMES = 4
  BAG_SEL_FILES = {
    "hp"      => "item_sel_l",
    "restore" => "item_sel_l",
    "balls"   => "item_sel_r",
    "battle"  => "item_sel_r",
    "command" => "item_command_sel",
    "cancel"  => "icon_cancel_sel",
  }
  BAG_SEL_OFFSET = {
    "hp"      => [252, -8],
    "restore" => [252, -8],
    "balls"   => [10, -8],
    "battle"  => [10, -8],
    "command" => [-2, -8],
    "cancel"  => [16, -8],
  }

  # Bag pocket pages
  BAG_POCKET_NAMES = {
    "hp"      => "HP / PP RESTORE",
    "restore" => "STATUS RESTORE",
    "balls"   => "POKÉ BALLS",
    "battle"  => "BATTLE ITEMS",
  }
  BAG_POCKET_TEXT_CENTER_X = 494   # header text is centered around this x, not the box's own midpoint
  BAG_POCKET_TEXT_Y = 30   # was 42, sat 12px too low
  BAG_POCKET_PAGE_TEXT_GAP = 10   # page indicator ("1/6") sits this many px after the pocket name, same y
  BAG_POCKET_ARROW_LEFT_POS  = [40, 28]    # relative to the message box's rest position
  BAG_POCKET_ARROW_RIGHT_POS = [114, 28]

  # Item grid within a pocket page
  BAG_ITEM_AREA_POS    = [0, 44]
  BAG_ITEM_AREA_SIZE   = [800, 352]
  BAG_ITEM_BUTTON_FILE = "item_button"
  BAG_ITEM_BUTTON_SIZE = [296, 86]
  BAG_ITEM_GRID_COLS = 2
  BAG_ITEM_GRID_ROWS = 3
  BAG_ITEM_SLOTS = BAG_ITEM_GRID_COLS * BAG_ITEM_GRID_ROWS
  BAG_ITEM_START_X = 92
  BAG_ITEM_START_Y = 64
  BAG_ITEM_SPACING_X = 24
  BAG_ITEM_SPACING_Y = 24   # mirrors BAG_ITEM_SPACING_X
  BAG_ITEM_TEXT_AREA_POS  = [82, 14]    # where the centered text area starts, relative to the button (y +4 - text sat too high)
  BAG_ITEM_TEXT_AREA_SIZE = [188, 60]
  BAG_ITEM_ICON_POS = [34, 16]
  BAG_ITEM_SLIDE_FRAMES = BAG_UI_SLIDE_FRAMES   # reuse the same pacing as the rest of the Bag UI
  BAG_ITEM_BUTTON_OPACITY_NORMAL   = CMD_BUTTON_OPACITY_NORMAL     # 220, same scheme as everywhere else
  BAG_ITEM_BUTTON_OPACITY_SELECTED = CMD_BUTTON_OPACITY_SELECTED   # 255

  # Item grid highlight
  BAG_ITEM_SEL_FILE   = "item_button_sel"
  BAG_ITEM_SEL_FRAMES = 4
  BAG_ITEM_SEL_OFFSET = [4, -8]

  # Item categories
  BAG_HP_ITEM_IDS = [
    :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :FULLRESTORE,
    :REVIVE, :MAXREVIVE, :ETHER, :MAXETHER, :ELIXIR, :MAXELIXIR, :PPUP, :PPMAX,
  ]
  BAG_STATUS_ITEM_IDS = [
    :ANTIDOTE, :BURNHEAL, :ICEHEAL, :AWAKENING, :PARALYZEHEAL, :FULLHEAL, :LUMBERRY,
  ]
  # Looked up against PokemonBag.pocket_names
  BAG_BALLS_POCKET_NAME = "Poké Balls"
  BAG_BATTLE_ITEMS_POCKET_NAME = "Battle Items"

  # Use Item page
  USE_ITEM_BUTTON_TEXT = "USE"
  USE_ITEM_DESC_FILE = "item_description"
  USE_ITEM_DESC_POS  = [0, 64]
  USE_ITEM_ICON_POS  = [120, 20]
  USE_ITEM_TEXT_COLOR        = Color.new(0, 0, 0)
  USE_ITEM_TEXT_SHADOW_COLOR = Color.new(173, 189, 189)
  # The name and each description line are centered within a restricted
  # area
  USE_ITEM_TEXT_AREA_X     = 44
  USE_ITEM_TEXT_AREA_WIDTH = 712
  USE_ITEM_NAME_Y = 36
  USE_ITEM_QTY_POS = [558, 36]   # fixed position, not centered
  USE_ITEM_DESC_Y  = 98
  USE_ITEM_DESC_LINE_HEIGHT = 32   # line spacing for the wrapped description text

  # Fight menu 
  FIGHT_BUTTON_GRAPHICS_PATH = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "Moves/"
  FIGHT_MOVE_KEYS = ["move0", "move1", "move2", "move3"]
  FIGHT_MOVE_POS = {
    "move0" => [114, 60],
    "move1" => [432, 60],
    "move2" => [114, 194],
    "move3" => [432, 194],
  }
  FIGHT_MOVE_NAME_Y = 22   # centered on the button
  FIGHT_MOVE_PP_POS = [86, 60]   # left-aligned, not centered
  FIGHT_SUMMARY_GRAPHICS_PATH = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "Party/"
  FIGHT_SUMMARY_FILE = "icon_summary"
  FIGHT_SUMMARY_POS  = [292, 314]

  # Highlight over whichever Fight button is selected
  FIGHT_SEL_FRAMES = 4
  FIGHT_SEL_FILES = {
    "move0" => "moves_sel", "move1" => "moves_sel", "move2" => "moves_sel", "move3" => "moves_sel",
    "summary" => "icon_summary_sel",
    "cancel"  => BAG_SEL_FILES["cancel"],
  }
  FIGHT_SEL_OFFSET = {
    "move0" => [-4, -8], "move1" => [-4, -8], "move2" => [-4, -8], "move3" => [-4, -8],
    "summary" => [-4, -8],
    "cancel"  => BAG_SEL_OFFSET["cancel"],
  }

  # Summary panel page
  SUMMARY_PANEL_FILE = "party_summary_panel"
  SUMMARY_PANEL_RESTING_POS = [0, 54]   # scrolls down from above the screen to rest here
  FIGHT_CHECK_MOVES_FILE = "icon_check_moves"
  FIGHT_CHECK_MOVES_POS  = [292, 372]

  # Summary panel's detail overlay
  SUMMARY_ICON_OFFSET = [36, -16]   # the animated PokemonIconSprite
  SUMMARY_NAME_POS = [126, 12]
  SUMMARY_LEVEL_POS = [34, 58]          # drawn as "Lv. ###"
  SUMMARY_NEXT_LEVEL_LABEL_POS = [34, 90]    # literal "NEXT LEVEL" text
  SUMMARY_NEXT_LEVEL_VALUE_RIGHT_X = 310     # value right-anchored to this x, same y as the label
  SUMMARY_NEXT_LEVEL_LABEL = "NEXT LEVEL"
  SUMMARY_ABILITY_POS = [34, 138]
  SUMMARY_ABILITY_DESC_POS = [34, 170]
  SUMMARY_ABILITY_DESC_MAX_WIDTH = 290
  SUMMARY_ITEM_POS = [34, 250]
  SUMMARY_NO_ITEM_TEXT = "No item held"
  SUMMARY_HP_POS = [608, 58]            # drawn as "HP ###/###"
  SUMMARY_EXP_BAR_FILE = "icon_exp_party"   # 128x4, same clipped-rect idea as icon_exp.png on icon_party
  SUMMARY_EXP_BAR_POS = [178, 122]
  SUMMARY_HP_OVERLAY_FILE = "icon_hp_overlay"   # static frame graphic, blitted whole
  SUMMARY_HP_OVERLAY_POS = [640, 86]
  # icon_overlay_hp.png reused straight from the root Battle System folder
  SUMMARY_HP_BAR_POS = [672, 92]
  SUMMARY_STAT_LABEL_POS = {
    "attack"  => [608, 106],
    "defense" => [608, 138],
    "spatk"   => [608, 170],
    "spdef"   => [608, 202],
    "speed"   => [608, 234],
  }
  SUMMARY_STAT_VALUE_POS = {
    "attack"  => [742, 106],
    "defense" => [742, 138],
    "spatk"   => [742, 170],
    "spdef"   => [742, 202],
    "speed"   => [742, 234],
  }
  SUMMARY_STAT_LABELS = {
    "attack"  => "ATTACK",
    "defense" => "DEFENSE",
    "spatk"   => "SP. ATK",
    "spdef"   => "SP. DEF",
    "speed"   => "SPEED",
  }
  SUMMARY_GENDER_POS = [389, 12]
  SUMMARY_GENDER_MALE_COLOR   = Color.new(0, 112, 248)     # Essentials' usual male gender colour
  SUMMARY_GENDER_FEMALE_COLOR = Color.new(248, 88, 120)    # Essentials' usual female gender colour
  SUMMARY_TYPE_ICON_POS = [[404, 10], [474, 10]]
  SUMMARY_TYPE_ICON_FILE = "type_icons"
  SUMMARY_TYPE_ICON_SIZE = [64, 24]   # 456 / 24 = 19 rows

  # Moves summary page
  MOVES_PANEL_FILE = "party_moves_panel"

  # Move detail content.
  MOVES_NAME_POS = [208, 58]
  MOVES_TYPE_ICON_POS = [384, 56]
  MOVES_PP_LABEL = "PP"
  MOVES_PP_LABEL_POS = [464, 58]
  MOVES_PP_VALUE_POS = [520, 58]      # drawn as "##/##"
  MOVES_CATEGORY_LABEL = "CATEGORY"
  MOVES_CATEGORY_LABEL_POS = [58, 106]
  MOVES_CATEGORY_VALUE_POS = [90, 138]
  MOVES_CATEGORY_ICON_POS = [14, 134]
  MOVES_CATEGORY_ICON_FILE = "category"   # Battle System/ root
  MOVES_CATEGORY_ICON_SIZE = [56, 28]
  MOVES_POWER_LABEL = "POWER"
  MOVES_POWER_LABEL_POS = [580, 106]
  MOVES_POWER_VALUE_POS = [748, 106]     # "---" for a move with no set power
  MOVES_ACCURACY_LABEL = "ACCURACY"
  MOVES_ACCURACY_LABEL_POS = [580, 138]
  MOVES_ACCURACY_VALUE_POS = [748, 138]  # "---" for a move that can't miss
  MOVES_DESC_POS = [36, 186]        # x moved +20 from its original 16
  MOVES_DESC_MAX_WIDTH = 728        # width taken down 40 from its original 768

  # Move slot picker
  MOVES_SLOT_KEYS = ["moveSlot0", "moveSlot1", "moveSlot2", "moveSlot3"]
  MOVES_SLOT_POS = {
    "moveSlot0" => [326, 402],
    "moveSlot1" => [406, 402],
    "moveSlot2" => [326, 434],
    "moveSlot3" => [406, 434],
  }
  MOVES_SLOT_GRID = { "moveSlot0" => [0, 0], "moveSlot1" => [0, 1], "moveSlot2" => [1, 0], "moveSlot3" => [1, 1] }
  MOVES_SLOT_GRAPHICS_PATH = FIGHT_SUMMARY_GRAPHICS_PATH   # Battle System/Party/
  MOVES_SLOT_FILE     = "move_slot"
  MOVES_SLOT_SEL_FILE = "move_slot_sel"

  # Party page
  PARTY_GRAPHICS_PATH = FIGHT_SUMMARY_GRAPHICS_PATH   # Battle System/Party/
  PARTY_SLOT_KEYS = ["partySlot0", "partySlot1", "partySlot2", "partySlot3", "partySlot4", "partySlot5"]
  PARTY_SLOT_POS = {
    "partySlot0" => [114, 64],  "partySlot1" => [432, 64],
    "partySlot2" => [114, 174], "partySlot3" => [432, 174],
    "partySlot4" => [114, 284], "partySlot5" => [432, 284],
  }
  PARTY_SLOT_GRID = {
    "partySlot0" => [0, 0], "partySlot1" => [0, 1],
    "partySlot2" => [1, 0], "partySlot3" => [1, 1],
    "partySlot4" => [2, 0], "partySlot5" => [2, 1],
  }
  PARTY_SLOT_ACTIVE_FILE = "party_slot_active"   # slot has a Pokemon in it, not currently highlighted
  PARTY_SLOT_EMPTY_FILE  = "party_slot_empty"    # slot is unfilled
  PARTY_SLOT_SEL_FILE    = "party_slot_sel"      # slot has a Pokemon in it AND is currently highlighted
  PARTY_MENU_SEL_FILE   = FIGHT_SEL_FILES["move0"]
  PARTY_MENU_SEL_OFFSET = FIGHT_SEL_OFFSET["move0"]
  PARTY_PROMPT_TEXT = "Choose a Pokémon."

  PARTY_ICON_OFFSET = [0, 0]        # animated PokemonIconSprite sits exactly on the slot's own xy
  PARTY_NAME_POS = [66, 18]
  PARTY_GENDER_POS = [228, 18]
  PARTY_LEVEL_POS = [14, 64]            # drawn as "Lv.###"
  PARTY_HP_TEXT_CENTER = [182, 78]      # "###/###", auto-centered both x and y
  # other HP bar in this file).
  PARTY_HP_OVERLAY_FILE = "icon_hp_overlay"
  PARTY_HP_OVERLAY_POS = [96, 46]
  PARTY_HP_BAR_FILE = "icon_party_hp_overlay"
  PARTY_HP_BAR_POS = [128, 52]

  # Party action menu
  PARTY_SUMMARY_POS = [168, 372]
  PARTY_CHECK_MOVES_POS = [414, 372]

  # Shift button
  PARTY_SHIFT_FILE = "icon_shift"
  PARTY_SHIFT_POS = [242, 92]
  PARTY_SHIFT_WIDTH = 316
  PARTY_SHIFT_NAME_GENDER_Y = 34   # name + gender symbol drawn as one centered block
  PARTY_SHIFT_ICON_POS = [126, 68]      # animated PokemonIconSprite
  PARTY_SHIFT_STATE_Y = 158             # "IN BATTLE" or "SWITCH", centered same as name/gender
  PARTY_SHIFT_SEL_FILE = "shift_sel"
  PARTY_SHIFT_SEL_OFFSET = [8, -8]

  # Double battle target picker
  TARGET_PANEL_KEYS = ["enemy1", "enemy2", "party1", "party2"]
  TARGET_PANEL_BATTLER_INDEX = { "enemy1" => 1, "enemy2" => 3, "party1" => 0, "party2" => 2, "cancel" => -1 }
  TARGET_PANEL_POS = {
    "enemy1" => FIGHT_MOVE_POS["move0"],
    "enemy2" => FIGHT_MOVE_POS["move1"],
    "party1" => FIGHT_MOVE_POS["move2"],
    "party2" => FIGHT_MOVE_POS["move3"],
  }
  TARGET_PANEL_FILE       = "pokemon_panel_field"
  TARGET_PANEL_EMPTY_FILE = "pokemon_panel_field_empty"
  TARGET_SEL_FIELD_FILE = "move_field_sel"
  TARGET_PANEL_ICON_OFFSET = [14, 16]
  TARGET_PANEL_NAME_Y = 38
  TARGET_PANEL_NAME_X_START = 82
  TARGET_PANEL_NAME_WIDTH = 158

  alias customUI_pbInitSprites pbInitSprites
  def pbInitSprites
    customUI_pbInitSprites
    return if pbInSafari?
    if @sprites["messageBox"]
      @sprites["messageBox"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "message_overlay.png")
      @sprites["messageBox"].x = 0
      @sprites["messageBox"].y = MESSAGE_REST_Y + MESSAGE_SCROLL_OFFSET
      @sprites["messageBox"].z = Z_MESSAGE_BOX
      @sprites["messageBox"].visible = false
    end
    @sprites["cmdBar_bg"].visible = false if @sprites["cmdBar_bg"]
    if @sprites["messageWindow"]
      @sprites["messageWindow"].baseColor   = Color.new(255, 255, 255)
      @sprites["messageWindow"].shadowColor = Color.new(33, 33, 33)
      @sprites["messageWindow"].z = Z_MESSAGE_WINDOW
      @sprites["messageWindow"].visible = false
    end
    @sprites["ballBarOverlay"] = IconSprite.new(@viewport)
    @sprites["ballBarOverlay"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "ball_bar_overlay.png")
    @sprites["ballBarOverlay"].x = 0
    @sprites["ballBarOverlay"].y = BALL_BAR_REST_Y - BALL_BAR_SCROLL_OFFSET
    @sprites["ballBarOverlay"].z = Z_BALL_BAR_OVERLAY
    @sprites["ballBarOverlay"].visible = false
  end

  # Scrolls the message box overlay up from off-screen into its rest position.
  def pbScrollMessageBoxIn(playSE = true)
    box = @sprites["messageBox"]
    return if !box
    pbSEPlay("SlideUp", 60) if playSE
    box.x = 0
    box.y = MESSAGE_REST_Y + MESSAGE_SCROLL_OFFSET
    box.visible = true
    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = MESSAGE_REST_Y + (MESSAGE_SCROLL_OFFSET * (1 - progress))
      pbUpdate
    end
    box.y = MESSAGE_REST_Y
  end

  # Scrolls the message box overlay back down off-screen
  def pbScrollMessageBoxOut
    box = @sprites["messageBox"]
    return if !box || !box.visible
    if @sprites["messageWindow"]
      @sprites["messageWindow"].text = ""
      @sprites["messageWindow"].visible = false
    end
    pbSEPlay("SlideDown", 60)
    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = MESSAGE_REST_Y + (MESSAGE_SCROLL_OFFSET * progress)
      pbUpdate
    end
    box.visible = false
  end

  # Scrolls the box out then straight back in, leaving it empty and visible
  def pbClearMessageBox
    return if !@sprites["messageBox"] || !@sprites["messageBox"].visible
    pbScrollMessageBoxOut
    pbScrollMessageBoxIn
  end

  # Full exit for the Command page once a choice is confirmed
  def pbHideCommandPageAssets
    pbHideCommandButtons
    pbHidePartyBalls
    pbHideCommandBackground
    pbScrollMessageBoxOut
  end

  # Replaces pbShowWindow
  alias customUI_pbShowWindow pbShowWindow
  def pbShowWindow(windowType)
    if windowType == MESSAGE_BOX
      if @sprites["messageBox"] && !@sprites["messageBox"].visible
        pbScrollMessageBoxIn
      end
      @sprites["messageWindow"].visible = true if @sprites["messageWindow"]
    end
    @sprites["commandWindow"].visible = false if @sprites["commandWindow"]
    @sprites["fightWindow"].visible   = false if @sprites["fightWindow"]
    @sprites["targetWindow"].visible  = (windowType == TARGET_BOX) if @sprites["targetWindow"]
  end

  # Explicit, on-demand close for the message box
  def pbHideMessageBox
    return if !@sprites["messageBox"] || !@sprites["messageBox"].visible
    pbScrollMessageBoxOut
    @sprites["messageWindow"].visible = false if @sprites["messageWindow"]
  end

  # Types text into messageWindow
  def pbSetMessageWindowText(text)
    cw = @sprites["messageWindow"]
    return if !cw
    cw.visible = true
    cw.setText(text)
    loop do
      pbUpdate(cw)
      break if !cw.busy?
    end
  end

  # Scrolls the ball bar down into its rest position
  def pbScrollBallBarIn
    bar = @sprites["ballBarOverlay"]
    return if !bar || bar.visible
    bar.x = 0
    bar.y = BALL_BAR_REST_Y - BALL_BAR_SCROLL_OFFSET
    bar.visible = true
    BALL_BAR_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / BALL_BAR_SCROLL_FRAMES.to_f
      bar.y = BALL_BAR_REST_Y - (BALL_BAR_SCROLL_OFFSET * (1 - progress))
      pbUpdate
    end
    bar.y = BALL_BAR_REST_Y
  end

  # Scrolls the ball bar back up off-screen
  def pbScrollBallBarOut
    bar = @sprites["ballBarOverlay"]
    return if !bar || !bar.visible
    BALL_BAR_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / BALL_BAR_SCROLL_FRAMES.to_f
      bar.y = BALL_BAR_REST_Y - (BALL_BAR_SCROLL_OFFSET * progress)
      pbUpdate
    end
    bar.visible = false
  end

  # Which icon_ball_* graphic represents a given party slot
  def pbPartyBallGraphic(pkmn)
    return "icon_ball_empty" if !pkmn
    return "icon_ball_faint" if !pkmn.able?
    return "icon_ball_status" if pkmn.status != :NONE
    return "icon_ball"
  end

  # Builds/refreshes the party ball row
  def pbBuildPartyBalls
    party = @battle.pbParty(0)
    Settings::MAX_PARTY_SIZE.times do |i|
      key = "partyBall_player_#{i}"
      if !@sprites[key]
        @sprites[key] = IconSprite.new(@viewport)
        @sprites[key].z = Z_PARTY_BALL
        @sprites[key].x = PLAYER_BALL_SLIDE_START_X
        @sprites[key].y = PARTY_BALL_Y
        @sprites[key].visible = false
      end
      @sprites[key].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + pbPartyBallGraphic(party[i]) + ".png")
    end
    return if !@battle.trainerBattle?
    enemyParty = @battle.pbParty(1)
    Settings::MAX_PARTY_SIZE.times do |i|
      key = "partyBall_enemy_#{i}"
      if !@sprites[key]
        @sprites[key] = IconSprite.new(@viewport)
        @sprites[key].z = Z_PARTY_BALL
        @sprites[key].x = ENEMY_BALL_SLIDE_START_X
        @sprites[key].y = PARTY_BALL_Y
        @sprites[key].visible = false
      end
      @sprites[key].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + pbPartyBallGraphic(enemyParty[i]) + ".png")
    end
  end

  # Cascades the party balls in one slot at a time
  def pbShowPartyBalls
    alreadyShown = @sprites["partyBall_player_0"] && @sprites["partyBall_player_0"].visible
    pbBuildPartyBalls
    return if alreadyShown
    pbScrollBallBarIn   # ball_bar_overlay finishes its scroll first...
    Settings::MAX_PARTY_SIZE.times do |round|
      playerIndex = (Settings::MAX_PARTY_SIZE - 1) - round   # slot 6 -> slot 1
      enemyIndex  = round                                     # slot 1 -> slot 6
      playerBall = @sprites["partyBall_player_#{playerIndex}"]
      enemyBall  = @battle.trainerBattle? ? @sprites["partyBall_enemy_#{enemyIndex}"] : nil
      restXPlayer = PLAYER_BALL_START_X + (playerIndex * (PARTY_BALL_SIZE + PARTY_BALL_SPACING))
      restXEnemy  = ENEMY_BALL_START_X + (enemyIndex * (PARTY_BALL_SIZE + PARTY_BALL_SPACING))
      if playerBall
        playerBall.x = PLAYER_BALL_SLIDE_START_X
        playerBall.visible = true
      end
      if enemyBall
        enemyBall.x = ENEMY_BALL_SLIDE_START_X
        enemyBall.visible = true
      end
      PARTY_BALL_FRAMES_PER_SLOT.times do |frame|
        progress = (frame + 1) / PARTY_BALL_FRAMES_PER_SLOT.to_f
        if playerBall
          playerBall.x = PLAYER_BALL_SLIDE_START_X + ((restXPlayer - PLAYER_BALL_SLIDE_START_X) * progress)
        end
        if enemyBall
          enemyBall.x = ENEMY_BALL_SLIDE_START_X + ((restXEnemy - ENEMY_BALL_SLIDE_START_X) * progress)
        end
        pbUpdate
      end
      playerBall.x = restXPlayer if playerBall
      enemyBall.x  = restXEnemy  if enemyBall
    end
  end

  # Animated exit for the party ball row
  def pbHidePartyBalls
    return if !@sprites["partyBall_player_0"] || !@sprites["partyBall_player_0"].visible
    Settings::MAX_PARTY_SIZE.times do |round|
      # Mirrored from the entrance order
      playerIndex = round
      enemyIndex  = (Settings::MAX_PARTY_SIZE - 1) - round
      playerBall = @sprites["partyBall_player_#{playerIndex}"]
      enemyBall  = @battle.trainerBattle? ? @sprites["partyBall_enemy_#{enemyIndex}"] : nil
      restXPlayer = PLAYER_BALL_START_X + (playerIndex * (PARTY_BALL_SIZE + PARTY_BALL_SPACING))
      restXEnemy  = ENEMY_BALL_START_X + (enemyIndex * (PARTY_BALL_SIZE + PARTY_BALL_SPACING))
      PARTY_BALL_FRAMES_PER_SLOT.times do |frame|
        progress = (frame + 1) / PARTY_BALL_FRAMES_PER_SLOT.to_f
        if playerBall
          playerBall.x = restXPlayer + ((PLAYER_BALL_SLIDE_START_X - restXPlayer) * progress)
        end
        if enemyBall
          enemyBall.x = restXEnemy + ((ENEMY_BALL_SLIDE_START_X - restXEnemy) * progress)
        end
        pbUpdate
      end
      playerBall.visible = false if playerBall
      enemyBall.visible  = false if enemyBall
    end
    pbScrollBallBarOut   # ...THEN the ball bar scrolls back up, once the balls are fully gone
  end

  # Full Command-page entrance.
  def pbShowCommandPrompt(text)
    textChanged = (text != @lastCommandPromptText)
    @lastCommandPromptText = text   # so pbBagMenuLoop can restore this exact text on cancel
    alreadyShown = @sprites["messageBox"] && @sprites["messageBox"].visible &&
                   @sprites["ballBarOverlay"] && @sprites["ballBarOverlay"].visible &&
                   @sprites["cmdBtn_fight"] && @sprites["cmdBtn_fight"].visible
    if alreadyShown
      # Only retypes if the text actually changed
      pbSetMessageWindowText(text) if textChanged
      pbShowPartyBalls   # graphics-only refresh; cascade is skipped since already shown
      return
    end
    pbScrollMessageBoxOut if @sprites["messageBox"] && @sprites["messageBox"].visible
    pbShowPartyBalls
    pbScrollCommandPanelIn
    pbSetMessageWindowText(text)
  end

  # Builds the shadow/ball background sprites used behind the Command page
  # prompt.
  def pbBuildCommandBackground
    if !@sprites["shadowOverlay"]
      @sprites["shadowOverlay"] = IconSprite.new(@viewport)
      @sprites["shadowOverlay"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "shadow_overlay.png")
      @sprites["shadowOverlay"].x = 0
      @sprites["shadowOverlay"].y = 0
      @sprites["shadowOverlay"].z = Z_SHADOW_OVERLAY
      @sprites["shadowOverlay"].opacity = 0
      @sprites["shadowOverlay"].visible = false
    end
    if !@sprites["ballOverlay"]
      @sprites["ballOverlay"] = Sprite.new(@viewport)
      @sprites["ballOverlay"].bitmap = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "ball_overlay.png")
      # Rotate around its own center
      @sprites["ballOverlay"].ox = @sprites["ballOverlay"].bitmap.width / 2
      @sprites["ballOverlay"].oy = @sprites["ballOverlay"].bitmap.height / 2
      @sprites["ballOverlay"].x = BALL_OVERLAY_X + @sprites["ballOverlay"].ox
      @sprites["ballOverlay"].y = BALL_OVERLAY_Y + @sprites["ballOverlay"].oy
      @sprites["ballOverlay"].z = Z_BALL_OVERLAY
      @sprites["ballOverlay"].opacity = 0
      @sprites["ballOverlay"].visible = false
    end
  end

  # Fades the shadow + ball in together
  def pbShowCommandBackground
    pbBuildCommandBackground
    shadow = @sprites["shadowOverlay"]
    ball   = @sprites["ballOverlay"]
    return if !shadow || !ball
    return if shadow.visible && ball.visible
    shadow.visible = true
    ball.visible = true
    COMMAND_BG_FADE_FRAMES.times do |frame|
      progress = (frame + 1) / COMMAND_BG_FADE_FRAMES.to_f
      shadow.opacity = (255 * progress).to_i
      ball.opacity   = (255 * progress).to_i
      pbUpdate
    end
    shadow.opacity = 255
    ball.opacity = 255
  end

  # Fades the shadow + ball back out (e.g. leaving the Command page).
  def pbHideCommandBackground
    shadow = @sprites["shadowOverlay"]
    ball   = @sprites["ballOverlay"]
    return if !shadow || !ball
    COMMAND_BG_FADE_FRAMES.times do |frame|
      progress = (frame + 1) / COMMAND_BG_FADE_FRAMES.to_f
      shadow.opacity = (255 * (1 - progress)).to_i
      ball.opacity   = (255 * (1 - progress)).to_i
      pbUpdate
    end
    shadow.visible = false
    ball.visible = false
  end

  def pbSpinBallOverlay
    ball = @sprites["ballOverlay"]
    return if !ball || !ball.visible
    ball.angle = (ball.angle + BALL_SPIN_SPEED) % 360
  end

  # Moves/re-skins the animated selection indicator onto whichever Command
  # button is currently selected.
  def pbUpdateCommandSelector(selectedKey)
    if !@sprites["cmdSel"]
      @sprites["cmdSel"] = IconSprite.new(@viewport)
      @sprites["cmdSel"].z = Z_COMMAND_SELECTOR
      @sprites["cmdSel"].visible = false
      @cmdSelFile  = nil
      @cmdSelFrame = 0
      @cmdSelTick  = 0
    end
    sel = @sprites["cmdSel"]
    isFight = (selectedKey == "fight")
    file = isFight ? SEL_LARGE_FILE : SEL_MEDIUM_FILE
    width  = isFight ? SEL_LARGE_W  : SEL_MEDIUM_W
    height = isFight ? SEL_LARGE_H  : SEL_MEDIUM_H
    frames = isFight ? SEL_LARGE_FRAMES : SEL_MEDIUM_FRAMES
    if @cmdSelFile != file
      sel.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      sel.src_rect.set(0, 0, width, height / frames)
      @cmdSelFile  = file
      @cmdSelFrame = 0
      @cmdSelTick  = 0
    end
    x, y = CMD_BUTTON_POS[selectedKey]
    if isFight
      x += SEL_LARGE_OFFSET_X
      y += SEL_LARGE_OFFSET_Y
    else
      x += SEL_MEDIUM_OFFSET_X
      y += SEL_MEDIUM_OFFSET_Y
    end
    sel.x = x
    sel.y = y
    sel.opacity = 255
    sel.visible = true
  end

  def pbAnimateCommandSelector
    sel = @sprites["cmdSel"]
    return if !sel || !sel.visible
    @cmdSelTick += 1
    return if @cmdSelTick < SEL_ANIM_SPEED
    @cmdSelTick = 0
    frames = (@cmdSelFile == SEL_LARGE_FILE) ? SEL_LARGE_FRAMES : SEL_MEDIUM_FRAMES
    height = (@cmdSelFile == SEL_LARGE_FILE) ? SEL_LARGE_H : SEL_MEDIUM_H
    @cmdSelFrame = (@cmdSelFrame + 1) % frames
    sel.src_rect.y = @cmdSelFrame * (height / frames)
  end

  alias customUI_pbUpdate pbUpdate
  def pbUpdate(*args)
    customUI_pbUpdate(*args)
    pbSpinBallOverlay
    pbAnimateCommandSelector
    pbAnimateBagSelector
    pbAnimateBagItemSel
    pbAnimateFightSelector
    pbAnimateSummaryPanelSelector
    pbAnimateTargetPanelSelector
    pbAnimateTargetPanelIcons
    pbAnimateBattlerIconBob
    pbAnimateSummaryPanelIcon
    pbAnimateMovesPanelSelector
    pbAnimateMovesPanelIcon
    pbAnimatePartyMenuSelector
    pbAnimatePartyIcons
    pbAnimatePartyActionSelector
    pbAnimatePartyShiftIcon
  end

  # Hides/shows the default Essentials data boxes
  def pbHideDataBoxes
    @sprites.each do |key, sprite|
      next if !key.is_a?(String) || !key.start_with?("dataBox_")
      sprite.visible = false if sprite
    end
  end

  def pbShowDataBoxes
    @sprites.each do |key, sprite|
      next if !key.is_a?(String) || !key.start_with?("dataBox_")
      sprite.visible = true if sprite
    end
  end

  # Builds the four Command buttons.
  def pbBuildCommandButtons
    CMD_BUTTON_POS.each do |key, (x, y)|
      spriteKey = "cmdBtn_#{key}"
      next if @sprites[spriteKey]
      @sprites[spriteKey] = IconSprite.new(@viewport)
      @sprites[spriteKey].setBitmap(CMD_BUTTON_GRAPHICS_PATH + CMD_BUTTON_FILES[key] + ".png")
      @sprites[spriteKey].x = x
      @sprites[spriteKey].y = y
      @sprites[spriteKey].z = Z_COMMAND_BUTTON
      @sprites[spriteKey].opacity = 0
      @sprites[spriteKey].visible = false
    end
  end

  def pbScrollCommandPanelIn
    pbBuildCommandButtons
    pbDrawAllBattlerIcons
    box = @sprites["messageBox"]
    alreadyShown = box && box.visible &&
                   @sprites["cmdBtn_fight"] && @sprites["cmdBtn_fight"].visible
    if alreadyShown
      pbSyncCmdCancelButton   # page's already up - just match mode, no animation needed
      return
    end
    pbSEPlay("SlideUp", 60) if box
    if box
      box.x = 0
      box.y = MESSAGE_REST_Y + MESSAGE_SCROLL_OFFSET
      box.visible = true
    end
    CMD_BUTTON_POS.each_key { |key| @sprites["cmdBtn_#{key}"].visible = true }
    iconSprites = pbBattlerIconSprites
    iconSprites.each { |s| s.opacity = 0; s.visible = true }
    # The double-battle "back to previous Pokemon" cancel button
    cancel = nil
    if @cmdCancelWanted
      pbBuildBagUI
      cancel = @sprites["bagUI_cancel"]
      cancelPos = BAG_UI_POS["cancel"]
      cancel.z = Z_BAG_POCKET_ARROW
      cancel.x = cancelPos[0]
      cancel.y = cancelPos[1]
      cancel.opacity = 0
      cancel.visible = true
      @cmdCancelShown = true
    end
    totalFrames = [MESSAGE_SCROLL_FRAMES, COMMAND_BUTTON_FADE_FRAMES].max
    totalFrames.times do |frame|
      if box
        boxProgress = [(frame + 1) / MESSAGE_SCROLL_FRAMES.to_f, 1.0].min
        box.y = MESSAGE_REST_Y + (MESSAGE_SCROLL_OFFSET * (1 - boxProgress))
      end
      btnProgress = [(frame + 1) / COMMAND_BUTTON_FADE_FRAMES.to_f, 1.0].min
      CMD_BUTTON_POS.each_key do |key|
        @sprites["cmdBtn_#{key}"].opacity = (CMD_BUTTON_OPACITY_NORMAL * btnProgress).to_i
      end
      iconSprites.each { |s| s.opacity = (255 * btnProgress).to_i }
      cancel.opacity = (255 * btnProgress).to_i if cancel
      pbUpdate
    end
    box.y = MESSAGE_REST_Y if box
    CMD_BUTTON_POS.each_key { |key| @sprites["cmdBtn_#{key}"].opacity = CMD_BUTTON_OPACITY_NORMAL }
    iconSprites.each { |s| s.opacity = 255 }
    cancel.opacity = 255 if cancel
  end

  # Highlights whichever button is currently selected
  def pbUpdateCommandButtonOpacity(selectedKey)
    CMD_BUTTON_POS.each_key do |key|
      sprite = @sprites["cmdBtn_#{key}"]
      next if !sprite
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    pbUpdateCommandSelector(selectedKey)
  end

  # Fades all four buttons
  def pbHideCommandButtons
    return if !@sprites["cmdBtn_fight"] || !@sprites["cmdBtn_fight"].visible
    startOpacity = {}
    CMD_BUTTON_POS.each_key do |key|
      startOpacity[key] = @sprites["cmdBtn_#{key}"].opacity if @sprites["cmdBtn_#{key}"]
    end
    selStartOpacity = @sprites["cmdSel"] ? @sprites["cmdSel"].opacity : 0
    iconSprites = pbBattlerIconSprites
    iconStartOpacity = {}
    iconSprites.each { |s| iconStartOpacity[s] = s.opacity }
    COMMAND_BUTTON_FADE_FRAMES.times do |frame|
      progress = (frame + 1) / COMMAND_BUTTON_FADE_FRAMES.to_f
      CMD_BUTTON_POS.each_key do |key|
        sprite = @sprites["cmdBtn_#{key}"]
        next if !sprite
        sprite.opacity = (startOpacity[key] * (1 - progress)).to_i
      end
      @sprites["cmdSel"].opacity = (selStartOpacity * (1 - progress)).to_i if @sprites["cmdSel"]
      iconSprites.each { |s| s.opacity = (iconStartOpacity[s] * (1 - progress)).to_i }
      pbUpdate
    end
    CMD_BUTTON_POS.each_key { |key| @sprites["cmdBtn_#{key}"].visible = false }
    @sprites["cmdSel"].visible = false if @sprites["cmdSel"]
    iconSprites.each { |s| s.visible = false }
    pbHideCmdCancelButton if @cmdCancelShown
  end

  # Wraps/replaces the Command page (Fight/Bag/Pokémon/Run) entirely
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    @activeCommandBattler = idxBattler   # which icon_party box currently bobs
    @cmdCancelWanted = (mode == 1)
    pbHideDataBoxes
    pbShowCommandBackground             # beat 1: shadow + spinning ball fade in
    pbShowCommandPrompt(texts[0].gsub("\n", " "))   # beat 2 (ball bar + party balls) + beat 3 (box+buttons+icons)

    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)

    currentKey = CMD_INDEX_TO_KEY[cw.index] || "fight"
    cw.index = CMD_KEY_TO_INDEX[currentKey]
    pbUpdateCommandButtonOpacity(currentKey)

    pbSyncCmdCancelButton

    ret = -1
    loop do
      oldKey = currentKey
      pbUpdate(cw)

      if Input.trigger?(Input::UP)
        currentKey = "fight"
      elsif Input.trigger?(Input::DOWN)
        currentKey = "run" if currentKey == "fight"
      elsif Input.trigger?(Input::LEFT) && currentKey == "fight"
        currentKey = "bag"   # drops straight down into the row's left end, same as Down always landing on run
      elsif Input.trigger?(Input::RIGHT) && currentKey == "fight"
        currentKey = "pokemon"   # ...and the row's right end
      elsif Input.trigger?(Input::LEFT) && currentKey != "fight"
        idx = CMD_ROW.index(currentKey)
        currentKey = CMD_ROW[(idx - 1) % CMD_ROW.length]
      elsif Input.trigger?(Input::RIGHT) && currentKey != "fight"
        idx = CMD_ROW.index(currentKey)
        currentKey = CMD_ROW[(idx + 1) % CMD_ROW.length]
      end
      if currentKey != oldKey
        cw.index = CMD_KEY_TO_INDEX[currentKey]
        pbUpdateCommandButtonOpacity(currentKey)
        pbPlayCursorSE
      end

      clickedKey = nil
      clickedCmdCancel = false
      if Mouse.active? && Mouse.click?
        CMD_BUTTON_POS.each_key do |key|
          clickedKey = key if Mouse.over?(@sprites["cmdBtn_#{key}"])
        end
        clickedCmdCancel = mode == 1 && @cmdCancelShown && Mouse.over?(@sprites["bagUI_cancel"])
      end

      if Input.trigger?(Input::USE) || clickedKey
        if clickedKey
          currentKey = clickedKey
          cw.index = CMD_KEY_TO_INDEX[currentKey]
          pbUpdateCommandButtonOpacity(currentKey)
        end
        pbPlayDecisionSE
        pbHideCommandPageAssets if currentKey == "run"
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif (Input.trigger?(Input::BACK) && mode == 1) || clickedCmdCancel
        pbPlayCancelSE
        pbFlashCmdCancelButton
        pbHideCmdCancelButton
        break
      elsif Input.trigger?(Input::F9) && $DEBUG
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    pbShowDataBoxes
    return ret
  end

  def pbShowCommandButtons(selectedKey)
    CMD_BUTTON_POS.each_key do |key|
      sprite = @sprites["cmdBtn_#{key}"]
      next if !sprite
      sprite.opacity = 0
      sprite.visible = true
    end
    iconSprites = pbBattlerIconSprites
    iconSprites.each { |s| s.opacity = 0; s.visible = true }
    COMMAND_BUTTON_FADE_FRAMES.times do |frame|
      progress = (frame + 1) / COMMAND_BUTTON_FADE_FRAMES.to_f
      CMD_BUTTON_POS.each_key do |key|
        sprite = @sprites["cmdBtn_#{key}"]
        sprite.opacity = (CMD_BUTTON_OPACITY_NORMAL * progress).to_i if sprite
      end
      iconSprites.each { |s| s.opacity = (255 * progress).to_i }
      pbUpdate
    end
    CMD_BUTTON_POS.each_key { |key| @sprites["cmdBtn_#{key}"].opacity = CMD_BUTTON_OPACITY_NORMAL if @sprites["cmdBtn_#{key}"] }
    iconSprites.each { |s| s.opacity = 255 }
    pbUpdateCommandButtonOpacity(selectedKey)
  end

  def pbFightIndexEnabled?(key, battler)
    return true if key == "summary" || key == "cancel"
    idx = FIGHT_MOVE_KEYS.index(key)
    return battler.moves[idx] && battler.moves[idx].id ? true : false
  end

  # Bakes a single move button
  def pbBuildFightButtonBitmap(battler, idx)
    move = battler.moves[idx]
    if move && move.id
      typeFile = move.type.to_s.downcase
      path = FIGHT_BUTTON_GRAPHICS_PATH + typeFile + ".png"
      path = FIGHT_BUTTON_GRAPHICS_PATH + "unknown.png" if !FileTest.exist?(path)
    else
      path = FIGHT_BUTTON_GRAPHICS_PATH + "empty.png"
    end
    base = Bitmap.new(path)
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    if move && move.id
      pbSetSystemFont(bmp)
      text_w = bmp.text_size(move.name).width
      left_x = (bmp.width / 2) - (text_w / 2)
      left_x -= 1 if left_x.odd?
      left_x = 0 if left_x < 0
      pp_text = _INTL("PP {1}/{2}", move.pp, battler.pokemon.moves[idx].totalpp)
      pbDrawTextPositions(bmp, [
        [move.name, left_x, FIGHT_MOVE_NAME_Y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [pp_text, FIGHT_MOVE_PP_POS[0], FIGHT_MOVE_PP_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
      ])
    end
    return bmp
  end

  # Builds/rebakes the four move buttons plus the summary button
  def pbBuildFightButtons(battler)
    pbBuildBagUI
    FIGHT_MOVE_KEYS.each_with_index do |key, idx|
      spriteKey = "fightBtn_#{key}"
      if !@sprites[spriteKey]
        @sprites[spriteKey] = IconSprite.new(@viewport)
        @sprites[spriteKey].z = Z_COMMAND_BUTTON
        @sprites[spriteKey].x, @sprites[spriteKey].y = FIGHT_MOVE_POS[key]
        @sprites[spriteKey].opacity = 0
        @sprites[spriteKey].visible = false
      end
      @sprites[spriteKey].bitmap&.dispose
      @sprites[spriteKey].bitmap = pbBuildFightButtonBitmap(battler, idx)
    end
    if !@sprites["fightBtn_summary"]
      @sprites["fightBtn_summary"] = IconSprite.new(@viewport)
      @sprites["fightBtn_summary"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + FIGHT_SUMMARY_FILE + ".png")
      @sprites["fightBtn_summary"].z = Z_COMMAND_BUTTON
      @sprites["fightBtn_summary"].x, @sprites["fightBtn_summary"].y = FIGHT_SUMMARY_POS
      @sprites["fightBtn_summary"].opacity = 0
      @sprites["fightBtn_summary"].visible = false
    end
  end

  def pbUpdateFightButtonOpacity(selectedKey)
    (FIGHT_MOVE_KEYS + ["summary"]).each do |key|
      sprite = @sprites["fightBtn_#{key}"]
      next if !sprite
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdateFightSelector(selectedKey)
  end

  # Moves/re-skins the Fight page's own highlight
  def pbUpdateFightSelector(selectedKey)
    if !@sprites["fightSel"]
      @sprites["fightSel"] = IconSprite.new(@viewport)
      @sprites["fightSel"].z = Z_COMMAND_SELECTOR
      @sprites["fightSel"].visible = false
      @fightSelFile  = nil
      @fightSelFrame = 0
      @fightSelTick  = 0
    end
    sel = @sprites["fightSel"]
    file = FIGHT_SEL_FILES[selectedKey]
    if @fightSelFile != file
      selPath = (selectedKey == "summary") ? FIGHT_SUMMARY_GRAPHICS_PATH : Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH
      sel.setBitmap(selPath + file + ".png")
      frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @fightSelFile  = file
      @fightSelFrame = 0
      @fightSelTick  = 0
    end
    pos = case selectedKey
          when "cancel"  then BAG_UI_POS["cancel"]
          when "summary" then FIGHT_SUMMARY_POS
          else FIGHT_MOVE_POS[selectedKey]
          end
    offset = FIGHT_SEL_OFFSET[selectedKey]
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @fightSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  def pbAnimateFightSelector
    sel = @sprites["fightSel"]
    return if !sel || !sel.visible
    @fightSelTick += 1
    return if @fightSelTick < SEL_ANIM_SPEED
    @fightSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @fightSelFrame = (@fightSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @fightSelFrame * frameHeight
  end

  # Entrance for the Fight page
  def pbShowFightButtons(battler, landOnKey)
    pbBuildFightButtons(battler)
    pbSEPlay("SlideUp", 60)
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true
    fadeKeys = FIGHT_MOVE_KEYS + ["summary"]
    fadeKeys.each do |key|
      sprite = @sprites["fightBtn_#{key}"]
      sprite.opacity = 0
      sprite.visible = true
    end
    pbUpdateFightSelector(landOnKey)
    sel = @sprites["fightSel"]
    selRestX = sel.x
    slideSelWithCancel = (landOnKey == "cancel")
    sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0] if slideSelWithCancel
    sel.opacity = 0
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      fadeKeys.each { |key| @sprites["fightBtn_#{key}"].opacity = (CMD_BUTTON_OPACITY_NORMAL * progress).to_i }
      if slideSelWithCancel
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    cancel.x = cancelPos[0]
    cancel.opacity = CMD_BUTTON_OPACITY_NORMAL
    fadeKeys.each { |key| @sprites["fightBtn_#{key}"].opacity = CMD_BUTTON_OPACITY_NORMAL }
    sel.x = selRestX
    sel.opacity = 255
    pbUpdateFightButtonOpacity(landOnKey)
  end

  def pbHideFightButtons
    return if !@sprites["bagUI_cancel"] || !@sprites["bagUI_cancel"].visible
    pbSEPlay("SlideDown", 60)
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancelStartOpacity = cancel ? cancel.opacity : 0
    fadeKeys = FIGHT_MOVE_KEYS + ["summary"]
    startOpacity = {}
    fadeKeys.each { |key| startOpacity[key] = @sprites["fightBtn_#{key}"].opacity if @sprites["fightBtn_#{key}"] }
    sel = @sprites["fightSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    # Same idea as the entrance - only slides out with cancel if that's
    # what it's currently bound to, otherwise just fades like its button.
    slideSelWithCancel = sel && @fightSelKey == "cancel"
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      fadeKeys.each do |key|
        sprite = @sprites["fightBtn_#{key}"]
        next if !sprite
        sprite.opacity = (startOpacity[key] * (1 - progress)).to_i
      end
      if sel
        if slideSelWithCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    cancel.visible = false if cancel
    cancel.z = Z_BAG_UI if cancel   # back to its normal tier, off the message box
    fadeKeys.each { |key| @sprites["fightBtn_#{key}"].visible = false if @sprites["fightBtn_#{key}"] }
    sel.visible = false if sel
  end

  def pbFlashFightSummaryButton
    sprite = @sprites["fightBtn_summary"]
    return if !sprite
    folder = FIGHT_SUMMARY_GRAPHICS_PATH
    2.times do
      sprite.setBitmap(folder + "icon_summary_p.png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
      sprite.setBitmap(folder + FIGHT_SUMMARY_FILE + ".png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
    end
  end

  def pbUpdateSummaryPanelOpacity(selectedKey)
    checkMoves = @sprites["fightBtn_check_moves"]
    checkMoves.opacity = (selectedKey == "check_moves") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if checkMoves
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdateSummaryPanelSelector(selectedKey)
  end

  def pbUpdateSummaryPanelSelector(selectedKey)
    if !@sprites["summaryPanelSel"]
      @sprites["summaryPanelSel"] = IconSprite.new(@viewport)
      @sprites["summaryPanelSel"].visible = false
      @summaryPanelSelFile  = nil
      @summaryPanelSelFrame = 0
      @summaryPanelSelTick  = 0
    end
    sel = @sprites["summaryPanelSel"]
    file = (selectedKey == "cancel") ? FIGHT_SEL_FILES["cancel"] : FIGHT_SEL_FILES["summary"]
    path = (selectedKey == "cancel") ? Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH : FIGHT_SUMMARY_GRAPHICS_PATH
    if @summaryPanelSelFile != file
      sel.setBitmap(path + file + ".png")
      frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @summaryPanelSelFile  = file
      @summaryPanelSelFrame = 0
      @summaryPanelSelTick  = 0
    end
    pos = (selectedKey == "cancel") ? BAG_UI_POS["cancel"] : FIGHT_CHECK_MOVES_POS
    offset = (selectedKey == "cancel") ? FIGHT_SEL_OFFSET["cancel"] : FIGHT_SEL_OFFSET["summary"]
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @summaryPanelSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  def pbAnimateSummaryPanelSelector
    sel = @sprites["summaryPanelSel"]
    return if !sel || !sel.visible
    @summaryPanelSelTick += 1
    return if @summaryPanelSelTick < SEL_ANIM_SPEED
    @summaryPanelSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @summaryPanelSelFrame = (@summaryPanelSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @summaryPanelSelFrame * frameHeight
  end

  def pbFlashSummaryPanelCheckMovesButton
    sprite = @sprites["fightBtn_check_moves"]
    return if !sprite
    folder = FIGHT_SUMMARY_GRAPHICS_PATH
    2.times do
      sprite.setBitmap(folder + FIGHT_CHECK_MOVES_FILE + "_p.png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
      sprite.setBitmap(folder + FIGHT_CHECK_MOVES_FILE + ".png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
    end
  end

  # Moves summary page

  def pbBuildMovesPanelIcon(pkmn)
    @sprites["movesPanelIcon"]&.dispose
    @sprites["movesPanelIcon"] = PokemonIconSprite.new(pkmn, @viewport)
    icon = @sprites["movesPanelIcon"]
    icon.x = SUMMARY_PANEL_RESTING_POS[0] + SUMMARY_ICON_OFFSET[0]
    icon.y = SUMMARY_PANEL_RESTING_POS[1] + SUMMARY_ICON_OFFSET[1]
    icon.z = Z_SUMMARY_PANEL + 1
    icon.visible = false
  end

  def pbAnimateMovesPanelIcon
    icon = @sprites["movesPanelIcon"]
    icon.update if icon && icon.visible
  end

  # Bakes name/gender/type icons onto party_moves_panel.png
  def pbBuildMovesPanelInfo(battler)
    pkmn = battler.pokemon
    if !@sprites["movesPanelInfo"]
      @sprites["movesPanelInfo"] = IconSprite.new(@viewport)
      @sprites["movesPanelInfo"].x = SUMMARY_PANEL_RESTING_POS[0]
      @sprites["movesPanelInfo"].y = SUMMARY_PANEL_RESTING_POS[1]
      @sprites["movesPanelInfo"].z = Z_SUMMARY_PANEL + 1
      @sprites["movesPanelInfo"].visible = false
    end
    info = @sprites["movesPanelInfo"]
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + MOVES_PANEL_FILE + ".png")
    bmp = Bitmap.new(base.width, base.height)
    base.dispose
    pbSetSystemFont(bmp)

    texts = []
    texts << [pkmn.name, SUMMARY_NAME_POS[0], SUMMARY_NAME_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    if pkmn.gender != 2   # 0 = male, 1 = female, 2 = genderless (no symbol)
      genderText  = (pkmn.gender == 0) ? "♂" : "♀"
      genderColor = (pkmn.gender == 0) ? SUMMARY_GENDER_MALE_COLOR : SUMMARY_GENDER_FEMALE_COLOR
      texts << [genderText, SUMMARY_GENDER_POS[0], SUMMARY_GENDER_POS[1], :left, genderColor, BAG_UI_TEXT_SHADOW_COLOR]
    end
    pbDrawTextPositions(bmp, texts)
    pbDrawSummaryTypeIcons(bmp, pkmn)   # same sheet/positions as the Summary panel

    info.bitmap&.dispose
    info.bitmap = bmp

    pbBuildMovesPanelIcon(pkmn)
  end

  # Wraps text within MOVES_DESC_MAX_WIDTH
  def pbDrawMovesDescription(bmp, text)
    return if !text || text.empty?
    words = text.split(" ")
    lines = []
    currentLine = ""
    words.each do |word|
      candidate = currentLine.empty? ? word : "#{currentLine} #{word}"
      if !currentLine.empty? && bmp.text_size(candidate).width > MOVES_DESC_MAX_WIDTH
        lines << currentLine
        currentLine = word
      else
        currentLine = candidate
      end
    end
    lines << currentLine if !currentLine.empty?
    lineHeight = bmp.text_size("Wg").height + 2
    positions = lines.each_with_index.map do |line, i|
      [line, MOVES_DESC_POS[0], MOVES_DESC_POS[1] + (i * lineHeight),
       :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    end
    pbDrawTextPositions(bmp, positions)
  end

  def pbBuildMovesPanelMoveInfo(battler, moveIdx = 0)
    if !@sprites["movesPanelMoveInfo"]
      @sprites["movesPanelMoveInfo"] = IconSprite.new(@viewport)
      @sprites["movesPanelMoveInfo"].x = SUMMARY_PANEL_RESTING_POS[0]
      @sprites["movesPanelMoveInfo"].y = SUMMARY_PANEL_RESTING_POS[1]
      @sprites["movesPanelMoveInfo"].z = Z_SUMMARY_PANEL + 1
      @sprites["movesPanelMoveInfo"].visible = false
    end
    moveInfo = @sprites["movesPanelMoveInfo"]
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + MOVES_PANEL_FILE + ".png")
    bmp = Bitmap.new(base.width, base.height)
    base.dispose
    move = battler.moves[moveIdx]
    if move && move.id
      pbSetSystemFont(bmp)
      ppText = "#{move.pp}/#{battler.pokemon.moves[moveIdx].totalpp}"
      # move.category is the raw 0/1/2 Physical/Special/Status value (no
      # pbIsPhysical?/pbIsSpecial?/pbIsStatus? helpers on Battle::Move).
      categoryText = case move.category
                     when 0 then _INTL("Physical")
                     when 1 then _INTL("Special")
                     else _INTL("Status")
                     end
      powerText = (move.power > 0) ? move.power.to_s : "---"   # baseDamage is deprecated as of v21.1
      accuracyText = (move.accuracy > 0) ? move.accuracy.to_s : "---"
      texts = [
        [move.name, MOVES_NAME_POS[0], MOVES_NAME_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [MOVES_PP_LABEL, MOVES_PP_LABEL_POS[0], MOVES_PP_LABEL_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [ppText, MOVES_PP_VALUE_POS[0], MOVES_PP_VALUE_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [MOVES_CATEGORY_LABEL, MOVES_CATEGORY_LABEL_POS[0], MOVES_CATEGORY_LABEL_POS[1], :left,
         BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [categoryText, MOVES_CATEGORY_VALUE_POS[0], MOVES_CATEGORY_VALUE_POS[1], :left,
         BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [MOVES_POWER_LABEL, MOVES_POWER_LABEL_POS[0], MOVES_POWER_LABEL_POS[1], :left,
         BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [powerText, MOVES_POWER_VALUE_POS[0], MOVES_POWER_VALUE_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [MOVES_ACCURACY_LABEL, MOVES_ACCURACY_LABEL_POS[0], MOVES_ACCURACY_LABEL_POS[1], :left,
         BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
        [accuracyText, MOVES_ACCURACY_VALUE_POS[0], MOVES_ACCURACY_VALUE_POS[1], :left,
         BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
      ]
      pbDrawTextPositions(bmp, texts)
      pbDrawMovesDescription(bmp, GameData::Move.get(move.id).description)
      sheet = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + SUMMARY_TYPE_ICON_FILE + ".png")
      w, h = SUMMARY_TYPE_ICON_SIZE
      row = GameData::Type.get(move.type).icon_position
      bmp.blt(MOVES_TYPE_ICON_POS[0], MOVES_TYPE_ICON_POS[1], sheet, Rect.new(0, row * h, w, h))
      sheet.dispose
      # Category icon
      categorySheet = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + MOVES_CATEGORY_ICON_FILE + ".png")
      cw, ch = MOVES_CATEGORY_ICON_SIZE
      bmp.blt(MOVES_CATEGORY_ICON_POS[0], MOVES_CATEGORY_ICON_POS[1], categorySheet,
              Rect.new(0, move.category * ch, cw, ch))
      categorySheet.dispose
    end
    moveInfo.bitmap&.dispose
    moveInfo.bitmap = bmp
  end

  # Whether the Pokemon actually has a move in a given slot
  def pbMovesSlotEnabled?(key, battler)
    idx = MOVES_SLOT_KEYS.index(key)
    return false if !idx
    move = battler.moves[idx]
    return move && move.id ? true : false
  end

  # Builds a button for every occupied slot
  def pbBuildMovesSlotButtons(battler)
    MOVES_SLOT_KEYS.each do |key|
      spriteKey = "movesSlot_#{key}"
      if pbMovesSlotEnabled?(key, battler)
        if !@sprites[spriteKey]
          @sprites[spriteKey] = IconSprite.new(@viewport)
          @sprites[spriteKey].setBitmap(MOVES_SLOT_GRAPHICS_PATH + MOVES_SLOT_FILE + ".png")
          @sprites[spriteKey].z = Z_COMMAND_BUTTON
          @sprites[spriteKey].x, @sprites[spriteKey].y = MOVES_SLOT_POS[key]
          @sprites[spriteKey].opacity = 0
          @sprites[spriteKey].visible = false
        end
      elsif @sprites[spriteKey]
        @sprites[spriteKey].dispose
        @sprites.delete(spriteKey)
      end
    end
  end

  def pbMovesSlotButtonSprites
    return MOVES_SLOT_KEYS.filter_map { |key| @sprites["movesSlot_#{key}"] }
  end

  # Opacity scheme covers both the slot buttons and cancel - same shape as
  # pbUpdateSummaryPanelOpacity/pbUpdateFightButtonOpacity.
  def pbUpdateMovesPanelOpacity(selectedKey)
    MOVES_SLOT_KEYS.each do |key|
      sprite = @sprites["movesSlot_#{key}"]
      next if !sprite
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdateMovesPanelSelector(selectedKey)
  end

  # move_slot_sel for a slot, cancel's own Bag UI highlight for cancel - same
  # idea as pbUpdateFightSelector.
  def pbUpdateMovesPanelSelector(selectedKey)
    if !@sprites["movesPanelSel"]
      @sprites["movesPanelSel"] = IconSprite.new(@viewport)
      @sprites["movesPanelSel"].visible = false
      @movesPanelSelFile  = nil
      @movesPanelSelFrame = 0
      @movesPanelSelTick  = 0
    end
    sel = @sprites["movesPanelSel"]
    file = (selectedKey == "cancel") ? FIGHT_SEL_FILES["cancel"] : MOVES_SLOT_SEL_FILE
    path = (selectedKey == "cancel") ? Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH : MOVES_SLOT_GRAPHICS_PATH
    if @movesPanelSelFile != file
      sel.setBitmap(path + file + ".png")
      if selectedKey == "cancel"
        frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
        sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      else
        sel.src_rect.set(0, 0, sel.bitmap.width, sel.bitmap.height)
      end
      @movesPanelSelFile  = file
      @movesPanelSelFrame = 0
      @movesPanelSelTick  = 0
    end
    pos = (selectedKey == "cancel") ? BAG_UI_POS["cancel"] : MOVES_SLOT_POS[selectedKey]
    offset = (selectedKey == "cancel") ? FIGHT_SEL_OFFSET["cancel"] : [0, 0]
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @movesPanelSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  # Non-wrapping 2x2 grid nav
  def pbMovesPanelNextKey(currentKey, dRow, dCol, battler)
    if currentKey == "cancel"
      return currentKey if dCol != -1
      return @movesPanelLastSlotKey if @movesPanelLastSlotKey && pbMovesSlotEnabled?(@movesPanelLastSlotKey, battler)
      return MOVES_SLOT_KEYS.find { |key| pbMovesSlotEnabled?(key, battler) } || currentKey
    end
    pos = MOVES_SLOT_GRID[currentKey]
    return currentKey if !pos
    row, col = pos
    return "cancel" if dCol == 1 && col == 1
    if dCol != 0
      partnerKey = MOVES_SLOT_GRID.key([row, col + dCol])
      return (partnerKey && pbMovesSlotEnabled?(partnerKey, battler)) ? partnerKey : currentKey
    elsif dRow != 0
      partnerKey = MOVES_SLOT_GRID.key([row + dRow, col])
      return (partnerKey && pbMovesSlotEnabled?(partnerKey, battler)) ? partnerKey : currentKey
    end
    return currentKey
  end

  def pbAnimateMovesPanelSelector
    sel = @sprites["movesPanelSel"]
    return if !sel || !sel.visible
    return if @movesPanelSelKey != "cancel"   # move_slot_sel is a single still frame - nothing to step
    @movesPanelSelTick += 1
    return if @movesPanelSelTick < SEL_ANIM_SPEED
    @movesPanelSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @movesPanelSelFrame = (@movesPanelSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @movesPanelSelFrame * frameHeight
  end

  # Entrance
  def pbShowMovesPanel(selectedKey, battler)
    pbBuildMovesPanelInfo(battler)      # rebuilt every time, so it's never stale
    pbBuildMovesSlotButtons(battler)
    moveIdx = MOVES_SLOT_KEYS.index(selectedKey) || 0
    pbBuildMovesPanelMoveInfo(battler, moveIdx)
    if !@sprites["movesPanel"]
      @sprites["movesPanel"] = IconSprite.new(@viewport)
      @sprites["movesPanel"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + MOVES_PANEL_FILE + ".png")
      @sprites["movesPanel"].z = Z_SUMMARY_PANEL
      @sprites["movesPanel"].x = SUMMARY_PANEL_RESTING_POS[0]
      @sprites["movesPanel"].visible = false
    end
    pbSEPlay("SlideUp", 60)
    panel = @sprites["movesPanel"]
    panelRestY = SUMMARY_PANEL_RESTING_POS[1]
    panel.y = -panel.bitmap.height
    panel.visible = true

    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true

    slotSprites = pbMovesSlotButtonSprites
    slotSprites.each { |sprite| sprite.opacity = 0; sprite.visible = true }

    pbUpdateMovesPanelSelector(selectedKey)
    sel = @sprites["movesPanelSel"]
    selRestX, selRestY = sel.x, sel.y
    slideSelWithCancel = (selectedKey == "cancel")
    sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0] if slideSelWithCancel
    sel.opacity = 0

    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      panel.y = -panel.bitmap.height + ((panelRestY - (-panel.bitmap.height)) * progress)
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      slotSprites.each { |sprite| sprite.opacity = (CMD_BUTTON_OPACITY_NORMAL * progress).to_i }
      if slideSelWithCancel
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    panel.y = panelRestY
    cancel.x = cancelPos[0]
    slotSprites.each { |sprite| sprite.opacity = CMD_BUTTON_OPACITY_NORMAL }
    sel.x, sel.y = selRestX, selRestY
    sel.opacity = 255
    pbUpdateMovesPanelOpacity(selectedKey)
    @sprites["movesPanelInfo"].visible = true if @sprites["movesPanelInfo"]
    @sprites["movesPanelIcon"].visible = true if @sprites["movesPanelIcon"]
    @sprites["movesPanelMoveInfo"].visible = true if @sprites["movesPanelMoveInfo"]
  end

  # Reverse of pbShowMovesPanel.
  def pbHideMovesPanel
    pbSEPlay("SlideDown", 60)
    @sprites["movesPanelInfo"].visible = false if @sprites["movesPanelInfo"]
    @sprites["movesPanelIcon"].visible = false if @sprites["movesPanelIcon"]
    @sprites["movesPanelMoveInfo"].visible = false if @sprites["movesPanelMoveInfo"]
    panel = @sprites["movesPanel"]
    cancel = @sprites["bagUI_cancel"]
    panelRestY = SUMMARY_PANEL_RESTING_POS[1]
    cancelPos = BAG_UI_POS["cancel"]
    cancelStartOpacity = cancel ? cancel.opacity : 0
    slotSprites = pbMovesSlotButtonSprites
    slotStartOpacity = {}
    slotSprites.each { |sprite| slotStartOpacity[sprite] = sprite.opacity }
    sel = @sprites["movesPanelSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selBoundToCancel = sel && @movesPanelSelKey == "cancel"
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      panel.y = panelRestY + ((-panel.bitmap.height - panelRestY) * progress) if panel
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      slotSprites.each { |sprite| sprite.opacity = (slotStartOpacity[sprite] * (1 - progress)).to_i }
      if sel
        if selBoundToCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    panel.visible = false if panel
    if cancel
      cancel.visible = false
      cancel.z = Z_BAG_UI
    end
    slotSprites.each { |sprite| sprite.visible = false }
    sel.visible = false if sel
  end

  # This page's own input loop
  def pbMovesPanelMenu(battler)
    currentKey = MOVES_SLOT_KEYS.find { |key| pbMovesSlotEnabled?(key, battler) } || "cancel"
    @movesPanelLastSlotKey = currentKey if currentKey != "cancel"
    pbShowMovesPanel(currentKey, battler)
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbMovesPanelNextKey(currentKey, dRow, dCol, battler)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        # Keyboard-only - a mouse click never updates this
        @movesPanelLastSlotKey = currentKey if currentKey != "cancel"
        pbUpdateMovesPanelOpacity(currentKey)
        pbBuildMovesPanelMoveInfo(battler, MOVES_SLOT_KEYS.index(currentKey)) if currentKey != "cancel"
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        MOVES_SLOT_KEYS.each do |key|
          sprite = @sprites["movesSlot_#{key}"]
          clickedKey = key if sprite && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey   # mouse clicks don't touch @movesPanelLastSlotKey - keyboard-only
        pbUpdateMovesPanelOpacity(currentKey)
        pbBuildMovesPanelMoveInfo(battler, MOVES_SLOT_KEYS.index(currentKey)) if currentKey != "cancel"
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideMovesPanel
        break
      end
      # Confirming a move slot doesn't lead anywhere yet beyond what
      # navigating there already does
    end
  end

  # Entrance for the Summary panel
  def pbShowSummaryPanel(selectedKey, battler)
    pbBuildSummaryPanelInfo(battler)   # rebuilt every time, so it's never stale
    if !@sprites["summaryPanel"]
      @sprites["summaryPanel"] = IconSprite.new(@viewport)
      @sprites["summaryPanel"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + SUMMARY_PANEL_FILE + ".png")
      @sprites["summaryPanel"].z = Z_SUMMARY_PANEL
      @sprites["summaryPanel"].x = SUMMARY_PANEL_RESTING_POS[0]
      @sprites["summaryPanel"].visible = false
    end
    if !@sprites["fightBtn_check_moves"]
      @sprites["fightBtn_check_moves"] = IconSprite.new(@viewport)
      @sprites["fightBtn_check_moves"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + FIGHT_CHECK_MOVES_FILE + ".png")
      @sprites["fightBtn_check_moves"].z = Z_COMMAND_BUTTON
      @sprites["fightBtn_check_moves"].x = FIGHT_CHECK_MOVES_POS[0]
      @sprites["fightBtn_check_moves"].visible = false
    end
    pbSEPlay("SlideUp", 60)
    panel = @sprites["summaryPanel"]
    panelRestY = SUMMARY_PANEL_RESTING_POS[1]
    panel.y = -panel.bitmap.height
    panel.visible = true

    checkMoves = @sprites["fightBtn_check_moves"]
    checkMovesRestY = FIGHT_CHECK_MOVES_POS[1]
    checkMoves.y = Graphics.height
    checkMoves.opacity = 0
    checkMoves.visible = true

    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true

    pbUpdateSummaryPanelSelector(selectedKey)
    sel = @sprites["summaryPanelSel"]
    selRestX = sel.x
    selRestY = sel.y
    if selectedKey == "cancel"
      sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]
    else
      sel.y = Graphics.height + FIGHT_SEL_OFFSET["summary"][1]
    end
    sel.opacity = 0

    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      panel.y = -panel.bitmap.height + ((panelRestY - (-panel.bitmap.height)) * progress)
      checkMoves.y = Graphics.height + ((checkMovesRestY - Graphics.height) * progress)
      checkMoves.opacity = (255 * progress).to_i
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      if selectedKey == "cancel"
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      else
        sel.y = (Graphics.height + FIGHT_SEL_OFFSET["summary"][1]) +
                ((selRestY - (Graphics.height + FIGHT_SEL_OFFSET["summary"][1])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    panel.y = panelRestY
    checkMoves.y = checkMovesRestY
    cancel.x = cancelPos[0]
    sel.x = selRestX
    sel.y = selRestY
    sel.opacity = 255
    pbUpdateSummaryPanelOpacity(selectedKey)
    @sprites["summaryPanelInfo"].visible = true if @sprites["summaryPanelInfo"]
    @sprites["summaryPanelIcon"].visible = true if @sprites["summaryPanelIcon"]
  end

  def pbHideSummaryPanel
    pbSEPlay("SlideDown", 60)
    @sprites["summaryPanelInfo"].visible = false if @sprites["summaryPanelInfo"]
    @sprites["summaryPanelIcon"].visible = false if @sprites["summaryPanelIcon"]
    panel = @sprites["summaryPanel"]
    checkMoves = @sprites["fightBtn_check_moves"]
    cancel = @sprites["bagUI_cancel"]
    panelRestY = SUMMARY_PANEL_RESTING_POS[1]
    checkMovesRestY = FIGHT_CHECK_MOVES_POS[1]
    cancelPos = BAG_UI_POS["cancel"]
    cancelStartOpacity = cancel ? cancel.opacity : 0
    checkMovesStartOpacity = checkMoves ? checkMoves.opacity : 0
    sel = @sprites["summaryPanelSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selStartY = sel ? sel.y : nil
    selBoundToCancel = sel && @summaryPanelSelKey == "cancel"
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      panel.y = panelRestY + ((-panel.bitmap.height - panelRestY) * progress) if panel
      if checkMoves
        checkMoves.y = checkMovesRestY + ((Graphics.height - checkMovesRestY) * progress)
        checkMoves.opacity = (checkMovesStartOpacity * (1 - progress)).to_i
      end
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      if sel
        if selBoundToCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        else
          sel.y = selStartY + (((Graphics.height + FIGHT_SEL_OFFSET["summary"][1]) - selStartY) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    panel.visible = false if panel
    checkMoves.visible = false if checkMoves
    if cancel
      cancel.visible = false
      cancel.z = Z_BAG_UI
    end
    sel.visible = false if sel
  end

  # Exp still needed to reach the next level
  def pbSummaryExpToNextLevel(pkmn)
    return 0 if pkmn.level >= GameData::GrowthRate.max_level
    growth = GameData::GrowthRate.get(pkmn.species_data.growth_rate)
    nextLevelExp = growth.minimum_exp_for_level(pkmn.level + 1)
    return [nextLevelExp - pkmn.exp, 0].max
  rescue NoMethodError
    return 0
  end

  def pbDrawSummaryAbilityDescription(bmp, text)
    return if !text || text.empty?
    words = text.split(" ")
    lines = []
    currentLine = ""
    words.each do |word|
      candidate = currentLine.empty? ? word : "#{currentLine} #{word}"
      if !currentLine.empty? && bmp.text_size(candidate).width > SUMMARY_ABILITY_DESC_MAX_WIDTH
        lines << currentLine
        currentLine = word
      else
        currentLine = candidate
      end
    end
    lines << currentLine if !currentLine.empty?
    lineHeight = bmp.text_size("Wg").height + 2
    positions = lines.each_with_index.map do |line, i|
      [line, SUMMARY_ABILITY_DESC_POS[0], SUMMARY_ABILITY_DESC_POS[1] + (i * lineHeight),
       :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    end
    pbDrawTextPositions(bmp, positions)
  end

  # Blits each of the Pokemon's types onto the overlay
  def pbDrawSummaryTypeIcons(bmp, pkmn)
    sheet = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + SUMMARY_TYPE_ICON_FILE + ".png")
    w, h = SUMMARY_TYPE_ICON_SIZE
    pkmn.types.each_with_index do |type, i|
      pos = SUMMARY_TYPE_ICON_POS[i]
      next if !pos
      row = GameData::Type.get(type).icon_position
      bmp.blt(pos[0], pos[1], sheet, Rect.new(0, row * h, w, h))
    end
    sheet.dispose
  end

  # icon_hp_overlay.png
  def pbDrawSummaryHPBar(bmp, pkmn)
    frame = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + SUMMARY_HP_OVERLAY_FILE + ".png")
    bmp.blt(SUMMARY_HP_OVERLAY_POS[0], SUMMARY_HP_OVERLAY_POS[1], frame, frame.rect)
    frame.dispose

    hpFraction = pbBattlerHPFraction(pkmn)
    hpBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "icon_overlay_hp.png")
    hpRow = (hpFraction > 0.5) ? 0 : (hpFraction > 0.2) ? 1 : 2
    hpWidth = (hpBase.width * hpFraction).round
    if hpWidth > 0
      bmp.blt(SUMMARY_HP_BAR_POS[0], SUMMARY_HP_BAR_POS[1], hpBase, Rect.new(0, hpRow * 4, hpWidth, 4))
    end
    hpBase.dispose
  end

  # Exp progress bar
  def pbDrawSummaryExpBar(bmp, pkmn)
    fraction = pbBattlerExpFraction(pkmn)
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + SUMMARY_EXP_BAR_FILE + ".png")
    width = (base.width * fraction).round
    bmp.blt(SUMMARY_EXP_BAR_POS[0], SUMMARY_EXP_BAR_POS[1], base, Rect.new(0, 0, width, base.height)) if width > 0
    base.dispose
  end

  # The selected Pokemon's own icon
  def pbBuildSummaryPanelIcon(pkmn)
    @sprites["summaryPanelIcon"]&.dispose
    @sprites["summaryPanelIcon"] = PokemonIconSprite.new(pkmn, @viewport)
    icon = @sprites["summaryPanelIcon"]
    icon.x = SUMMARY_PANEL_RESTING_POS[0] + SUMMARY_ICON_OFFSET[0]
    icon.y = SUMMARY_PANEL_RESTING_POS[1] + SUMMARY_ICON_OFFSET[1]
    icon.z = Z_SUMMARY_PANEL + 1
    icon.visible = false
  end

  # Steps the Pokemon icon's own animation
  def pbAnimateSummaryPanelIcon
    icon = @sprites["summaryPanelIcon"]
    icon.update if icon && icon.visible
  end

  # Bakes the Summary panel's whole detail overlay
  def pbBuildSummaryPanelInfo(battler)
    pkmn = battler.pokemon
    if !@sprites["summaryPanelInfo"]
      @sprites["summaryPanelInfo"] = IconSprite.new(@viewport)
      @sprites["summaryPanelInfo"].x = SUMMARY_PANEL_RESTING_POS[0]
      @sprites["summaryPanelInfo"].y = SUMMARY_PANEL_RESTING_POS[1]
      @sprites["summaryPanelInfo"].z = Z_SUMMARY_PANEL + 1
      @sprites["summaryPanelInfo"].visible = false
    end
    info = @sprites["summaryPanelInfo"]
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + SUMMARY_PANEL_FILE + ".png")
    bmp = Bitmap.new(base.width, base.height)
    base.dispose
    pbSetSystemFont(bmp)

    texts = []
    texts << [pkmn.name, SUMMARY_NAME_POS[0], SUMMARY_NAME_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    texts << [_INTL("Lv. {1}", pkmn.level), SUMMARY_LEVEL_POS[0], SUMMARY_LEVEL_POS[1], :left,
              BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    texts << [SUMMARY_NEXT_LEVEL_LABEL, SUMMARY_NEXT_LEVEL_LABEL_POS[0], SUMMARY_NEXT_LEVEL_LABEL_POS[1], :left,
              BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    # Right-anchored to SUMMARY_NEXT_LEVEL_VALUE_RIGHT_X
    nextLevelText = pbSummaryExpToNextLevel(pkmn).to_s
    nextLevelWidth = bmp.text_size(nextLevelText).width
    nextLevelX = SUMMARY_NEXT_LEVEL_VALUE_RIGHT_X - nextLevelWidth
    nextLevelX -= 1 if nextLevelX.odd?
    nextLevelX = 0 if nextLevelX < 0
    texts << [nextLevelText, nextLevelX, SUMMARY_NEXT_LEVEL_LABEL_POS[1], :left,
              BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]

    abilityName = battler.ability ? battler.ability.name : ""
    abilityDesc = battler.ability ? battler.ability.description : ""
    texts << [abilityName, SUMMARY_ABILITY_POS[0], SUMMARY_ABILITY_POS[1], :left,
              BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]

    itemName = battler.item ? battler.item.name : SUMMARY_NO_ITEM_TEXT
    texts << [itemName, SUMMARY_ITEM_POS[0], SUMMARY_ITEM_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]

    texts << [_INTL("HP {1}/{2}", pkmn.hp, pkmn.totalhp), SUMMARY_HP_POS[0], SUMMARY_HP_POS[1], :left,
              BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]

    statValues = {
      "attack"  => pkmn.attack,
      "defense" => pkmn.defense,
      "spatk"   => pkmn.spatk,
      "spdef"   => pkmn.spdef,
      "speed"   => pkmn.speed,
    }
    SUMMARY_STAT_LABEL_POS.each_key do |key|
      labelPos = SUMMARY_STAT_LABEL_POS[key]
      valuePos = SUMMARY_STAT_VALUE_POS[key]
      texts << [SUMMARY_STAT_LABELS[key], labelPos[0], labelPos[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
      texts << [statValues[key].to_s, valuePos[0], valuePos[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
    end

    if pkmn.gender != 2   # 0 = male, 1 = female, 2 = genderless (no symbol)
      genderText  = (pkmn.gender == 0) ? "♂" : "♀"
      genderColor = (pkmn.gender == 0) ? SUMMARY_GENDER_MALE_COLOR : SUMMARY_GENDER_FEMALE_COLOR
      texts << [genderText, SUMMARY_GENDER_POS[0], SUMMARY_GENDER_POS[1], :left, genderColor, BAG_UI_TEXT_SHADOW_COLOR]
    end

    pbDrawTextPositions(bmp, texts)
    pbDrawSummaryAbilityDescription(bmp, abilityDesc)
    pbDrawSummaryTypeIcons(bmp, pkmn)
    pbDrawSummaryExpBar(bmp, pkmn)
    pbDrawSummaryHPBar(bmp, pkmn)

    info.bitmap&.dispose
    info.bitmap = bmp

    pbBuildSummaryPanelIcon(pkmn)
  end

  # Summary panel's own input loop
  def pbSummaryPanelMenu(battler, restoreCommandPrompt = true)
    currentKey = "check_moves"
    pbHideMessageBox   # "What will {1} do?" has no business showing over this page
    pbShowSummaryPanel(currentKey, battler)
    loop do
      pbUpdate

      if Input.trigger?(Input::LEFT) && currentKey != "check_moves"
        pbPlayCursorSE
        currentKey = "check_moves"
        pbUpdateSummaryPanelOpacity(currentKey)
      elsif Input.trigger?(Input::RIGHT) && currentKey != "cancel"
        pbPlayCursorSE
        currentKey = "cancel"
        pbUpdateSummaryPanelOpacity(currentKey)
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        clickedKey = "check_moves" if @sprites["fightBtn_check_moves"] && Mouse.over?(@sprites["fightBtn_check_moves"])
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey
        pbUpdateSummaryPanelOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideSummaryPanel
        if restoreCommandPrompt
          pbScrollMessageBoxIn(false)
          pbSetMessageWindowText(@lastCommandPromptText) if @lastCommandPromptText
        end
        break
      elsif confirmed && currentKey == "check_moves"
        pbPlayDecisionSE
        pbFlashSummaryPanelCheckMovesButton
        pbHideSummaryPanel
        pbMovesPanelMenu(battler)
        pbShowSummaryPanel(currentKey, battler)
      end
    end
  end

  def pbFightNextKey(currentKey, dRow, dCol, battler)
    if dCol != 0 && FIGHT_MOVE_KEYS.include?(currentKey)
      idx = FIGHT_MOVE_KEYS.index(currentKey)
      partnerKey = FIGHT_MOVE_KEYS[idx.even? ? idx + 1 : idx - 1]
      return pbFightIndexEnabled?(partnerKey, battler) ? partnerKey : currentKey
    end
    return currentKey if dRow == 0
    case currentKey
    when "move0"
      return (dRow == 1 && pbFightIndexEnabled?("move2", battler)) ? "move2" : currentKey
    when "move1"
      return (dRow == 1 && pbFightIndexEnabled?("move3", battler)) ? "move3" : currentKey
    when "move2"
      return "summary" if dRow == 1
      return pbFightIndexEnabled?("move0", battler) ? "move0" : currentKey
    when "move3"
      return "summary" if dRow == 1
      return pbFightIndexEnabled?("move1", battler) ? "move1" : currentKey
    when "summary"
      return "cancel" if dRow == 1
      return (@fightLastMoveKey && pbFightIndexEnabled?(@fightLastMoveKey, battler)) ? @fightLastMoveKey : "move0"
    when "cancel"
      return "summary" if dRow == -1
      return currentKey
    end
    return currentKey
  end

  # The Fight page's own input loop
  # TODO: Mega Evolution (Input::ACTION) and Shift (Input::SPECIAL) aren't
  # wired up yet either - megaEvoPossible is accepted but currently unused.
  def pbFightMenu(idxBattler, megaEvoPossible = false)
    battler = @battle.battlers[idxBattler]
    wasSecondBattlerOfDouble = @cmdCancelWanted
    pbHideDataBoxes
    pbHideCommandButtons   # fight/bag/run/pokemon + icon_party/icon_foe exit - message box/prompt text stay up untouched
    currentKey = (@fightLastMoveKey && pbFightIndexEnabled?(@fightLastMoveKey, battler)) ? @fightLastMoveKey : "move0"
    @fightLastMoveKey = currentKey
    pbShowFightButtons(battler, currentKey)

    result = false
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbFightNextKey(currentKey, dRow, dCol, battler)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        @fightLastMoveKey = currentKey if FIGHT_MOVE_KEYS.include?(currentKey)
        pbUpdateFightButtonOpacity(currentKey)
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        (FIGHT_MOVE_KEYS + ["summary"]).each do |key|
          sprite = @sprites["fightBtn_#{key}"]
          clickedKey = key if sprite && pbFightIndexEnabled?(key, battler) && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey   # mouse clicks don't touch @fightLastMoveKey - keyboard-only
        pbUpdateFightButtonOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        # Backing out always closes this page and returns to the Command
        # menu
        yield(-1)
        pbHideFightButtons
        result = false
        break
      elsif confirmed && currentKey == "summary"
        pbPlayDecisionSE
        pbFlashFightSummaryButton
        pbHideFightButtons
        pbSummaryPanelMenu(battler)
        pbShowFightButtons(battler, currentKey)
      elsif confirmed
        pbPlayDecisionSE
        if yield FIGHT_MOVE_KEYS.index(currentKey)
          pbHideFightButtons
          result = true
          break
        end
      end
    end

    if result && (@battle.singleBattle? || wasSecondBattlerOfDouble)
      # Move accepted and there's nobody else left to act this round
      pbHideCommandPageAssets
    elsif result
      # Move accepted, but this was the FIRST Pokemon of a double battle
      pbShowCommandButtons("fight")
    else
      pbShowCommandButtons("fight")   # cancelled - bring the Command buttons back, message box was never touched
    end
    pbShowDataBoxes
    return result
  end

  def pbTargetPanelEligible?(key, idxBattler, target_data)
    idx = TARGET_PANEL_BATTLER_INDEX[key]
    return false if !idx || idx >= @battle.battlers.length
    battler = @battle.battlers[idx]
    return false if !battler || battler.fainted?
    return true if target_data.targets_all
    sameSide = (idx.even? == idxBattler.even?)
    return sameSide ? !target_data.targets_foe : target_data.targets_foe
  end

  # Builds/rebakes the four panels
  def pbBuildTargetPanels
    TARGET_PANEL_KEYS.each do |key|
      spriteKey = "targetPanel_#{key}"
      if !@sprites[spriteKey]
        @sprites[spriteKey] = IconSprite.new(@viewport)
        @sprites[spriteKey].z = Z_COMMAND_BUTTON
        @sprites[spriteKey].x, @sprites[spriteKey].y = TARGET_PANEL_POS[key]
        @sprites[spriteKey].opacity = 0
        @sprites[spriteKey].visible = false
      end
      panelSprite = @sprites[spriteKey]
      idx = TARGET_PANEL_BATTLER_INDEX[key]
      battler = (idx && idx < @battle.battlers.length) ? @battle.battlers[idx] : nil
      occupied = battler && !battler.fainted?
      file = occupied ? TARGET_PANEL_FILE : TARGET_PANEL_EMPTY_FILE
      base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      bmp = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      iconKey = "targetPanelIcon_#{key}"
      if occupied
        text = battler.name
        pbSetSystemFont(bmp)
        text_w = bmp.text_size(text).width
        left_x = TARGET_PANEL_NAME_X_START + (TARGET_PANEL_NAME_WIDTH / 2) - (text_w / 2)
        left_x -= 1 if left_x.odd?
        left_x = TARGET_PANEL_NAME_X_START if left_x < TARGET_PANEL_NAME_X_START
        pbDrawTextPositions(bmp, [[text, left_x, TARGET_PANEL_NAME_Y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]])
        @sprites[iconKey]&.dispose
        @sprites[iconKey] = PokemonIconSprite.new(battler.pokemon, @viewport)
        @sprites[iconKey].x = TARGET_PANEL_POS[key][0] + TARGET_PANEL_ICON_OFFSET[0]
        @sprites[iconKey].y = TARGET_PANEL_POS[key][1] + TARGET_PANEL_ICON_OFFSET[1]
        @sprites[iconKey].z = Z_COMMAND_BUTTON + 1
        @sprites[iconKey].visible = false
      elsif @sprites[iconKey]
        @sprites[iconKey].dispose
        @sprites.delete(iconKey)
      end
      panelSprite.bitmap&.dispose
      panelSprite.bitmap = bmp
    end
  end

  def pbTargetPanelIconSprites
    return TARGET_PANEL_KEYS.filter_map { |key| @sprites["targetPanelIcon_#{key}"] }
  end

  # Steps each occupied panel's icon animation
  def pbAnimateTargetPanelIcons
    pbTargetPanelIconSprites.each { |icon| icon.update if icon.visible }
  end

  # Same opacity scheme as everywhere else, plus the highlight sprite.
  def pbUpdateTargetPanelOpacity(selectedKey, isField)
    TARGET_PANEL_KEYS.each do |key|
      sprite = @sprites["targetPanel_#{key}"]
      next if !sprite
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdateTargetPanelSelector(selectedKey, isField)
  end

  # Moves/re-skins the highlight
  def pbUpdateTargetPanelSelector(selectedKey, isField)
    if !@sprites["targetPanelSel"]
      @sprites["targetPanelSel"] = IconSprite.new(@viewport)
      @sprites["targetPanelSel"].z = Z_COMMAND_SELECTOR
      @sprites["targetPanelSel"].visible = false
      @targetPanelSelFile  = nil
      @targetPanelSelFrame = 0
      @targetPanelSelTick  = 0
    end
    sel = @sprites["targetPanelSel"]
    file = (selectedKey == "cancel") ? FIGHT_SEL_FILES["cancel"] : (isField ? TARGET_SEL_FIELD_FILE : FIGHT_SEL_FILES["move0"])
    if @targetPanelSelFile != file
      sel.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @targetPanelSelFile  = file
      @targetPanelSelFrame = 0
      @targetPanelSelTick  = 0
    end
    pos = (selectedKey == "cancel") ? BAG_UI_POS["cancel"] : TARGET_PANEL_POS[selectedKey]
    offset = (selectedKey == "cancel") ? FIGHT_SEL_OFFSET["cancel"] : FIGHT_SEL_OFFSET["move0"]
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @targetPanelSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  # Steps the target panel selector's animation frame - same pattern as
  # pbAnimateFightSelector.
  def pbAnimateTargetPanelSelector
    sel = @sprites["targetPanelSel"]
    return if !sel || !sel.visible
    @targetPanelSelTick += 1
    return if @targetPanelSelTick < SEL_ANIM_SPEED
    @targetPanelSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @targetPanelSelFrame = (@targetPanelSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @targetPanelSelFrame * frameHeight
  end

  # Entrance for the target panels
  def pbShowTargetPanels(landOnKey, isField)
    pbBuildTargetPanels
    pbSEPlay("SlideUp", 60)
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true
    TARGET_PANEL_KEYS.each do |key|
      sprite = @sprites["targetPanel_#{key}"]
      sprite.opacity = 0
      sprite.visible = true
    end
    icons = pbTargetPanelIconSprites
    icons.each { |icon| icon.opacity = 0; icon.visible = true }
    pbUpdateTargetPanelSelector(landOnKey, isField)
    sel = @sprites["targetPanelSel"]
    selRestX = sel.x
    slideSelWithCancel = (landOnKey == "cancel")
    sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0] if slideSelWithCancel
    sel.opacity = 0
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      TARGET_PANEL_KEYS.each { |key| @sprites["targetPanel_#{key}"].opacity = (CMD_BUTTON_OPACITY_NORMAL * progress).to_i }
      icons.each { |icon| icon.opacity = (255 * progress).to_i }
      if slideSelWithCancel
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    cancel.x = cancelPos[0]
    cancel.opacity = CMD_BUTTON_OPACITY_NORMAL
    TARGET_PANEL_KEYS.each { |key| @sprites["targetPanel_#{key}"].opacity = CMD_BUTTON_OPACITY_NORMAL }
    icons.each { |icon| icon.opacity = 255 }
    sel.x = selRestX
    sel.opacity = 255
    pbUpdateTargetPanelOpacity(landOnKey, isField)
  end

  # Reverse of pbShowTargetPanels.
  def pbHideTargetPanels
    pbSEPlay("SlideDown", 60)
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancelStartOpacity = cancel ? cancel.opacity : 0
    startOpacity = {}
    TARGET_PANEL_KEYS.each { |key| startOpacity[key] = @sprites["targetPanel_#{key}"].opacity if @sprites["targetPanel_#{key}"] }
    icons = pbTargetPanelIconSprites
    iconStartOpacity = {}
    icons.each { |icon| iconStartOpacity[icon] = icon.opacity }
    sel = @sprites["targetPanelSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    slideSelWithCancel = sel && @targetPanelSelKey == "cancel"
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      TARGET_PANEL_KEYS.each do |key|
        sprite = @sprites["targetPanel_#{key}"]
        next if !sprite
        sprite.opacity = (startOpacity[key] * (1 - progress)).to_i
      end
      icons.each { |icon| icon.opacity = (iconStartOpacity[icon] * (1 - progress)).to_i }
      if sel
        if slideSelWithCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    cancel.visible = false if cancel
    cancel.z = Z_BAG_UI if cancel
    TARGET_PANEL_KEYS.each { |key| @sprites["targetPanel_#{key}"].visible = false if @sprites["targetPanel_#{key}"] }
    icons.each { |icon| icon.visible = false }
    sel.visible = false if sel
  end

  # Works out where Up/Down/Left/Right from the current key land
  TARGET_PANEL_GRID = { "enemy1" => [0, 0], "enemy2" => [0, 1], "party1" => [1, 0], "party2" => [1, 1] }
  def pbTargetPanelNextKey(currentKey, dRow, dCol, eligible)
    if currentKey == "cancel"
      return currentKey if dRow != -1
      return (@targetLastKey && eligible.include?(@targetLastKey)) ? @targetLastKey : (eligible.first || currentKey)
    end
    pos = TARGET_PANEL_GRID[currentKey]
    return "cancel" if !pos
    row, col = pos
    if dCol != 0
      partnerKey = TARGET_PANEL_GRID.key([row, col + dCol])
      return (partnerKey && eligible.include?(partnerKey)) ? partnerKey : currentKey
    elsif dRow != 0
      partnerRow = row + dRow
      return "cancel" if partnerRow > 1
      return currentKey if partnerRow < 0
      partnerKey = TARGET_PANEL_GRID.key([partnerRow, col])
      return (partnerKey && eligible.include?(partnerKey)) ? partnerKey : currentKey
    end
    return currentKey
  end

  def pbChooseTarget(idxBattler, target_data)
    eligible = TARGET_PANEL_KEYS.select { |key| pbTargetPanelEligible?(key, idxBattler, target_data) }
    return -1 if eligible.empty?
    return TARGET_PANEL_BATTLER_INDEX[eligible.first] if eligible.length == 1 && !target_data.targets_all
    isField = target_data.targets_all || target_data.num_targets == 2
    pbHideFightButtons   # no-op if the move grid's already down - see the guard added there
    currentKey = (@targetLastKey && eligible.include?(@targetLastKey)) ? @targetLastKey : eligible.first
    pbShowTargetPanels(currentKey, isField)
    result = -1
    loop do
      pbUpdate
      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbTargetPanelNextKey(currentKey, dRow, dCol, eligible)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        @targetLastKey = currentKey if eligible.include?(currentKey)
        pbUpdateTargetPanelOpacity(currentKey, isField)
      end
      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        eligible.each do |key|
          sprite = @sprites["targetPanel_#{key}"]
          clickedKey = key if sprite && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey
        pbUpdateTargetPanelOpacity(currentKey, isField)
      end

      confirmed = Input.trigger?(Input::USE) || clickedKey
      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        result = -1
        break
      elsif confirmed
        pbPlayDecisionSE
        result = TARGET_PANEL_BATTLER_INDEX[currentKey]
        break
      end
    end
    pbHideTargetPanels
    # Cancelled - the move grid needs to be showing again
    pbShowFightButtons(@battle.battlers[idxBattler], @fightLastMoveKey || "move0") if result < 0
    return result
  end

  # Battler name/status icon boxes.

  # Position for a given battler index's icon box, or nil if that slot isn't
  # supported
  def pbBattlerIconPos(idxBattler)
    partyPos = idxBattler / 2   # 0 = slot 1, 1 = slot 2
    return nil if partyPos > 1
    return idxBattler.even? ? PLAYER_ICON_POS[partyPos] : ENEMY_ICON_POS[partyPos]
  end

  # Builds the single icon box sprite for a given battler index
  def pbBuildBattlerIcon(idxBattler)
    pos = pbBattlerIconPos(idxBattler)
    return if !pos
    key = "battlerIcon_#{idxBattler}"
    return if @sprites[key]
    @sprites[key] = Sprite.new(@viewport)
    @sprites[key].x = pos[0]
    @sprites[key].y = pos[1]
    @sprites[key].z = Z_BATTLER_ICON
    @sprites[key].opacity = 0
    @sprites[key].visible = false
  end

  # HP fraction (0-1) for a battler's current Pokemon.
  def pbBattlerHPFraction(pkmn)
    return 0 if !pkmn || pkmn.totalhp == 0
    return pkmn.hp.to_f / pkmn.totalhp
  end

  # EXP fraction (0-1) toward the next level, for the EXP bar
  def pbBattlerExpFraction(pkmn)
    return 0 if !pkmn
    return 0 if pkmn.level >= GameData::GrowthRate.max_level
    growth = GameData::GrowthRate.get(pkmn.species_data.growth_rate)
    curLevelExp  = growth.minimum_exp_for_level(pkmn.level)
    nextLevelExp = growth.minimum_exp_for_level(pkmn.level + 1)
    return 0 if nextLevelExp <= curLevelExp
    return [(pkmn.exp - curLevelExp).to_f / (nextLevelExp - curLevelExp), 0].max
  rescue NoMethodError
    return 0
  end

  # Redraws a battler's icon box onto its single baked bitmap
  def pbDrawBattlerIcon(idxBattler)
    pos = pbBattlerIconPos(idxBattler)
    return if !pos
    pbBuildBattlerIcon(idxBattler)
    sprite = @sprites["battlerIcon_#{idxBattler}"]
    battler = @battle.battlers[idxBattler]
    if !battler || !battler.pokemon
      sprite.visible = false
      return
    end
    isPlayerSide = idxBattler.even?
    bgFile = isPlayerSide ? "icon_party" : "icon_foe"
    pkmn = battler.pokemon
    sprite.bitmap&.dispose
    base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + bgFile + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    # Name, centered within BATTLER_ICON_WIDTH via the fail-safe formula.
    pbSetSystemFont(bmp)
    text = battler.name
    text_w = bmp.text_size(text).width
    center_x = BATTLER_ICON_WIDTH / 2
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BATTLER_NAME_Y_OFFSET, :left,
       BATTLER_NAME_TEXT_COLOR, BATTLER_NAME_SHADOW_COLOR]])
    # HP bar
    hpFraction = pbBattlerHPFraction(pkmn)
    hpBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "icon_overlay_hp.png")
    hpRow = (hpFraction > 0.5) ? 0 : (hpFraction > 0.2) ? 1 : 2
    hpWidth = (hpBase.width * hpFraction).round
    hpX, hpY = isPlayerSide ? [38, 34] : [38, 40]
    if hpWidth > 0
      bmp.blt(hpX, hpY, hpBase, Rect.new(0, hpRow * 4, hpWidth, 4))
    end
    hpBase.dispose
    # EXP bar
    if isPlayerSide
      expFraction = pbBattlerExpFraction(pkmn)
      expBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "icon_exp.png")
      expWidth = (expBase.width * expFraction).round
      bmp.blt(38, 40, expBase, Rect.new(0, 0, expWidth, expBase.height)) if expWidth > 0
      expBase.dispose
    end
    # Status icon - fainted / status condition / pokerus / none.
    statusRow = nil
    if battler.fainted?
      statusRow = GameData::Status.count - 1
    elsif pkmn.status != :NONE
      statusRow = GameData::Status.get(pkmn.status).icon_position
    elsif pkmn.pokerusStage == 1
      statusRow = GameData::Status.count
    end
    if statusRow
      statusBase = Bitmap.new("Graphics/UI/statuses")
      bmp.blt(BATTLER_STATUS_OFFSET_X, BATTLER_STATUS_OFFSET_Y, statusBase, Rect.new(0, 16 * statusRow, 44, 16))
      statusBase.dispose
    end
    if !isPlayerSide && !@battle.trainerBattle? && $player.owned?(pkmn.species)
      caughtBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "caught_icon.png")
      bmp.blt(8, 46, caughtBase, caughtBase.rect)
      caughtBase.dispose
    end
    sprite.bitmap = bmp
    if @sprites["cmdBtn_fight"] && @sprites["cmdBtn_fight"].visible
      sprite.visible = true
      sprite.opacity = 255
    end
  end

  # Redraws every currently-relevant battler's icon box
  def pbDrawAllBattlerIcons
    @battle.battlers.each_index { |i| pbDrawBattlerIcon(i) }
  end

  def pbBattlerIconSprites
    return @battle.battlers.each_index.filter_map { |i| @sprites["battlerIcon_#{i}"] }
  end

  # Idle bob for icon_party
  def pbAnimateBattlerIconBob
    idxBattler = @activeCommandBattler
    # If the active battler changed since the last tick
    if @battlerBobIdx && @battlerBobIdx != idxBattler
      oldSprite = @sprites["battlerIcon_#{@battlerBobIdx}"]
      oldPos = pbBattlerIconPos(@battlerBobIdx)
      oldSprite.y = oldPos[1] if oldSprite && oldPos
      @battlerBobOffset = 0
      @battlerBobDir = -1
      @battlerBobTick = 0
    end
    @battlerBobIdx = idxBattler
    return if !idxBattler || idxBattler.odd?   # enemy side (icon_foe) never bobs
    sprite = @sprites["battlerIcon_#{idxBattler}"]
    return if !sprite || !sprite.visible
    pos = pbBattlerIconPos(idxBattler)
    return if !pos
    @battlerBobOffset ||= 0
    @battlerBobDir    ||= -1
    @battlerBobTick    = (@battlerBobTick || 0) + 1
    if @battlerBobTick >= BATTLER_BOB_TICKS
      @battlerBobTick = 0
      @battlerBobOffset += BATTLER_BOB_STEP * @battlerBobDir
      if @battlerBobOffset <= -BATTLER_BOB_MAX_OFFSET
        @battlerBobOffset = -BATTLER_BOB_MAX_OFFSET
        @battlerBobDir = 1
      elsif @battlerBobOffset >= 0
        @battlerBobOffset = 0
        @battlerBobDir = -1
      end
    end
    sprite.y = pos[1] + @battlerBobOffset
  end

  alias customUI_pbRefreshEverything pbRefreshEverything
  def pbRefreshEverything(*args)
    customUI_pbRefreshEverything(*args)
    pbDrawAllBattlerIcons
  end

  alias customUI_pbRefresh pbRefresh
  def pbRefresh(*args)
    customUI_pbRefresh(*args)
    pbDrawAllBattlerIcons
  end

  alias customUI_pbRefreshOne pbRefreshOne
  def pbRefreshOne(idxBattler, *args)
    customUI_pbRefreshOne(idxBattler, *args)
    pbDrawBattlerIcon(idxBattler)
  end

  alias customUI_pbChangePokemon pbChangePokemon
  def pbChangePokemon(idxBattler, pkmn, *args)
    customUI_pbChangePokemon(idxBattler, pkmn, *args)
    pbDrawBattlerIcon(idxBattler)
  end

  # Bag page.

  # The last item actually used from the Use Item page (@lastUsedItem, set
  # by pbItemMenu
  def pbLastUsedItem
    return nil if @lastUsedItem.nil?
    return nil if pbBagItemQuantity(@lastUsedItem) <= 0
    return @lastUsedItem
  end

  def pbSetLastUsedItem(item_id)
    @lastUsedItem = item_id
  end

  # Builds the Bag page sprites
  def pbBuildBagUI
    BAG_UI_FILES.each_key do |key|
      spriteKey = "bagUI_#{key}"
      next if @sprites[spriteKey]
      pos = BAG_UI_POS[key]
      size = BAG_UI_SIZE[key]
      @sprites[spriteKey] = IconSprite.new(@viewport)
      if key == "command"
        # Built via pbDrawBagCommandButton below instead
      else
        @sprites[spriteKey].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + BAG_UI_FILES[key] + ".png")
        bmp = @sprites[spriteKey].bitmap
        pbSetSystemFont(bmp)
        if BAG_UI_TEXT[key]
          positions = BAG_UI_TEXT[key].map { |text, x, y| [text, x, y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR] }
          pbDrawTextPositions(bmp, positions)
        end
      end
      case BAG_UI_SLIDE_FROM[key]
      when :left
        @sprites[spriteKey].x = -size[0]
        @sprites[spriteKey].y = pos[1]
      when :right
        @sprites[spriteKey].x = Graphics.width
        @sprites[spriteKey].y = pos[1]
      when :bottom
        @sprites[spriteKey].x = pos[0]
        @sprites[spriteKey].y = Graphics.height
      end
      # Cancel starts at the normal Bag tier like every other button here
      @sprites[spriteKey].z = Z_BAG_UI
      @sprites[spriteKey].opacity = 0
      @sprites[spriteKey].visible = false
    end
    if !@sprites["bagSel"]
      @sprites["bagSel"] = IconSprite.new(@viewport)
      @sprites["bagSel"].z = Z_BAG_UI_SEL
      @sprites["bagSel"].opacity = 0
      @sprites["bagSel"].visible = false
      @bagSelFile  = nil
      @bagSelFrame = 0
      @bagSelTick  = 0
      @bagSelKey   = nil
    end
    pbDrawBagCommandButton
  end

  # (Re)bakes item_command's bitmap from scratch - background
  def pbDrawBagCommandButton
    sprite = @sprites["bagUI_command"]
    return if !sprite
    base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + BAG_UI_FILES["command"] + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    size = BAG_UI_SIZE["command"]
    text_w = bmp.text_size(BAG_UI_COMMAND_TEXT).width
    center_x = size[0] / 2
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[BAG_UI_COMMAND_TEXT, left_x, BAG_UI_COMMAND_TEXT_Y, :left,
       BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]])
    item_id = pbLastUsedItem
    if item_id
      iconFile = (GameData::Item.icon_filename(item_id) rescue nil)
      if iconFile && FileTest.exist?(iconFile + ".png")
        iconBase = Bitmap.new(iconFile)
        bmp.blt(BAG_UI_COMMAND_ICON_POS[0], BAG_UI_COMMAND_ICON_POS[1], iconBase, iconBase.rect)
        iconBase.dispose
      end
    end
    sprite.bitmap&.dispose
    sprite.bitmap = bmp
  end

  # Moves/reskins the bagSel highlight onto whichever button is currently
  # selected
  def pbUpdateBagSelector(selectedKey)
    sel = @sprites["bagSel"]
    return if !sel
    file = BAG_SEL_FILES[selectedKey]
    if @bagSelFile != file
      sel.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      frameHeight = sel.bitmap.height / BAG_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @bagSelFile  = file
      @bagSelFrame = 0
      @bagSelTick  = 0
    end
    @bagSelKey = selectedKey   # which grid key it's currently bound to, for exit-animation direction
    pos = BAG_UI_POS[selectedKey]
    offset = BAG_SEL_OFFSET[selectedKey]
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
  end

  def pbAnimateBagSelector
    sel = @sprites["bagSel"]
    return if !sel || !sel.visible
    @bagSelTick += 1
    return if @bagSelTick < SEL_ANIM_SPEED
    @bagSelTick = 0
    frameHeight = sel.bitmap.height / BAG_SEL_FRAMES
    @bagSelFrame = (@bagSelFrame + 1) % BAG_SEL_FRAMES
    sel.src_rect.y = @bagSelFrame * frameHeight
  end

  # A given Bag button's target opacity
  def pbBagButtonTargetOpacity(key, selectedKey)
    return BAG_UI_OPACITY_NO_LAST_ITEM if key == "command" && pbLastUsedItem.nil?
    return (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
  end

  # Applies pbBagButtonTargetOpacity to every Bag button for the given
  # selection - called on entrance settle and every time the grid selection
  # changes in pbBagMenuLoop.
  def pbUpdateBagButtonOpacity(selectedKey)
    BAG_UI_FILES.each_key do |key|
      sprite = @sprites["bagUI_#{key}"]
      next if !sprite
      sprite.opacity = pbBagButtonTargetOpacity(key, selectedKey)
    end
  end

  # Slides every Bag page button in from its own edge
  def pbShowBagUI
    alreadyShown = @sprites["bagUI_command"] && @sprites["bagUI_command"].visible
    pbBuildBagUI
    return nil if alreadyShown
    pbSEStop   # cut off the Command page's slide-out SE if it's still tailing off, no frame delay needed
    pbSEPlay("SlideUp", 60)
    itemChosen = catch(:bagItemUsed) do
      pbShowBagButtons(BAG_GRID[0][0])   # "hp" - matches pbBagMenuLoop's starting selection
      pbBagMenuLoop
      nil
    end
    return itemChosen
  end

  # The actual entrance animation for all six Bag buttons
  def pbShowBagButtons(landOnKey)
    pbDrawBagCommandButton
    BAG_UI_FILES.each_key { |key| @sprites["bagUI_#{key}"].visible = true }
    pbUpdateBagSelector(landOnKey)
    sel = @sprites["bagSel"]
    selRestX = sel ? sel.x : nil
    selRestY = sel ? sel.y : nil
    selOffset = BAG_SEL_OFFSET[landOnKey]
    selFrom = BAG_UI_SLIDE_FROM[landOnKey]
    selSize = BAG_UI_SIZE[landOnKey]
    sel.visible = true if sel
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      BAG_UI_FILES.each_key do |key|
        sprite = @sprites["bagUI_#{key}"]
        pos = BAG_UI_POS[key]
        size = BAG_UI_SIZE[key]
        targetOpacity = pbBagButtonTargetOpacity(key, landOnKey)
        case BAG_UI_SLIDE_FROM[key]
        when :left
          sprite.x = -size[0] + ((pos[0] - -size[0]) * progress)
        when :right
          sprite.x = Graphics.width + ((pos[0] - Graphics.width) * progress)
        when :bottom
          sprite.y = Graphics.height + ((pos[1] - Graphics.height) * progress)
        end
        sprite.opacity = (targetOpacity * progress).to_i
      end

      if sel
        case selFrom
        when :left
          sel.x = (-selSize[0] + selOffset[0]) + ((selRestX - (-selSize[0] + selOffset[0])) * progress)
        when :right
          sel.x = (Graphics.width + selOffset[0]) + ((selRestX - (Graphics.width + selOffset[0])) * progress)
        when :bottom
          sel.y = (Graphics.height + selOffset[1]) + ((selRestY - (Graphics.height + selOffset[1])) * progress)
        end
        sel.opacity = (255 * progress).to_i
      end
      pbUpdate
    end
    BAG_UI_FILES.each_key do |key|
      sprite = @sprites["bagUI_#{key}"]
      pos = BAG_UI_POS[key]
      sprite.x = pos[0]
      sprite.y = pos[1]
    end
    if sel
      sel.x = selRestX
      sel.y = selRestY
      sel.opacity = 255
    end
    pbUpdateBagButtonOpacity(landOnKey)
  end

  def pbHideBagUI(playSE = true)
    return if !@sprites["bagUI_command"] || !@sprites["bagUI_command"].visible
    pbSEPlay("SlideDown", 60) if playSE
    startOpacity = {}
    BAG_UI_FILES.each_key { |key| startOpacity[key] = @sprites["bagUI_#{key}"].opacity }
    sel = @sprites["bagSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selStartY = sel ? sel.y : nil
    selKey = @bagSelKey
    selFrom = selKey ? BAG_UI_SLIDE_FROM[selKey] : nil
    selSize = selKey ? BAG_UI_SIZE[selKey] : nil
    selOffset = selKey ? BAG_SEL_OFFSET[selKey] : nil
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      BAG_UI_FILES.each_key do |key|
        sprite = @sprites["bagUI_#{key}"]
        pos = BAG_UI_POS[key]
        size = BAG_UI_SIZE[key]
        case BAG_UI_SLIDE_FROM[key]
        when :left
          sprite.x = pos[0] + ((-size[0] - pos[0]) * progress)
        when :right
          sprite.x = pos[0] + ((Graphics.width - pos[0]) * progress)
        when :bottom
          sprite.y = pos[1] + ((Graphics.height - pos[1]) * progress)
        end
        sprite.opacity = (startOpacity[key] * (1 - progress)).to_i
      end
      if sel
        case selFrom
        when :left
          sel.x = selStartX + (((-selSize[0] + selOffset[0]) - selStartX) * progress)
        when :right
          sel.x = selStartX + (((Graphics.width + selOffset[0]) - selStartX) * progress)
        when :bottom
          sel.y = selStartY + (((Graphics.height + selOffset[1]) - selStartY) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    BAG_UI_FILES.each_key { |key| @sprites["bagUI_#{key}"].visible = false }
    sel.visible = false if sel
  end

  # Rebakes the message box graphic with the pocket's header text
  def pbBakeBagPocketHeader(category)
    box = @sprites["messageBox"]
    return if !box
    base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "message_overlay.png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    text = BAG_POCKET_NAMES[category] || category.to_s.upcase
    text_w = bmp.text_size(text).width
    left_x = BAG_POCKET_TEXT_CENTER_X - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    left_y = BAG_POCKET_TEXT_Y
    left_y -= 1 if left_y.odd?
    left_y = 0 if left_y < 0
    pageText = "#{(@bagCurrentPage || 0) + 1}/#{pbBagCategoryPageCount(category)}"
    page_x = left_x + text_w + BAG_POCKET_PAGE_TEXT_GAP
    page_x -= 1 if page_x.odd?
    pbDrawTextPositions(bmp, [
      [text, left_x, left_y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
      [pageText, page_x, left_y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR],
    ])
    box.bitmap = bmp
  end

  def pbBuildBagPocketArrows
    { "bagPocketArrowLeft" => ["leftarrow", BAG_POCKET_ARROW_LEFT_POS],
      "bagPocketArrowRight" => ["rightarrow", BAG_POCKET_ARROW_RIGHT_POS] }.each do |key, (file, offset)|
      next if @sprites[key]
      @sprites[key] = IconSprite.new(@viewport)
      @sprites[key].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      @sprites[key].x = offset[0]
      @sprites[key].y = MESSAGE_REST_Y + offset[1]
      @sprites[key].z = Z_BAG_POCKET_ARROW
      @sprites[key].opacity = 0
      @sprites[key].visible = false
    end
  end

  # Scrolls the message box in exactly like pbScrollMessageBoxIn
  def pbScrollBagPocketIn(category)
    box = @sprites["messageBox"]
    return if !box
    pbBakeBagPocketHeader(category)
    pbBuildBagPocketArrows
    leftArrow = @sprites["bagPocketArrowLeft"]
    rightArrow = @sprites["bagPocketArrowRight"]
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    pbSEPlay("SlideUp", 60)
    box.x = 0
    box.y = MESSAGE_REST_Y + MESSAGE_SCROLL_OFFSET
    box.visible = true
    [leftArrow, rightArrow].each { |a| a.visible = true; a.opacity = 0 }
    if cancel
      cancel.z = Z_BAG_POCKET_ARROW   # raised above the message box graphic just for the pocket header - back to Z_BAG_UI in pbScrollBagPocketOut
      cancel.x = Graphics.width
      cancel.y = cancelPos[1]
      cancel.opacity = 0
      cancel.visible = true
    end
    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = MESSAGE_REST_Y + (MESSAGE_SCROLL_OFFSET * (1 - progress))
      leftArrow.y = box.y + BAG_POCKET_ARROW_LEFT_POS[1]
      rightArrow.y = box.y + BAG_POCKET_ARROW_RIGHT_POS[1]
      leftArrow.opacity = (255 * progress).to_i
      rightArrow.opacity = (255 * progress).to_i
      if cancel
        cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
        cancel.opacity = (255 * progress).to_i
      end
      pbUpdate
    end
    box.y = MESSAGE_REST_Y
    leftArrow.y = MESSAGE_REST_Y + BAG_POCKET_ARROW_LEFT_POS[1]
    rightArrow.y = MESSAGE_REST_Y + BAG_POCKET_ARROW_RIGHT_POS[1]
    leftArrow.opacity = 255
    rightArrow.opacity = 255
    if cancel
      cancel.x = cancelPos[0]
      cancel.opacity = 255
    end
  end

  def pbScrollBagPocketOut
    box = @sprites["messageBox"]
    return if !box || !box.visible
    leftArrow = @sprites["bagPocketArrowLeft"]
    rightArrow = @sprites["bagPocketArrowRight"]
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    pbSEPlay("SlideDown", 60)
    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = MESSAGE_REST_Y + (MESSAGE_SCROLL_OFFSET * progress)
      if leftArrow
        leftArrow.y = box.y + BAG_POCKET_ARROW_LEFT_POS[1]
        leftArrow.opacity = (255 * (1 - progress)).to_i
      end
      if rightArrow
        rightArrow.y = box.y + BAG_POCKET_ARROW_RIGHT_POS[1]
        rightArrow.opacity = (255 * (1 - progress)).to_i
      end
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (255 * (1 - progress)).to_i
      end
      pbUpdate
    end
    box.visible = false
    leftArrow.visible = false if leftArrow
    rightArrow.visible = false if rightArrow
    if cancel
      cancel.visible = false
      cancel.z = Z_BAG_UI   # back to its normal tier, below bagSel, now that it's off the pocket header
    end
    box.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "message_overlay.png")   # back to plain, no baked text
  end

  # Looks up a pocket's 1-based number by its display name
  def pbBagPocketNumber(pocketName)
    idx = PokemonBag.pocket_names.index(pocketName)
    return idx ? idx + 1 : nil
  rescue StandardError
    return nil
  end

  # $bag.quantity(item) returns how many of that item the player owns
  def pbBagHasItem?(item_id)
    return pbBagItemQuantity(item_id) > 0
  end

  def pbBagItemQuantity(item_id)
    return 0 if !$bag
    return $bag.quantity(item_id)
  rescue StandardError
    return 0
  end

  def pbBagOwnedItemIDs
    return [] if !$bag
    ids = []
    $bag.pockets.each do |pocket|
      next if !pocket
      pocket.each { |item_id, qty| ids.push(item_id) if qty && qty > 0 }
    end
    return ids
  rescue StandardError
    return []
  end

  def pbBagPocketItemIDs(pocketNum)
    return [] if !$bag || !pocketNum
    pocket = $bag.pockets[pocketNum]
    return [] if !pocket
    return pocket.select { |item_id, qty| qty && qty > 0 }.map { |item_id, qty| item_id }
  rescue StandardError
    return []
  end

  # Every item ID (unpaged, full list) for a given pocket category
  def pbBagCategoryAllItems(category)
    case category
    when "hp"
      return BAG_HP_ITEM_IDS.select { |id| pbBagHasItem?(id) }
    when "restore"
      return BAG_STATUS_ITEM_IDS.select { |id| pbBagHasItem?(id) }
    when "balls"
      return pbBagPocketItemIDs(pbBagPocketNumber(BAG_BALLS_POCKET_NAME))
    when "battle"
      return pbBagPocketItemIDs(pbBagPocketNumber(BAG_BATTLE_ITEMS_POCKET_NAME))
    else
      return []
    end
  end

  # How many 6-item pages a category's full item list spans. Always at
  # least 1, even with zero items, so "1/1" is shown rather than "1/0".
  def pbBagCategoryPageCount(category)
    total = pbBagCategoryAllItems(category).length
    return [(total / BAG_ITEM_SLOTS.to_f).ceil, 1].max
  end

  # The 6 item IDs (nil-padded to always be exactly BAG_ITEM_SLOTS long) to
  # show for a given pocket category on a given 0-based page.
  def pbBagCategoryItems(category, page = 0)
    all = pbBagCategoryAllItems(category)
    slice = all[(page * BAG_ITEM_SLOTS), BAG_ITEM_SLOTS] || []
    slice += Array.new(BAG_ITEM_SLOTS - slice.length, nil) if slice.length < BAG_ITEM_SLOTS
    return slice
  end

  # Screen position for a given item button slot (0-5), row-major across the
  # 2x3 grid.
  def pbBagItemButtonPos(slot)
    row = slot / BAG_ITEM_GRID_COLS
    col = slot % BAG_ITEM_GRID_COLS
    x = BAG_ITEM_START_X + (col * (BAG_ITEM_BUTTON_SIZE[0] + BAG_ITEM_SPACING_X))
    y = BAG_ITEM_START_Y + (row * (BAG_ITEM_BUTTON_SIZE[1] + BAG_ITEM_SPACING_Y))
    return [x, y]
  end

  # Builds the six item button sprites if they don't already exist, parked
  # off-screen to the right and hidden/transparent.
  def pbBuildBagItemButtons
    BAG_ITEM_SLOTS.times do |slot|
      key = "bagItemButton_#{slot}"
      next if @sprites[key]
      pos = pbBagItemButtonPos(slot)
      @sprites[key] = Sprite.new(@viewport)
      @sprites[key].x = Graphics.width
      @sprites[key].y = pos[1]
      @sprites[key].z = Z_BAG_ITEM_BUTTON
      @sprites[key].opacity = 0
      @sprites[key].visible = false
    end
  end

  # Whether a given item grid slot can be selected at all
  def pbItemIndexEnabled?(slot)
    return false if slot.nil? || slot < 0 || slot >= BAG_ITEM_SLOTS
    return !(@bagItemIds.nil? || @bagItemIds[slot].nil?)
  end

  # A given item grid slot's target opacity
  def pbItemButtonTargetOpacity(slot, selectedSlot)
    return (slot == selectedSlot) ? BAG_ITEM_BUTTON_OPACITY_SELECTED : BAG_ITEM_BUTTON_OPACITY_NORMAL
  end

  def pbUpdateItemButtonOpacity(selectedSlot)
    BAG_ITEM_SLOTS.times do |slot|
      sprite = @sprites["bagItemButton_#{slot}"]
      next if !sprite
      sprite.opacity = pbItemButtonTargetOpacity(slot, selectedSlot)
    end
  end

  # Builds the item grid's animated 4-frame highlight sprite
  def pbBuildBagItemSel
    return if @sprites["bagItemSel"]
    sel = IconSprite.new(@viewport)
    sel.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + BAG_ITEM_SEL_FILE + ".png")
    frameHeight = sel.bitmap.height / BAG_ITEM_SEL_FRAMES
    sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
    sel.z = Z_BAG_ITEM_SEL
    sel.opacity = 0
    sel.visible = false
    @sprites["bagItemSel"] = sel
    @bagItemSelFrame = 0
    @bagItemSelTick  = 0
  end

  # Steps the item grid selector's animation frame - called every update
  def pbAnimateBagItemSel
    sel = @sprites["bagItemSel"]
    return if !sel || !sel.visible
    @bagItemSelTick += 1
    return if @bagItemSelTick < SEL_ANIM_SPEED
    @bagItemSelTick = 0
    frameHeight = sel.bitmap.height / BAG_ITEM_SEL_FRAMES
    @bagItemSelFrame = (@bagItemSelFrame + 1) % BAG_ITEM_SEL_FRAMES
    sel.src_rect.y = @bagItemSelFrame * frameHeight
  end

  # Moves the item grid highlight onto the given slot
  # and mouse clicks route through it.
  def pbUpdateItemGridSelector(selectedSlot)
    pbBuildBagItemSel
    sel = @sprites["bagItemSel"]
    pos = pbBagItemButtonPos(selectedSlot)
    sel.x = pos[0] + BAG_ITEM_SEL_OFFSET[0]
    sel.y = pos[1] + BAG_ITEM_SEL_OFFSET[1]
    sel.opacity = 255
    sel.visible = true
    @bagItemSelectedSlot = selectedSlot
    pbUpdateItemButtonOpacity(selectedSlot)
  end

  # Builds one item button's bitmap - background, name/quantity text
  def pbBuildBagItemButtonBitmap(item_id)
    base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + BAG_ITEM_BUTTON_FILE + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    if item_id
      pbSetSystemFont(bmp)
      itemData = GameData::Item.get(item_id)
      name = itemData.name
      qty = pbBagItemQuantity(item_id)
      area_x, area_y = BAG_ITEM_TEXT_AREA_POS
      area_w, area_h = BAG_ITEM_TEXT_AREA_SIZE
      center_x = area_w / 2
      [name, "x#{qty}"].each_with_index do |text, i|
        text_w = bmp.text_size(text).width
        left_x = center_x - (text_w / 2)
        left_x -= 1 if left_x.odd?
        left_x = 0 if left_x < 0
        line_y = area_y + (i * (area_h / 2))
        pbDrawTextPositions(bmp, [[text, area_x + left_x, line_y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]])
      end
      iconFile = (GameData::Item.icon_filename(item_id) rescue nil)
      if iconFile && FileTest.exist?(iconFile + ".png")
        iconBase = Bitmap.new(iconFile)
        bmp.blt(BAG_ITEM_ICON_POS[0], BAG_ITEM_ICON_POS[1], iconBase, iconBase.rect)
        iconBase.dispose
      end
    end
    return bmp
  end

  def pbDrawBagItemButton(slot, item_id)
    sprite = @sprites["bagItemButton_#{slot}"]
    return if !sprite
    sprite.bitmap&.dispose
    sprite.bitmap = pbBuildBagItemButtonBitmap(item_id)
  end

  # Slides all six item buttons in from the right together
  def pbShowBagItemButtons(category)
    items = pbBagCategoryItems(category, @bagCurrentPage || 0)
    @bagItemIds = items
    pbBuildBagItemButtons
    pbBuildBagItemSel
    BAG_ITEM_SLOTS.times { |slot| pbDrawBagItemButton(slot, items[slot]) }
    BAG_ITEM_SLOTS.times { |slot| @sprites["bagItemButton_#{slot}"].visible = true }

    landOnSlot = (0...BAG_ITEM_SLOTS).find { |slot| items[slot] } || 0
    @bagItemSelectedSlot = landOnSlot
    sel = @sprites["bagItemSel"]
    selPos = pbBagItemButtonPos(landOnSlot)
    sel.x = selPos[0] + BAG_ITEM_SEL_OFFSET[0]
    sel.y = selPos[1] + BAG_ITEM_SEL_OFFSET[1]
    sel.visible = true

    BAG_ITEM_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_ITEM_SLIDE_FRAMES.to_f
      BAG_ITEM_SLOTS.times do |slot|
        sprite = @sprites["bagItemButton_#{slot}"]
        pos = pbBagItemButtonPos(slot)
        targetOpacity = pbItemButtonTargetOpacity(slot, landOnSlot)
        sprite.x = Graphics.width + ((pos[0] - Graphics.width) * progress)
        sprite.opacity = (targetOpacity * progress).to_i
        sel.x = sprite.x + BAG_ITEM_SEL_OFFSET[0] if slot == landOnSlot
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    BAG_ITEM_SLOTS.times do |slot|
      sprite = @sprites["bagItemButton_#{slot}"]
      pos = pbBagItemButtonPos(slot)
      sprite.x = pos[0]
    end
    sel.x = selPos[0] + BAG_ITEM_SEL_OFFSET[0]
    sel.opacity = 255
    pbUpdateItemButtonOpacity(landOnSlot)
  end

  def pbHideBagItemButtons
    return if !@sprites["bagItemButton_0"] || !@sprites["bagItemButton_0"].visible
    startOpacity = {}
    BAG_ITEM_SLOTS.times { |slot| startOpacity[slot] = @sprites["bagItemButton_#{slot}"].opacity }
    sel = @sprites["bagItemSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selSlot = @bagItemSelectedSlot
    BAG_ITEM_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_ITEM_SLIDE_FRAMES.to_f
      BAG_ITEM_SLOTS.times do |slot|
        sprite = @sprites["bagItemButton_#{slot}"]
        pos = pbBagItemButtonPos(slot)
        sprite.x = pos[0] + ((Graphics.width - pos[0]) * progress)
        sprite.opacity = (startOpacity[slot] * (1 - progress)).to_i
        sel.x = sprite.x + BAG_ITEM_SEL_OFFSET[0] if sel && slot == selSlot
      end
      sel.opacity = (selStartOpacity * (1 - progress)).to_i if sel
      pbUpdate
    end
    BAG_ITEM_SLOTS.times { |slot| @sprites["bagItemButton_#{slot}"].visible = false }
    sel.visible = false if sel
  end

  # A pocket page's own mini input loop
  def pbShowBagPocket(category)
    @bagCurrentPage = 0
    pbScrollBagPocketIn(category)
    pbShowBagItemButtons(category)
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end

      if dCol != 0
        row = @bagItemSelectedSlot / BAG_ITEM_GRID_COLS
        col = @bagItemSelectedSlot % BAG_ITEM_GRID_COLS
        if col == BAG_ITEM_GRID_COLS - 1 && dCol == 1
          pbSwitchBagItemPage(category, 1)
        elsif col == 0 && dCol == -1
          pbSwitchBagItemPage(category, -1)
        else
          newSlot = @bagItemSelectedSlot + dCol
          if pbItemIndexEnabled?(newSlot)
            pbPlayCursorSE
            pbUpdateItemGridSelector(newSlot)
          end
        end
      elsif dRow != 0
        newSlot = @bagItemSelectedSlot + (dRow * BAG_ITEM_GRID_COLS)
        if pbItemIndexEnabled?(newSlot)
          pbPlayCursorSE
          pbUpdateItemGridSelector(newSlot)
        end
      end

      mouseClicked = Mouse.active? && Mouse.click?

      previousSlot = @bagItemSelectedSlot
      clickedSlot = nil
      if mouseClicked
        BAG_ITEM_SLOTS.times do |slot|
          next if !pbItemIndexEnabled?(slot)
          sprite = @sprites["bagItemButton_#{slot}"]
          clickedSlot = slot if sprite && Mouse.over?(sprite)
        end
      end

      if clickedSlot && clickedSlot != previousSlot
        pbUpdateItemGridSelector(clickedSlot)
      end
      confirmedItem = pbItemIndexEnabled?(@bagItemSelectedSlot) && (Input.trigger?(Input::USE) || clickedSlot)

      clickedCancel = mouseClicked && @sprites["bagUI_cancel"] &&
                      Mouse.over?(@sprites["bagUI_cancel"])
      clickedLeftArrow  = mouseClicked && @sprites["bagPocketArrowLeft"] &&
                          Mouse.over?(@sprites["bagPocketArrowLeft"])
      clickedRightArrow = mouseClicked && @sprites["bagPocketArrowRight"] &&
                          Mouse.over?(@sprites["bagPocketArrowRight"])
      if confirmedItem
        pbPlayDecisionSE
        item_id = @bagItemIds[@bagItemSelectedSlot]
        pbHideBagItemButtons
        pbScrollBagPocketOut
        pbShowUseItemPage(category, item_id)   # blocks until backed out (or the item was USEd, which throws :bagItemUsed instead of returning)
        pbScrollBagPocketIn(category)
        pbShowBagItemButtons(category)
      elsif clickedLeftArrow
        pbSwitchBagItemPage(category, -1)
      elsif clickedRightArrow
        pbSwitchBagItemPage(category, 1)
      elsif Input.trigger?(Input::BACK) || clickedCancel
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideBagItemButtons
        pbScrollBagPocketOut
        break
      end
    end
  end

  # Flashes the cancel button's graphic between icon_cancel and icon_cancel_p
  def pbFlashBagCancelButton
    sprite = @sprites["bagUI_cancel"]
    return if !sprite
    folder = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH
    2.times do
      sprite.setBitmap(folder + "icon_cancel_p.png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
      sprite.setBitmap(folder + "icon_cancel.png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
    end
  end

  # Command menu's own "back to previous Pokemon" cancel
  def pbSyncCmdCancelButton
    return if @cmdCancelShown == @cmdCancelWanted
    if @cmdCancelWanted
      pbBuildBagUI   # make sure bagUI_cancel exists even if Bag/Fight haven't opened yet this battle
      cancel = @sprites["bagUI_cancel"]
      cancelPos = BAG_UI_POS["cancel"]
      cancel.z = Z_BAG_POCKET_ARROW
      cancel.x = cancelPos[0]
      cancel.y = cancelPos[1]
      cancel.opacity = 255
      cancel.visible = true
    else
      cancel = @sprites["bagUI_cancel"]
      if cancel
        cancel.visible = false
        cancel.z = Z_BAG_UI
      end
    end
    @cmdCancelShown = @cmdCancelWanted
  end

  # Reverse of the fade-in pbScrollCommandPanelIn plays
  def pbHideCmdCancelButton
    return if !@cmdCancelShown
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
      pbUpdate
    end
    cancel.visible = false
    cancel.x = cancelPos[0]
    cancel.z = Z_BAG_UI
    @cmdCancelShown = false
    @cmdCancelWanted = false
  end

  def pbFlashCmdCancelButton
    pbFlashBagCancelButton
  end

  # Flashes whichever pocket arrow was clicked between its normal and _p
  def pbFlashBagPocketArrow(direction)
    key  = (direction == 1) ? "bagPocketArrowRight" : "bagPocketArrowLeft"
    file = (direction == 1) ? "rightarrow" : "leftarrow"
    sprite = @sprites[key]
    return if !sprite
    folder = Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH
    2.times do
      sprite.setBitmap(folder + file + "_p.png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
      sprite.setBitmap(folder + file + ".png")
      BAG_CANCEL_FLASH_FRAMES.times { pbUpdate }
    end
  end

  # Switches the item grid to the next/previous page
  def pbSwitchBagItemPage(category, direction)
    pageCount = pbBagCategoryPageCount(category)
    newPage = (@bagCurrentPage || 0) + direction
    return if newPage < 0 || newPage >= pageCount
    pbPlayDecisionSE
    pbFlashBagPocketArrow(direction)

    sel = @sprites["bagItemSel"]
    sel.visible = false if sel

    distance = BAG_ITEM_AREA_SIZE[0]
    incomingItems = pbBagCategoryItems(category, newPage)
    BAG_ITEM_SLOTS.times do |slot|
      key = "bagItemButtonIncoming_#{slot}"
      pos = pbBagItemButtonPos(slot)
      @sprites[key] ||= Sprite.new(@viewport)
      @sprites[key].x = pos[0] + (direction * distance)
      @sprites[key].y = pos[1]
      @sprites[key].z = Z_BAG_ITEM_BUTTON
      @sprites[key].opacity = BAG_ITEM_BUTTON_OPACITY_NORMAL
      @sprites[key].bitmap&.dispose
      @sprites[key].bitmap = pbBuildBagItemButtonBitmap(incomingItems[slot])
      @sprites[key].visible = true
    end

    BAG_ITEM_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_ITEM_SLIDE_FRAMES.to_f
      BAG_ITEM_SLOTS.times do |slot|
        pos = pbBagItemButtonPos(slot)
        outSprite = @sprites["bagItemButton_#{slot}"]
        inSprite  = @sprites["bagItemButtonIncoming_#{slot}"]
        outSprite.x = pos[0] - (direction * distance * progress)
        inSprite.x  = (pos[0] + (direction * distance)) - (direction * distance * progress)
      end
      pbUpdate
    end

    BAG_ITEM_SLOTS.times do |slot|
      pos = pbBagItemButtonPos(slot)
      outSprite = @sprites["bagItemButton_#{slot}"]
      inSprite  = @sprites["bagItemButtonIncoming_#{slot}"]
      outSprite.bitmap&.dispose
      outSprite.bitmap = inSprite.bitmap   # ownership transferred - don't dispose it below
      outSprite.x = pos[0]
      inSprite.bitmap = nil
      inSprite.visible = false
    end

    @bagCurrentPage = newPage
    @bagItemIds = incomingItems
    pbBakeBagPocketHeader(category)

    row = (@bagItemSelectedSlot || 0) / BAG_ITEM_GRID_COLS
    landCol = (direction == 1) ? 0 : (BAG_ITEM_GRID_COLS - 1)
    landSlot = (row * BAG_ITEM_GRID_COLS) + landCol
    landSlot = (0...BAG_ITEM_SLOTS).find { |slot| pbItemIndexEnabled?(slot) } || 0 if !pbItemIndexEnabled?(landSlot)
    pbUpdateItemGridSelector(landSlot)
  end

  # Builds the Use Item page's "USE" button
  def pbBuildUseItemButton
    return if @sprites["useItemButton"]
    size = BAG_UI_SIZE["command"]
    sprite = IconSprite.new(@viewport)
    base = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + BAG_UI_FILES["command"] + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    text_w = bmp.text_size(USE_ITEM_BUTTON_TEXT).width
    center_x = size[0] / 2
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[USE_ITEM_BUTTON_TEXT, left_x, BAG_UI_COMMAND_TEXT_Y, :left,
       BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]])
    sprite.bitmap = bmp
    sprite.z = Z_BAG_UI
    sprite.opacity = 0
    sprite.visible = false
    @sprites["useItemButton"] = sprite
  end

  # Builds the item_description.png sprite if it doesn't already exist,
  # hidden/transparent until the Use Item page is actually shown.
  def pbBuildUseItemDesc
    return if @sprites["useItemDesc"]
    sprite = IconSprite.new(@viewport)
    sprite.x = USE_ITEM_DESC_POS[0]
    sprite.y = USE_ITEM_DESC_POS[1]
    sprite.z = Z_USE_ITEM_DESC
    sprite.opacity = 0
    sprite.visible = false
    @sprites["useItemDesc"] = sprite
  end

  # Splits text into lines that each fit within max_width when drawn
  def pbWrapUseItemDescLines(bmp, text, max_width)
    lines = []
    currentLine = ""
    text.split(" ").each do |word|
      candidate = currentLine.empty? ? word : "#{currentLine} #{word}"
      if bmp.text_size(candidate).width > max_width && !currentLine.empty?
        lines.push(currentLine)
        currentLine = word
      else
        currentLine = candidate
      end
    end
    lines.push(currentLine) if !currentLine.empty?
    return lines
  end

  # Bakes the Use Item page's content onto item_description.png
  def pbDrawUseItemDesc(item_id)
    sprite = @sprites["useItemDesc"]
    return if !sprite
    sprite.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + USE_ITEM_DESC_FILE + ".png")
    bmp = sprite.bitmap
    pbSetSystemFont(bmp)
    itemData = GameData::Item.get(item_id)
    return if !itemData

    area_center = USE_ITEM_TEXT_AREA_X + (USE_ITEM_TEXT_AREA_WIDTH / 2)

    name = itemData.name
    name_w = bmp.text_size(name).width
    name_x = area_center - (name_w / 2)
    name_x -= 1 if name_x.odd?
    name_x = USE_ITEM_TEXT_AREA_X if name_x < USE_ITEM_TEXT_AREA_X
    pbDrawTextPositions(bmp, [[name, name_x, USE_ITEM_NAME_Y, :left, USE_ITEM_TEXT_COLOR, USE_ITEM_TEXT_SHADOW_COLOR]])

    qtyText = "x#{pbBagItemQuantity(item_id)}"
    pbDrawTextPositions(bmp, [[qtyText, USE_ITEM_QTY_POS[0], USE_ITEM_QTY_POS[1], :left,
       USE_ITEM_TEXT_COLOR, USE_ITEM_TEXT_SHADOW_COLOR]])

    iconFile = (GameData::Item.icon_filename(item_id) rescue nil)
    if iconFile && FileTest.exist?(iconFile + ".png")
      iconBase = Bitmap.new(iconFile)
      bmp.blt(USE_ITEM_ICON_POS[0], USE_ITEM_ICON_POS[1], iconBase, iconBase.rect)
      iconBase.dispose
    end

    desc = itemData.description || ""
    lines = pbWrapUseItemDescLines(bmp, desc, USE_ITEM_TEXT_AREA_WIDTH)
    lines.each_with_index do |line, i|
      line_w = bmp.text_size(line).width
      line_x = area_center - (line_w / 2)
      line_x -= 1 if line_x.odd?
      line_x = USE_ITEM_TEXT_AREA_X if line_x < USE_ITEM_TEXT_AREA_X
      line_y = USE_ITEM_DESC_Y + (i * USE_ITEM_DESC_LINE_HEIGHT)
      pbDrawTextPositions(bmp, [[line, line_x, line_y, :left, USE_ITEM_TEXT_COLOR, USE_ITEM_TEXT_SHADOW_COLOR]])
    end
  end

  # The Use Item page
  def pbShowUseItemPage(category, item_id)
    pbBuildUseItemButton
    pbBuildUseItemDesc
    pbDrawUseItemDesc(item_id)

    useBtn = @sprites["useItemButton"]
    cancel = @sprites["bagUI_cancel"]
    desc   = @sprites["useItemDesc"]
    usePos = BAG_UI_POS["command"]
    cancelPos = BAG_UI_POS["cancel"]

    useBtn.x = usePos[0]
    useBtn.y = Graphics.height
    useBtn.opacity = 0
    useBtn.visible = true
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true
    desc.opacity = 0
    desc.visible = true

    landOnKey = "command"
    @useItemSelectedKey = landOnKey
    pbUpdateBagSelector(landOnKey)
    sel = @sprites["bagSel"]
    selRestX, selRestY = sel.x, sel.y
    sel.opacity = 0
    sel.visible = true

    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      useBtn.y = Graphics.height + ((usePos[1] - Graphics.height) * progress)
      useBtn.opacity = (255 * progress).to_i
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      desc.opacity = (255 * progress).to_i
      # landOnKey is always "command" (slides on Y, from the bottom) here,
      # so the selector rides along on Y the same way pbShowBagButtons
      # does it for any bottom-sliding button.
      sel.y = Graphics.height + BAG_SEL_OFFSET["command"][1] +
              ((selRestY - (Graphics.height + BAG_SEL_OFFSET["command"][1])) * progress)
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    useBtn.y = usePos[1]
    useBtn.opacity = 255
    cancel.x = cancelPos[0]
    cancel.opacity = 255
    desc.opacity = 255
    sel.x, sel.y = selRestX, selRestY
    sel.opacity = 255

    pbUseItemMenuLoop(category, item_id)
  end

  # Reverse of pbShowUseItemPage's entrance
  def pbHideUseItemPage
    useBtn = @sprites["useItemButton"]
    cancel = @sprites["bagUI_cancel"]
    desc   = @sprites["useItemDesc"]
    usePos = BAG_UI_POS["command"]
    cancelPos = BAG_UI_POS["cancel"]
    sel = @sprites["bagSel"]
    selKey = @useItemSelectedKey
    selStartX = sel ? sel.x : nil
    selStartY = sel ? sel.y : nil
    selStartOpacity = sel ? sel.opacity : 0
    useStartOpacity = useBtn.opacity
    cancelStartOpacity = cancel.opacity
    descStartOpacity = desc ? desc.opacity : 0

    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      useBtn.y = usePos[1] + ((Graphics.height - usePos[1]) * progress)
      useBtn.opacity = (useStartOpacity * (1 - progress)).to_i
      cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
      cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      desc.opacity = (descStartOpacity * (1 - progress)).to_i if desc
      if sel
        case selKey
        when "command"
          sel.y = selStartY + (((Graphics.height + BAG_SEL_OFFSET["command"][1]) - selStartY) * progress)
        when "cancel"
          sel.x = selStartX + (((Graphics.width + BAG_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    useBtn.visible = false
    cancel.visible = false
    desc.visible = false if desc
    sel.visible = false if sel
  end

  # The Use Item page's own mini input loop
  def pbUseItemMenuLoop(category, item_id)
    loop do
      pbUpdate

      dCol = 0
      dCol = -1 if Input.trigger?(Input::LEFT)
      dCol = 1  if Input.trigger?(Input::RIGHT)
      if dCol != 0
        idx = USE_ITEM_GRID.index(@useItemSelectedKey) || 0
        newKey = USE_ITEM_GRID[(idx + dCol) % USE_ITEM_GRID.length]
        pbPlayCursorSE
        pbUpdateBagSelector(newKey)
        @useItemSelectedKey = newKey
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        clickedKey = "command" if @sprites["useItemButton"] && Mouse.over?(@sprites["useItemButton"])
        clickedKey = "cancel"  if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != @useItemSelectedKey
        pbUpdateBagSelector(clickedKey)
        @useItemSelectedKey = clickedKey
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if confirmed && @useItemSelectedKey == "cancel"
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideUseItemPage
        break
      elsif confirmed
        pbPlayDecisionSE
        if pbUseItemIsDoubleBattleBall?(category)
          pbHideUseItemPage
          target = pbChooseBallTarget
          if target < 0
            pbShowUseItemPage(category, item_id)
            break
          end
          throw :bagItemUsed, item_id
        end
        # Does NOT call pbSetLastUsedItem here
        pbHideUseItemPage
        throw :bagItemUsed, item_id
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideUseItemPage
        break
      end
    end
  end

  def pbUseItemIsDoubleBattleBall?(category)
    return category == "balls" && !@battle.singleBattle?
  end

  # Target picker for throwing a Poke Ball in a double battle
  def pbChooseBallTarget
    eligible = TARGET_PANEL_KEYS.select do |key|
      next false if !key.start_with?("enemy")
      idx = TARGET_PANEL_BATTLER_INDEX[key]
      idx && idx < @battle.battlers.length && @battle.battlers[idx] && !@battle.battlers[idx].fainted?
    end
    return -1 if eligible.empty?
    if eligible.length == 1
      @lastBallTargetIdx = TARGET_PANEL_BATTLER_INDEX[eligible.first]
      return @lastBallTargetIdx
    end
    currentKey = eligible.first
    pbShowTargetPanels(currentKey, false)
    result = -1
    loop do
      pbUpdate
      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbTargetPanelNextKey(currentKey, dRow, dCol, eligible)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        pbUpdateTargetPanelOpacity(currentKey, false)
      end
      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        eligible.each do |key|
          sprite = @sprites["targetPanel_#{key}"]
          clickedKey = key if sprite && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey
        pbUpdateTargetPanelOpacity(currentKey, false)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey
      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        result = -1
        break
      elsif confirmed
        pbPlayDecisionSE
        result = TARGET_PANEL_BATTLER_INDEX[currentKey]
        @lastBallTargetIdx = result
        break
      end
    end
    pbHideTargetPanels
    return result
  end

  def pbBagIndexEnabled?(key)
    return !(key == "command" && pbLastUsedItem.nil?)
  end

  # Bag page's own input loop
  def pbBagMenuLoop
    row = 0
    col = 0   # starts on hp, top-left of the grid
    loop do
      pbUpdate
      oldRow, oldCol = row, col

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      if dRow != 0 || dCol != 0
        newRow, newCol = row, col
        loop do
          newRow = (newRow + dRow) % BAG_GRID.length
          newCol = (newCol + dCol) % BAG_GRID[newRow].length
          break if pbBagIndexEnabled?(BAG_GRID[newRow][newCol])
        end
        row, col = newRow, newCol
      end

      clickedKey = nil
      if Mouse.active? && Mouse.click?
        BAG_UI_FILES.each_key do |key|
          next if !pbBagIndexEnabled?(key)
          sprite = @sprites["bagUI_#{key}"]
          clickedKey = key if sprite && Mouse.over?(sprite)
        end
      end
      if clickedKey
        BAG_GRID.each_with_index do |gridRow, r|
          c = gridRow.index(clickedKey)
          row, col = r, c if c
        end
      end

      currentBagKey = BAG_GRID[row][col]
      confirmedCancel = currentBagKey == "cancel" && (Input.trigger?(Input::USE) || clickedKey == "cancel")
      pocketKeys = ["hp", "restore", "balls", "battle"]
      confirmedPocket = pocketKeys.include?(currentBagKey) && (Input.trigger?(Input::USE) || clickedKey == currentBagKey)
      confirmedCommand = currentBagKey == "command" && pbBagIndexEnabled?("command") &&
                          (Input.trigger?(Input::USE) || clickedKey == "command")

      if row != oldRow || col != oldCol
        pbUpdateBagButtonOpacity(currentBagKey)
        pbUpdateBagSelector(currentBagKey)
        pbPlayCursorSE unless confirmedCancel || confirmedPocket || confirmedCommand
      end

      if confirmedPocket
        pbPlayDecisionSE
        pbHideBagUI                        # all six exit, including cancel
        pbShowBagPocket(currentBagKey)     # header scroll in (cancel rides in with it) -> waits for cancel -> scroll out
        pbShowBagButtons(currentBagKey)    # all six re-enter, landing back on the pocket just visited
        next
      end

      # item_command jumps straight to the Use Item page for the saved
      # last-used item
      if confirmedCommand
        pbPlayDecisionSE
        item_id = pbLastUsedItem
        pbHideBagUI
        pbShowUseItemPage(nil, item_id)
        pbShowBagButtons("command")
        next
      end

      if Input.trigger?(Input::BACK) || confirmedCancel
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHideBagUI(false)   # silent - pbCommandMenuEx's own SlideUp follows right after
        break
      end
    end
  end

  # Entry point the battle engine calls when the player picks Bag from the
  # Command menu (Battle#pbItemMenu
  alias customUI_pbItemMenu pbItemMenu
  def pbItemMenu(idxBattler, firstAction)
    wasSecondBattlerOfDouble = @cmdCancelWanted
    pbHideDataBoxes
    pbHideCommandButtons
    pbScrollMessageBoxOut
    registered = false
    loop do
      @lastBallTargetIdx = nil   # cleared per item, so a stale pick never leaks into an unrelated one
      item_id = pbShowBagUI   # blocks until the player backs out, or confirms USE on an item
      break if !item_id
      item = GameData::Item.get(item_id)
      useType = item.battle_use
      idxPkmn = -1
      idxMove = -1
      case useType
      when 1, 3
        # HP/PP restore, status restore, and battle item pockets all pick a
        # target from the Party page now
        idxPkmn = pbChooseItemTargetPokemon(_INTL("Use {1} on who?", item.name))
      when 4
        opponents = @battle.allOtherSideBattlers(idxBattler)
        if opponents.length == 1
          idxPkmn = opponents[0].index
        elsif @lastBallTargetIdx && opponents.any? { |b| b.index == @lastBallTargetIdx }
          idxPkmn = @lastBallTargetIdx
        end
      when 5
        idxPkmn = idxBattler
      end
      if idxPkmn < 0
        pbHideMessageBox
        next
      end
      if yield item_id, useType, idxPkmn, idxMove, self
        # Only mark it as the last-used item once confirmed
        pbSetLastUsedItem(item_id)
        registered = true
        break
      end
      # Engine rejected the choice (bad target, can't be used on that
      # Pokémon, no effect, etc.)
      pbHideMessageBox
    end
    if registered && (@battle.singleBattle? || wasSecondBattlerOfDouble)
      # Item accepted and there's nobody else left to act this round - close
      # the whole Command page, same as Fight/Run.
      pbHideCommandPageAssets
    elsif registered
      # Item accepted, but this was the FIRST Pokemon of a double battle
      pbShowCommandButtons("fight")
    end
    pbShowDataBoxes
    return registered
  end

  # Party page - replaces the default Essentials party screen. 
  def pbPartySlotEnabled?(key)
    idx = PARTY_SLOT_KEYS.index(key)
    return false if !idx
    party = @battle.pbParty(0)
    return party[idx] ? true : false
  end

  # Subpixel-safe centering on both axes
  def pbDrawCenteredText(bmp, text, centerX, centerY, color, shadow)
    size = bmp.text_size(text)
    left_x = centerX - (size.width / 2)
    left_x -= 1 if left_x.odd?
    top_y = centerY - (size.height / 2)
    top_y -= 1 if top_y.odd?
    pbDrawTextPositions(bmp, [[text, left_x, top_y, :left, color, shadow]])
  end

  # Builds/rebakes all six slot buttons
  def pbBuildPartySlotButtons
    party = @battle.pbParty(0)
    PARTY_SLOT_KEYS.each_with_index do |key, idx|
      spriteKey = "partySlot_#{key}"
      if !@sprites[spriteKey]
        @sprites[spriteKey] = IconSprite.new(@viewport)
        @sprites[spriteKey].z = Z_COMMAND_BUTTON
        @sprites[spriteKey].x, @sprites[spriteKey].y = PARTY_SLOT_POS[key]
        @sprites[spriteKey].opacity = 0
        @sprites[spriteKey].visible = false
      end
      pbDrawPartySlot(key, party[idx], false)
    end
    pbBuildPartyIcons(party)
  end

  # (Re)bakes one slot's own bitmap
  def pbDrawPartySlot(key, pkmn, selected)
    sprite = @sprites["partySlot_#{key}"]
    return if !sprite
    file = pkmn ? (selected ? PARTY_SLOT_SEL_FILE : PARTY_SLOT_ACTIVE_FILE) : PARTY_SLOT_EMPTY_FILE
    base = Bitmap.new(PARTY_GRAPHICS_PATH + file + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    if pkmn
      pbSetSystemFont(bmp)
      texts = [[pkmn.name, PARTY_NAME_POS[0], PARTY_NAME_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]]
      if pkmn.gender != 2   # 0 = male, 1 = female, 2 = genderless (no symbol)
        genderText  = (pkmn.gender == 0) ? "♂" : "♀"
        genderColor = (pkmn.gender == 0) ? SUMMARY_GENDER_MALE_COLOR : SUMMARY_GENDER_FEMALE_COLOR
        texts << [genderText, PARTY_GENDER_POS[0], PARTY_GENDER_POS[1], :left, genderColor, BAG_UI_TEXT_SHADOW_COLOR]
      end
      texts << ["Lv.#{pkmn.level}", PARTY_LEVEL_POS[0], PARTY_LEVEL_POS[1], :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]
      pbDrawTextPositions(bmp, texts)

      frame = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + PARTY_HP_OVERLAY_FILE + ".png")
      bmp.blt(PARTY_HP_OVERLAY_POS[0], PARTY_HP_OVERLAY_POS[1], frame, frame.rect)
      frame.dispose

      hpFraction = pbBattlerHPFraction(pkmn)
      hpBase = Bitmap.new(PARTY_GRAPHICS_PATH + PARTY_HP_BAR_FILE + ".png")
      hpRow = (hpFraction > 0.5) ? 0 : (hpFraction > 0.2) ? 1 : 2
      hpWidth = (hpBase.width * hpFraction).round
      if hpWidth > 0
        bmp.blt(PARTY_HP_BAR_POS[0], PARTY_HP_BAR_POS[1], hpBase, Rect.new(0, hpRow * 4, hpWidth, 4))
      end
      hpBase.dispose

      pbDrawCenteredText(bmp, "#{pkmn.hp}/#{pkmn.totalhp}", PARTY_HP_TEXT_CENTER[0], PARTY_HP_TEXT_CENTER[1],
                          BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR)
    end
    sprite.bitmap&.dispose
    sprite.bitmap = bmp
  end

  # Six animated Pokemon icons
  def pbBuildPartyIcons(party)
    PARTY_SLOT_KEYS.each_with_index do |key, idx|
      spriteKey = "partyIcon_#{key}"
      @sprites[spriteKey]&.dispose
      @sprites[spriteKey] = nil
      pkmn = party[idx]
      next if !pkmn
      pos = PARTY_SLOT_POS[key]
      @sprites[spriteKey] = PokemonIconSprite.new(pkmn, @viewport)
      icon = @sprites[spriteKey]
      icon.x = pos[0] + PARTY_ICON_OFFSET[0]
      icon.y = pos[1] + PARTY_ICON_OFFSET[1]
      icon.z = Z_COMMAND_BUTTON + 1
      icon.opacity = 0
      icon.visible = false
    end
  end

  def pbPartyIconSprites
    return PARTY_SLOT_KEYS.filter_map { |key| @sprites["partyIcon_#{key}"] }
  end

  # Steps every party icon's own bounce/blink animation
  def pbAnimatePartyIcons
    PARTY_SLOT_KEYS.each do |key|
      icon = @sprites["partyIcon_#{key}"]
      icon.update if icon && icon.visible
    end
  end

  # All six slot sprites, in key order - used for the fade cascade.
  def pbPartySlotSprites
    return PARTY_SLOT_KEYS.filter_map { |key| @sprites["partySlot_#{key}"] }
  end

  def pbUpdatePartyMenuOpacity(selectedKey)
    party = @battle.pbParty(0)
    PARTY_SLOT_KEYS.each do |key|
      sprite = @sprites["partySlot_#{key}"]
      next if !sprite
      idx = PARTY_SLOT_KEYS.index(key)
      pbDrawPartySlot(key, party[idx], key == selectedKey)
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdatePartyMenuSelector(selectedKey)
  end

  def pbUpdatePartyMenuSelector(selectedKey)
    if !@sprites["partyMenuSel"]
      @sprites["partyMenuSel"] = IconSprite.new(@viewport)
      @sprites["partyMenuSel"].visible = false
      @partyMenuSelFile  = nil
      @partyMenuSelFrame = 0
      @partyMenuSelTick  = 0
    end
    sel = @sprites["partyMenuSel"]
    file = (selectedKey == "cancel") ? FIGHT_SEL_FILES["cancel"] : PARTY_MENU_SEL_FILE
    if @partyMenuSelFile != file
      sel.setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + file + ".png")
      frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @partyMenuSelFile  = file
      @partyMenuSelFrame = 0
      @partyMenuSelTick  = 0
    end
    pos = (selectedKey == "cancel") ? BAG_UI_POS["cancel"] : PARTY_SLOT_POS[selectedKey]
    offset = (selectedKey == "cancel") ? FIGHT_SEL_OFFSET["cancel"] : PARTY_MENU_SEL_OFFSET
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @partyMenuSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  def pbAnimatePartyMenuSelector
    sel = @sprites["partyMenuSel"]
    return if !sel || !sel.visible
    @partyMenuSelTick += 1
    return if @partyMenuSelTick < SEL_ANIM_SPEED
    @partyMenuSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @partyMenuSelFrame = (@partyMenuSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @partyMenuSelFrame * frameHeight
  end

  def pbPartyMenuNextKey(currentKey, dRow, dCol)
    if currentKey == "cancel"
      return currentKey if dRow != -1
      return @partyMenuLastSlotKey if @partyMenuLastSlotKey && pbPartySlotEnabled?(@partyMenuLastSlotKey)
      return PARTY_SLOT_KEYS.find { |key| pbPartySlotEnabled?(key) } || currentKey
    end
    pos = PARTY_SLOT_GRID[currentKey]
    return currentKey if !pos
    row, col = pos
    if dCol != 0
      partnerKey = PARTY_SLOT_GRID.key([row, col + dCol])
      return (partnerKey && pbPartySlotEnabled?(partnerKey)) ? partnerKey : currentKey
    elsif dRow != 0
      partnerKey = PARTY_SLOT_GRID.key([row + dRow, col])
      return "cancel" if dRow == 1 && (!partnerKey || !pbPartySlotEnabled?(partnerKey))
      return (partnerKey && pbPartySlotEnabled?(partnerKey)) ? partnerKey : currentKey
    end
    return currentKey
  end

  def pbShowPartyMenu(selectedKey, promptText = PARTY_PROMPT_TEXT)
    pbBuildBagUI   # make sure bagUI_cancel exists even if Bag/Fight haven't opened yet this battle
    pbBuildPartySlotButtons
    pbSEPlay("SlideUp", 60)

    box = @sprites["messageBox"]
    boxRestY = MESSAGE_REST_Y
    if box
      box.x = 0
      box.y = boxRestY + MESSAGE_SCROLL_OFFSET
      box.visible = true
    end

    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true

    slotSprites = pbPartySlotSprites
    slotSprites.each { |sprite| sprite.opacity = 0; sprite.visible = true }
    iconSprites = pbPartyIconSprites
    iconSprites.each { |sprite| sprite.opacity = 0; sprite.visible = true }

    pbUpdatePartyMenuSelector(selectedKey)
    sel = @sprites["partyMenuSel"]
    selRestX = sel.x
    slideSelWithCancel = (selectedKey == "cancel")
    sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0] if slideSelWithCancel
    sel.opacity = 0

    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = boxRestY + (MESSAGE_SCROLL_OFFSET * (1 - progress)) if box
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      slotSprites.each { |sprite| sprite.opacity = (CMD_BUTTON_OPACITY_NORMAL * progress).to_i }
      iconSprites.each { |sprite| sprite.opacity = (255 * progress).to_i }
      if slideSelWithCancel
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    box.y = boxRestY if box
    cancel.x = cancelPos[0]
    slotSprites.each { |sprite| sprite.opacity = CMD_BUTTON_OPACITY_NORMAL }
    iconSprites.each { |sprite| sprite.opacity = 255 }
    sel.x = selRestX
    sel.opacity = 255
    pbUpdatePartyMenuOpacity(selectedKey)
    pbSetMessageWindowText(promptText)
  end

  # Reverse of pbShowPartyMenu.
  def pbHidePartyMenu
    pbSEPlay("SlideDown", 60)
    if @sprites["messageWindow"]
      @sprites["messageWindow"].text = ""
      @sprites["messageWindow"].visible = false
    end
    box = @sprites["messageBox"]
    boxRestY = MESSAGE_REST_Y
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancelStartOpacity = cancel ? cancel.opacity : 0
    slotSprites = pbPartySlotSprites
    slotStartOpacity = {}
    slotSprites.each { |sprite| slotStartOpacity[sprite] = sprite.opacity }
    iconSprites = pbPartyIconSprites
    iconStartOpacity = {}
    iconSprites.each { |sprite| iconStartOpacity[sprite] = sprite.opacity }
    sel = @sprites["partyMenuSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selBoundToCancel = sel && @partyMenuSelKey == "cancel"
    MESSAGE_SCROLL_FRAMES.times do |frame|
      progress = (frame + 1) / MESSAGE_SCROLL_FRAMES.to_f
      box.y = boxRestY + (MESSAGE_SCROLL_OFFSET * progress) if box
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      slotSprites.each { |sprite| sprite.opacity = (slotStartOpacity[sprite] * (1 - progress)).to_i }
      iconSprites.each { |sprite| sprite.opacity = (iconStartOpacity[sprite] * (1 - progress)).to_i }
      if sel
        if selBoundToCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    box.visible = false if box
    if cancel
      cancel.visible = false
      cancel.z = Z_BAG_UI
    end
    slotSprites.each { |sprite| sprite.visible = false }
    iconSprites.each { |sprite| sprite.visible = false }
    sel.visible = false if sel
  end

  # Builds/rebakes the summary + check_moves buttons for the Party page's
  def pbBuildPartyActionButtons(pkmn)
    pbBuildBagUI
    if !@sprites["partyAction_shift"]
      @sprites["partyAction_shift"] = IconSprite.new(@viewport)
      @sprites["partyAction_shift"].z = Z_COMMAND_BUTTON
      @sprites["partyAction_shift"].x, @sprites["partyAction_shift"].y = PARTY_SHIFT_POS
      @sprites["partyAction_shift"].opacity = 0
      @sprites["partyAction_shift"].visible = false
    end
    pbDrawPartyShiftContent(pkmn)
    pbBuildPartyShiftIcon(pkmn)
    if !@sprites["partyAction_summary"]
      @sprites["partyAction_summary"] = IconSprite.new(@viewport)
      @sprites["partyAction_summary"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + FIGHT_SUMMARY_FILE + ".png")
      @sprites["partyAction_summary"].z = Z_COMMAND_BUTTON
      @sprites["partyAction_summary"].x, @sprites["partyAction_summary"].y = PARTY_SUMMARY_POS
      @sprites["partyAction_summary"].opacity = 0
      @sprites["partyAction_summary"].visible = false
    end
    if !@sprites["partyAction_check_moves"]
      @sprites["partyAction_check_moves"] = IconSprite.new(@viewport)
      @sprites["partyAction_check_moves"].setBitmap(FIGHT_SUMMARY_GRAPHICS_PATH + FIGHT_CHECK_MOVES_FILE + ".png")
      @sprites["partyAction_check_moves"].z = Z_COMMAND_BUTTON
      @sprites["partyAction_check_moves"].x, @sprites["partyAction_check_moves"].y = PARTY_CHECK_MOVES_POS
      @sprites["partyAction_check_moves"].opacity = 0
      @sprites["partyAction_check_moves"].visible = false
    end
  end

  # Whether this Pokemon is currently out on the field (fainted battlers
  # don't count - a fainted active Pokemon still needs to be offered as a
  # switch target, not shown as "IN BATTLE").
  def pbPartyPokemonActive?(pkmn)
    return @battle.battlers.any? { |b| b && !b.fainted? && b.pokemon == pkmn }
  end

  # (Re)bakes the shift button's own bitmap
  def pbDrawPartyShiftContent(pkmn)
    sprite = @sprites["partyAction_shift"]
    return if !sprite
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + PARTY_SHIFT_FILE + ".png")
    bmp = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    centerX = PARTY_SHIFT_WIDTH / 2

    nameText = pkmn.name
    genderText = (pkmn.gender != 2) ? ((pkmn.gender == 0) ? " ♂" : " ♀") : ""
    genderColor = (pkmn.gender == 0) ? SUMMARY_GENDER_MALE_COLOR : SUMMARY_GENDER_FEMALE_COLOR
    nameWidth = bmp.text_size(nameText).width
    genderWidth = genderText.empty? ? 0 : bmp.text_size(genderText).width
    totalWidth = nameWidth + genderWidth
    left_x = centerX - (totalWidth / 2)
    left_x -= 1 if left_x.odd?
    texts = [[nameText, left_x, PARTY_SHIFT_NAME_GENDER_Y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]]
    if !genderText.empty?
      texts << [genderText, left_x + nameWidth, PARTY_SHIFT_NAME_GENDER_Y, :left, genderColor, BAG_UI_TEXT_SHADOW_COLOR]
    end

    stateText = pbPartyPokemonActive?(pkmn) ? "IN BATTLE" : "SWITCH"
    stateWidth = bmp.text_size(stateText).width
    state_x = centerX - (stateWidth / 2)
    state_x -= 1 if state_x.odd?
    texts << [stateText, state_x, PARTY_SHIFT_STATE_Y, :left, BAG_UI_TEXT_COLOR, BAG_UI_TEXT_SHADOW_COLOR]

    pbDrawTextPositions(bmp, texts)
    sprite.bitmap&.dispose
    sprite.bitmap = bmp
  end

  # Animated PokemonIconSprite for the shift button
  def pbBuildPartyShiftIcon(pkmn)
    @sprites["partyActionShiftIcon"]&.dispose
    @sprites["partyActionShiftIcon"] = PokemonIconSprite.new(pkmn, @viewport)
    icon = @sprites["partyActionShiftIcon"]
    icon.x = PARTY_SHIFT_POS[0] + PARTY_SHIFT_ICON_POS[0]
    icon.y = PARTY_SHIFT_POS[1] + PARTY_SHIFT_ICON_POS[1]
    icon.z = Z_COMMAND_BUTTON + 1
    icon.opacity = 0
    icon.visible = false
  end

  def pbAnimatePartyShiftIcon
    icon = @sprites["partyActionShiftIcon"]
    icon.update if icon && icon.visible
  end

  def pbUpdatePartyActionOpacity(selectedKey)
    shift = @sprites["partyAction_shift"]
    shift.opacity = (selectedKey == "shift") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if shift
    summary = @sprites["partyAction_summary"]
    summary.opacity = (selectedKey == "summary") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if summary
    checkMoves = @sprites["partyAction_check_moves"]
    checkMoves.opacity = (selectedKey == "check_moves") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if checkMoves
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdatePartyActionSelector(selectedKey)
  end

  # shift/summary/check_moves all reuse the same selector graphic/offset

  def pbUpdatePartyActionSelector(selectedKey)
    if !@sprites["partyActionSel"]
      @sprites["partyActionSel"] = IconSprite.new(@viewport)
      @sprites["partyActionSel"].visible = false
      @partyActionSelFile  = nil
      @partyActionSelFrame = 0
      @partyActionSelTick  = 0
    end
    sel = @sprites["partyActionSel"]
    file = case selectedKey
           when "cancel" then FIGHT_SEL_FILES["cancel"]
           when "shift"  then PARTY_SHIFT_SEL_FILE
           else FIGHT_SEL_FILES["summary"]
           end
    path = (selectedKey == "cancel") ? Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH : FIGHT_SUMMARY_GRAPHICS_PATH
    if @partyActionSelFile != file
      sel.setBitmap(path + file + ".png")
      frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
      sel.src_rect.set(0, 0, sel.bitmap.width, frameHeight)
      @partyActionSelFile  = file
      @partyActionSelFrame = 0
      @partyActionSelTick  = 0
    end
    pos = case selectedKey
          when "cancel"  then BAG_UI_POS["cancel"]
          when "shift"   then PARTY_SHIFT_POS
          when "summary" then PARTY_SUMMARY_POS
          else PARTY_CHECK_MOVES_POS
          end
    offset = case selectedKey
             when "cancel" then FIGHT_SEL_OFFSET["cancel"]
             when "shift"  then PARTY_SHIFT_SEL_OFFSET
             else FIGHT_SEL_OFFSET["summary"]
             end
    sel.x = pos[0] + offset[0]
    sel.y = pos[1] + offset[1]
    @partyActionSelKey = selectedKey
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  def pbAnimatePartyActionSelector
    sel = @sprites["partyActionSel"]
    return if !sel || !sel.visible
    @partyActionSelTick += 1
    return if @partyActionSelTick < SEL_ANIM_SPEED
    @partyActionSelTick = 0
    frameHeight = sel.bitmap.height / FIGHT_SEL_FRAMES
    @partyActionSelFrame = (@partyActionSelFrame + 1) % FIGHT_SEL_FRAMES
    sel.src_rect.y = @partyActionSelFrame * frameHeight
  end

  # Entrance for the action menu - called right after pbHidePartyMenu
  def pbShowPartyActionMenu(selectedKey, pkmn)
    pbBuildPartyActionButtons(pkmn)
    pbSEPlay("SlideUp", 60)

    shift = @sprites["partyAction_shift"]
    shift.y = Graphics.height
    shiftRestY = PARTY_SHIFT_POS[1]
    shift.opacity = 0
    shift.visible = true

    shiftIcon = @sprites["partyActionShiftIcon"]
    shiftIconRestY = PARTY_SHIFT_POS[1] + PARTY_SHIFT_ICON_POS[1]
    shiftIcon.y = Graphics.height + PARTY_SHIFT_ICON_POS[1]
    shiftIcon.opacity = 0
    shiftIcon.visible = true

    summary = @sprites["partyAction_summary"]
    summary.y = Graphics.height
    summaryRestY = PARTY_SUMMARY_POS[1]
    summary.opacity = 0
    summary.visible = true

    checkMoves = @sprites["partyAction_check_moves"]
    checkMoves.y = Graphics.height
    checkMovesRestY = PARTY_CHECK_MOVES_POS[1]
    checkMoves.opacity = 0
    checkMoves.visible = true

    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    cancel.z = Z_BAG_POCKET_ARROW
    cancel.x = Graphics.width
    cancel.y = cancelPos[1]
    cancel.opacity = 0
    cancel.visible = true

    pbUpdatePartyActionSelector(selectedKey)
    sel = @sprites["partyActionSel"]
    selRestX = sel.x
    selRestY = sel.y
    slideSelWithCancel = (selectedKey == "cancel")
    if slideSelWithCancel
      sel.x = Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]
    else
      sel.y = Graphics.height + FIGHT_SEL_OFFSET["summary"][1]
    end
    sel.opacity = 0

    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      shift.y = Graphics.height + ((shiftRestY - Graphics.height) * progress)
      shift.opacity = (255 * progress).to_i
      shiftIcon.y = (Graphics.height + PARTY_SHIFT_ICON_POS[1]) + ((shiftIconRestY - (Graphics.height + PARTY_SHIFT_ICON_POS[1])) * progress)
      shiftIcon.opacity = (255 * progress).to_i
      summary.y = Graphics.height + ((summaryRestY - Graphics.height) * progress)
      summary.opacity = (255 * progress).to_i
      checkMoves.y = Graphics.height + ((checkMovesRestY - Graphics.height) * progress)
      checkMoves.opacity = (255 * progress).to_i
      cancel.x = Graphics.width + ((cancelPos[0] - Graphics.width) * progress)
      cancel.opacity = (255 * progress).to_i
      if slideSelWithCancel
        sel.x = (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) +
                ((selRestX - (Graphics.width + FIGHT_SEL_OFFSET["cancel"][0])) * progress)
      else
        sel.y = (Graphics.height + FIGHT_SEL_OFFSET["summary"][1]) +
                ((selRestY - (Graphics.height + FIGHT_SEL_OFFSET["summary"][1])) * progress)
      end
      sel.opacity = (255 * progress).to_i
      pbUpdate
    end
    shift.y = shiftRestY
    shiftIcon.y = shiftIconRestY
    summary.y = summaryRestY
    checkMoves.y = checkMovesRestY
    cancel.x = cancelPos[0]
    sel.x = selRestX
    sel.y = selRestY
    sel.opacity = 255
    pbUpdatePartyActionOpacity(selectedKey)
  end

  # Reverse of pbShowPartyActionMenu.
  def pbHidePartyActionMenu
    pbSEPlay("SlideDown", 60)
    shift = @sprites["partyAction_shift"]
    shiftIcon = @sprites["partyActionShiftIcon"]
    summary = @sprites["partyAction_summary"]
    checkMoves = @sprites["partyAction_check_moves"]
    cancel = @sprites["bagUI_cancel"]
    shiftRestY = PARTY_SHIFT_POS[1]
    shiftIconRestY = PARTY_SHIFT_POS[1] + PARTY_SHIFT_ICON_POS[1]
    summaryRestY = PARTY_SUMMARY_POS[1]
    checkMovesRestY = PARTY_CHECK_MOVES_POS[1]
    cancelPos = BAG_UI_POS["cancel"]
    shiftStartOpacity = shift ? shift.opacity : 0
    shiftIconStartOpacity = shiftIcon ? shiftIcon.opacity : 0
    summaryStartOpacity = summary ? summary.opacity : 0
    checkMovesStartOpacity = checkMoves ? checkMoves.opacity : 0
    cancelStartOpacity = cancel ? cancel.opacity : 0
    sel = @sprites["partyActionSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selStartY = sel ? sel.y : nil
    selBoundToCancel = sel && @partyActionSelKey == "cancel"
    BAG_UI_SLIDE_FRAMES.times do |frame|
      progress = (frame + 1) / BAG_UI_SLIDE_FRAMES.to_f
      if shift
        shift.y = shiftRestY + ((Graphics.height - shiftRestY) * progress)
        shift.opacity = (shiftStartOpacity * (1 - progress)).to_i
      end
      if shiftIcon
        shiftIcon.y = shiftIconRestY + (((Graphics.height + PARTY_SHIFT_ICON_POS[1]) - shiftIconRestY) * progress)
        shiftIcon.opacity = (shiftIconStartOpacity * (1 - progress)).to_i
      end
      if summary
        summary.y = summaryRestY + ((Graphics.height - summaryRestY) * progress)
        summary.opacity = (summaryStartOpacity * (1 - progress)).to_i
      end
      if checkMoves
        checkMoves.y = checkMovesRestY + ((Graphics.height - checkMovesRestY) * progress)
        checkMoves.opacity = (checkMovesStartOpacity * (1 - progress)).to_i
      end
      if cancel
        cancel.x = cancelPos[0] + ((Graphics.width - cancelPos[0]) * progress)
        cancel.opacity = (cancelStartOpacity * (1 - progress)).to_i
      end
      if sel
        if selBoundToCancel
          sel.x = selStartX + (((Graphics.width + FIGHT_SEL_OFFSET["cancel"][0]) - selStartX) * progress)
        else
          sel.y = selStartY + (((Graphics.height + FIGHT_SEL_OFFSET["summary"][1]) - selStartY) * progress)
        end
        sel.opacity = (selStartOpacity * (1 - progress)).to_i
      end
      pbUpdate
    end
    shift.visible = false if shift
    shiftIcon.visible = false if shiftIcon
    summary.visible = false if summary
    checkMoves.visible = false if checkMoves
    if cancel
      cancel.visible = false
      cancel.z = Z_BAG_UI
    end
    sel.visible = false if sel
  end

  #Shift navigation grid
  def pbPartyActionNextKey(currentKey, dRow, dCol)
    if currentKey == "shift"
      return "summary" if dCol == -1
      return "cancel" if dCol == 1
      return "check_moves" if dRow == 1
      return currentKey
    end
    return "shift" if dRow == -1
    row = ["summary", "check_moves", "cancel"]
    idx = row.index(currentKey)
    return currentKey if !idx
    if dCol == -1
      return idx > 0 ? row[idx - 1] : currentKey
    elsif dCol == 1
      return idx < row.length - 1 ? row[idx + 1] : currentKey
    end
    return currentKey
  end

  #Pop-up for already in battle
  def pbShowPartyAlreadyInBattleMessage(pkmn)
    pbScrollMessageBoxIn(true)
    pbSetMessageWindowText(_INTL("{1} is already in battle.", pkmn.name))
    loop do
      pbUpdate
      break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK) || (Mouse.active? && Mouse.click?)
    end
    pbScrollMessageBoxOut
  end

  #Party switch confirmation
  def pbPartyActionMenu(pkmn)
    currentKey = "shift"
    pbShowPartyActionMenu(currentKey, pkmn)
    result = nil
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbPartyActionNextKey(currentKey, dRow, dCol)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        pbUpdatePartyActionOpacity(currentKey)
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        clickedKey = "shift" if @sprites["partyAction_shift"] && Mouse.over?(@sprites["partyAction_shift"])
        clickedKey = "summary" if @sprites["partyAction_summary"] && Mouse.over?(@sprites["partyAction_summary"])
        clickedKey = "check_moves" if @sprites["partyAction_check_moves"] && Mouse.over?(@sprites["partyAction_check_moves"])
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey
        pbUpdatePartyActionOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        pbHidePartyActionMenu
        break
      elsif confirmed && currentKey == "shift"
        if pbPartyPokemonActive?(pkmn)
          pbPlayBuzzerSE
          pbShowPartyAlreadyInBattleMessage(pkmn)
        else
          pbPlayDecisionSE
          pbHidePartyActionMenu
          result = @battle.pbParty(0).index(pkmn)
          break
        end
      elsif confirmed && currentKey == "summary"
        pbPlayDecisionSE
        pbHidePartyActionMenu
        pbSummaryPanelMenu(PartyPseudoBattler.new(pkmn), false)   # false - no message box in this context, see pbSummaryPanelMenu
        pbShowPartyActionMenu(currentKey, pkmn)
      elsif confirmed && currentKey == "check_moves"
        pbPlayDecisionSE
        pbHidePartyActionMenu
        pbMovesPanelMenu(PartyPseudoBattler.new(pkmn))
        pbShowPartyActionMenu(currentKey, pkmn)
      end
    end
    return result
  end

  # Simple party-target picker for using an item on a Pokemon
  def pbChooseItemTargetPokemon(promptText)
    currentKey = PARTY_SLOT_KEYS.find { |key| pbPartySlotEnabled?(key) } || "cancel"
    pbShowPartyMenu(currentKey, promptText)
    result = -1
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbPartyMenuNextKey(currentKey, dRow, dCol)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        pbUpdatePartyMenuOpacity(currentKey)
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        PARTY_SLOT_KEYS.each do |key|
          sprite = @sprites["partySlot_#{key}"]
          clickedKey = key if sprite && pbPartySlotEnabled?(key) && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey
        pbUpdatePartyMenuOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        result = -1
        break
      elsif confirmed
        pbPlayDecisionSE
        result = PARTY_SLOT_KEYS.index(currentKey)
        break
      end
    end
    pbHidePartyMenu
    return result
  end

  #Party screen replacement. 
  def pbPartyMenu(idxBattler)
    wasSecondBattlerOfDouble = @cmdCancelWanted
    pbHideDataBoxes
    pbHideCommandButtons   # fight/bag/run/pokemon + icon_party/icon_foe exit
    pbScrollMessageBoxOut  # "What will {1} do?" exits too - reloaded with new text below

    currentKey = (@partyMenuLastSlotKey && pbPartySlotEnabled?(@partyMenuLastSlotKey)) ? @partyMenuLastSlotKey :
                 (PARTY_SLOT_KEYS.find { |key| pbPartySlotEnabled?(key) } || "cancel")
    @partyMenuLastSlotKey = currentKey if currentKey != "cancel"
    pbShowPartyMenu(currentKey)

    result = false
    loop do
      pbUpdate

      dRow = 0
      dCol = 0
      if Input.trigger?(Input::UP)
        dRow = -1
      elsif Input.trigger?(Input::DOWN)
        dRow = 1
      elsif Input.trigger?(Input::LEFT)
        dCol = -1
      elsif Input.trigger?(Input::RIGHT)
        dCol = 1
      end
      newKey = pbPartyMenuNextKey(currentKey, dRow, dCol)
      if newKey != currentKey
        pbPlayCursorSE
        currentKey = newKey
        @partyMenuLastSlotKey = currentKey if currentKey != "cancel"   # keyboard-only
        pbUpdatePartyMenuOpacity(currentKey)
      end

      mouseClicked = Mouse.active? && Mouse.click?
      clickedKey = nil
      if mouseClicked
        PARTY_SLOT_KEYS.each do |key|
          sprite = @sprites["partySlot_#{key}"]
          clickedKey = key if sprite && pbPartySlotEnabled?(key) && Mouse.over?(sprite)
        end
        clickedKey = "cancel" if @sprites["bagUI_cancel"] && Mouse.over?(@sprites["bagUI_cancel"])
      end
      if clickedKey && clickedKey != currentKey
        currentKey = clickedKey   # mouse clicks don't touch @partyMenuLastSlotKey - keyboard-only
        pbUpdatePartyMenuOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        yield(-1)
        pbHidePartyMenu
        result = false
        break
      elsif confirmed
        pbPlayDecisionSE
        idx = PARTY_SLOT_KEYS.index(currentKey)
        party = @battle.pbParty(0)
        pbHidePartyMenu
        switchIdx = pbPartyActionMenu(party[idx])
        if switchIdx && yield(switchIdx)
          result = true
          break
        end
        pbShowPartyMenu(currentKey)
      end
    end

    if result && (@battle.singleBattle? || wasSecondBattlerOfDouble)
      pbHideCommandPageAssets
    elsif result
      pbShowCommandButtons("fight")
    else
      #Cancelled
    end
    pbShowDataBoxes
    return result
  end
end

class PartyPseudoBattler
  attr_reader :pokemon
  def initialize(pkmn)
    @pokemon = pkmn
  end

  def ability
    @pokemon.ability
  end

  def item
    @pokemon.item
  end

  def moves
    @pokemon.moves.map { |m| PartyPseudoMove.new(m) }
  end
end

class PartyPseudoMove
  def initialize(pkmnMove)
    @pkmnMove = pkmnMove
    @data = (pkmnMove && pkmnMove.id) ? GameData::Move.get(pkmnMove.id) : nil
  end

  def id
    @pkmnMove&.id
  end

  def pp
    @pkmnMove&.pp
  end

  def name
    @data&.name
  end

  def category
    @data&.category
  end

  def power
    @data&.power
  end

  def accuracy
    @data&.accuracy
  end

  def type
    @data&.type
  end
end

class Battle
  #pbPartyScreen over-ride
  alias customUI_pbPartyScreen pbPartyScreen
  def pbPartyScreen(idxBattler, *args)
    ret = -1
    @scene.pbPartyMenu(idxBattler) do |idxParty|
      next false if idxParty < 0
      next false if !pbRegisterSwitch(idxBattler, idxParty)
      ret = idxParty
      next true
    end
    return ret
  end
end

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
  end
end

# FOCUSUSER_Y/FOCUSTARGET_Y are fixed animation-authoring anchors (not screen
# coordinates) - shifting them breaks PBAnimationPlayerX's line transform math,
# so only PLAYER_BASE_Y/FOE_BASE_Y (actual screen positions) are changed.
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
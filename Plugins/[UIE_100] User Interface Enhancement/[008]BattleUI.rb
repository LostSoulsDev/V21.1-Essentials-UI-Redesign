#===============================================================================
#                        Custom Battle Screen
#                               V 1.0.46
#                        Developed by Carmaniac
#===============================================================================
# Replaces the default Pokémon Essentials battle UI (command bar, fight bar,
# party ball tray, message box, and Bag/item flow) with a custom graphic set.
# Everything in this file works by reopening Battle::Scene and either
# aliasing + overriding an existing method, or adding new ones it calls.
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
  Z_SUMMARY_PANEL    = 125   # party_summary_panel.png + its icon/overlay - ball_overlay/ball_bar/icon_ball sit above it
  Z_BALL_OVERLAY     = 150
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

  # Command page buttons. Index order (0-3) has to match what the base
  # engine expects for Fight/Bag/Pokemon/Run - on-screen nav is separate
  # below since the layout isn't a simple 1D list.
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

  # Selection highlight over the Command buttons - IconSprite with src_rect
  # stepped by a tick counter, same trick as the Party screen's highlight.
  # sel_large sits over Fight, sel_medium over whichever of Bag/Run/Pokemon
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

  # Idle bob for whichever player battler is actually active right now (the
  # one @activeCommandBattler points at) - icon_party only, icon_foe never
  # bobs. Whole-pixel steps only, no easing/sub-pixel positions, so the
  # sprite never sits on a blurred half-pixel.
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
  BAG_UI_SLIDE_FRAMES = 12   # slowed down from 6 - the load in/out was too quick
  BAG_UI_OPACITY_NO_LAST_ITEM = 140   # item_command's opacity when there's no saved last-used item yet

  # Text baked onto the Bag buttons - same colour/shadow as the message
  # window. {key => [[text, x, y], ...]}, positions relative to the
  # button's own graphic. item_command's "LAST ITEM USED" label is handled
  # separately below (x is centered, not fixed).
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

  # 2x3 grid matching the buttons' actual on-screen layout: hp/balls top
  # row, restore/battle middle, command/cancel bottom.
  BAG_GRID = [
    ["hp",      "balls"],
    ["restore", "battle"],
    ["command", "cancel"],
  ]
  BAG_CANCEL_FLASH_FRAMES = 4   # how long each icon_cancel/icon_cancel_p swap holds

  # Highlight over whichever Bag button is selected - same cmdSel idea, same
  # 4-frame animation. Frame height comes from each graphic's own bitmap
  # height / BAG_SEL_FRAMES rather than a hardcoded size, since not every
  # file is the same dimensions. Position is relative to BAG_UI_POS.
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

  # Bag pocket pages (opened by confirming hp/restore/balls/battle). All four
  # share the exact same structure - only the header text and the item list
  # differ - so there's one shared implementation rather than four separate
  # ones. Header text below is a placeholder - update freely to match final
  # copy.
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

  # Item grid within a pocket page - item_button.png, 2x3 layout.
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

  # Item grid highlight - same animated 4-frame pattern as cmdSel/bagSel.
  # 288x384 total, so each of the 4 frames is 288x96; sits 4x-8 relative to
  # whichever item_button.png slot is currently selected.
  BAG_ITEM_SEL_FILE   = "item_button_sel"
  BAG_ITEM_SEL_FRAMES = 4
  BAG_ITEM_SEL_OFFSET = [4, -8]

  # Item categories - no built-in Essentials flag distinguishes "restores
  # HP/PP" or "cures status", so these are hand-maintained ID whitelists
  # (standard vanilla item IDs). Poké Balls/Battle Items use the item's own
  # pocket/is_poke_ball? data instead, since those ARE real vanilla pockets.
  # Double-check these lists against the project's actual items.txt/PBS data
  # if items are ever added, renamed, or removed.
  BAG_HP_ITEM_IDS = [
    :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :FULLRESTORE,
    :REVIVE, :MAXREVIVE, :ETHER, :MAXETHER, :ELIXIR, :MAXELIXIR, :PPUP, :PPMAX,
  ]
  BAG_STATUS_ITEM_IDS = [
    :ANTIDOTE, :BURNHEAL, :ICEHEAL, :AWAKENING, :PARALYZEHEAL, :FULLHEAL, :LUMBERRY,
  ]
  # Looked up against PokemonBag.pocket_names, so these strings must exactly
  # match the pocket display names defined in the project's PBS data.
  BAG_BALLS_POCKET_NAME = "Poké Balls"
  BAG_BATTLE_ITEMS_POCKET_NAME = "Battle Items"

  # Use Item page - reached by confirming an item on the pocket grid. USE
  # reuses item_command.png (rebaked with "USE" on its own sprite, so the
  # real "LAST ITEM USED" button's bitmap is untouched) next to the same
  # cancel button, with item_description.png fading in alongside. USE/
  # cancel share the same bagSel highlight as the main Bag page.
  USE_ITEM_GRID = ["command", "cancel"]   # left/right, matches their actual on-screen x order
  USE_ITEM_BUTTON_TEXT = "USE"
  USE_ITEM_DESC_FILE = "item_description"
  USE_ITEM_DESC_POS  = [0, 64]
  USE_ITEM_ICON_POS  = [120, 20]
  USE_ITEM_TEXT_COLOR        = Color.new(0, 0, 0)
  USE_ITEM_TEXT_SHADOW_COLOR = Color.new(173, 189, 189)
  # The name and each description line are centered within a restricted
  # area, NOT the full 800px width - starting at x=44, 712px wide (so it
  # ends at 756, not the full graphic edge).
  USE_ITEM_TEXT_AREA_X     = 44
  USE_ITEM_TEXT_AREA_WIDTH = 712
  USE_ITEM_NAME_Y = 36
  USE_ITEM_QTY_POS = [558, 36]   # fixed position, not centered
  USE_ITEM_DESC_Y  = 98
  USE_ITEM_DESC_LINE_HEIGHT = 32   # line spacing for the wrapped description text

  # Fight menu - reached by confirming Fight on the Command page. 2x2 move
  # grid, summary button underneath, cancel button borrowed straight from
  # the Bag UI (same graphic, position, entrance/exit as everywhere else it
  # shows up). Move graphics are named by type (electric/ghost/dark/...),
  # with "unknown" as the fallback for a type with no graphic and "empty"
  # for a slot with no move in it - same file naming as the old version.
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

  # Highlight over whichever Fight button is selected - same 4-frame
  # animated idea as bagSel/cmdSel. Cancel reuses the Bag UI's own cancel
  # highlight graphic/offset rather than a new one, since it's the same
  # button. moves_sel and icon_summary_sel both divide evenly into 4 frames,
  # matching every other selector in this file.
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

  # Summary panel page - reached by confirming "summary" on the Fight page.
  # Not designed yet beyond the panel itself + the check_moves button, which
  # currently does nothing when confirmed. Cancel here just closes the panel
  # and goes back to the Fight page's move grid.
  SUMMARY_PANEL_FILE = "party_summary_panel"
  SUMMARY_PANEL_RESTING_POS = [0, 54]   # scrolls down from above the screen to rest here
  FIGHT_CHECK_MOVES_FILE = "icon_check_moves"
  FIGHT_CHECK_MOVES_POS  = [292, 372]

  # Summary panel's detail overlay (name/level/ability/stats/gender/types)
  # plus the selected Pokemon's own animated icon. Everything below is
  # relative to the panel's own top-left (SUMMARY_PANEL_RESTING_POS). Text
  # colour/shadow throughout matches the message window, same as the rest of
  # this UI.
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
  # icon_overlay_hp.png reused straight from the root Battle System folder -
  # same 100x12/3-band clipped-rect convention as pbDrawBattlerIcon's HP bar.
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
  # One icon per type, left to right - custom sprite sheet (Battle System/
  # type_icons.png, 64x456, same type order as GameData::Type's own
  # icon_position), same sheet+icon_position convention this file already
  # uses for status icons (Graphics/UI/statuses, see pbDrawBattlerIcon).
  # +2 on y versus the first pass at this.
  SUMMARY_TYPE_ICON_POS = [[404, 10], [474, 10]]
  SUMMARY_TYPE_ICON_FILE = "type_icons"
  SUMMARY_TYPE_ICON_SIZE = [64, 24]   # 456 / 24 = 19 rows

  alias customUI_pbInitSprites pbInitSprites
  def pbInitSprites
    customUI_pbInitSprites
    return if pbInSafari?
    if @sprites["messageBox"]
      @sprites["messageBox"].setBitmap(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "message_overlay.png")
      @sprites["messageBox"].x = 0
      # Start off-screen below the rest position; pbShowWindow scrolls it up
      # the first time the message box is actually shown.
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
    # New sprite (no base engine equivalent) - starts parked off-screen above
    # the top edge; pbScrollCommandPanelIn slides it down into place.
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

  # Scrolls the message box overlay back down off-screen. Clears/hides the
  # text window right at the start, in step with the box beginning to move,
  # so old text doesn't linger on screen while the graphic slides away
  # underneath it.
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

  # Scrolls the box out then straight back in, leaving it empty and visible -
  # a deliberate "clear this page, ready for the next one" transition. Not
  # tied to any specific text; called explicitly at real transition points
  # (see pbCommandMenuEx) rather than automatically on every message.
  def pbClearMessageBox
    return if !@sprites["messageBox"] || !@sprites["messageBox"].visible
    pbScrollMessageBoxOut
    pbScrollMessageBoxIn
  end

  # Full exit for the Command page once a choice is confirmed - buttons,
  # party balls, shadow/ball backdrop, and message box all close out. Unlike
  # pbClearMessageBox this leaves the box fully hidden, not empty-but-up, so
  # whatever real message comes next scrolls itself back in normally.
  def pbHideCommandPageAssets
    pbHideCommandButtons
    pbHidePartyBalls
    pbHideCommandBackground
    pbScrollMessageBoxOut
  end

  # Replaces pbShowWindow entirely rather than calling the base version
  # first, so fightWindow/commandWindow never flash visible for a frame.
  #
  # Message box only plays its scroll-in animation on hidden -> shown. If
  # it's already up, a new MESSAGE_BOX request just swaps the text in place
  # (a run of ordinary lines like "A wild {1} appeared!" / "Go, {1}!"
  # shouldn't animate between every line). The scroll-out-then-back-in
  # "clear" only happens where we trigger it explicitly - pbShowCommandPrompt
  # and pbClearMessageBox.
  #
  # Also: the message box/window deliberately do NOT auto-hide just because
  # some other window type (COMMAND_BOX etc) got requested - the base engine
  # calls pbShowWindow(COMMAND_BOX) as part of the Command menu, and if that
  # closed the message box every time, "What will {1} do?" would slide in
  # and immediately back out. It only closes when something explicitly
  # calls pbScrollMessageBoxOut / pbHideMessageBox / pbClearMessageBox.
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

  # Explicit, on-demand close for the message box - scrolls it out and hides
  # the text. Nothing calls this automatically; use it whenever "until I say
  # otherwise" is over and the box should actually clear.
  def pbHideMessageBox
    return if !@sprites["messageBox"] || !@sprites["messageBox"].visible
    pbScrollMessageBoxOut
    @sprites["messageWindow"].visible = false if @sprites["messageWindow"]
  end

  # Types text into messageWindow, essentials-style. Scene#pbUpdate only
  # calls cw.update for whatever window gets passed to it, and that's what
  # drives the letter-by-letter reveal - so this has to loop pbUpdate(cw)
  # itself rather than a bare pbUpdate, same as pbDisplayMessage does.
  # Unlike pbDisplayMessage, no pause arrow and no auto-close - text just
  # sits there until something else clears it.
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

  # Scrolls the ball bar down into its rest position on its own - the first
  # half of beat 2 (see pbShowPartyBalls), completing before the icon_ball
  # party row starts cascading in. No-ops if already showing.
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

  # Scrolls the ball bar back up off-screen on its own - the second half of
  # beat 2's exit (see pbHidePartyBalls), run only after the icon_ball party
  # row has fully finished exiting.
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

  # Which icon_ball_* graphic represents a given party slot - empty slot,
  # fainted, has a status condition, or fine. Reused for both sides.
  def pbPartyBallGraphic(pkmn)
    return "icon_ball_empty" if !pkmn
    return "icon_ball_faint" if !pkmn.able?
    return "icon_ball_status" if pkmn.status != :NONE
    return "icon_ball"
  end

  # Builds/refreshes the party ball row - player always, enemy too if it's
  # a trainer battle (wild battles are just the one Pokémon). Existing
  # sprites keep their position/visibility so reopening the Command page
  # doesn't reset anything already on screen; only the graphic refreshes.
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

  # Cascades the party balls in one slot at a time - player side back to
  # front (slot 6 first), enemy side front to back (slot 1 first), both
  # advancing together. Skips the animation (just refreshes graphics) if
  # already shown, so returning from the Fight menu doesn't replay it.
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

  # Animated exit for the party ball row - reverse of pbShowPartyBalls,
  # sliding each ball back out to its side's fixed anchor (same round
  # order/pairing) rather than just vanishing instantly. The icon_ball row
  # finishes exiting FIRST, then the ball bar scrolls back up after (mirror
  # of the entrance, where the bar finishes first and the balls follow).
  # No-ops if the row isn't actually shown.
  def pbHidePartyBalls
    return if !@sprites["partyBall_player_0"] || !@sprites["partyBall_player_0"].visible
    Settings::MAX_PARTY_SIZE.times do |round|
      # Mirrored from the entrance order: player exits starting with slot 1
      # (entrance started with slot 6), enemy exits starting with slot 6
      # (entrance started with slot 1).
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

  # Full Command-page entrance. Shadow/ball backdrop fades in first (from
  # pbCommandMenuEx, before this runs), then the ball bar + party row
  # (pbShowPartyBalls), then message box + buttons + battler icons together
  # (pbScrollCommandPanelIn), then the prompt text types in. If it's all
  # already on screen this just refreshes text/graphics, no animation.
  def pbShowCommandPrompt(text)
    textChanged = (text != @lastCommandPromptText)
    @lastCommandPromptText = text   # so pbBagMenuLoop can restore this exact text on cancel
    alreadyShown = @sprites["messageBox"] && @sprites["messageBox"].visible &&
                   @sprites["ballBarOverlay"] && @sprites["ballBarOverlay"].visible &&
                   @sprites["cmdBtn_fight"] && @sprites["cmdBtn_fight"].visible
    if alreadyShown
      # Only retypes if the text actually changed - backing out of Fight/Bag
      # back to the same battler's prompt shouldn't replay the type-in
      # animation for text that's already sitting there unchanged.
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
  # prompt. Built once; safe to call every time the Command menu opens.
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
      # Rotate around its own center: origin at the bitmap's midpoint, and the
      # sprite's x/y shifted by that origin so 270,110 stays the visual
      # top-left corner of the image rather than its pivot point.
      @sprites["ballOverlay"].ox = @sprites["ballOverlay"].bitmap.width / 2
      @sprites["ballOverlay"].oy = @sprites["ballOverlay"].bitmap.height / 2
      @sprites["ballOverlay"].x = BALL_OVERLAY_X + @sprites["ballOverlay"].ox
      @sprites["ballOverlay"].y = BALL_OVERLAY_Y + @sprites["ballOverlay"].oy
      @sprites["ballOverlay"].z = Z_BALL_OVERLAY
      @sprites["ballOverlay"].opacity = 0
      @sprites["ballOverlay"].visible = false
    end
  end

  # Fades the shadow + ball in together (ball's already spinning as it
  # fades). No-ops if already showing so returning from the Fight menu
  # doesn't replay it.
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

  # Advances the ball's spin by one frame's worth. Only does anything while
  # the ball is actually on screen.
  def pbSpinBallOverlay
    ball = @sprites["ballOverlay"]
    return if !ball || !ball.visible
    ball.angle = (ball.angle + BALL_SPIN_SPEED) % 360
  end

  # Moves/re-skins the animated selection indicator onto whichever Command
  # button is currently selected. Fight gets sel_large (offset from Fight's
  # own position); Bag/Run/Pokemon get sel_medium sitting exactly on that
  # button. Swapping graphic files resets the frame back to 0 and re-sets
  # src_rect's full size; while staying on the same graphic, only the
  # animation tick (pbAnimateCommandSelector) moves src_rect.y.
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

  # Steps the selector's animation frame - called every update tick, same
  # pattern as the Party screen's pbUpdateCommandHighlightAnim.
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

  # pbUpdate is the scene's central per-frame refresh - it runs continuously
  # regardless of which loop currently has input focus (message waits, the
  # command loop, the fight loop, etc). Hooking the spin/selector animation
  # in here means they keep animating for the whole time the Command page
  # is open, without needing to touch/reimplement the Command menu's input
  # loop itself.
  alias customUI_pbUpdate pbUpdate
  def pbUpdate(*args)
    customUI_pbUpdate(*args)
    pbSpinBallOverlay
    pbAnimateCommandSelector
    pbAnimateBagSelector
    pbAnimateBagItemSel
    pbAnimateFightSelector
    pbAnimateSummaryPanelSelector
    pbAnimateBattlerIconBob
    pbAnimateSummaryPanelIcon
  end

  # Hides/shows the default Essentials data boxes (the HP/name/status boxes
  # for the Pokemon on field) while the Command page options are up.
  #
  # Relies on each battler's data box sprite being keyed "dataBox_<index>"
  # in @sprites - the standard v21.1 naming. Update the key check below if
  # a project's pbInitSprites ever names them differently.
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

  # Builds the four Command buttons. Built once; safe to call every time the
  # Command page opens. Newly-created sprites start transparent and hidden;
  # already-existing sprites are left as-is (position/opacity/visibility
  # untouched) so re-opening the page doesn't reset anything already shown.
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

  # Beat 3 of the Command page entrance: message box scrolling up and all
  # four command buttons (+ battler icon boxes) fading in, all inside ONE
  # frame loop so they visibly move as a single synced group rather than
  # one after another. Each piece still runs to its own frame count - only
  # the loop itself is shared. The slide sound effect is the message
  # window's own (only plays if the box is actually scrolling) - buttons/
  # icon boxes fading in are silent. No-ops if everything's already
  # showing.
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
    # The double-battle "back to previous Pokemon" cancel button (see
    # pbSyncCmdCancelButton) fades in alongside fight/bag/run/pokemon here,
    # silently, rather than doing its own separate slide-in afterward.
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

  # Highlights whichever button is currently selected (full opacity); every
  # other button sits at the dimmer "unselected" opacity. Also moves/re-skins
  # the animated sel_large/sel_medium indicator onto that same button.
  def pbUpdateCommandButtonOpacity(selectedKey)
    CMD_BUTTON_POS.each_key do |key|
      sprite = @sprites["cmdBtn_#{key}"]
      next if !sprite
      sprite.opacity = (key == selectedKey) ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL
    end
    pbUpdateCommandSelector(selectedKey)
  end

  # Fades all four buttons (and the selector indicator) out from whatever
  # opacity they're each currently at, then hides them - used right when a
  # choice is confirmed, so everything is gone and ready for the next
  # screen (Fight/Bag/etc) to build its own. Not used on cancel/back - only
  # on an actual confirmed choice.
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
    # Not part of the fade above (fixed opacity, not index-driven) - just
    # needs to be off screen too, and its own flag reset so the next
    # pbCommandMenuEx call re-shows it cleanly if mode == 1 again.
    pbHideCmdCancelButton if @cmdCancelShown
  end

  # Wraps/replaces the Command page (Fight/Bag/Pokémon/Run) entirely: hides
  # the field data boxes, fades in the shadow/ball background, runs the full
  # prompt sequence (message box + ball bar scrolling in together, followed
  # by the party balls cascading in), fades the four command buttons in, and
  # then runs the selection loop itself directly rather than delegating to
  # the base engine - the 2D button layout (Fight on its own above a
  # Bag/Run/Pokemon row) isn't something the stock 1D command list can drive.
  #
  # Navigation: Up always jumps to Fight. Down from Fight always lands on
  # Run specifically. Left/Right cycle through Bag/Run/Pokemon (in their
  # on-screen left-to-right order) and only do anything when not on Fight.
  #
  # Every piece of the background/prompt/balls/buttons is idempotent: if
  # already on screen (backed out of the Fight menu straight back into
  # Command), this just refreshes content/highlight in place rather than
  # replaying any animation. None of it auto-hides on return either - it
  # all stays up until something explicitly hides it. Only the data boxes
  # are restored here, since those are specifically meant to hide only
  # while the Command page options are actually up.
  #
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    @activeCommandBattler = idxBattler   # which icon_party box currently bobs - see pbAnimateBattlerIconBob
    # mode == 1 means this is the second Pokemon of a double battle choosing
    # its action, and the player can still back out to reselect the first
    # one's - only then does the extra cancel button belong on screen. Set
    # before pbShowCommandPrompt so pbScrollCommandPanelIn's own fade-in
    # cascade (fight/bag/run/pokemon buttons) can bring this in alongside
    # them on a fresh entrance, rather than as a separate animation after.
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

    # pbScrollCommandPanelIn (via pbShowCommandPrompt above) already brought
    # the cancel button in as part of the same fade if this was a fresh
    # entrance; this just catches the "page was already up, only the mode
    # changed" case (e.g. engine moved straight from battler 1 to battler 2
    # without ever hiding the Command page in between) - a no-op otherwise.
    pbSyncCmdCancelButton

    ret = -1
    loop do
      oldKey = currentKey
      pbUpdate(cw)

      # Keyboard/pad navigation only - hovering the mouse over a button does
      # NOT move the selection by itself anymore.
      if Input.trigger?(Input::UP)
        currentKey = "fight"
      elsif Input.trigger?(Input::DOWN)
        currentKey = "run" if currentKey == "fight"
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

      # A click selects and confirms in the same action - whichever button
      # the mouse is over when clicked becomes the choice immediately.
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
        # Fight and Bag don't do anything here beyond returning their index -
        # the battle engine calls back into this Scene through its own
        # pbFightMenu/pbItemMenu overrides (further below) once it gets that
        # index, and those own the whole screen transition from there.
        # Keeping the index meaning intact matters - it's the exact value
        # the base engine's command-phase loop switches on.
        #
        # Run leaves the Command page entirely - every asset (buttons + sel
        # indicator, party balls, ball bar, shadow/ball backdrop, message
        # box/text) does its own exit animation. The message box ends up
        # fully hidden (not just cleared) rather than scrolled back in
        # empty, so whatever battle text comes next ("Got away safely!"
        # etc.) triggers the NORMAL hidden->shown entrance via pbShowWindow
        # on its own - no extra animation layered on top.
        #
        # Pokemon isn't built yet, so confirming it just returns the index
        # and leaves every Command-page asset exactly as it is.
        pbHideCommandPageAssets if currentKey == "run"
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif (Input.trigger?(Input::BACK) && mode == 1) || clickedCmdCancel
        pbPlayCancelSE
        pbFlashCmdCancelButton
        # Scrolls straight out here rather than waiting for the next
        # pbCommandMenuEx call (battler 1's own prompt/mode) to sync it away
        # with no animation - it should visibly leave right away, not sit
        # frozen until "What will {1} do?" catches up to the previous battler.
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

  # Fades the four Command buttons + battler icon boxes back in - the
  # reverse of pbHideCommandButtons. Doesn't touch the message box/ball bar/
  # backdrop, since Fight never hides those in the first place.
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

  # Whether a Fight grid cell can be selected - move slots need an actual
  # move in that slot, summary/cancel are always selectable.
  def pbFightIndexEnabled?(key, battler)
    return true if key == "summary" || key == "cancel"
    idx = FIGHT_MOVE_KEYS.index(key)
    return battler.moves[idx] && battler.moves[idx].id ? true : false
  end

  # Bakes a single move button - background graphic (by type, "unknown" if
  # that type has no graphic, "empty" if the slot has no move) plus the move
  # name and PP. Private (load -> copy -> draw) bitmap, not setBitmap
  # directly - type graphics are reused across multiple move slots, and
  # setBitmap sharing a cached bitmap across sprites is what caused the
  # item_command/USE button text-bleed bug earlier in this file.
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

  # Builds/rebakes the four move buttons plus the summary button. Also makes
  # sure bagUI_cancel exists, in case Fight gets opened before the Bag page
  # ever has been this battle.
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

  # Highlights whichever Fight key is selected (full opacity; everything
  # else drops to the normal scheme) and moves the Fight selector onto it.
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

  # Moves/re-skins the Fight page's own highlight onto whichever key is
  # selected - moves_sel for the four move slots, icon_summary_sel for
  # summary, and the Bag UI's own cancel highlight (graphic + offset) for
  # cancel, since that's literally the same button.
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
    @fightSelKey = selectedKey   # which key it's bound to, for pbShowFightButtons/pbHideFightButtons to slide it with
    # cancel itself sits raised above the message box (see pbShowFightButtons)
    # while this page is up - the selector needs to sit a tier above THAT
    # specifically when it's bound to cancel, or it renders underneath it.
    sel.z = (selectedKey == "cancel") ? Z_BAG_POCKET_ARROW + 1 : Z_COMMAND_SELECTOR
    sel.opacity = 255
    sel.visible = true
  end

  # Steps the Fight selector's animation frame - same pattern as
  # pbAnimateBagSelector/pbAnimateCommandSelector.
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

  # Entrance for the Fight page - cancel slides in from the right (same
  # graphic/position/animation borrowed from the Bag UI), the five move/
  # summary buttons just fade in place (no slide, for now).
  def pbShowFightButtons(battler, landOnKey)
    pbBuildFightButtons(battler)
    pbSEPlay("SlideUp", 60)
    cancel = @sprites["bagUI_cancel"]
    cancelPos = BAG_UI_POS["cancel"]
    # Raised above the message box for as long as this page is up - same
    # trick pbScrollBagPocketIn uses for the same reason (cancel shares the
    # screen with the message box here too, and needs to render on top of
    # it, not underneath). Put back in pbHideFightButtons.
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
    # The selector copies whichever entrance its bound button uses - slides
    # in from the right alongside cancel if that's what's selected, or just
    # fades in place like the move/summary buttons do (they don't slide).
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

  # Reverse of pbShowFightButtons.
  def pbHideFightButtons
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

  # Same flash-between-normal-and-_p pattern as pbFlashBagCancelButton, for
  # the summary button.
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

  # Highlights whichever Summary panel key is selected - same opacity scheme
  # as everywhere else, plus the highlight sprite itself.
  def pbUpdateSummaryPanelOpacity(selectedKey)
    checkMoves = @sprites["fightBtn_check_moves"]
    checkMoves.opacity = (selectedKey == "check_moves") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if checkMoves
    cancel = @sprites["bagUI_cancel"]
    cancel.opacity = (selectedKey == "cancel") ? CMD_BUTTON_OPACITY_SELECTED : CMD_BUTTON_OPACITY_NORMAL if cancel
    pbUpdateSummaryPanelSelector(selectedKey)
  end

  # check_moves reuses icon_summary_sel at the same relative offset as the
  # Fight page's summary button; cancel reuses the Bag UI's own highlight -
  # same idea as pbUpdateFightSelector, just for this page's two keys.
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

  # Steps the Summary panel selector's animation frame - same pattern as
  # pbAnimateFightSelector.
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

  # Same flash-between-normal-and-_p pattern as pbFlashFightSummaryButton,
  # for check_moves. Doesn't lead anywhere yet - just the visual feedback.
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

  # Entrance for the Summary panel - party_summary_panel scrolls down from
  # above the screen, check_moves scrolls up from the bottom in sync with
  # cancel sliding back in from the right (borrowed again from the Bag UI).
  # Called after pbHideFightButtons has already taken the move grid off screen.
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
    # Selector slides in alongside whichever button it's bound to - check_moves
    # from the bottom, cancel from the right (both real slides here, not fades).
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
    # Detail overlay + icon reveal only once the panel itself is at rest,
    # rather than trying to track them through the panel's own slide.
    @sprites["summaryPanelInfo"].visible = true if @sprites["summaryPanelInfo"]
    @sprites["summaryPanelIcon"].visible = true if @sprites["summaryPanelIcon"]
  end

  # Reverse of pbShowSummaryPanel.
  def pbHideSummaryPanel
    pbSEPlay("SlideDown", 60)
    # Detail overlay + icon disappear immediately, same as the panel
    # graphic itself starting to move - they never animated in on their own,
    # so they don't animate out on their own either.
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

  # Exp still needed to reach the next level - 0 once already at the cap.
  # Same growth-rate lookup as pbBattlerExpFraction, just the raw remainder
  # instead of a fraction.
  def pbSummaryExpToNextLevel(pkmn)
    return 0 if pkmn.level >= GameData::GrowthRate.max_level
    growth = GameData::GrowthRate.get(pkmn.species_data.growth_rate)
    nextLevelExp = growth.minimum_exp_for_level(pkmn.level + 1)
    return [nextLevelExp - pkmn.exp, 0].max
  rescue NoMethodError
    return 0
  end

  # pbDrawTextPositions only draws single lines - the ability description
  # needs to wrap within SUMMARY_ABILITY_DESC_MAX_WIDTH, so this measures and
  # breaks it into lines by hand before handing them off the same way. Line
  # spacing comes from the font's own actual glyph height (plus a little
  # breathing room) rather than a guessed constant, so lines never overlap
  # regardless of font/size.
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

  # Blits each of the Pokemon's types onto the overlay, left to right - the
  # project's own custom type_icons.png sheet (Battle System/ root), same
  # sheet+icon_position convention this file already uses for status icons
  # (GameData::Status#icon_position + the "Graphics/UI/statuses" sheet, see
  # pbDrawBattlerIcon).
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

  # icon_hp_overlay.png (static frame) + icon_overlay_hp.png (the fill,
  # reused straight from the root Battle System folder) - same clipped-rect
  # convention as pbDrawBattlerIcon's own HP bar.
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

  # Exp progress bar - same clipped-rect idea as icon_exp.png on icon_party
  # (pbDrawBattlerIcon), just this page's own bigger graphic/position.
  def pbDrawSummaryExpBar(bmp, pkmn)
    fraction = pbBattlerExpFraction(pkmn)
    base = Bitmap.new(FIGHT_SUMMARY_GRAPHICS_PATH + SUMMARY_EXP_BAR_FILE + ".png")
    width = (base.width * fraction).round
    bmp.blt(SUMMARY_EXP_BAR_POS[0], SUMMARY_EXP_BAR_POS[1], base, Rect.new(0, 0, width, base.height)) if width > 0
    base.dispose
  end

  # The selected Pokemon's own icon - a real PokemonIconSprite (same class
  # the Party screen uses) rather than something baked onto the overlay
  # bitmap, so its usual bounce/blink animation keeps playing while this
  # page is up (see pbAnimateSummaryPanelIcon).
  def pbBuildSummaryPanelIcon(pkmn)
    @sprites["summaryPanelIcon"]&.dispose
    @sprites["summaryPanelIcon"] = PokemonIconSprite.new(pkmn, @viewport)
    icon = @sprites["summaryPanelIcon"]
    icon.x = SUMMARY_PANEL_RESTING_POS[0] + SUMMARY_ICON_OFFSET[0]
    icon.y = SUMMARY_PANEL_RESTING_POS[1] + SUMMARY_ICON_OFFSET[1]
    icon.z = Z_SUMMARY_PANEL + 1
    icon.visible = false
  end

  # Steps the Pokemon icon's own animation - PokemonIconSprite handles its
  # bounce/blink timing internally, this just has to call it every frame
  # like the Party screen does.
  def pbAnimateSummaryPanelIcon
    icon = @sprites["summaryPanelIcon"]
    icon.update if icon && icon.visible
  end

  # Bakes the Summary panel's whole detail overlay (name/level/next-level
  # exp/ability/ability description/held item/HP/stats/gender/types) and
  # rebuilds the animated icon - called fresh every time the panel opens so
  # it always reflects whichever Pokemon is actually active right now.
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
    # Private (load -> copy -> draw) bitmap, matching this file's usual
    # pattern for text baked onto a graphic - transparent canvas the same
    # size as the panel background, drawn on top of it as its own sprite.
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
    # Right-anchored to SUMMARY_NEXT_LEVEL_VALUE_RIGHT_X - same fail-safe
    # left_x formula used everywhere else in this file for centered text,
    # just measuring from the right edge instead of the middle: clamped to
    # an even number (no sub-pixel rendering) and never negative.
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

  # Summary panel's own input loop - simple left/right between check_moves
  # and cancel, no wraparound. check_moves doesn't lead anywhere yet (not
  # designed); cancel plays its usual flash then closes the panel, handing
  # control back to pbFightMenu, which re-shows the move grid.
  def pbSummaryPanelMenu(battler)
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
        # Silent - pbFightMenu's pbShowFightButtons plays its own SlideUp
        # right after this returns, and both firing together doubled up.
        pbScrollMessageBoxIn(false)
        pbSetMessageWindowText(@lastCommandPromptText) if @lastCommandPromptText
        break
      elsif confirmed && currentKey == "check_moves"
        pbPlayDecisionSE
        pbFlashSummaryPanelCheckMovesButton
        # Doesn't lead anywhere yet - check_moves isn't designed.
      end
    end
  end

  # Works out where Up/Down/Left/Right from the current key land, given
  # which move slots are actually enabled. Blocked directions (nothing
  # enabled that way) just return the current key unchanged.
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

  # The Fight page's own input loop, called by the battle engine
  # (Battle#pbFightMenu) with a block that registers whatever gets chosen -
  # same yield contract as the base engine: a move index (0-3) to pick that
  # move, or -1 for cancel. The block returns true once it's actually
  # accepted the choice, false to reject it (bad target, move not usable,
  # etc.) and stay on this page rather than closing.
  #
  # 2x2 move grid, summary underneath, cancel underneath that - Up from
  # summary goes back to whichever move was last selected via the keyboard
  # (@fightLastMoveKey; mouse clicks don't update it, per spec). Confirming
  # summary opens the Summary panel (pbSummaryPanelMenu); its own cancel
  # closes that panel and returns here with the move grid shown again.
  #
  # TODO: double battles aren't handled here - two battlers choosing moves
  # back-to-back, and target selection between multiple allies/foes, still
  # need designing. Target selection between multiple foes/allies already
  # falls back to the base engine's own target screen when needed (that's
  # handled on the Battle side, not here), but this page's own layout has
  # only ever been designed against a single active battler per side.
  #
  # TODO: Mega Evolution (Input::ACTION) and Shift (Input::SPECIAL) aren't
  # wired up yet either - megaEvoPossible is accepted but currently unused.
  def pbFightMenu(idxBattler, megaEvoPossible = false)
    battler = @battle.battlers[idxBattler]
    # pbCommandMenuEx already un-hid the data boxes right before it returned
    # (it doesn't know Fight is about to take over the screen), same as the
    # Bag case - hide them again here, restored at the end.
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
        currentKey = clickedKey   # mouse clicks don't touch @fightLastMoveKey - keyboard-only, per spec
        pbUpdateFightButtonOpacity(currentKey)
      end
      confirmed = Input.trigger?(Input::USE) || clickedKey

      if (confirmed && currentKey == "cancel") || Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbFlashBagCancelButton
        # Backing out always closes this page and returns to the Command
        # menu - unlike a move pick, cancel isn't something the engine can
        # reject, so this doesn't wait on yield's return value to decide
        # whether to close. Still yields -1 so the engine gets a chance to
        # clear any pending registration state for this battler.
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
        # Engine rejected the move (target cancelled, not usable, etc.) -
        # stay here and let the player choose again.
      end
    end

    if result
      pbHideCommandPageAssets   # move accepted, turn's committed - close the whole Command page, same as Run
    else
      pbShowCommandButtons("fight")   # cancelled - bring the Command buttons back, message box was never touched
    end
    pbShowDataBoxes
    return result
  end

  # Battler name/status icon boxes.

  # Position for a given battler index's icon box, or nil if that slot isn't
  # supported - only party position 0 or 1 per side (i.e. single/double
  # battles) get a box.
  def pbBattlerIconPos(idxBattler)
    partyPos = idxBattler / 2   # 0 = slot 1, 1 = slot 2
    return nil if partyPos > 1
    return idxBattler.even? ? PLAYER_ICON_POS[partyPos] : ENEMY_ICON_POS[partyPos]
  end

  # Builds the single icon box sprite for a given battler index, if it
  # doesn't already exist. Everything (background, name, HP bar, EXP bar,
  # status icon, caught icon) is baked onto this one sprite's bitmap so it
  # can just be swapped wholesale whenever the battler changes, and so the
  # whole box fades in/out as one unit alongside the command buttons.
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

  # EXP fraction (0-1) toward the next level, for the EXP bar (player side
  # only). Mirrors the standard Essentials growth-rate calculation used by
  # the vanilla data box.
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

  # Redraws a battler's icon box onto its single baked bitmap - background
  # graphic, centered name text (same fail-safe centering idiom as the Party
  # screen), the essentials-style 3-band HP bar, the EXP bar (player side
  # only), the status icon, and (enemy side, wild battles only) the caught
  # icon if that species is already registered as owned. Hides the whole box
  # if there's no battler in that slot. Does NOT change visibility/opacity
  # if the Command panel isn't currently up - pbScrollCommandPanelIn/
  # pbHideCommandButtons own that fade; this only rebakes content, unless
  # the panel is already open, in which case a battler swap needs to show
  # immediately.
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
    # HP bar - icon_overlay_hp.png is 100x12, 3 vertical 4px bands stacked
    # (green/yellow/red), same convention as the vanilla HP bar; only the
    # band matching the current HP fraction is blitted, clipped to width.
    hpFraction = pbBattlerHPFraction(pkmn)
    hpBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "icon_overlay_hp.png")
    hpRow = (hpFraction > 0.5) ? 0 : (hpFraction > 0.2) ? 1 : 2
    hpWidth = (hpBase.width * hpFraction).round
    hpX, hpY = isPlayerSide ? [38, 34] : [38, 40]
    if hpWidth > 0
      bmp.blt(hpX, hpY, hpBase, Rect.new(0, hpRow * 4, hpWidth, 4))
    end
    hpBase.dispose
    # EXP bar - player side only. icon_exp.png is 100x4, a single bar
    # clipped to the fraction of the way to the next level.
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
    # Caught icon - enemy side, wild battles only, if this species is
    # already registered as owned in the Pokedex.
    if !isPlayerSide && !@battle.trainerBattle? && $player.owned?(pkmn.species)
      caughtBase = Bitmap.new(Settings::CUSTOM_BATTLE_UI_GRAPHICS_PATH + "caught_icon.png")
      bmp.blt(8, 46, caughtBase, caughtBase.rect)
      caughtBase.dispose
    end
    sprite.bitmap = bmp
    # If the Command panel is already open, a battler swap should show
    # immediately rather than waiting for the next fade-in.
    if @sprites["cmdBtn_fight"] && @sprites["cmdBtn_fight"].visible
      sprite.visible = true
      sprite.opacity = 255
    end
  end

  # Redraws every currently-relevant battler's icon box (both sides, slots
  # 1-2 only - see pbBattlerIconPos).
  def pbDrawAllBattlerIcons
    @battle.battlers.each_index { |i| pbDrawBattlerIcon(i) }
  end

  # All existing battler icon box sprites (built so far), in battler-index
  # order - used by the Command panel fade in/out.
  def pbBattlerIconSprites
    return @battle.battlers.each_index.filter_map { |i| @sprites["battlerIcon_#{i}"] }
  end

  # Idle bob for icon_party - only the battler currently being commanded
  # (@activeCommandBattler, set in pbCommandMenuEx) bobs, so in a double
  # battle the other player slot's box stays still. Steps up/down in fixed
  # even-pixel increments rather than easing, so it never lands on a
  # sub-pixel y value.
  def pbAnimateBattlerIconBob
    idxBattler = @activeCommandBattler
    # If the active battler changed since the last tick (double battle
    # switching who's being commanded), snap the previous one back to its
    # resting y before it loses the bob - otherwise it can get left sitting
    # mid-bob with no more ticks to bring it back down.
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
  # by pbItemMenu once the battle engine has genuinely accepted the item).
  # Returns nil - so item_command falls back to its "nothing saved yet"
  # opacity/disabled state - both when nothing's been used yet and when the
  # saved item has since run out (quantity <= 0), so a depleted item never
  # lingers as a stale shortcut.
  def pbLastUsedItem
    return nil if @lastUsedItem.nil?
    return nil if pbBagItemQuantity(@lastUsedItem) <= 0
    return @lastUsedItem
  end

  def pbSetLastUsedItem(item_id)
    @lastUsedItem = item_id
  end

  # Builds the Bag page sprites (if they don't already exist), bakes their
  # static text labels on (same colour/shadow as the message window - see
  # BAG_UI_TEXT/BAG_UI_COMMAND_TEXT), and parks them at their off-screen
  # slide-in start position, hidden/transparent.
  def pbBuildBagUI
    BAG_UI_FILES.each_key do |key|
      spriteKey = "bagUI_#{key}"
      next if @sprites[spriteKey]
      pos = BAG_UI_POS[key]
      size = BAG_UI_SIZE[key]
      @sprites[spriteKey] = IconSprite.new(@viewport)
      if key == "command"
        # Built via pbDrawBagCommandButton below instead - it needs
        # periodic rebaking (to reflect the current last-used item's icon/
        # absence), and item_command.png is now ALSO loaded by the Use Item
        # page's own USE button (pbBuildUseItemButton), which turned out to
        # share the same cached Bitmap object when both used setBitmap
        # directly - baking text onto one silently bled onto the other. A
        # private (non-cached) bitmap avoids that entirely.
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
      # (so bagSel, at Z_BAG_UI_SEL, correctly renders ON TOP of it while
      # on the main Bag page) - it's only temporarily raised to
      # Z_BAG_POCKET_ARROW by pbScrollBagPocketIn/Out while it's on screen
      # together with the reused message box graphic (which sits way
      # higher, at Z_MESSAGE_BOX), and put back afterward.
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

  # (Re)bakes item_command's bitmap from scratch - background, "LAST ITEM
  # USED" label, and (once pbLastUsedItem actually returns something) that
  # item's icon at BAG_UI_COMMAND_ICON_POS. Always builds a fresh private
  # bitmap (load -> copy -> draw), NEVER draws directly onto whatever
  # setBitmap returns, since item_command.png is also loaded by the Use
  # Item page's own USE button and the two sprites turned out to share a
  # cached Bitmap object when both used setBitmap - baking text onto one
  # bled onto the other. Called once at build time and again every time the
  # Bag page is shown (pbShowBagButtons), so the icon always reflects the
  # current last-used item (or its absence, e.g. once it's run out).
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
  # selected - graphic and offset both depend on the key (see
  # BAG_SEL_FILES/BAG_SEL_OFFSET), positioned relative to that button's own
  # BAG_UI_POS (not its current animated position, since the selector only
  # ever needs to be right once buttons are at rest). Swapping graphic files
  # resets the animation frame back to 0, same as the Command selector.
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

  # Steps the bagSel animation frame - called every update tick, same
  # pattern as pbAnimateCommandSelector.
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

  # A given Bag button's target opacity, same normal/selected scheme as the
  # Command menu buttons (CMD_BUTTON_OPACITY_NORMAL/SELECTED). item_command
  # is the one exception: while there's no saved last-used item yet
  # (pbLastUsedItem is nil - always true for now), it stays fixed at the
  # dimmer BAG_UI_OPACITY_NO_LAST_ITEM regardless of selection. Only once an
  # item is actually saved does it start following the normal/selected
  # opacity like every other button.
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

  # Slides every Bag page button in from its own edge (hp/restore from the
  # left, balls/battle/cancel from the right, item_command from the bottom),
  # all in one synced loop so they arrive together. Uses the message
  # window's own slide-in sound. Once settled, hands off to pbBagMenuLoop,
  # which owns the Bag page until the player backs out via cancel - this
  # call blocks until that happens. No-ops (skipping straight past the
  # entrance) if the buttons are already shown, as a safety net.
  #
  # Returns the item ID the player confirmed USE on, or nil if they backed
  # all the way out without picking anything. Tearing down the rest of the
  # Command page once an item's actually confirmed is the caller's job
  # (pbItemMenu) - this method only owns the Bag page's own six buttons.
  def pbShowBagUI
    alreadyShown = @sprites["bagUI_command"] && @sprites["bagUI_command"].visible
    pbBuildBagUI
    return nil if alreadyShown
    pbSEStop   # cut off the Command page's slide-out SE if it's still tailing off, no frame delay needed
    pbSEPlay("SlideUp", 60)
    # :bagItemUsed is thrown by pbUseItemMenuLoop when USE is actually
    # confirmed, carrying the chosen item's ID as its value - that jumps
    # straight back out here (past pbBagMenuLoop and any pocket/Use Item
    # sub-loops it's nested inside) rather than unwinding through every
    # intermediate menu normally via cancel.
    itemChosen = catch(:bagItemUsed) do
      pbShowBagButtons(BAG_GRID[0][0])   # "hp" - matches pbBagMenuLoop's starting selection
      pbBagMenuLoop
      nil
    end
    return itemChosen
  end

  # The actual entrance animation for all six Bag buttons (+ bagSel fading
  # in alongside them) - extracted out of pbShowBagUI so it can also be
  # reused when returning from a pocket page, without re-triggering
  # pbBagMenuLoop a second time (the caller is already inside it). Rebakes
  # item_command every time (pbDrawBagCommandButton) so its icon always
  # reflects the current last-used item.
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
      # bagSel rides along with whichever button it's bound to - same edge,
      # same travel distance - rather than sitting fixed in place while just
      # fading in, which looked disconnected from the button it highlights.
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

  # Reverse of pbShowBagUI - slides every Bag page button back out to the
  # same edge it entered from, all in one synced closing animation, then
  # hides them. No-ops if not actually shown.
  #
  # playSE defaults on for the two in-Bag transitions (into a pocket, into
  # the Use Item page) where nothing else is about to make noise. The
  # Command menu cancel path passes false - pbCommandMenuEx's own SlideUp
  # follows right after once the engine calls back into it, and the two
  # sounds landing on top of each other was the actual complaint.
  def pbHideBagUI(playSE = true)
    return if !@sprites["bagUI_command"] || !@sprites["bagUI_command"].visible
    pbSEPlay("SlideDown", 60) if playSE
    startOpacity = {}
    BAG_UI_FILES.each_key { |key| startOpacity[key] = @sprites["bagUI_#{key}"].opacity }
    sel = @sprites["bagSel"]
    selStartOpacity = sel ? sel.opacity : 0
    selStartX = sel ? sel.x : nil
    selStartY = sel ? sel.y : nil
    # bagSel exits along the same edge/distance as whichever button it's
    # currently bound to (@bagSelKey, tracked by pbUpdateBagSelector).
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

  # Rebakes the message box graphic with the pocket's header text (centered
  # around BAG_POCKET_TEXT_CENTER_X using the same fail-safe protection as
  # everywhere else in this UI, y fixed at BAG_POCKET_TEXT_Y), same colour/
  # shadow as the message window, plus a page indicator ("1/6" etc, from
  # @bagCurrentPage/pbBagCategoryPageCount) sitting BAG_POCKET_PAGE_TEXT_GAP
  # px after the pocket name ends, same y. No message window text is shown -
  # this is purely the graphic itself relabeled. Called both on first
  # opening a pocket and after switching pages, so the page number always
  # stays in sync.
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

  # Builds the pocket header's left/right arrow sprites if they don't
  # already exist, parked hidden/transparent at the message box's rest
  # position (pbScrollBagPocketIn slides them in together with the box).
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

  # Scrolls the message box in exactly like pbScrollMessageBoxIn, but first
  # rebaked with the pocket's header text, with the left/right arrows riding
  # along with it (same y offset as the box, fading in together), and with
  # cancel sliding back in from the right to its normal Bag position at the
  # same time - it was fully hidden by pbHideBagUI just before this, so it
  # gets its own re-entrance rather than staying static. No bagSel highlight
  # is shown on it here - that's a grid/index-selection thing, and the
  # pocket page has no grid.
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

  # Reverse of pbScrollBagPocketIn - scrolls the box + arrows + cancel back
  # out (cancel sliding off to the right, same as it does on the main Bag
  # page), then resets the message box graphic back to plain (no baked
  # pocket text), so it's clean for the next real message/prompt or pocket
  # header. The caller is responsible for bringing the other five Bag
  # buttons (and cancel, as part of that same full entrance) back in.
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

  # Looks up a pocket's 1-based number by its display name, via
  # PokemonBag.pocket_names - used for the balls/battle categories, which
  # are real vanilla pockets rather than a hand-picked whitelist. Returns
  # nil (rather than raising) if the name isn't found, so a naming mismatch
  # just shows an empty list instead of crashing.
  def pbBagPocketNumber(pocketName)
    idx = PokemonBag.pocket_names.index(pocketName)
    return idx ? idx + 1 : nil
  rescue StandardError
    return nil
  end

  # $bag.quantity(item) returns how many of that item the player owns (0 if
  # none/unowned). PokemonBag has no pbHasItem? method, so quantity > 0 is
  # the correct owned-check.
  def pbBagHasItem?(item_id)
    return pbBagItemQuantity(item_id) > 0
  end

  def pbBagItemQuantity(item_id)
    return 0 if !$bag
    return $bag.quantity(item_id)
  rescue StandardError
    return 0
  end

  # Every item ID the player's bag currently has at least 1 of, read
  # directly from $bag.pockets - a 1-indexed array of pockets, each an
  # array of [item_id, quantity] pairs - rather than scanning every
  # GameData::Item entry and probing each one.
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

  # Every item ID (with quantity > 0) in a specific 1-based pocket number,
  # read directly from $bag.pockets[pocketNum]. $bag.pockets is itself
  # already 1-indexed (index 0 is unused/nil - vanilla loops run
  # (1...@bag.pockets.length)), so a 1-based pocketNum maps straight to
  # pockets[pocketNum], NOT pockets[pocketNum - 1].
  def pbBagPocketItemIDs(pocketNum)
    return [] if !$bag || !pocketNum
    pocket = $bag.pockets[pocketNum]
    return [] if !pocket
    return pocket.select { |item_id, qty| qty && qty > 0 }.map { |item_id, qty| item_id }
  rescue StandardError
    return []
  end

  # Every item ID (unpaged, full list) for a given pocket category. hp/
  # restore use the hand-maintained whitelists (BAG_HP_ITEM_IDS/
  # BAG_STATUS_ITEM_IDS) since Essentials has no built-in flag for "restores
  # HP/PP" or "cures status". balls/battle use the item's own real vanilla
  # pocket data instead, read directly from $bag.pockets via
  # pbBagPocketItemIDs.
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

  # Whether a given item grid slot can be selected at all - only true if
  # the current page actually has an item in that slot (empty slots, when
  # there's fewer than 6 items on a page, are shown but not selectable).
  # Relies on @bagItemIds, kept in sync by pbShowBagItemButtons/
  # pbSwitchBagItemPage.
  def pbItemIndexEnabled?(slot)
    return false if slot.nil? || slot < 0 || slot >= BAG_ITEM_SLOTS
    return !(@bagItemIds.nil? || @bagItemIds[slot].nil?)
  end

  # A given item grid slot's target opacity - selected sits full opacity,
  # every other (filled) slot sits at the dimmer BAG_ITEM_BUTTON_OPACITY_NORMAL,
  # same normal/selected scheme as the Command menu and Bag page buttons.
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

  # Builds the item grid's animated 4-frame highlight sprite (item_button_sel,
  # 288x384 -> 288x96 per frame) if it doesn't already exist, hidden/
  # transparent until the grid is actually shown.
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
  # tick, same pattern as pbAnimateCommandSelector/pbAnimateBagSelector.
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

  # Moves the item grid highlight onto the given slot (BAG_ITEM_SEL_OFFSET
  # relative to that slot's own button position), makes it visible, and
  # refreshes every button's opacity for the new selection. This is the
  # single place that changes which slot is "selected" - both keyboard nav
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
  # (centered in the 188x60 area starting at 82,10, same fail-safe
  # protection as the rest of this UI), and the item's icon at 34,16. If
  # item_id is nil (slot has nothing to show), it's just the plain button
  # graphic with no text/icon. Returns the bitmap rather than assigning it,
  # so it can be baked either straight onto an on-screen slot
  # (pbDrawBagItemButton) or onto an off-screen "incoming page" sprite
  # during a page-switch transition (pbSwitchBagItemPage).
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

  # Bakes pbBuildBagItemButtonBitmap's result straight onto the given
  # on-screen slot's own sprite.
  def pbDrawBagItemButton(slot, item_id)
    sprite = @sprites["bagItemButton_#{slot}"]
    return if !sprite
    sprite.bitmap&.dispose
    sprite.bitmap = pbBuildBagItemButtonBitmap(item_id)
  end

  # Slides all six item buttons in from the right together, after baking
  # each slot's content from pbBagCategoryItems(category, @bagCurrentPage)
  # (nil slots just show the plain button graphic and stay unselectable -
  # see pbItemIndexEnabled?). Lands the grid selector on the first filled
  # slot and fades it in alongside the buttons. Only used for the pocket's
  # initial open/close - switching between pages once inside uses
  # pbSwitchBagItemPage's own left/right transition instead.
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
        # bagItemSel rides along with whichever slot it's bound to, same
        # edge/distance as that slot's own button, rather than sitting
        # fixed in place while just fading - same fix as bagSel got.
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

  # Reverse of pbShowBagItemButtons - slides all six item buttons (and the
  # grid selector) back out to the right, then hides them. No-ops if not
  # actually shown.
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

  # A pocket page's own mini input loop - now a real 2x3 item grid
  # (pbItemIndexEnabled?/pbUpdateItemGridSelector), plus Back on the
  # keyboard or a click on the (still on-screen) cancel button.
  #
  # Up/Down move the selection within the current page, skipping empty
  # slots. Left/Right move within the page UNLESS already at that edge
  # column - pressing Right from column 2 (rightmost) or Left from column 1
  # (leftmost) instead triggers pbSwitchBagItemPage, same as clicking the
  # left/right arrow sprites directly. A mouse click on any filled slot
  # just moves the selection there - it does NOT confirm/act on it yet
  # (the item-use follow-up screen isn't designed yet).
  #
  # Back/cancel-click flashes icon_cancel/icon_cancel_p, exits the item
  # buttons, scrolls the header back out, and returns - the caller
  # (pbBagMenuLoop) is responsible for bringing the other Bag buttons back
  # afterward.
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

      # Mouse.click? is read ONCE per frame into mouseClicked and reused
      # below - calling it repeatedly (once per widget) was the actual bug
      # behind cancel/the arrows never responding to a click: this engine's
      # Mouse.click? consumes/resets itself after the first read in a given
      # frame, so only whichever check ran first ever saw it as true. Every
      # other click-driven loop in this file (Command menu, pbBagMenuLoop)
      # already reads it exactly once for the same reason.
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
      # A click on ANY enabled slot both selects AND confirms it in the same
      # action - same "select and confirm in one action" convention used
      # everywhere else in this UI (Command menu, main Bag grid). It does
      # NOT need to already be the selected slot first.
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
  # twice, same swap-and-hold pattern as the rest of this UI's press
  # feedback.
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

  # Command menu's own "back to previous Pokemon" cancel - only shown when
  # the base engine passes mode == 1 (we're on the second Pokemon of a
  # double battle and can still back out to reselect the first one's
  # action). Reuses the Bag UI's cancel button/graphic/position/slide-in,
  # same as the Fight page borrows it - it's the same button, just repurposed
  # here. Unlike everywhere else it's used, this one isn't part of the
  # command index (Up/Down/Left/Right never land on it) and always sits at
  # full opacity, and it's raised above the message box the same way Fight/
  # Bag's cancel is, since it shares the screen with "What will {1} do?".
  # Matches the cancel button's visibility to @cmdCancelWanted with no
  # animation - used when the Command page is already fully up (page never
  # hid between battlers) and only the mode changed, so there's no fade/
  # slide cascade running for it to join. A no-op if it already matches.
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

  # Reverse of the fade-in pbScrollCommandPanelIn plays for this button -
  # used when the player actually backs out (BACK/click), so it scrolls away
  # immediately rather than waiting for the next battler's Command page to
  # sync it away with no animation at all. No slide SE - the user found the
  # slide sound distracting/redundant on this particular button.
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

  # Same flash-between-normal-and-_p pattern as pbFlashBagCancelButton -
  # separate method only because the Command menu's cancel is conceptually
  # its own button, even though it's the same sprite/graphic underneath.
  def pbFlashCmdCancelButton
    pbFlashBagCancelButton
  end

  # Flashes whichever pocket arrow was clicked between its normal and _p
  # (pressed) graphic twice, same swap-and-hold pattern as
  # pbFlashBagCancelButton - direction 1 = right arrow, -1 = left arrow.
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

  # Switches the item grid to the next/previous page (direction 1 = next/
  # right arrow, -1 = previous/left arrow). No-ops silently if that would
  # go past the first/last page (no wraparound - can't go from page 1
  # straight to the last page or vice versa).
  #
  # The incoming page's six buttons are baked and parked off-screen on the
  # side the new page is "coming from" (right arrow -> incoming starts off
  # the right edge and both sets slide left; left arrow -> incoming starts
  # off the left edge and both sets slide right), then both the current and
  # incoming sets scroll together across the full BAG_ITEM_AREA_SIZE width
  # in one synced loop. Once settled, the incoming bitmaps are transferred
  # onto the real "bagItemButton_#" sprites (so future lookups/redraws keep
  # working normally) and the temporary incoming sprites are hidden again.
  # The pocket header is rebaked so its page indicator ("1/6" etc) stays in
  # sync, and the grid selector (hidden for the duration of the scroll,
  # since it doesn't need to visibly travel across pages) reappears on the
  # new page - same row as before, landing on the edge column you'd
  # naturally arrive at continuing in the direction you pressed (next page
  # -> leftmost column, previous page -> rightmost column), or the nearest
  # actually-filled slot if that one's empty.
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

  # Builds the Use Item page's "USE" button if it doesn't already exist -
  # its own sprite (NOT the shared bagUI_command one, so rebaking "USE"
  # here never touches the real Bag page's "LAST ITEM USED" label), same
  # graphic/position/text-y as item_command normally uses.
  def pbBuildUseItemButton
    return if @sprites["useItemButton"]
    size = BAG_UI_SIZE["command"]
    sprite = IconSprite.new(@viewport)
    # Built as a private (load -> copy -> draw) bitmap, NOT via setBitmap -
    # item_command.png is also loaded by the real bagUI_command button
    # (pbDrawBagCommandButton), and the two turned out to share a cached
    # Bitmap object when both used setBitmap directly: baking "USE" onto
    # this one was silently bleeding onto "LAST ITEM USED"'s bitmap too
    # (and vice versa). A private copy has no such connection.
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

  # Splits text into lines that each fit within max_width when drawn in
  # bmp's current font, breaking on word boundaries - same general approach
  # Essentials itself uses for wrapped message text. A single word wider
  # than max_width on its own is still placed alone on its own line rather
  # than looping forever.
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

  # Bakes the Use Item page's content onto item_description.png - the
  # item's icon (relative 120,20), its name (centered within the
  # restricted USE_ITEM_TEXT_AREA_X/WIDTH span, y 36), owned quantity as
  # "x###" (fixed at 558,36, not centered), and its description word-
  # wrapped to stay within that same restricted width, each line centered
  # the same way, starting at y 98. Colour/shadow are the page's own
  # (0,0,0 / 173,189,189), NOT the message window's white/dark-grey scheme
  # used everywhere else in this UI.
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

  # The Use Item page - reached either by confirming a selected item on a
  # pocket's item grid, or by confirming item_command ("LAST ITEM USED")
  # directly from the main Bag page (category is nil in that case - there's
  # no pocket to return to). The CALLER is responsible for hiding whatever
  # was on screen before calling this (pbHideBagItemButtons+
  # pbScrollBagPocketOut for a pocket, pbHideBagUI for the direct shortcut)
  # and for restoring it afterward - this method only owns the USE/cancel/
  # item_description entrance, its own input loop, and its own exit.
  #
  # USE/cancel slide in from bottom/right (same positions as the Bag page)
  # together with item_description.png fading in, all in one synced beat.
  # They're a 2x1 grid using the existing bagSel highlight system
  # (item_command_sel/icon_cancel_sel) - full opacity always, no dimming.
  # Blocks until the player backs out or USEs the item.
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

  # Reverse of pbShowUseItemPage's entrance - USE/cancel slide back out
  # (bottom/right respectively) and item_description fades out together,
  # with the selector riding out along whichever key it was last bound to
  # (@useItemSelectedKey). Only closes this page's own three sprites -
  # restoring whatever was open before (a pocket's item grid, or the main
  # Bag page) is the caller's job, same convention as pbShowUseItemPage's
  # entrance.
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

  # The Use Item page's own mini input loop - Left/Right toggle between USE
  # and cancel (USE_ITEM_GRID). A single click both selects AND confirms in
  # the same action (same "select and confirm in one action" convention as
  # every other grid in this UI - clicking a DIFFERENT key still confirms
  # it immediately, it doesn't need a second click once it's already
  # selected).
  #
  # Cancel flashes icon_cancel/icon_cancel_p, closes this page's own three
  # sprites, and returns normally - the caller (pbShowBagPocket or
  # pbBagMenuLoop) is responsible for restoring whatever was open before.
  #
  # USE closes this page's own sprites and throws :bagItemUsed carrying
  # item_id, unwinding straight back out to pbShowBagUI's catch block -
  # using an item ends the turn, so this skips past every intermediate
  # pocket/Bag menu loop still on the stack rather than unwinding through
  # each one via cancel. The item isn't marked as last-used here - that
  # only happens in pbItemMenu, once the battle engine has actually
  # accepted it (see pbItemMenu's comments for why).
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
        # Does NOT call pbSetLastUsedItem here - the battle engine hasn't
        # actually accepted this item yet at this point (that only
        # happens once pbItemMenu's yield returns true). Marking it as the
        # last-used item is pbItemMenu's job, right after that succeeds, so
        # a rejected item (no valid target, no effect, etc.) never shows up
        # as usable from item_command.
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

  # Whether a given Bag grid cell can be selected at all - item_command is
  # skipped entirely (can't be navigated onto or clicked) while there's no
  # saved last-used item to show, since it has nothing to act on. Every
  # other cell is always selectable.
  def pbBagIndexEnabled?(key)
    return !(key == "command" && pbLastUsedItem.nil?)
  end

  # Bag page's own input loop - 2x3 grid navigation (see BAG_GRID), skipping
  # over item_command entirely while it's disabled (pbBagIndexEnabled?).
  #
  # A mouse click on any enabled button both selects AND confirms it in the
  # same action, same as the Command menu - it doesn't just move the mouse
  # over a button, it commits to it immediately.
  #
  # Only cancel (bottom-right, index 6) actually does anything on confirm
  # yet: Back on the keyboard, a mouse click on the cancel graphic, or
  # confirming while cancel is the highlighted index all flash
  # icon_cancel/icon_cancel_p twice, then close every Bag button
  # (pbHideBagUI) and bring the Command page prompt back (message box +
  # buttons + battler icon boxes doing their normal load-in animation - the
  # shadow/ball backdrop, ball bar, and party balls were never hidden, so
  # they're untouched). Every other grid cell is selectable/navigable but
  # not wired up to anything yet.
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

      # A click both selects AND confirms in the same action - whichever
      # enabled button the mouse is over when clicked becomes the choice
      # immediately, exactly like the Command menu's buttons.
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
      # last-used item, bypassing pockets entirely - category is nil here
      # (there is no pocket context), so pbShowUseItemPage/
      # pbUseItemMenuLoop know to close/reopen the main six-button Bag
      # page on the way in/out instead of a pocket's item grid.
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
        # Doesn't call pbShowCommandPrompt itself - pbItemMenu returning
        # false sends control back to the battle engine, which calls
        # pbCommandMenu (and so pbCommandMenuEx) again on its own. Doing it
        # here too was retyping "What will {1} do?" a second time right
        # after pbCommandMenuEx's own entrance had just typed it once.
        break
      end
    end
  end

  # Entry point the battle engine calls when the player picks Bag from the
  # Command menu (Battle#pbItemMenu, in the base battle scripts, yields
  # item/useType/idxPkmn/idxMove/itemScene to this and registers the choice
  # with whatever it gets back). Runs the custom Bag UI in place of the
  # vanilla one, and loops back into it if the engine rejects whatever got
  # picked (wrong target, item not usable here, etc.) rather than ending the
  # turn on a bad choice.
  #
  # Target selection is simplified to single-battle assumptions for now:
  # items used on a Pokémon or battler (useType 1/3) target whoever's
  # choosing this turn, Poké Balls (useType 4) target the lone opponent, and
  # no-target items (useType 5) don't need one. Multi-battle targeting and
  # move selection for Ethers-style items (useType 2) aren't wired up yet -
  # those items just get skipped with the player sent back to the Bag page.
  alias customUI_pbItemMenu pbItemMenu
  def pbItemMenu(idxBattler, firstAction)
    # pbCommandMenuEx already un-hides the data boxes right before it returns
    # (it doesn't know Bag is about to take over the screen), so they need
    # hiding again here for as long as this custom UI is up - restored at
    # the very end, same bracket pbCommandMenuEx uses for its own portion.
    pbHideDataBoxes
    pbHideCommandButtons
    pbScrollMessageBoxOut
    registered = false
    loop do
      item_id = pbShowBagUI   # blocks until the player backs out, or confirms USE on an item
      break if !item_id
      item = GameData::Item.get(item_id)
      useType = item.battle_use
      idxPkmn = -1
      idxMove = -1
      case useType
      when 1, 3
        idxPkmn = @battle.battlers[idxBattler].pokemonIndex
      when 4
        opponents = @battle.allOtherSideBattlers(idxBattler)
        idxPkmn = opponents[0].index if opponents.length == 1
      when 5
        idxPkmn = idxBattler
      end
      if idxPkmn < 0
        # Not supported by this UI yet (multi-target Poké Ball, Ether, etc.)
        # - a real message box may still have appeared while working that
        # out, so clear it before showing the Bag page again.
        pbHideMessageBox
        next
      end
      if yield item_id, useType, idxPkmn, idxMove, self
        # Only mark it as the last-used item once the engine has actually
        # accepted and registered it - a rejected item (wrong target, no
        # effect on that Pokémon, etc.) never counts, and a genuinely
        # successful one always does, regardless of item type.
        pbSetLastUsedItem(item_id)
        registered = true
        break
      end
      # Engine rejected the choice (bad target, can't be used on that
      # Pokémon, no effect, etc.). Validating the choice may have shown a
      # real battle message ("It won't have any effect", etc.) - that
      # message box stays open by design once shown (see pbShowWindow), so
      # it has to be closed explicitly here or it's left sitting on top of
      # the Bag page when it reopens.
      pbHideMessageBox
    end
    pbHideCommandPageAssets if registered
    pbShowDataBoxes
    return registered
  end
end

# Animation::Intro's default createProcesses adds a full-opacity "black_bar"
# sprite over the command bar area which only fades out 3/4 of the way through
# the intro - the source of a solid black rectangle at battle start. Skips
# creating that specific sprite; everything else is untouched.
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
#==============================================================================#
#                  Online System — Custom UI (Hub Screen)                      #
#==============================================================================#
# This is a NEW, SEPARATE screen on top of the existing Online system. It
# does NOT replace or modify Online.open_menu (the pbShowCommands version in
# MessageUI.rb) — that stays fully intact and callable, including "Enable
# Online Features", so every existing feature can still be tested while this
# custom UI is built out incrementally, screen by screen.
#
# Graphics folder: Graphics/Custom UI/Online/
#   grid.png     — 1600x480. Built as two identical 800px tiles side by side
#                  (same technique as the pause menu's top/bottom grids) so
#                  scrolling it left and wrapping at the halfway point (800px)
#                  looks seamless.
#   overlay.png  — 800x480, static, sits over the grid at (0,0).
#
# Any image file that doesn't exist yet falls back to a generated placeholder
# (solid fill + filename label) instead of crashing — this screen is safe to
# open and test with a completely empty Graphics/Custom UI/Online/ folder,
# and will start using real art the moment matching filenames are dropped in.
#==============================================================================#

class OnlineHub_Scene
  UI_FOLDER = "Graphics/Custom UI/Online/"

  SCREEN_W = 800
  SCREEN_H = 480

  GRID_W             = 1600
  GRID_SCROLL_W      = GRID_W / 2   # wrap point — grid.png tiles at half width
  GRID_SCROLL_SPEED  = 1            # pixels per frame, right to left

  ONLINE_TEXT_X       = 12
  ONLINE_TEXT_Y       = 16
  ONLINE_TEXT_COLOR   = Color.new(255, 255, 255)
  ONLINE_SHADOW_COLOR = Color.new(156, 156, 156)

  # Button row — index list order also determines left-to-right screen
  # position (button 0 = leftmost). Graphics are named identically to each
  # key, e.g. "friends.png", in UI_FOLDER.
  BUTTON_KEYS   = ["friends", "messages", "sessions", "trading", "battles", "settings"]
  BUTTON_W      = 76
  BUTTON_H      = 74
  BUTTON_GAP_X  = 40
  BUTTON_START_X = 72
  BUTTON_Y       = 204

  # Intro animation: each button fades in while sliding in from off the left
  # edge of the screen to its resting position. Staggered in REVERSE index
  # order — button index 0 (friends, leftmost) gets the longest start delay
  # so it's the last to arrive, and the last button in the list (settings,
  # rightmost) gets zero delay so it lands first, despite being drawn
  # furthest across the screen.
  BUTTON_ANIM_DURATION = 20   # frames each individual slide takes
  BUTTON_ANIM_STAGGER  = 6    # frames between each button's start time
  BUTTON_OFFSCREEN_X   = -BUTTON_W - 40

  #-----------------------------------------------------------------------------
  # Safe bitmap loader — falls back to a generated placeholder (solid fill +
  # filename label) if the real file doesn't exist yet, instead of crashing.
  # Lets every screen in this UI be tested before any real art exists.
  #-----------------------------------------------------------------------------
  def pbSafeBitmap(filename, w, h, fill_color = Color.new(40, 40, 60))
    path = UI_FOLDER + filename
    begin
      return Bitmap.new(path)
    rescue StandardError
      bmp = Bitmap.new(w, h)
      bmp.fill_rect(0, 0, w, h, fill_color)
      pbSetSystemFont(bmp)
      bmp.font.color = Color.new(255, 255, 255)
      bmp.draw_text(0, 0, w, h, "[missing: #{filename}]", 1)
      return bmp
    end
  end

  #-----------------------------------------------------------------------------
  # "2000" -> "2,000"
  #-----------------------------------------------------------------------------
  def pbFormatCount(n)
    n.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end

  #-----------------------------------------------------------------------------
  # Builds the "Online: N" text as its own full-screen transparent bitmap,
  # drawn above the overlay. Only rebuilt when the count actually changes —
  # see pbUpdate — not every frame.
  #-----------------------------------------------------------------------------
  def pbBuildOnlineCountBitmap
    bmp  = Bitmap.new(SCREEN_W, SCREEN_H)
    pbSetSystemFont(bmp)
    text = "Online: #{pbFormatCount(Online.online_count)}"
    if defined?(pbDrawTextPositions)
      pbDrawTextPositions(bmp, [[text, ONLINE_TEXT_X, ONLINE_TEXT_Y, :left,
                                  ONLINE_TEXT_COLOR, ONLINE_SHADOW_COLOR]])
    else
      # Manual fallback shadow-draw if pbDrawTextPositions isn't available
      # for some reason — keeps this screen working either way.
      bmp.font.color = ONLINE_SHADOW_COLOR
      bmp.draw_text(ONLINE_TEXT_X + 1, ONLINE_TEXT_Y + 1, 300, 32, text)
      bmp.font.color = ONLINE_TEXT_COLOR
      bmp.draw_text(ONLINE_TEXT_X, ONLINE_TEXT_Y, 300, 32, text)
    end
    bmp
  end

  #-----------------------------------------------------------------------------
  # Final resting X for a given button index — left to right, index order.
  #-----------------------------------------------------------------------------
  def pbButtonTargetX(index)
    BUTTON_START_X + (index * (BUTTON_W + BUTTON_GAP_X))
  end

  #-----------------------------------------------------------------------------
  # Frame (relative to intro start) at which button `index` begins its slide.
  # Reversed vs. list order — see BUTTON_ANIM_STAGGER comment above.
  #-----------------------------------------------------------------------------
  def pbButtonStartDelay(index)
    (BUTTON_KEYS.length - 1 - index) * BUTTON_ANIM_STAGGER
  end

  def pbBuildButtons
    @sprites["buttons"] = []
    BUTTON_KEYS.each_with_index do |key, i|
      btn = Sprite.new(@viewport)
      btn.bitmap = pbSafeBitmap("#{key}.png", BUTTON_W, BUTTON_H)
      btn.x       = BUTTON_OFFSCREEN_X
      btn.y       = BUTTON_Y
      btn.z       = 3
      btn.opacity = 0
      @sprites["buttons"] << btn
    end
  end

  #-----------------------------------------------------------------------------
  # Advances the staggered slide-in for every button, given how many frames
  # have elapsed since the intro began. Returns true once every button has
  # reached its final resting position.
  #-----------------------------------------------------------------------------
  def pbUpdateButtonIntro(elapsed_frames)
    all_done = true
    @sprites["buttons"].each_with_index do |btn, i|
      target_x = pbButtonTargetX(i)
      delay    = pbButtonStartDelay(i)
      local_frame = elapsed_frames - delay

      if local_frame < 0
        # Hasn't started yet — stay hidden, off-screen
        btn.x       = BUTTON_OFFSCREEN_X
        btn.opacity = 0
        all_done    = false
      elsif local_frame >= BUTTON_ANIM_DURATION
        # Finished — snap exactly to rest, in case of frame rounding
        btn.x       = target_x
        btn.opacity = 255
      else
        t        = (local_frame + 1) / BUTTON_ANIM_DURATION.to_f
        progress = 1 - (1 - t) ** 2   # ease-out, matches pause menu style
        btn.x       = BUTTON_OFFSCREEN_X + ((target_x - BUTTON_OFFSCREEN_X) * progress).to_i
        btn.opacity = (255 * progress).to_i
        all_done    = false
      end
    end
    all_done
  end

  def pbTotalIntroFrames
    pbButtonStartDelay(0) + BUTTON_ANIM_DURATION  # index 0 has the longest delay
  end

  #-----------------------------------------------------------------------------
  # Main loop
  #-----------------------------------------------------------------------------
  def main
    @viewport   = Viewport.new(0, 0, SCREEN_W, SCREEN_H)
    @viewport.z = 99999
    @sprites    = {}

    # Grid — scrolling background layer
    @sprites["grid"] = Sprite.new(@viewport)
    @sprites["grid"].bitmap = pbSafeBitmap("grid.png", GRID_W, SCREEN_H)
    @sprites["grid"].x = 0
    @sprites["grid"].y = 0
    @sprites["grid"].z = 0
    @grid_x = 0

    # Overlay — static, sits over the grid
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = pbSafeBitmap("overlay.png", SCREEN_W, SCREEN_H)
    @sprites["overlay"].x = 0
    @sprites["overlay"].y = 0
    @sprites["overlay"].z = 1

    # Live online-player-count text — above the overlay
    @sprites["count_text"] = Sprite.new(@viewport)
    @sprites["count_text"].bitmap = pbBuildOnlineCountBitmap
    @sprites["count_text"].x = 0
    @sprites["count_text"].y = 0
    @sprites["count_text"].z = 2
    @last_online_count = Online.online_count

    pbBuildButtons

    Graphics.transition

    # Intro — staggered button slide-in. BACK can cancel out during this too.
    cancelled = false
    total_intro_frames = pbTotalIntroFrames
    (0...total_intro_frames).each do |frame|
      Graphics.update
      Input.update
      @grid_x -= GRID_SCROLL_SPEED
      @grid_x = 0 if @grid_x <= -GRID_SCROLL_W
      @sprites["grid"].x = @grid_x
      pbUpdateSceneMap if defined?(pbUpdateSceneMap)
      pbUpdateButtonIntro(frame)
      if Input.trigger?(Input::BACK)
        cancelled = true
        break
      end
    end
    pbUpdateButtonIntro(total_intro_frames) unless cancelled  # ensure exact final snap

    unless cancelled
      loop do
        Graphics.update
        Input.update
        pbUpdate
        break if Input.trigger?(Input::BACK)
      end
    end

    Graphics.freeze
    pbDispose
  end

  def pbUpdate
    # Scroll the grid right -> left, wrapping seamlessly at the half-width
    # point — identical technique to the pause menu's grid scroll.
    @grid_x -= GRID_SCROLL_SPEED
    @grid_x = 0 if @grid_x <= -GRID_SCROLL_W
    @sprites["grid"].x = @grid_x

    # Keeps the overworld/Game_Player ticking behind this screen — same
    # technique the pause menu uses via pbUpdateSceneMap — which is what
    # lets WS polling (and therefore the live online count) keep updating
    # while this screen is open, without this file needing its own
    # networking logic at all.
    pbUpdateSceneMap if defined?(pbUpdateSceneMap)

    # Only rebuild the text bitmap when the count actually changes, not
    # every frame.
    current = Online.online_count
    if current != @last_online_count
      @last_online_count = current
      @sprites["count_text"].bitmap.dispose
      @sprites["count_text"].bitmap = pbBuildOnlineCountBitmap
    end
  end

  def pbDispose
    @sprites.each_value do |s|
      if s.is_a?(Array)
        s.each { |sub| sub.bitmap&.dispose; sub.dispose }
      else
        s.bitmap&.dispose
        s.dispose
      end
    end
    @viewport.dispose
  end
end

#==============================================================================#
# Entry point — deliberately separate from Online.open_menu (MessageUI.rb).
# Both can be called independently; nothing here touches the existing
# command-window menu or its "Enable Online Features" toggle.
#==============================================================================#
module Online
  def self.open_custom_hub
    OnlineHub_Scene.new.main
  end
end
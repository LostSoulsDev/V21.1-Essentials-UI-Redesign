#==============================================================================#
#             Carmaniac's (AKA Lostsoulsdev) Speech Bubble                     #
#                                 V3.0.2                                       #
#------------------------------------------------------------------------------#
#                           For Essentials V21.1                               #
#                 Developed by Carmaniac (AKA Lostsoulsdev)                    #
#                Big thanks to NoNonever for keeping updated                   #
#==============================================================================#
# To use, call pbSpeech(type, eventID, KeepAlive)
#
# Where type is either 1 or 2:
# 1 - Floating bubble
# 2 - Speech bubble with arrow
# 3 - Short arrow window
# 4 - Shocked window
#
# New call methods
# pbSpeechBubble(event_id, "text", options)
# place pbSpeechBubble("Text, options") in event comment for auto bubble placement
#==============================================================================#
#Player Class Modifications
#==============================================================================#

# Player Class Modifications
class Game_Temp
  attr_accessor :speechbubble_bubble
  attr_accessor :speechbubble_vp
  attr_accessor :speechbubble_arrow
  attr_accessor :speechbubble_outofrange
  attr_accessor :speechbubble_talking
  attr_accessor :speechbubble_keepalive
  attr_accessor :speechbubble_direction
  attr_accessor :message_window
  attr_accessor :speechbubbles
  attr_accessor :speechbubble_timers
  attr_accessor :speechbubbles
  attr_accessor :speechbubble_forcebottom
  attr_accessor :speechbubble_forcearrow
end

module MessageConfig
  BUBBLETEXTBASE  = Color.new(248,248,248)
  BUBBLETEXTSHADOW= Color.new(72,80,88)
end

class Rect
  def intersect?(other)
    return false if self.x + self.width  <= other.x
    return false if self.x >= other.x + other.width
    return false if self.y + self.height <= other.y
    return false if self.y >= other.y + other.height
    true
  end
end

class Window_AdvancedTextPokemon
  def text=(value)
    if value && value != "" && $game_temp.speechbubble_bubble && $game_temp.speechbubble_bubble > 0
      # Determine speaker (player or event)
      speaker =
        if $game_temp.speechbubble_talking == -1
          $game_player
        else
          $game_map.events[$game_temp.speechbubble_talking]
        end

      # Stop if nothing valid
      return unless speaker

      case $game_temp.speechbubble_bubble
      when 4 # Shock bubble
        $game_temp.speechbubble_bubble = 0 if !$game_temp.speechbubble_keepalive
        resizeToFit2(value, 130, 64)
        @x = speaker.screen_x
        @y = speaker.screen_y - (32 + @height)
        if @y > (Graphics.height - @height - 2)
          @y = (Graphics.height - @height)
        elsif @y < 2
          @y = 2
        end
        if @x > (Graphics.width - @width - 2)
          @x = (speaker.screen_x - @width)
        elsif @x < 2
          @x = 2
        end

      when 1 # Floating bubble
        $game_temp.speechbubble_bubble = 0 if !$game_temp.speechbubble_keepalive
        resizeToFit2(value, 400, 100)
        @x = speaker.screen_x
        @y = speaker.screen_y - (32 + @height)
        if @y > (Graphics.height - @height - 2)
          @y = (Graphics.height - @height)
        elsif @y < 2
          @y = 2
        end
        if @x > (Graphics.width - @width - 2)
          @x = (speaker.screen_x - @width)
        elsif @x < 2
          @x = 2
        end
      else
        # Any other type - just reset safely
        $game_temp.speechbubble_bubble = 0 if !$game_temp.speechbubble_keepalive
      end
    end
    setText(value)
  end

  def overlaps?(other_window)
    return false if !other_window
    return false if self.disposed? || other_window.disposed?
    self_rect = Rect.new(self.x, self.y, self.width, self.height)
    other_rect = Rect.new(other_window.x, other_window.y, other_window.width, other_window.height)
    self_rect.intersect?(other_rect)
  end
end

def pbRepositionMessageWindow(msgwindow, linecount = 2)
  return if !msgwindow || msgwindow.disposed?
  return unless $game_temp
  return if !$game_map || !$game_temp
  # Allow -1 for player
  if $game_temp.speechbubble_talking &&
     $game_temp.speechbubble_talking != -1 &&
     (!$game_map || !$game_map.events[$game_temp.speechbubble_talking])
    echoln("[SpeechBubble] Invalid talking event (#{$game_temp.speechbubble_talking}); resetting.")
    $game_temp.speechbubble_talking = nil
  end

  msgwindow.height = 32 * linecount + msgwindow.borderY
  msgwindow.y = (Graphics.height - msgwindow.height)

  if $game_temp.in_battle && !$scene.respond_to?("update_basic")
    msgwindow.y = 0
  elsif $game_system && $game_system.respond_to?("message_position")
    case $game_system.message_position
    when 0 # up
      msgwindow.y = 0
    when 1 # middle
      msgwindow.y = (Graphics.height / 2) - (msgwindow.height / 2)
    when 2
      # Determine event or player target
      target =
        if $game_temp.speechbubble_talking == -1
          $game_player
        else
          $game_map.events[$game_temp.speechbubble_talking]
        end

      if $game_temp.speechbubble_bubble == 3 && target
        # Short arrow window
        $game_temp.speechbubble_direction = "normal"
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 100
        msgwindow.width = 400

        msgwindow.x = target.screen_x - (msgwindow.width / 2)
        msgwindow.x = 0 if msgwindow.x < 0
        msgwindow.x = Graphics.width - msgwindow.width if msgwindow.x > (Graphics.width - msgwindow.width)

        if $game_player.direction == 2 # Facing down
          msgwindow.y = target.screen_y + 14
          if msgwindow.y > (Graphics.height - msgwindow.height)
            msgwindow.y = target.screen_y - (msgwindow.height + 60)
          end
        else
          msgwindow.y = target.screen_y - (msgwindow.height + 60)
          if msgwindow.y < 16
            msgwindow.y = target.screen_y + 14
            $game_temp.speechbubble_direction = "down"
          else
            $game_temp.speechbubble_direction = "normal"
          end
        end

      elsif $game_temp.speechbubble_bubble == 1
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 100
        msgwindow.width = 400

      elsif $game_temp.speechbubble_bubble == 4
        msgwindow.setSkin("Graphics/windowskins/shock")
        msgwindow.height = 100
        msgwindow.width = 400

      elsif $game_temp.speechbubble_bubble == 2
        msgwindow.setSkin("Graphics/windowskins/frlgtextskin")
        msgwindow.height = 102
        msgwindow.width = Graphics.width
        if $game_player.direction == 8
          $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280 + 96)
          msgwindow.y = 6
        else
          $game_temp.speechbubble_vp = Viewport.new(0, 6 + msgwindow.height, Graphics.width, 280 + 96)
          msgwindow.y = (Graphics.height - msgwindow.height) - 6
          msgwindow.y = 6 if $game_temp.speechbubble_outofrange
        end
      else
        msgwindow.height = 102
        msgwindow.y = Graphics.height - msgwindow.height - 6
      end
    end
  end

  # Window opacity
  if $game_system && $game_system.respond_to?("message_frame")
    msgwindow.opacity = 0 if $game_system.message_frame != 0
  end

  if $game_message
    case $game_message.background
    when 1, 2
      msgwindow.opacity = 0
    end
  end
end

def pbCreateMessageWindow(viewport = nil, skin = nil)
  arrow = nil
  # Determine event or player target
  return Window_AdvancedTextPokemon.new("") if !$game_map || !$game_temp
  target =
    if $game_temp.speechbubble_talking == -1
      $game_player
    else
      $game_map.events[$game_temp.speechbubble_talking]
    end

  if $game_temp.speechbubble_bubble == 3 && target
    if $game_player.direction == 2
      $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      $game_temp.speechbubble_vp.z = 999999
      arrow = Sprite.new($game_temp.speechbubble_vp)
      arrow.x = target.screen_x - 17
      arrow.z = 999999
      if target.screen_y > 240 + 96
        arrow.y = target.screen_y - 60
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "DownArrow")
      else
        arrow.y = target.screen_y - 8
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "UpArrow")
      end
    else
      $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      $game_temp.speechbubble_vp.z = 999999
      arrow = Sprite.new($game_temp.speechbubble_vp)
      arrow.x = target.screen_x - 17
      arrow.z = 999999
      if target.screen_y > 240 + 96
        arrow.y = target.screen_y - 60
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "DownArrow")
      elsif target.screen_y < 176 + 48
        arrow.y = target.screen_y - 8
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "UpArrow")
      else
        arrow.y = target.screen_y - 60
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "DownArrow")
      end
    end

  elsif $game_temp.speechbubble_bubble == 2 && target
    if $game_player.direction == 8
      $game_temp.speechbubble_vp = Viewport.new(0, 104, Graphics.width, 280 + 96)
      $game_temp.speechbubble_vp.z = 999999
      arrow = Sprite.new($game_temp.speechbubble_vp)
      arrow.x = target.screen_x - Graphics.width
      arrow.y = (target.screen_y - Graphics.height) - 32# + 136
      arrow.z = 999999
      arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow4")
      arrow.zoom_x = 2
      arrow.zoom_y = 2
      if arrow.x < -230
        arrow.x = target.screen_x
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow3")
      end
    else
      $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, 280 + 96)
      $game_temp.speechbubble_vp.z = 999999
      arrow = Sprite.new($game_temp.speechbubble_vp)
      arrow.x = target.screen_x
      arrow.y = target.screen_y
      arrow.z = 999999
      arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow1")
      if arrow.y >= Graphics.height - 120
        $game_temp.speechbubble_outofrange = true
        $game_temp.speechbubble_vp.rect.y += 104
        arrow.x = target.screen_x - Graphics.width
        arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow4")
        arrow.y = (target.screen_y - Graphics.height) - 32# - 136
        if arrow.x < -250
          arrow.x = target.screen_x
          arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow3")
        end
        if arrow.x >= 256
          arrow.x -= 15
          arrow.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", "Arrow3")
        end
      else
        $game_temp.speechbubble_outofrange = false
      end
      arrow.zoom_x = 2
      arrow.zoom_y = 2
    end
  end

  $game_temp.speechbubble_arrow = arrow
  msgwindow = Window_AdvancedTextPokemon.new("")
  msgwindow.z = 99999 unless viewport
  msgwindow.viewport = viewport if viewport
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
  pbBottomLeftLines(msgwindow, 2)
  $game_temp.message_window_showing = true if $game_temp
  $game_message.visible = true if $game_message
  skin = MessageConfig.pbGetSpeechFrame() if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing=false if $game_temp
  $game_message.visible=false if $game_message
  msgwindow.dispose
  $game_temp.speechbubble_arrow.dispose if $game_temp.speechbubble_arrow
  $game_temp.speechbubble_vp.dispose if $game_temp.speechbubble_vp
end

#==============================================================================#
# Floating Bubbles new script handler
#==============================================================================#
module SpeechBubble
  # Returns active bubbles
  def self.active_bubbles
    $game_temp.speechbubbles ||= []
  end

  # Safely clear a bubble
  def self.clear_bubble(bubble)
    return unless bubble && bubble[:window]
    bubble[:window].dispose unless bubble[:window].disposed?
    active_bubbles.delete(bubble)
  end

  # Safely clear all bubbles
  def self.clear_all
    active_bubbles.each do |bubble|
      bubble[:window].dispose if bubble[:window] && !bubble[:window].disposed?
    end
    active_bubbles.clear
  end

  # Update bubbles each frame
def self.update_following_bubbles
  return if active_bubbles.empty?

  if !$game_temp.speechbubble_vp || $game_temp.speechbubble_vp.disposed?
    $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    $game_temp.speechbubble_vp.z = 999_999
  end

  active_bubbles.dup.each do |bubble|
    # Determine the target: player or event
    target = bubble[:event_id] == -1 ? $game_player : $game_map.events[bubble[:event_id]]
    next unless target

    window = bubble[:window]
    next if !window || window.disposed?

    # Position above the target
    window.x = target.screen_x
    window.y = target.screen_y - window.height - 32

    # --- Dynamic Avoidance ---
    if bubble[:avoid]
      candidates = [
        [window.x, window.y],
        [window.x - window.width, window.y],
        [window.x + window.width, window.y],
        [window.x, target.screen_y + 16],
        [window.x - window.width, target.screen_y + 16],
        [window.x + window.width, target.screen_y + 16],
        [window.x - window.width - 8, window.y + window.height / 2],
        [window.x + window.width + 8, window.y + window.height / 2]
      ]
      candidates.each do |cx, cy|
        window.x = cx
        window.y = cy
        break unless active_bubbles.any? do |other|
          other != bubble &&
          other[:window] &&
          !other[:window].disposed? &&
          window.overlaps?(other[:window])
        end
      end
    end
    
    # --- Distance check ---
    if bubble[:max_distance]
      dist = nil
      if bubble[:event_id] == -1
        if bubble[:source_event_id] && $game_map.events[bubble[:source_event_id]]
          src_ev = $game_map.events[bubble[:source_event_id]]
          dx = $game_player.screen_x - src_ev.screen_x
          dy = $game_player.screen_y - src_ev.screen_y
          dist = Math.sqrt(dx**2 + dy**2)
        end
      else
        ev = $game_map.events[bubble[:event_id]]
        dx = $game_player.screen_x - ev.screen_x
        dy = $game_player.screen_y - ev.screen_y
        dist = Math.sqrt(dx**2 + dy**2)
      end

      if dist && dist > bubble[:max_distance]
        if bubble[:fade]
          window.opacity -= 16
          if window.opacity <= 0
            clear_bubble(bubble)
            next
          end
        else
          clear_bubble(bubble)
          next
        end
      end
    end

    # --- Fade-in ---
    if bubble[:fade] && !bubble[:faded_in]
      window.opacity += 16
      if window.opacity >= 255
        window.opacity = 255
        bubble[:faded_in] = true
        bubble[:timer_start] = Graphics.frame_count
      end
    end

    # --- Timer auto-clear ---
    if bubble[:timer] && bubble[:faded_in]
      frames_passed = Graphics.frame_count - bubble[:timer_start]
      if frames_passed >= bubble[:timer] * Graphics.frame_rate
        if bubble[:fade]
          window.opacity -= 16
          if window.opacity <= 0
            clear_bubble(bubble)
            next
          end
        else
          clear_bubble(bubble)
          next
        end
      end
    end
  end
end

  # Update auto comment bubbles
def self.update_comment_bubbles
  return unless $game_map && $game_map.events

  $game_map.events.each_value do |ev|
    next unless ev.list
    next unless ev.instance_variable_defined?(:@speechbubble_comment_data)

    args_str = ev.instance_variable_get(:@speechbubble_comment_data)
    begin
      args = eval("[#{args_str}]")
    rescue
      next
    end

    # Determine target: player (-1) or event itself
    target_id = args[0].is_a?(Integer) ? args[0] : ev.id
    target = target_id == -1 ? $game_player : $game_map.events[target_id]
    next unless target

    # Determine max distance in pixels
    max_distance_tiles = args.find { |a| a.is_a?(Hash) && a[:Max] }&.[](:Max)
    max_distance_pixels = max_distance_tiles ? max_distance_tiles * 32 : nil

    # Compute distance from player to original event (always)
    dx = $game_player.screen_x - ev.screen_x
    dy = $game_player.screen_y - ev.screen_y
    distance = Math.sqrt(dx**2 + dy**2)

    # Reset ready if player leaves catchment
    if max_distance_pixels && distance > max_distance_pixels
      ev.instance_variable_set(:@speechbubble_ready, true)
      ev.instance_variable_set(:@speechbubble_active, false)
      next
    end

    # Trigger bubble if ready and within distance
    ready = ev.instance_variable_get(:@speechbubble_ready)
    active = ev.instance_variable_get(:@speechbubble_active)
    next unless ready && !active && (!max_distance_pixels || distance <= max_distance_pixels)

    # Check if bubble already exists
    existing = SpeechBubble.active_bubbles.find { |b| b[:event_id] == target_id }
    if existing
      existing[:window].visible = true
      existing[:faded_in] = true
    else
      # Determine text and remaining args
      if target_id == -1
        # Player-following bubble: args[1] is text, rest are options
        text = args[1].is_a?(String) ? args[1] : ""
        remaining_args = args[2..] || []
      else
        # Event bubble: args[0] is text, rest are options
        text = args[0].is_a?(String) ? args[0] : ""
        remaining_args = args[1..] || []
      end

      # Create the bubble and assign source_event_id if over player
      pbSpeechBubble(target_id, text, *remaining_args)
      if target_id == -1
        # Find the bubble we just created
        new_bubble = SpeechBubble.active_bubbles.last
        new_bubble[:source_event_id] = ev.id
      end
    end

    ev.instance_variable_set(:@speechbubble_active, true)
    ev.instance_variable_set(:@speechbubble_ready, false)
  end
end
end

# Scan events for comment bubbles
module SpeechBubble
  def self.scan_comment_bubbles
    return if !$game_map || !$game_map.events || $game_map.events.empty?
    $game_map.events.each do |id, ev|
      next unless ev.list
      ev.list.each do |command|
        next unless [108, 408].include?(command.code)
        comment = command.parameters[0]
        if comment =~ /pbSpeechBubble\s*\((.+)\)/i
          ev.instance_variable_set(:@speechbubble_comment_data, Regexp.last_match(1))
          ev.instance_variable_set(:@speechbubble_active, false)
          ev.instance_variable_set(:@speechbubble_ready, true)
        end
      end
    end
  end
end

# Game_Map hook
class Game_Map
  alias speechbubble_setup_with_comments setup
  def setup(map_id)
    speechbubble_setup_with_comments(map_id)
    SpeechBubble.scan_comment_bubbles
  end
end

# Scene_Map hook
class Scene_Map
  alias speechbubble_update_following_bubbles_mod update
  def update
    speechbubble_update_following_bubbles_mod
    SpeechBubble.update_following_bubbles
    SpeechBubble.update_comment_bubbles
  end
end

def pbSpeechBubble(event_id, text, *args)
  # Determine target
  target_ev = event_id == -1 ? $game_player : $game_map.events[event_id]
  return unless target_ev

  timer = nil
  fade = false
  avoid = false
  max_distance = nil
  shock = false

  args.each do |arg|
    case arg
    when Numeric
      timer ||= arg
    when Symbol
      case arg
      when :F
        fade = true
      when :A
        avoid = true
      when :Shock
        shock = true
      end
    when Hash
      max_distance = arg[:Max] if arg[:Max]
    end
  end

  max_distance *= 32 if max_distance

  if !$game_temp.speechbubble_vp || $game_temp.speechbubble_vp.disposed?
    $game_temp.speechbubble_vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
    $game_temp.speechbubble_vp.z = 999_999
  end

  # Reuse existing bubble if available
  existing = SpeechBubble.active_bubbles.find { |b| b[:event_id] == event_id }
  if existing
    window = existing[:window]
    window.text = text
    window.opacity = fade ? 0 : 255
    existing[:timer] = timer
    existing[:fade] = fade
    existing[:avoid] = avoid
    existing[:shock] = shock
    existing[:faded_in] = !fade
    existing[:timer_start] = Graphics.frame_count
    existing[:max_distance] = max_distance
    return
  end

  # --- Create new bubble window ---------------------------------------------
  window = Window_AdvancedTextPokemon.new("")
  window.viewport = $game_temp.speechbubble_vp
  window.visible = true
  window.back_opacity = MessageConfig::WINDOW_OPACITY

  # Apply skin + sizing
  if shock
    window.setSkin("Graphics/windowskins/shock")
    window.width = 1
    window.height = 1
    window.resizeToFit2(text, 400, 150)
  else
    window.setSkin("Graphics/windowskins/frlgtextskin")
    window.width = 1
    window.height = 1
    window.resizeToFit2(text, 400, 150)
  end

  window.text = text
  window.x = target_ev.screen_x
  window.y = target_ev.screen_y - window.height - 32
  window.opacity = fade ? 0 : 255

  # Automatically track source event for player-following bubbles
  source_event_id = nil
  if event_id == -1
    source_event_id = @event.id if defined?(@event) && @event
  end

  SpeechBubble.active_bubbles << {
    event_id: event_id,
    window: window,
    timer: timer,
    fade: fade,
    avoid: avoid,
    faded_in: !fade,
    timer_start: Graphics.frame_count,
    text: text,
    max_distance: max_distance,
    source_event_id: source_event_id,
    shock: shock
  }

  # --- Shock shake animation -----------------------------------------------
  if shock
    # Simple shake effect (subtle, lasts ~20 frames)
    frames = 20
    amplitude = 6
    org_x = window.x
    org_y = window.y
    frames.times do |i|
      offset = ((i.even? ? 1 : -1) * amplitude)
      window.x = org_x + offset
      Graphics.update
      Input.update
      amplitude -= 1 if amplitude > 0
    end
    window.x = org_x
    window.y = org_y
  end
end
#==============================================================================#
#                    FUNCTIONS HELPER AND COMMANDS                             #
#==============================================================================#
# Clear all bubbles
def pbClearBub
  SpeechBubble.clear_all
  if $game_temp.speechbubble_vp && !$game_temp.speechbubble_vp.disposed?
    $game_temp.speechbubble_vp.dispose
    $game_temp.speechbubble_vp = nil
  end
end

# Distance check for normal events or player
def pbCheckDist(max_tiles, event_id=nil)
  event_id ||= $game_map.events[@event.id].id rescue nil
  return false unless event_id

  target = event_id == -1 ? $game_player : $game_map.events[event_id]
  return false unless target

  dx = $game_player.x - target.x
  dy = $game_player.y - target.y
  distance = Math.sqrt(dx**2 + dy**2)
  distance <= max_tiles
end

def pbSpeech(status = 0, value = 0, keepalive = false)
  if value == -1
    # Target player
    $game_temp.speechbubble_talking = -1
  else
    # Target event
    char = get_character(value)
    return unless char
    $game_temp.speechbubble_talking = char.id
  end
  $game_temp.speechbubble_bubble = status
  $game_temp.speechbubble_keepalive = keepalive
end

def pbCallBub(status = 0, value = 0)
  if value == -1
    # Target player
    $game_temp.speechbubble_talking = -1
  else
    # Target event
    char = get_character(value)
    return unless char
    $game_temp.speechbubble_talking = char.id
  end
  $game_temp.speechbubble_bubble = status
end
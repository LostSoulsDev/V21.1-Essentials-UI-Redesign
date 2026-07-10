#==============================================================================#
#                         Online System — Message UI                           #
#==============================================================================#

module Online
  WINDOW_WIDTH  = 800
  WINDOW_HEIGHT = 480
  THREAD_X      = 0
  THREAD_Y      = 48   # leave room for header
  THREAD_W      = 800
  THREAD_H      = 336  # leave room for input bar at bottom
  LINE_HEIGHT   = 24
  LEFT_INDENT   = 8    # received messages x offset
  RIGHT_INDENT  = 300  # sent messages x offset
  LINES_VISIBLE = (THREAD_H / LINE_HEIGHT).floor

  #=============================================================================
  # Main online menu
  #=============================================================================
  # Gated at the top: if online features are off, this is the ONLY thing you
  # can do from here — turn them on. Nothing else in this file (messages,
  # friends, sessions, "who's online") is reachable at all unless the menu
  # below it actually gets built, so gating happens exactly once, here.
  #=============================================================================
  def self.open_menu
    unless Online.features_enabled?
      commands = ["Enable Online Features", "Close"]
      choice   = pbShowCommands(nil, commands, 1)
      if choice == 0
        pbMessage("Enabling online features...")
        Online.enable_online_features!
        pbMessage("Online features enabled!")
      end
      return
    end

    # Fetch unread count once on open, not every loop iteration
    $online_blocking = true
    all_messages = fetch_messages
    $online_blocking = false
    unread = all_messages.count { |m| m["read"] == "false" }

    loop do
      inbox_label   = unread > 0 ? "Messages (#{unread} new)" : "Messages"
      session_label = in_session? ? "Session (#{current_session})" : "Sessions"
      commands = [inbox_label, "New Message", "Who's Online (#{Online.online_count})",
                  "Friends", session_label, "Quick Match", "Disable Online Features", "Close"]
      choice   = pbShowCommands(nil, commands, commands.length - 1)

      case choice
      when 0
        open_conversations
        $online_blocking = true
        all_messages = fetch_messages
        $online_blocking = false
        unread = all_messages.count { |m| m["read"] == "false" }
      when 1 then open_compose
      when 2 then show_online_trainers
      when 3 then Online.open_friends_menu
      when 4 then Online.open_session_menu
      when 5 then Online.start_quick_match
      when 6
        if pbConfirmMessage("Disable online features? This will leave any active session.")
          Online.disable_online_features!
          pbMessage("Online features disabled.")
          return
        end
      else return
      end
    end
  end

  #=============================================================================
  # Conversation list
  #=============================================================================
  def self.open_conversations
    pbMessage("Fetching messages...")
    convos = fetch_conversations
    if convos.empty?
      pbMessage("You have no messages.")
      return
    end

    loop do
      names    = convos.keys
      commands = names.map do |name|
        messages = convos[name]["messages"]
        last     = messages.last
        preview  = last ? last["message"].to_s[0..25] : ""
        preview += "..." if last && last["message"].to_s.length > 25
        unread   = messages.count { |m| m["mine"] == "false" && m["read"] == "false" }
        unread > 0 ? "[#{unread}] #{name}: #{preview}" : "#{name}: #{preview}"
      end
      commands << "Back"

      choice = pbShowCommands(nil, commands, commands.length - 1)
      return if choice < 0 || choice == commands.length - 1

      other_name = names[choice]
      open_thread(other_name, convos[other_name])
      convos = fetch_conversations
    end
  end

  #=============================================================================
  # Thread viewer — draws conversation in a Window_Base
  #=============================================================================
  def self.open_thread(other_name, convo)
    messages = convo["messages"]
    other_id = convo["other_id"]

    # Mark received messages as read
    messages.each do |msg|
      mark_read(msg["id"]) if msg["mine"] == "false" && msg["read"] == "false"
    end

    # Wrap all messages into display lines
    # Each entry is [text, mine] where mine is true/false
    lines = []
    messages.each do |msg|
      mine   = msg["mine"] == "true"
      prefix = mine ? "#{$player.name}: " : "#{other_name}: "
      text   = "#{prefix}#{msg["message"]}"
      # Word wrap at ~60 chars for received, ~55 for sent (accounts for indent)
      wrap_width = mine ? 55 : 60
      wrapped = word_wrap(text, wrap_width)
      wrapped.each_with_index do |line, i|
        # Continuation lines indent to align with text after prefix
        if i > 0
          indent = mine ? " " * $player.name.length : " " * other_name.length
          line   = "#{indent}  #{line}"
        end
        lines << [line, mine]
      end
    end

    scroll_top = [lines.length - LINES_VISIBLE, 0].max
    viewport   = ::Viewport.new(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    viewport.z = 99999

    # Header bar
    header = ::SpriteWindow_Base.new(0, 0, WINDOW_WIDTH, 48)
    header.viewport = viewport
    header.contents = ::Bitmap.new(WINDOW_WIDTH - 32, 48)
    pbSetSystemFont(header.contents)
    header.contents.font.color = ::Color.new(0, 0, 0)
    header.contents.font.bold = true
    header.contents.draw_text(0, 0, WINDOW_WIDTH - 32, 32,
                              "Conversation with #{other_name}", 1)

    # Thread window
    thread_win = ::SpriteWindow_Base.new(THREAD_X, THREAD_Y, THREAD_W, THREAD_H)
    thread_win.viewport = viewport
    thread_win.contents = ::Bitmap.new(THREAD_W - 32, THREAD_H - 32)
    pbSetSystemFont(thread_win.contents)

    # Bottom bar — options
    bottom = ::SpriteWindow_Base.new(0, THREAD_Y + THREAD_H, WINDOW_WIDTH, 96)
    bottom.viewport = viewport
    bottom.contents = ::Bitmap.new(WINDOW_WIDTH - 32, 64)
    pbSetSystemFont(bottom.contents)
    bottom.contents.font.color = ::Color.new(0, 0, 0)
    bottom.contents.draw_text(0, 0, WINDOW_WIDTH - 32, 32,
                              "UP/DOWN: Scroll   Z: Reply   X: Back   A: Delete", 1)

    redraw = true

    loop do
      Graphics.update
      Input.update

      if redraw
        draw_thread(thread_win, lines, scroll_top)
        redraw = false
      end

      if Input.repeat?(Input::UP)
        if scroll_top > 0
          scroll_top -= 1
          redraw = true
        end
      elsif Input.repeat?(Input::DOWN)
        if scroll_top < [lines.length - LINES_VISIBLE, 0].max
          scroll_top += 1
          redraw = true
        end
      elsif Input.trigger?(Input::USE)  # Z — reply
        header.dispose
        thread_win.dispose
        bottom.dispose
        viewport.dispose

        reply = compose_message
        if reply && !reply.empty?
          send_message(other_id.to_i, other_name, reply)
          # Refresh and re-open
          convos = fetch_conversations
          if convos[other_name]
            open_thread(other_name, convos[other_name])
          end
        end
        return

      elsif Input.trigger?(Input::BACK)  # X — back
        break

      elsif Input.trigger?(Input::AUX1)  # A — delete
        header.dispose
        thread_win.dispose
        bottom.dispose
        viewport.dispose

        if pbConfirmMessage("Delete conversation with #{other_name}?")
          messages.each { |msg| delete("messages", params: { "id" => "eq.#{msg["id"]}" }) }
          pbMessage("Conversation deleted.")
        end
        return
      end
    end

    header.dispose
    thread_win.dispose
    bottom.dispose
    viewport.dispose
  end

  #=============================================================================
  # Draw thread lines into the window
  #=============================================================================
  def self.draw_thread(win, lines, scroll_top)
    win.contents.dispose if win.contents && !win.contents.disposed?
    win.contents = ::Bitmap.new(win.width - 32, win.height - 32)
    pbSetSystemFont(win.contents)
    win.contents.font.color = ::Color.new(0, 0, 0)  # black text
    visible = lines[scroll_top, LINES_VISIBLE] || []
    visible.each_with_index do |entry, i|
      text, mine = entry
      x = mine ? RIGHT_INDENT : LEFT_INDENT
      y = i * LINE_HEIGHT
      win.contents.draw_text(x, y, win.width - 32 - x, LINE_HEIGHT, text)
    end
  end

  #=============================================================================
  # Word wrap helper
  #=============================================================================
  def self.word_wrap(text, max_chars)
    words  = text.split(" ")
    lines  = []
    current = ""
    words.each do |word|
      if current.empty?
        current = word
      elsif (current + " " + word).length <= max_chars
        current += " " + word
      else
        lines << current
        current = word
      end
    end
    lines << current unless current.empty?
    lines.empty? ? [""] : lines
  end

  #=============================================================================
  # Compose a new message — pick from online trainers
  #=============================================================================
  def self.open_compose(recipient_id = nil, recipient_name = nil)
    unless recipient_id
      # Let player choose how to find the recipient
      method_commands = ["From online trainers", "Search by name", "Cancel"]
      method_choice   = pbShowCommands(nil, method_commands, 2)
      return if method_choice < 0 || method_choice == 2

      if method_choice == 0
        # Show all online trainers including self (useful for testing)
        trainers = online_trainers
        if trainers.empty?
          pbMessage("No trainers are online right now.")
          return
        end
        names  = trainers.map { |t| t["trainer_name"] }
        names << "Cancel"
        choice = pbShowCommands(nil, names, names.length - 1)
        return if choice < 0 || choice == names.length - 1
        recipient_name = trainers[choice]["trainer_name"]
        recipient_id   = trainers[choice]["trainer_id"].to_i

      else
        # Search by trainer name in the database
        search_name = pbEnterText("Enter trainer name:", 0, 20)
        return if search_name.nil? || search_name.empty?

        raw = get("trainers", params: { "trainer_name" => "ilike.#{search_name}" })
        results = extract_array(raw, ["trainer_name", "trainer_id"])

        if results.empty?
          pbMessage("No trainer found with that name.")
          return
        end

        if results.length == 1
          recipient_name = results[0]["trainer_name"]
          recipient_id   = results[0]["trainer_id"].to_i
        else
          # Multiple results — let player pick
          names  = results.map { |t| t["trainer_name"] }
          names << "Cancel"
          choice = pbShowCommands(nil, names, names.length - 1)
          return if choice < 0 || choice == names.length - 1
          recipient_name = results[choice]["trainer_name"]
          recipient_id   = results[choice]["trainer_id"].to_i
        end
      end
    end

    message = compose_message
    return unless message && !message.empty?
    send_message(recipient_id, recipient_name, message)
    pbMessage("Message sent to #{recipient_name}!")
  end

  #=============================================================================
  # Show who's online
  #=============================================================================
  def self.show_online_trainers
    trainers = online_trainers
    if trainers.empty?
      pbMessage("No other trainers are online right now.")
      return
    end
    list = trainers.map { |t| t["trainer_name"] }.join("\n")
    pbMessage("Trainers online:\n#{list}")
  end

  #=============================================================================
  # Text input helper
  #=============================================================================
  def self.compose_message
    pbEnterText("Enter your message:", 0, 80)
  end

  #=============================================================================
  # Session menu
  #=============================================================================
  def self.open_session_menu
    if Online.in_session?
      commands = ["Who's Here", "Leave Session", "Back"]
      choice   = pbShowCommands(nil, commands, 2)
      case choice
      when 0 then Online.show_session_players
      when 1
        if pbConfirmMessage("Leave the current session?")
          Online.leave_session
          pbMessage("You left the session.")
        end
      end
    else
      commands = ["Browse Sessions", "Friend Sessions", "Host Session", "Join by Code", "Back"]
      choice   = pbShowCommands(nil, commands, 4)
      case choice
      when 0 then Online.open_session_browser(:public)
      when 1 then Online.open_session_browser(:friends)
      when 2 then Online.open_host_session_menu
      when 3
        code = pbEnterText("Enter session code:", 0, 16)
        return if code.nil? || code.empty?
        result = Online.join_session(code.upcase)
        if result == :full
          pbMessage("That session is full!")
        elsif result
          pbMessage("Joined session!")
        else
          pbMessage("Session not found or no longer active.")
        end
      end
    end
  end

  def self.open_host_session_menu
    desc        = pbEnterText("Session description (optional):", 0, 40)
    vis_choice  = pbShowCommands(nil, ["Public", "Private (Friends only)"], 1)
    visibility  = vis_choice == 1 ? "private" : "public"
    size_choice = pbShowCommands(nil, ["2 players", "4 players", "8 players"], 2)
    max_players = [2, 4, 8][size_choice] || 8
    code = Online.host_session(description: desc, visibility: visibility, max_players: max_players)
    if code.nil?
      pbMessage("Couldn't create a session — make sure online features are enabled.")
      return
    end
    pbMessage("Session created!\nCode: \b#{code}\b\n#{visibility == "public" ? "Listed publicly." : "Friends only."}")
  end

  def self.open_session_browser(mode)
    pbMessage("Fetching sessions...")
    sessions = mode == :friends ? Online.fetch_friend_sessions : Online.fetch_public_sessions
    if sessions.empty?
      pbMessage(mode == :friends ? "No friend sessions found." : "No public sessions found.")
      return
    end
    loop do
      commands = sessions.map do |s|
        count = s["player_count"].to_i
        max   = s["max_players"].to_i
        desc  = s["description"].to_s.empty? ? "" : " - #{s["description"][0..20]}"
        "#{s["host_name"]}#{desc} (#{count}/#{max})"
      end
      commands << "Refresh"
      commands << "Back"
      choice = pbShowCommands(nil, commands, commands.length - 1)
      return if choice < 0 || choice == commands.length - 1
      if choice == commands.length - 2
        sessions = mode == :friends ? Online.fetch_friend_sessions : Online.fetch_public_sessions
        next
      end
      s       = sessions[choice]
      players = s["player_names"].to_s.empty? ? "Unknown" : s["player_names"]
      desc    = s["description"].to_s.empty? ? "No description" : s["description"]
      pbMessage("Host: #{s["host_name"]}\n#{desc}\nPlayers: #{players}")
      if pbConfirmMessage("Join this session?")
        result = Online.join_session(s["session_code"])
        if result == :full
          pbMessage("That session is full!")
        elsif result
          pbMessage("Joined!")
          return
        else
          pbMessage("Session no longer available.")
          sessions.delete(s)
        end
      end
    end
  end

  def self.show_session_players
    raw     = Online.get("positions", params: { "session_code" => "eq.#{Online.current_session}" })
    players = Online.extract_array(raw, ["trainer_name", "map_id"])
    return pbMessage("No other players found.") if players.empty?
    list = players.map { |p| p["trainer_name"] }.join("\n")
    pbMessage("Players in session:\n#{list}")
  end

  #=============================================================================
  # Friends menu
  #=============================================================================
  def self.open_friends_menu
    # Check and clean stale requests on open
    Online.cleanup_stale_requests

    loop do
      friends  = Online.fetch_friends
      pending  = Online.fetch_pending_requests
      req_label = pending.empty? ? "Add Friend" : "Add Friend | #{pending.length} Request(s)"
      commands = friends.map { |f| f["friend_name"] }
      commands << req_label
      commands << "Back"

      choice = pbShowCommands(nil, commands, commands.length - 1)
      return if choice < 0 || choice == commands.length - 1

      if choice == commands.length - 2
        # Add friend / view requests
        sub_commands = ["Send Friend Request"]
        sub_commands << "View Requests (#{pending.length})" unless pending.empty?
        sub_commands << "Back"
        sub = pbShowCommands(nil, sub_commands, sub_commands.length - 1)
        next if sub < 0 || sub == sub_commands.length - 1

        if sub == 0
          # Send request
          name   = pbEnterText("Enter trainer name:", 0, 20)
          next if name.nil? || name.empty?
          result = Online.send_friend_request(name)
          case result
          when :not_found     then pbMessage("Trainer not found.")
          when :self          then pbMessage("You can't add yourself!")
          when :already_exists then pbMessage("Request already sent or already friends.")
          else pbMessage("Friend request sent to #{result}!")
          end
        elsif sub == 1 && !pending.empty?
          # View incoming requests
          open_friend_requests(pending)
        end
        next
      end

      # Friend options
      friend  = friends[choice]
      options = ["Remove Friend", "Back"]
      action  = pbShowCommands(nil, options, 1)
      if action == 0
        if pbConfirmMessage("Remove #{friend["friend_name"]} from friends?")
          Online.remove_friend(friend["friend_id"])
          pbMessage("Removed #{friend["friend_name"]}.")
        end
      end
    end
  end

  def self.open_friend_requests(pending)
    pending.each do |req|
      pbMessage("Friend request from #{req["player_name"]}:")
      choice = pbShowCommands(nil, ["Accept", "Decline"], 1)
      if choice == 0
        Online.accept_friend_request(req)
        pbMessage("You are now friends with #{req["player_name"]}!")
      elsif choice == 1
        Online.decline_friend_request(req)
        pbMessage("Request from #{req["player_name"]} declined.")
      end
    end
  end
end
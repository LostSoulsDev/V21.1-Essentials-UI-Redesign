class VOEMovement
  # ==========================================
  # Presets
  # ==========================================

  Agressive = {
    move_route: [
      :move_toward_player,
      :end,
    ],
    move_speed: 3,
    move_frequency: 6,
    touch: true,
  }

  Fugitive = {
    move_route: [
      :turn_toward_player,
      [:wait, 12],
      :move_away_from_player,
      :move_away_from_player,
      :move_away_from_player,
      :move_away_from_player,
      :move_away_from_player,
      :move_away_from_player,
      :move_away_from_player,
      [:wait, 12],
      :end,
    ],
    move_speed: 3,
    move_frequency: 6,
    touch: false,
  }

  Curious = {
    move_route: [
      :move_toward_player,
      :move_toward_player,
      :turn_toward_player,
      [:wait, 60],
      :turn_toward_player,
      :move_toward_player,
      [:wait, 30],
      :turn_toward_player,
      :end,
    ],
    move_speed: 2,
    move_frequency: 6,
    touch: false,
  }

  RepelFlee = {
  move_route: [
    :turn_toward_player,
    :turn_180,
    :move_forward,
    :move_away_from_player,
    :move_away_from_player,
    :move_away_from_player,
    :move_random,
    :end
  ],
  move_speed: 5,
  move_frequency: 6,
  touch: false
}

  # ==========================================
  # Move Hashes
  # ==========================================

  Poke_Move = {
    WIMPOD: {
      move_route: [
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        :move_random,
        :move_random,
        :move_random,
        :end,
      ],
      move_speed: 4,
      move_frequency: 6,
      touch: false,
    },
    VELUZA: {
      move_route: [
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_random,
        :move_random,
        :end,
      ],
      move_speed: 4,
      move_frequency: 6,
      touch: true,
    },
  }

  Nature_Move = {
    DOCILE: Curious,
    BASHFUL: Fugitive,
    CAREFUL: Fugitive,
    TIMID: Fugitive,
    JOLLY: Curious,
    NAIVE: Curious,
    HARDY: {
      move_route: [
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        [:wait, 20],
        :move_random,
        :move_random,
        :move_random,
        [:wait, 15],
        :end,
      ],
      move_speed: 3,
      move_frequency: 6,
    },
    LONELY: {
      move_route: [
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        [:wait, 4],
        [:play_se, RPG::AudioFile.new("Player jump", 75, 100)],
        [:jump, 0, 0],
        [:wait, 32],
        :end,
      ],
      move_speed: 2,
      move_frequency: 6,
    },
    BRAVE: {
      move_route: [
        :move_toward_player,
        :end,
      ],
      move_speed: 3,
      move_frequency: 5,
      touch: true,
    },
    IMPISH: {
      move_route: [
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        :move_toward_player,
        [:wait, 8],
        [:play_se, RPG::AudioFile.new("Player jump", 75, 100)],
        [:jump, 0, 0],
        [:wait, 4],
        [:play_se, RPG::AudioFile.new("Player jump", 75, 100)],
        [:jump, 0, 0],
        [:wait, 8],
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        :move_away_from_player,
        [:wait, 8],
        [:play_se, RPG::AudioFile.new("Player jump", 75, 100)],
        [:jump, 0, 0],
        [:wait, 4],
        [:play_se, RPG::AudioFile.new("Player jump", 75, 100)],
        [:jump, 0, 0],
        [:wait, 8],
        :end,
      ],
      move_speed: 3,
      move_frequency: 6,
      touch: false,
    },
    LAX: {
      move_route: [
        :turn_toward_player,
        [:wait, 20],
        :move_random,
        :move_random,
        [:wait, 20],
        :turn_toward_player,
        [:wait, 20],
        :move_random,
        [:wait, 20],
        :end,
      ],
      move_speed: 1,
      move_frequency: 3,
      touch: false,
    },
    HASTY: {
      move_route: [
        :move_random,
        :end,
      ],
      move_speed: 2,
      move_frequency: 3,
      touch: false,
    },
  }
end

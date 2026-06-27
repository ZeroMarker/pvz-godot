# Plants vs Zombies - Godot Remake

A complete remake of the classic Plants vs Zombies game using Godot 4.x engine.

## Features

- **Complete Gameplay**: Faithful recreation of the original PvZ mechanics
- **Multiple Plants**: Sunflower, Peashooter, Wall-nut, Cherry Bomb, and more
- **Various Zombies**: Regular, Conehead, Buckethead, and special zombies
- **Sun System**: Collect sun to plant defenders
- **Level System**: Multiple levels with increasing difficulty
- **UI Interface**: Main menu, game UI, pause menu, and level selection

## Requirements

- Godot 4.2 or later
- No additional dependencies required

## Getting Started

1. Clone this repository
2. Open the project in Godot 4.x
3. Run the main scene (`scenes/main_menu.tscn`)

## Project Structure

```
pvz-godot/
├── scenes/          # Game scenes (main menu, game, levels)
├── scripts/         # GDScript files
├── assets/          # Game assets (sprites, sounds, fonts)
├── addons/          # Godot addons/plugins
├── project.godot    # Project configuration
└── README.md        # This file
```

## Controls

- **Mouse**: Select plants and interact with UI
- **Left Click**: Place plants, collect sun
- **Right Click**: Cancel selection
- **ESC**: Pause game

## Development

This project is built with Godot 4.x using GDScript. The architecture follows Godot's best practices with scene-based composition.

### Key Systems

1. **Plant System**: Modular plant behavior with stats and abilities
2. **Zombie AI**: Pathfinding and attack patterns
3. **Sun Economy**: Resource management and collection
4. **Wave System**: Zombie spawning and difficulty progression
5. **UI System**: Menus, HUD, and game state management

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original Plants vs Zombies game by PopCap Games
- Godot Engine community
- All contributors and supporters

## Disclaimer

This is a fan-made project for educational purposes. Plants vs Zombies is a trademark of PopCap Games/EA.
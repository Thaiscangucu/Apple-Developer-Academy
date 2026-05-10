# Proxima estação: Cãofusão Nos Trilhos!


### Objective
This project was developed for academic purposes as part of the Apple Developer Academy | Mackenzie program. It utilizes Swift, SwiftUI, the SpriteKit framework, and GameKit for multiplayer networking.

## Discover the Game

Mr. Ademir, a scarlet macaw, began cultivating various fruits in his garden. However, the fruits grew excessively large, causing his house to overflow with them. Faced with this predicament, he decided to send João César and his brothers to the nearest train station to sell his crops. Little did he know that Roberto Paulo, a hungry caramel-colored dog, was observing the situation and was determined to prevent it from happening!

The game mechanics revolve around a tag-and-catch game set in a train station inspired by Luz. The game features living elements and trains that continuously depart. As macaws, players must sell all their fruit to other macaws who serve as customers. On the other hand, the dog’s objective is to locate the macaws with the fruit and devour all of it before they can sell it.

## Technical Features

Based on the core mechanics, the game implements several native Apple frameworks to create a real-time multiplayer experience:

* **GameKit & Game Center:** Handles user authentication and real-time multiplayer networking (`MatchManagerViewModel`). Players are matched, and their positional data is continuously synced across devices.
* **GameController:** Utilizes `GCVirtualController` to create a native, on-screen left thumbstick for fluid player movement.
* **SpriteKit:** Manages the game rendering, physics bodies, and scene updates (`ControleScene` and `PlayerScene`). Player positions are calculated dynamically using delta vectors and normalized coordinates.
* **SwiftUI:** Powers the interface state management, seamlessly transitioning users between the `MenuView`, `GameView`, and `GameOver` screens based on the multiplayer match status.

## Test

To test the project’s source code, follow these steps:

1. Download TestFlight from the App Store.
2. Access the link: https://testflight.apple.com/join/Tx7G15nf
3. Follow the instructions provided to install the game on your device.

*Note for developers: To run the source code locally, open `ProximaEstacaoApp.swift` in Xcode. Ensure your Apple Developer account is configured properly, as the project requires the Game Center entitlement (`com.apple.developer.game-center`) to test multiplayer features.*

## Developers involved

[Emanuela Caetano](https://github.com/EmanuelaCaetano), [Vinicius Marques](https://github.com/hyauss), [Lucca Pivoto](https://github.com/LuccaPV), [Thomas Grandin](https://github.com/ThomasPGR), [André Cortarelli](https://github.com/AndreContarelli), [Kleber Gadelha](https://github.com/Kleber-gadelha), [Pedro Moreiras](https://github.com/Pepeu31), [Ana Carolina](https://github.com/Ana-Carolina-Evangelista), [Camila Toniato](https://github.com/camilatoniato) and [Thais Canguçu](https://github.com/Thaiscangucu).

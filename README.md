## Dou Dizhu Game (Fighting Landlord)

We are building a popular Chinese card game -- Dou Dizhu. It’s a three-person game, and the objective is to be the first person hands out all his or her cards! More information about this game can be found at [Doudizhu](https://en.wikipedia.org/wiki/Dou_dizhu).

#### Cool feature our game has (in chronological order of game process)
 - Enter the username and game room name to enter a room
 - If the room has less than 3 players, you will be joining the game as a **player**
 - If the room has more than 3 players, you will be joining the game as an **observer**. You could choose which player’s perspective to view. Also, observers can chat with other observers, while players cannot join the chat or see the message from others.
 - Players will need to click the **“ready”** button to prepare the start of the game. Once all three players click the “ready”, the game will start and they will have 15 seconds to decide whether bid for a landlord.
 - The player will receive a hand of cards and the three landlord cards will also be shown at the top of the screen.
 - Three players can choose to bid for the landlord, the chosen landlord will receive the three Dizhu card at the top of the screen
 - When it is in a player's turn, it has 30 seconds to play the cards. It can click cards to select cards, and then click “hand out” to play those selected cards. If the player want to skip its round, just click "Hands out" button without select any card. The system won’t allow players to hand out any illegal combination of cards.
 - While the game is over, it will report the winner and enter the pre-start state, player can click **“ready”** to play the next game.
 - The observer can switch the view by clicking player’s name. In the observer’s screen, there are also a chatting bar. Observers can use this chatting bar to communicate with other observers. 

#### Basic instruction
When in you turn, you need to hand out the same type of playing as the last player(if there is, excluding skipping), and it must has higher rank.

The rank and type can be found in followed table: 
-   Individual cards are ranked, while suits are irrlevant:
    

Colored Joker > Black & White Joker > 2 > Ace (A) > King (K) > Queen (Q) > Jack (J) > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3.

-   There are several categories of hands.
    

| Category | Description | Example |
|--------------|------------------------------|---------|
| Solo | Any single Card | 3 |
| Solo Chain | Five or more consecutive individual cards | 34567 |
| Pair | Two matching card of equal rank | 33 |
| Pair Sisters | Three or more consecutive pairs | 334455 |
| Trio | Three-of-a-kind: Three individual cards of the same rank with a single or pair as kicker | 333+4 |
| Airplane | Two or more consecutive trios | 333444+56 |
| Bomb | Four-of-a-kind, defies category rules, yet subjected to the rank | 3333 |
| Rocket! | Double Joker, ruin the universe. | CJ&BJ |

-   Compare only the same category
    
-   Compare only the Chains with the same length
    
-   Compare the rank without kicker(the side cards played with the primal category)
    
-   Jockers and 2 are non-consecutive cards
    
-   Score:
    

- The basic rule is the winner takes points from loser or losers. The landlord pay for both peasants if lost, or charge both of them if winning.

- Each Rocket/bomb will double the score in a round.

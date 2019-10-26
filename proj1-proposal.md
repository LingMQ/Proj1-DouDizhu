
# Fight Against Landlord (Dou Dizhu)

### Team: Sikang Hu && Lingmiao Qiu

  

## What game are you going to build?

  

We are going to build a popular Chinese card game, Dou Dizhu. It's a game for
three players - each bidding for the Landlord position. Those who chose not to
claim the Landlord, enter the game as farmers, competing against the Landlord.
Both the landlord and farmers take turns to play cards. There are some specific
rules about combining the cards when playing and the ranks of the cards. The
objective of the game is to be the first player to have no card left. More
information can be found:
[https://www.youtube.com/watch?v=HsW-W74uz_k](https://www.youtube.com/watch?v=HsW-W74uz_k)
and
[https://en.wikipedia.org/wiki/Dou_dizhu](https://en.wikipedia.org/wiki/Dou_dizhu)

  

## Is the game well specified (e.g. Reversi) or will it require some game work (e.g. a monster battle game)?

  

Yes, our game is well specified by several rules:

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

  
  
  

## Is there any game functionality that you’d like to include but may need to cut if you run out of time?

Artificial Intelligent (Robot), well-designed UI, not persistent, expiration of the game state (1 day)

  

We will be focusing on making sure this game is a three-player game and bound by all the rules mentioned in the previous section. Since our focus is on the functionality of the game, the visual appealingness of the game UI will be our secondary concern. For example, for each card, we will only indicate the value of the card, but won’t include any suite image or any jacks, queens, kings, jokers images (the game is irrelevant about the card suite).

  

The game needs three people to start playing. If any of those three players quit during the game, the game should allow that player to rejoin the game. But since when more than one user left the game, determining which player’s seat the new player will be sitting on can be problematic, we might cut this feature. Instead, if the user quit the game, he or she won’t be able to rejoin the game and the game will automatically pass his or her turn. Considering this class is a web class instead of an AI class, we won’t spend time implement a game bot.

  

With our limited time on this project, we won’t have enough time to make this game persistent, meaning we won’t have a database to store users’ information and score. Once the server shuts down or restarts, users’ score will be erased. In the case of all three players left the game, we would like to have the feature to delete that game automatically after one day. But this will be a plus feature, and we will only implement this if we have extra time.

  

## What challenges do you expect to encounter?

-   Intervention, reconnect to the same game with the previous name. How to detect a user is disconnected.
    
-   Different information for different players, meaning what players have on their browser will be different from each others’. Reply to the first player’s card, also push to the other two players.
    
-   Prompt for who is the winner: a pop-up displays the points of each user.
    
-   Selection: how to decide which cards are selected: maintain an array of selection in the react component’s state.
    
-   How to impose the rules of the game
    

- Rank: build a map from String to number.

- Category of hands: how to check current playing is compatible or comparable with the playing at last round.

-   Smooth User Interface, maybe with some funny animation such as the explosion of the bomb.

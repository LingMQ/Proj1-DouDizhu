
# Web Project 1 Report

  

#### Authors: Sikang Hu & Lingmiao Qiu

#### Game Name: Dou Dizhu (Fighting Against Landlord)

## Introduction and Game Description

There are many interesting card games in the world, such as Poker, Eleusis, and
Tri-card. Among those games, we want to build one that both interesting and
refreshing for our users. Eventually, we decided to build a popular Chinese card
game called Dou Dizhu. Dou Dizhu is not widely spread in the US, so we thought
this is a relatively refreshing game for our peers to play with each other. Plus
it’s a super fun game once you understand the rule! Many people have described
this game as easy to learn but hard to master, requiring mathematical and
strategic thinking as well as carefully planned execution.

  

The direct English translation of this game means fighting against the landlord.
The game originates during the cultural revolution period in China as the class
struggle encouraged peasants to take up arms against the landlords who were
among the criticism group.

  

As for the rule, Dou Dizhu is built for three players - each bidding for the
Landlord position. Those who chose not to claim the Landlord, enter the game as
farmers, competing against the Landlord. The objective of the game is to be the
first player to have no card left. Both the landlord and farmers take turns to
play cards. There are some specific rules about the ranks of the cards and
combining the cards. More information and rules can be found:

[https://www.youtube.com/watch?v=HsW-W74uz_k](https://www.youtube.com/watch?v=HsW-W74uz_k)

and

[https://en.wikipedia.org/wiki/Dou_dizhu](https://en.wikipedia.org/wiki/Dou_dizhu)

  

## UI Design

We have two main pages in the game. The first page asks the player’s name and
which game room he or she wants to join. A player can choose to either enter a
room as a player or enter a room as an observer to watch other people’s games.
Once entered the room, we will go to the second page -- game page. In this page,
we designed the page to include the room name, game timer, a deck of card,
players’ score, and any other necessary components for Dou Dizhu game. Both
pages’ layouts are drawn using CSS. We carefully choose the background image for
both pages. The images are both good-looking and toned to the specific
color/opacity so the text is still easily recognizable.

  

We choose the card image from the recommend source “Open Game Art”. The original
image is kind of large ~400KB. To optimize the speed of the game, we compressed
the image to ~78KB without sacrifice much image quality. We use a map like
structure to map to each card image. We number card from 1 to 54 and use those
numbers as the key for the map. In the way, the server-side of the program only
needs to worry about how to using the number to represent card and operate on
the number. Whenever a user clicks a card, the card will be enlarged to mark the
selection. The users can select as many card as they prefer, but only the valid
combination of card can be played. We also customized the font and color of the
web page. So the pages look both fun and visually appealing.

## UI to Server Protocol

In our Dou Dizhu application, a user could be either a player or an observer,
depending on when the user enters the room. Our user needs to pick a name to
join a room. On joining the room, it will initialize a communication with the
server through WebSocket and pass its name to the server to get a seat. If all
three seats are occupied, the user will be assigned to be an audience, who can
watch the game from a player’s view and chat with other audiences. Since there
are two different roles, we have two series of protocols, while both of them are
implemented through messages and payloads passed through WebSocket.

  

A player can send messages as followed:

-   Ready: inform the server it is ready for a new game. The last player issuing
-   this message will initialize the game, that is the server will deal cards to
-   each player and inform each player to bidding for the landlord.
    
-   Bid: inform the server it bids for the landlord of this game at the bidding
-   phase. Players sending this message will be put into a pool, from which the
-   server will pick out the landlord randomly.
    
-   Play &lt cards&gt: inform the server the cards it wants to play, if it is
-   legal, the server will update the game state and broadcast the latest view.
    

  

An observer can send messages as followed:

-   Chat: send a message to all the audience in this room. The message will be
-   displayed at all the audience’s chat area.
    

 ## Data structures on server

To enable Dou Dizhu to be a multiplayer game, we utilized GenSever as it can
keep state and execute code asynchronously. Each game room that players created
will correspond to a GenSever. And we store game information and data (such as:
the hand of card that players hold, what did players play in the last round and
who is the landlord) in the GenServer. At the same time, we also implemented a
backup agent for the game. The backup agent backs up data and ensures that when
a user exit the game accidentally, he or she could rejoin the game again later
using the same username and same game room.

  

In our game, we included the following state:

-   The cards each player still has
    
-   What did players play in the last round
    
-   Last valid card combination that being played
    
-   Who is landlord
    
-   Who is the current player
    
-   What’s the base score of the game.
    

Respectively, 1 and 2 are a 2d list. And 3 is a tuple as 3 need to presented
both who played last valid combination and what is that combination. 4, 5, 6 are
all needed primitive type variables.

  

On the other hand, in the chat module, we have two data structures. One is the
observer map. This map basically stores the information about all the audience
of the game. The map key is the observer name (our user name is unique, but with
the time limit we didn’t implement the user authentication), and the mapped
value is the player that the observer is sitting next to. Where the observer sit
determine which player’s perspective the observer will have.

  

## Implementation of game rules

Once three players all entered the game room and selected the “ready!” button,
the game will start. We implemented the mechanism for biding the landlord as
each of the users have a fair chance to become the landlord. We use a list to
store any player who bid for the landlord position in the first 15s. If the
winner of the last game bid for the landlord, his or her name will be put in the
list twice has his or her chance of getting of landlord will double. The
landlord will then be randomly selected from the list.

  

When a user is playing the card. Our program will first check which player turn
it is. After the player selects the cards and clicks “hand out”, the program
using pattern matching to check whether the card combination is valid as there
are specific rules on how should the cards being combined in the Dou Dizhu game.
The pattern matching is accomplished by first sort the array of the selected
card, then route to different function based on how many cards are in the array,
as different number of card means different pattern. Some numbers can be
multiple combinations. In this case, we use conditional statements to deal with
each situation. The specific card combination rules that we implemented are in
the table below. Meanwhile, the program will also check whether the newly played
card ranks larger than the previous player’s card, if the current player is not
the first player in the round.

  

Each player is bound by a 30s timer to play his or her card. Whenever the timer
is needed, the channel will send the signal to schedule a timer for itself,
before broadcasting the information to all the subscribers, which are all the
players and observers. If the play didn’t play any card, the turns will go to
the next player. If none of the players play the card in the current round, the
system will automatically select the smallest ranked card in the hand to play.
The program checks whether the game is finished or not after each round.

  

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

  

## Challenges and Solutions

### Game rule

-   How to decide the types, whether the playing is legal
    

There are over 10 types, including some trivial cases, such as rocket, nothing,
as well as some complex cases such as airplane(trio chain). If number of cards
is less than 5, we will sort the cards by rank and check whether the head is the
same as the last element, then we can decide the type by length(also check trio
with a ticker). If there are more than 4 cards, we count the frequency of each
kind of card, and group them by frequence, then figure out the time
correspondingly.

  

To decide whether the playing is legal, we store the feature of the last valid
playing, which is the type, length, and smallest critical card. If the current
playing is in the same type and length as the last one and have a larger
smallest critical card, it is legal. However, there are also same edge cases,
such as current player cannot skip this round if the other two players skip
their last round.

  

-   How to shift from a phase to the next phase
    

Generally, there are three phases for a Dou Dizhu game: preparing, bidding,
playing. At the beginning, the user will declare to be ready for the game. Once
all the players are ready, the game enters bidding phase, where the player will
have their own cards and know the extra landlord cards to decide whether to bid
for the landlord to get the cards and privilege to play. After assign the
landlord, the game enters playing phase, where each player takes turns to play.
Once a player hands out all its cards, the game terminate, entering preparing
phase.

  

To implement this feature, we make our channel handler to check whether it is
necessary to enter the next phase every time there is a change. If it is, the
handler will send it self an message(may be asynchronous) to schedule the
change.

  

-   How to handle the situation that different players have a different view
    

In a Dou Dizhu game, each player has its own view of the game, meaning only the
player itself knows its cards at hand. Therefore, we need to send the unique
view to each player. To cope with this, we filter the outgoing message by a
handle_out callback function, which will customize the game view according to
the name of the socket’s owner.

  

-   How to implement the timer
    

A strategy game is more interesting if time is limited for making a decision. In
our game, the player has 15 seconds to decide whether to bid for the landlord or
not, and 30 seconds to decide how to play cards. If a timer is necessary, the
channel handler will schedule an asynchronous message to itself to enforce the
rule. And it will also send each client the start time to synchronizing the
timer. However, the timer on the client’s side does not enforce anything, but
just inform the player the time left. The server keep track of a sequence number
to determine whether it is necessary to enforce an update. Every time there is a
playing, the sequence number will increment by one. If the server receive the
message with the same sequence number, it will detect that the time is up. But,
if the sequence number is different from the current one, it will simply ignore
the message. Once time is up, the server will update the state, and broadcast
the latest game view.

  

## Adjustment for requirement

-   In our game, the player is not allowed to chat or communicate with others,
-   which is cheating. So, we only provide the chat feature for the audiences.
    

## Reference and Attributes

- "Dou Dizhu". Wikipedia, Wikimedia Foundation, 19 Sept. 2019, “en.wikipedia.org/wiki/Dou_dizhu.
    
- "Dou Dizhu". Rules of Card Games: Dou Dizhu, www.pagat.com/climbing/doudizhu.html.
    
- https://opengameart.org/content/playing-cards licensed under CC-BY3.0 and OGA-BY 3.0
    
- https://www.pexels.com/photo/man-holding-playing-cards-2631067/ licensed under Pexels


defmodule Doudizhu.DoudizhuTest do
  use ExUnit.Case
  import Doudizhu.Game
  
  setup do
   {:ok, game: new()}
  end
  
  # TODO anyway to use pipe
  test "add player", context do
    game = context[:game]
    {:ok, game} = add_player(game, "Tom")
    {:ok, game} = add_player(game, "Jerry")
    {:ok, game} = add_player(game, "John")
    {:error, game} = add_player(game, "Mary")
    assert Enum.sort(Map.keys(game[:players])) 
      == Enum.sort(["Tom", "Jerry", "John"])
  end
  
  test "deal card", context do
   hands = context[:game] 
         |> init_game 
         |> Map.get(:hands)
         |> Enum.map(fn x -> Enum.uniq(x) end)
   assert length(Enum.at(hands, 0)) == 17
   assert length(Enum.at(hands, 1)) == 17
   assert length(Enum.at(hands, 2)) == 17
   assert length(Enum.at(hands, 3)) == 3
   assert hands 
          |> List.flatten 
          |> Enum.uniq
          |> length
          |> (&(&1 == 54)).()
  end
  
  test "assign landlord", context do
    game = context[:game]
    {:ok, game} = add_player(game, "1")
    {:ok, game} = add_player(game, "2")
    {:ok, game} = add_player(game, "3")
    hands = 
    game
    |> init_game
    |> assign_lord("1")
    |> Map.get(:hands)
    assert length(Enum.at(hands, 0)) == 20
    assert length(Enum.at(hands, 1)) == 17
    assert length(Enum.at(hands, 2)) == 17
    assert length(Enum.at(hands, 3)) == 3
    assert hands 
          |> List.flatten 
          |> Enum.uniq
          |> length
          |> (&(&1 == 54)).()
    
  end
end

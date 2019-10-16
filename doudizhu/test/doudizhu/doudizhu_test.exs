defmodule Doudizhu.DoudizhuTest do
  use ExUnit.Case
  import Doudizhu.Game
  
  test "single hand" do
    assert validate(game, user, ["A"])
  end
end

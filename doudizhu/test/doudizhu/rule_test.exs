defmodule Doudizhu.RuleTest do
  use ExUnit.Case
  import Doudizhu.Rule
  
  test "single" do
    assert get_cat([51]) == :single
    assert get_cat([0]) == :single
    assert get_cat([12]) == :single
    assert get_cat([5]) == :single
    assert get_cat([7]) == :single
    assert get_cat([]) != :single
  end
  
  test "pair" do
    assert get_cat([5, 5]) == :pair
    assert get_cat([12, 12]) == :pair
    assert get_cat([0, 0]) == :pair
    assert get_cat([1, 0]) != :pair
  end
  
  test "trio" do
    assert get_cat([5, 5, 5]) == :trio
    assert get_cat([4,5,5]) != :trio
    assert get_cat([0, 10,10]) != :trio
    assert get_cat([0, 0, 0]) == :trio
  end
  
  test "trio1" do
    assert get_cat([5, 5, 5, 10]) == :trio1
    assert get_cat([3, 5 ,5,5]) == :trio1
    assert get_cat([10,10, 10, 10]) != :trio1
    assert get_cat([0, 0, 1, 1]) != :trio1
  end
end

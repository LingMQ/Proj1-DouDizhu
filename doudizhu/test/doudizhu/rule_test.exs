defmodule Doudizhu.RuleTest do
  use ExUnit.Case
  import Doudizhu.Rule
  
  test "single" do
    assert get_cat([51]) == {:single, 1, 51}
    assert get_cat([0]) == {:single, 1, 0}
    assert get_cat([12]) == {:single, 1, 12}
    assert get_cat([5]) == {:single, 1, 5}
    assert get_cat([7]) == {:single, 1, 7}
  end
  
  test "pair" do
    assert get_cat([5, 5]) == {:pair, 1, 5}
    assert get_cat([12, 12]) == {:pair, 1, 12}
    assert get_cat([0, 0]) == {:pair, 1, 0}
  end
  
  test "trio" do
    assert get_cat([5, 5, 5]) == {:trio0, 1, 5}
    assert get_cat([0, 0, 0]) == {:trio0, 1, 0}
    assert get_cat([12, 12, 12]) == {:trio0, 1, 12}
  end
  
  test "trio1" do
    assert get_cat([5, 5, 5, 10]) == {:trio1, 1, 5}
    assert get_cat([3, 5 ,5, 5]) == {:trio1, 1, 5}
  end
  
  test "trio2" do
    assert get_cat([5, 5, 5, 10, 10]) == {:trio2, 1, 5}
    assert get_cat([3, 3, 5 ,5, 5]) == {:trio2, 1, 5}
  end
  
  test "bomb" do
    assert get_cat([10, 10, 10, 10]) == {:bomb, 1, 10}
    assert get_cat([12, 12, 12, 12]) == {:bomb, 1, 12}
  end
  
  test "four1" do
    assert get_cat([5, 5, 5, 5, 6, 7]) == {:four1, 1, 5}
    assert get_cat([3, 4, 6, 6 ,6, 6]) == {:four1, 1, 6}
  end
  
  test "four2" do
    assert get_cat([5, 5, 5, 5, 6, 6, 7, 7]) == {:four2, 1, 5}
    assert get_cat([3, 3, 4, 4, 6, 6 ,6, 6]) == {:four2, 1, 6}
  end
  
  test "air0" do
    assert get_cat([7, 7, 7, 8, 8, 8]) == {:air0, 2, 7}
    assert get_cat([3, 3, 3, 4, 4, 4, 5, 5, 5]) == {:air0, 3, 3}
    assert get_cat([3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6]) 
    == {:air0, 4, 3}
    assert get_cat([7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11]) 
    == {:air0, 5, 7}
    assert get_cat(
        [6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11]
      ) == {:air0, 6, 6}
  end
  
  test "air1" do
    assert get_cat([5, 5, 5, 5, 6, 6, 7, 7]) == {:four2, 1, 5}
    assert get_cat([3, 3, 4, 4, 6, 6 ,6, 6]) == {:four2, 1, 6}
  end
  
  test "air2" do
    assert get_cat([5, 5, 5, 5, 6, 6, 7, 7]) == {:four2, 1, 5}
    assert get_cat([3, 3, 4, 4, 6, 6 ,6, 6]) == {:four2, 1, 6}
  end

  test "single chain" do
    assert get_cat([1, 2, 3, 4, 5]) == {:schain, 5, 1}
    assert (0..6 |> Enum.into([]) |> get_cat == {:schain, 7, 0})
    assert (0..11 |> Enum.into([]) |> get_cat == {:schain, 12, 0})
    assert get_cat([1, 2, 3, 5, 6]) == :illegal
    assert (0..12 |> Enum.into([]) |> get_cat == :illegal)
  end
  
  test "pair chain" do
    assert get_cat([5, 5, 5, 5, 6, 6, 7, 7]) == {:four2, 1, 5}
    assert get_cat([3, 3, 4, 4, 6, 6 ,6, 6]) == {:four2, 1, 6}
  end
  
  test "rocket" do
   assert get_cat([52, 53]) == :rocket
  end
  
  test "none" do
   assert get_cat([]) == :none
  end
  
  test "illegal" do
   assert get_cat([1, 2]) == :illegal
   assert get_cat([3, 3, 5]) == :illegal
   assert get_cat([3, 3, 4, 4]) == :illegal
   assert get_cat([3, 4, 5, 6]) == :illegal
  end
end

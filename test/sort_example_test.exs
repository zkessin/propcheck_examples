defmodule SortTest do
  @moduledoc """
  Some simple tests around sort

  """
  use ExUnit.Case
  use PropCheck

  test "Typical Sort Example test " do
    assert Enum.sort([3, 2, 1]) == [1, 2, 3]
  end

  property "Sort Is Idempotent" do
    forall l <- list(integer()) do
      Enum.sort(l) == l |> Enum.sort() |> Enum.sort()
    end
  end

  @tag :skip
  property "Sort Preserves Length" do
    forall l <- list(integer()) do
      length(l) == l |> :lists.usort() |> length()
    end
  end

  @tag :skip
  property "Adjust default number of tests, generate two types of data" do
    numtests(
      1000,
      forall {needle, haystack} <- {integer(), list(integer())} do
        n = :lists.delete(needle, haystack)
        not Enum.member?(n, needle)
      end
    )
  end

  property "Filter Generated data" do
    forall l <- list(integer()) do
      implies(l != [], do: Enum.min(l) == l |> Enum.sort() |> hd())
    end
  end
end

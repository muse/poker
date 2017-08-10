defmodule PokerCardTest do
  use     ExUnit.Case
  doctest Poker
  alias   Poker.Card

  describe "Poker.Card.new/1" do
    # Poker.Card.break/1
    test "Raises ArgumentError when breaking a malformed card" do
      Enum.each(["", "AAA", "0"], fn card ->
        assert_raise ArgumentError, ~r/malformed card/i, fn -> Card.new(card) end
      end)
    end
    # Poker.Card.valid?/1
    test "Raises ArgumentError when creating a invalid card" do
      Enum.each(["3M", "PP", "1C"], fn card ->
        assert_raise ArgumentError, ~r/invalid card/i, fn -> Card.new(card) end
      end)
    end
    test "Creates a card through a string" do
      assert Card.new("AD") === %Card{face: "A", suit: "D", ordinal: 12}
      assert Card.new("2S") === %Card{face: "2", suit: "S", ordinal: 0}
      assert Card.new("7C") === %Card{face: "7", suit: "C", ordinal: 5}
    end
    test "Creates a card through a tuple" do
      assert Card.new({"A", "D"}) === %Card{face: "A", suit: "D", ordinal: 12}
      assert Card.new({"2", "S"}) === %Card{face: "2", suit: "S", ordinal: 0}
      assert Card.new({"7", "C"}) === %Card{face: "7", suit: "C", ordinal: 5}
    end
  end

  describe "Poker.Card.random/1" do
    test "Generates random cards" do
      Enum.each(Card.random(3), fn card ->
        assert Map.get(card, :__struct__, nil) === Card
      end)
    end
  end
end

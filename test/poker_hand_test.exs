defmodule PokerHandTest do
  use     ExUnit.Case
  doctest Poker
  alias   Poker.{Hand, Card}
  import  TestHelper

  setup_all do
    {:ok,
      ranks: [
        "straight-flush":  ["TH", "JH", "QH", "KH", "AH"], # A
        "four-of-a-kind":  ["2H", "2C", "2D", "2S", "AH"], # 2
        "full-house":      ["2H", "3H", "2D", "3C", "3D"], # 3
        "flush":           ["KC", "TC", "7C", "6C", "4C"], # K
        "straight":        ["9H", "TH", "QH", "KH", "JC"], # K
        "three-of-a-kind": ["2H", "2D", "2C", "KC", "QD"], # 2
        "two-pair":        ["2H", "7H", "2D", "3C", "3D"], # 3
        "one-pair":        ["KH", "4S", "TS", "2D", "KS"], # K
        "high-card":       ["2H", "5H", "7D", "8C", "9S"], # 9
      ]
    }
  end

  describe "Poker.Hand.evaluate/1" do
    test "Creates a new hand", state do
      assert state
          |> take_hands(["high-card"])
          |> Hand.evaluate
         === [
          %Hand{
            cards: [
              %Card{face: "2", ordinal: 0, suit: "H"},
              %Card{face: "5", ordinal: 3, suit: "H"},
              %Card{face: "7", ordinal: 5, suit: "D"},
              %Card{face: "8", ordinal: 6, suit: "C"},
              %Card{face: "9", ordinal: 7, suit: "S"}],
            value: {0, 7}}
         ]
    end
    test "Creates multiple hands and orders these on their value", state do
      assert state
          |> take_hands(["high-card", "flush", "straight", "two-pair"])
          |> Hand.evaluate
         === [
          %Hand{
            cards: [
              %Card{face: "K", ordinal: 11, suit: "C"},
              %Card{face: "T", ordinal: 8, suit: "C"},
              %Card{face: "7", ordinal: 5, suit: "C"},
              %Card{face: "6", ordinal: 4, suit: "C"},
              %Card{face: "4", ordinal: 2, suit: "C"}],
            value: {16, 11}},
          %Hand{
            cards: [
              %Card{face: "9", ordinal: 7, suit: "H"},
              %Card{face: "T", ordinal: 8, suit: "H"},
              %Card{face: "Q", ordinal: 10, suit: "H"},
              %Card{face: "K", ordinal: 11, suit: "H"},
              %Card{face: "J", ordinal: 9, suit: "C"}],
            value: {14, 11}},
          %Hand{
            cards: [
              %Card{face: "2", ordinal: 0, suit: "H"},
              %Card{face: "7", ordinal: 5, suit: "H"},
              %Card{face: "2", ordinal: 0, suit: "D"},
              %Card{face: "3", ordinal: 1, suit: "C"},
              %Card{face: "3", ordinal: 1, suit: "D"}],
            value: {9, 1}},
          %Hand{
            cards: [
              %Card{face: "2", ordinal: 0, suit: "H"},
              %Card{face: "5", ordinal: 3, suit: "H"},
              %Card{face: "7", ordinal: 5, suit: "D"},
              %Card{face: "8", ordinal: 6, suit: "C"},
              %Card{face: "9", ordinal: 7, suit: "S"}],
            value: {0, 7}}
         ]
    end
    test "Raises ArgumentError when creating a malformed hand", state do
      state
      |> take_hands(["high-card", "one-pair", "two-pair"])
      |> Enum.map(fn [_ | cards] ->
           # Return only 4 cards which result in malformed hands.
           cards
         end)
      |> Enum.each(fn hand ->
           assert_raise ArgumentError, ~r/malformed hand/i, fn -> Hand.evaluate([hand]) end
         end)
    end
  end
  describe "Poker.Hand.format/1" do
      test "Determines a win condition", state do
        assert state
            |> take_hands(["high-card", "one-pair", "two-pair"])
            |> Hand.evaluate
            |> Hand.format
           === [
            state: :win,
            which: [
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "2", ordinal: 0, suit: "H"},
                  %Poker.Card{face: "7", ordinal: 5, suit: "H"},
                  %Poker.Card{face: "2", ordinal: 0, suit: "D"},
                  %Poker.Card{face: "3", ordinal: 1, suit: "C"},
                  %Poker.Card{face: "3", ordinal: 1, suit: "D"}],
              value: {9, 1}},
            ],
            other: [
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "K", ordinal: 11, suit: "H"},
                  %Poker.Card{face: "4", ordinal: 2, suit: "S"},
                  %Poker.Card{face: "T", ordinal: 8, suit: "S"},
                  %Poker.Card{face: "2", ordinal: 0, suit: "D"},
                  %Poker.Card{face: "K", ordinal: 11, suit: "S"}],
                value: {6, 11}},
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "2", ordinal: 0, suit: "H"},
                  %Poker.Card{face: "5", ordinal: 3, suit: "H"},
                  %Poker.Card{face: "7", ordinal: 5, suit: "D"},
                  %Poker.Card{face: "8", ordinal: 6, suit: "C"},
                  %Poker.Card{face: "9", ordinal: 7, suit: "S"}],
                value: {0, 7}}
             ]]
      end
      test "Determines a tie condition", state do
        assert state
            |> take_hands(["high-card", "flush", "flush"])
            |> Hand.evaluate
            |> Hand.format
           === [
            state: :tie,
            which: [
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "K", ordinal: 11, suit: "C"},
                  %Poker.Card{face: "T", ordinal: 8, suit: "C"},
                  %Poker.Card{face: "7", ordinal: 5, suit: "C"},
                  %Poker.Card{face: "6", ordinal: 4, suit: "C"},
                  %Poker.Card{face: "4", ordinal: 2, suit: "C"}],
                value: {16, 11}},
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "K", ordinal: 11, suit: "C"},
                  %Poker.Card{face: "T", ordinal: 8, suit: "C"},
                  %Poker.Card{face: "7", ordinal: 5, suit: "C"},
                  %Poker.Card{face: "6", ordinal: 4, suit: "C"},
                  %Poker.Card{face: "4", ordinal: 2, suit: "C"}],
                value: {16, 11}}
            ],
            other: [
              %Poker.Hand{
                cards: [
                  %Poker.Card{face: "2", ordinal: 0, suit: "H"},
                  %Poker.Card{face: "5", ordinal: 3, suit: "H"},
                  %Poker.Card{face: "7", ordinal: 5, suit: "D"},
                  %Poker.Card{face: "8", ordinal: 6, suit: "C"},
                  %Poker.Card{face: "9", ordinal: 7, suit: "S"}],
                value: {0, 7}}
            ]]
      end
  end
end

defmodule Poker.Card do
  @moduledoc """
  A playing card from a deck, the structure contains the face, the suit and
  the bound ordinal.
  """

  defstruct [:face, :suit, :ordinal]

  @suits   ["H", "D", "S", "C"]
  @faces   ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
  @ordinal @faces |> Enum.map(&String.to_atom/1) |> Enum.with_index |> Keyword.new

  # Break the card apart and return the face and suit separately.
  defp break(<<face::binary-size(1), suit::binary-size(1)>>) do
    {face, suit}
  end
  defp break(card) do
    raise ArgumentError, "Malformed card, #{card}"
  end

  defp valid?(face, suit) do
    face in @faces && suit in @suits
  end

  @doc """
  Take 1..52 cards of a deck in a random order.
  """
  def random(amount \\ 1) do
    Enum.map(@faces, fn face ->
      Enum.map(@suits, fn suit ->
        face <> suit
      end)
    end)
    |> Enum.flat_map(&(&1))
    |> Enum.take_random(amount)
    |> Enum.map(&new/1)
  end

  @doc """
  Create a new card based on a 2 byte string, the first byte being the face and
  the second byte being the suit, or a tuple containg the face and the suit.
  """
  def new({face, suit}) do
    if valid?(face, suit) do
      %__MODULE__{face: face, suit: suit, ordinal: @ordinal[String.to_atom(face)]}
    else
      raise ArgumentError, "Invalid card, #{face}#{suit}"
    end
  end
  def new(card) do
    card |> break |> new
  end
end

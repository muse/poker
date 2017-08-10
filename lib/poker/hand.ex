defmodule Poker.Hand do
  @moduledoc """
  A hand containing any amount of cards. The structure contains the value,
  which is a tuple containing the combination value and the highest card value.
  It also contains the cards, which are Poker.Card structures.
  """

  alias Poker.Card

  defstruct [:value, :cards]

  defp strip(cards, nil) do
    cards
  end
  defp strip(cards, filter) do
    Enum.filter(cards, filter)
  end

  defp flush?(suits) do
    length(suits) === 1
  end

  # Sort faces or suits by their occurance in a list.
  defp sort(cards, on) do
    case on do
      :faces -> Enum.map(cards, &(&1.face))
      :suits -> Enum.map(cards, &(&1.suit))
    end
    |> Enum.group_by(&(&1))
    |> Map.to_list
    |> Enum.map(fn {key, value} -> {String.to_atom(key), Enum.count(value)} end)
  end

  # Retrieve the relevant cards for ranks.
  defp occurance(faces, amount) do
    faces
    |> Enum.filter(fn {_, value} -> value === amount end)
    |> Keyword.keys()
    |> Enum.map(&to_string/1)
  end

  defp highest(cards) do
    Enum.sort(cards, &(&1.ordinal >= &2.ordinal)) |> hd
  end

  # STFL  = 30  # ST + FL
  # FOAC  = 24  # x2 TOAC
  # FH    = 18  # OP + TOAC
  # FL    = 16
  # ST    = 14
  # TOAC  = 12  # x2 OP
  # TP    = 9
  # OP    = 6
  # HC    = 0
  defp rank([consecutive: {consecutive?, wheel}, suits: suits, faces: faces, cards: cards]) do
    wheel? =
      if wheel do &(&1.face !== "A") else nil end
    occurances =
      fn amount -> &(&1.face in occurance(faces, amount)) end
    {value, filter} =
      case {consecutive?, flush?(suits)} do
        {false, true} ->
          {16, nil}
        {true, false} ->
          {14, wheel?}
        {true, true} ->
          {30, wheel?}
        _ ->
          case Keyword.values(faces) |> Enum.sort do
            [1, 1, 1, 1, 1] ->
              {0, nil}
            [1, 1, 1, 2] ->
              {6, occurances.(2)}
            [1, 2, 2] ->
              {9, occurances.(2)}
            [1, 1, 3] ->
              {12, occurances.(3)}
            [2, 3] ->
              {18, occurances.(3)}
            [1, 4] ->
              {24, occurances.(4)}
          end
      end
    %__MODULE__{
      value: {value, strip(cards, filter) |> highest |> Map.get(:ordinal)},
      cards: cards,
    }
  end

  defp consecutive(cards) do
    ordinal = Enum.map(cards, &(&1.ordinal))
    wheel   = [12, 0, 1, 2, 3]
    if Enum.empty?(wheel -- ordinal) do
      {true, true}
    else
      consecutive? =
        ordinal
        |> Enum.sort
        |> Enum.chunk(2, 1)
        |> Enum.all?(fn [x, y] -> x + 1 === y end)
      {consecutive?, false}
    end
  end

  defp visualize(%{cards: cards, value: {value, high}}) do
    cards =
      cards
      |> Enum.map(&("#{&1.face}#{&1.suit}"))
      |> Enum.join(" ")
    value =
      case value do
        30 -> "Straight flush"
        24 -> "Four of a kind"
        18 -> "Full house"
        16 -> "Flush"
        14 -> "Straight"
        12 -> "Three of a kind"
        9  -> "Two pair"
        6  -> "One pair"
        0  -> "High card"
      end <> ", highest card: #{high}"
    "#{cards} #{value}"
  end

  @doc """
  Evaluate any amount of hands and order these by their combination value and
  their high card value.
  """
  def evaluate(hands) do
    Enum.map(hands, fn hand ->
      if length(hand) === 5 do
        cards =
          Enum.map(hand, fn card ->
            case card do
              %Card{} ->
                card
              _ ->
                Card.new(card)
            end
          end)
        [{:consecutive, consecutive(cards)},
         {:suits, sort(cards, :suits)},
         {:faces, sort(cards, :faces)},
         {:cards, cards}]
      else
        raise ArgumentError, "Malformed hand, missing #{5 - length(hand)} cards"
      end
    end)
    |> Enum.map(&rank/1)
    |> Enum.sort(&(&1.value <= &2.value))
    |> Enum.sort(&(&2.value <= &1.value))
  end

  @doc """
  Determine the final condition of the round and format the entries from evaluate/1
  to show which hand has won, or which hands have tied.
  """
  def format([first, second | other] = hands) do
    {state, {which, other}} =
      cond do
        first.value === second.value ->
          {:tie, Enum.split_while(hands, &(first.value === &1.value))}
        first.value > second.value ->
          {:win, {[first], [second | other]}}
      end
    [state: state, which: which, other: other]
  end
  def format([first | other]) do
    [state: :win, which: [first], other: other]
  end

  @doc """
  Pleasantly display the output from format.
  """
  def display([state: state, which: which, other: other]) do
    IO.puts "Round results: #{state}"
    IO.puts "Relevant hands:"
    Enum.map(which, fn hand ->
      IO.puts visualize(hand)
    end)
    IO.puts "Losing hands:"
    Enum.map(other, fn hand ->
      IO.puts visualize(hand)
    end)
  end
end

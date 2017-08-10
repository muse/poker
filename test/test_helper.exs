ExUnit.start()

defmodule TestHelper do
  def take_hands(%{ranks: ranks}, keys) do
    Enum.map(keys, fn key ->
      Keyword.get(ranks, String.to_atom(key))
    end)
  end
end

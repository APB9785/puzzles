# Poker hand comparison
# 
# Takes two inputs - the player's hand and the opponent's hand.
# Each is represented by a string - two characters per card, separated by spaces.
# (e.g. "8H 9C TD JH QH")
# 
# Expected output is an integer representing win/loss/draw - using Texas Hold 'em rules.


defmodule PokerHands do
  @result %{win: 1, loss: 2, tie: 3}
  @ranks %{high_card: 1, pair: 2, two_pairs: 3, three_of_a_kind: 4,
           straight: 5, flush: 6, full_house: 7, four_of_a_kind: 8,
           straight_flush: 9}
  
  def compare(player, opponent) do
    {p, pt} = %{hand: parse_hand(player)} |> run_checks |> Map.get(:rank)
    
    {o, ot} = %{hand: parse_hand(opponent)} |> run_checks |> Map.get(:rank)
    
    cond do
      @ranks[p] > @ranks[o] ->
        @result.win
      @ranks[p] < @ranks[o] ->
        @result.loss
      @ranks[p] == @ranks[o] ->
        tiebreak(pt, ot)
    end
  end
  
  def run_checks(state) do
    case state.hand do
    
      # Straight flush
      [{a, s}, {b, s}, {c, s}, {d, s}, {e, s}]
      when (e == d + 1) and (d == c + 1) and (c == b + 1) and (b == a + 1) ->
        Map.put(state, :rank, {:straight_flush, [e]})
      
      # Four-of-a-kind
      [{a, _}, {b, _}, {b, _}, {b, _}, {b, _}] ->
        Map.put(state, :rank, {:four_of_a_kind, [b, a]})
      [{a, _}, {a, _}, {a, _}, {a, _}, {b, _}] ->
        Map.put(state, :rank, {:four_of_a_kind, [a, b]})
        
      # Full house
      [{a, _}, {a, _}, {a, _}, {b, _}, {b, _}] ->
        Map.put(state, :rank, {:full_house, [a, b]})
      [{a, _}, {a, _}, {b, _}, {b, _}, {b, _}] ->
        Map.put(state, :rank, {:full_house, [b, a]})
      
      # Flush
      [{a, s}, {b, s}, {c, s}, {d, s}, {e, s}] ->
        Map.put(state, :rank, {:flush, [e, d, c, b, a]})
        
      # Straight
      [{a, _}, {b, _}, {c, _}, {d, _}, {e, _}]
      when (e == d + 1) and (d == c + 1) and (c == b + 1) and (b == a + 1) ->
        Map.put(state, :rank, {:straight, [e]})
        
      # Three-of-a-kind
      [{a, _}, {a, _}, {a, _}, {b, _}, {c, _}] ->
        Map.put(state, :rank, {:three_of_a_kind, [a, c, b]})
      [{a, _}, {b, _}, {b, _}, {b, _}, {c, _}] ->
        Map.put(state, :rank, {:three_of_a_kind, [b, c, a]})
      [{a, _}, {b, _}, {c, _}, {c, _}, {c, _}] ->
        Map.put(state, :rank, {:three_of_a_kind, [c, b, a]})
      
      # Two pairs
      [{a, _}, {a, _}, {b, _}, {b, _}, {c, _}] ->
        Map.put(state, :rank, {:two_pairs, [b, a, c]})
      [{a, _}, {a, _}, {b, _}, {c, _}, {c, _}] ->
        Map.put(state, :rank, {:two_pairs, [c, a, b]})
      [{a, _}, {b, _}, {b, _}, {c, _}, {c, _}] ->
        Map.put(state, :rank, {:two_pairs, [c, b, a]})
        
      # Pair
      [{a, _}, {a, _}, {b, _}, {c, _}, {d, _}] ->
        Map.put(state, :rank, {:pair, [a, d, c, b]})
      [{a, _}, {b, _}, {b, _}, {c, _}, {d, _}] ->
        Map.put(state, :rank, {:pair, [b, d, c, a]})
      [{a, _}, {b, _}, {c, _}, {c, _}, {d, _}] ->
        Map.put(state, :rank, {:pair, [c, d, b, a]})
      [{a, _}, {b, _}, {c, _}, {d, _}, {d, _}] ->
        Map.put(state, :rank, {:pair, [d, c, b, a]})
      
      # High Card
      [{a, _}, {b, _}, {c, _}, {d, _}, {e, _}] ->
        Map.put(state, :rank, {:high_card, [e, d, c, b, a]})
    end
  end
  
  def parse_hand(str) do
    String.split(str, " ")
    |> Stream.map(fn x ->
         [val, suit] = String.graphemes(x)
         suit =
           case suit do
             "H" -> :hearts
             "C" -> :clubs
             "D" -> :diamonds
             "S" -> :spades
           end
         val =
           case val do
             "T" -> 10
             "J" -> 11
             "Q" -> 12
             "K" -> 13
             "A" -> 14
             _ -> String.to_integer(val)
           end
         {val, suit}
       end)
    |> Enum.sort(fn a, b -> elem(a, 0) <= elem(b, 0) end)
  end
  
  def tiebreak([], []), do: @result.tie
  def tiebreak([ph | pt], [oh | ot]) when ph > oh, do: @result.win
  def tiebreak([ph | pt], [oh | ot]) when ph < oh, do: @result.loss
  def tiebreak([ph | pt], [oh | ot]) when ph == oh, do: tiebreak(pt, ot)
end

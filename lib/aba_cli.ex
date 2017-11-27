defmodule AbaCLI do
  @moduledoc """
  Documentation for AbaCLI.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AbaCLI.hello
      :world

  """
  def hello do
    :world
  end

  def db_update_all do
    AbaCLI.Map.db_update_maps
    AbaCLI.Hero.db_update_heroes
    AbaCLI.Ability.db_update_abilities
    AbaCLI.Talent.db_update_talents
    AbaCLI.Replay.db_update_replays
  end
end

defmodule AbaCLI.Player do
  import Ecto.Query
  
  def db_update_players(players, replay_db) do
    Enum.each players, fn player ->
      battletag = Map.get(player, "battletag")
      blizz_id = Map.get(player, "blizz_id")
      hero_name = Map.get(player, "hero") # This is used to lookup a hero in the db by name for later association
      hero_level = Map.get(player, "hero_level")
      party = Map.get(player, "party")
      silenced_bool = Map.get(player, "silenced")
      team = Map.get(player, "team")
      winner = Map.get(player, "winner")

      silenced =
        case silenced_bool do
          false -> 0
          true -> 1
        end

      [battletag_name | [battletag_id]] = String.split(battletag, "#")
      hero_db = AbaModel.Repo.get_by!(AbaModel.Hero, name: hero_name)

      {:ok, player_db} = 
        case AbaModel.Repo.get_by(AbaModel.Player, [replay_id: replay_db.id, blizz_id: blizz_id]) do
          nil -> %AbaModel.Player{
            battletag_name: battletag_name,
            battletag_id: battletag_id,
            blizz_id: blizz_id,
            hero_level: hero_level,
            party: party,
            silenced: silenced,
            team: team,
            winner: winner
          }
          player -> player
        end
        |> AbaModel.Repo.preload(:hero)
        |> AbaModel.Repo.preload(:replay)
        |> AbaModel.Player.changeset(%{
          battletag_name: battletag_name,
          battletag_id: battletag_id,
          blizz_id: blizz_id,
          hero_level: hero_level,
          party: party,
          silenced: silenced,
          team: team,
          winner: winner
        })
        |> Ecto.Changeset.put_assoc(:hero, hero_db)
        |> Ecto.Changeset.put_assoc(:replay, replay_db)
        |> AbaModel.Repo.insert_or_update()
      
      # SCORE
      case Map.get(player, "score") do
        nil -> nil
        score -> AbaCLI.Score.db_update_score(score, player_db)
      end
    end
  end
end
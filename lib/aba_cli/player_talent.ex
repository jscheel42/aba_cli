defmodule AbaCLI.PlayerTalent do
  
  def db_update_player_talent(talents, player_db) do
    Enum.each talents, fn talent ->
      {level_str, name} = talent
      level = String.to_integer(level_str)
      talent_db = AbaModel.Repo.get_by!(AbaModel.Talent, name: name)

      {:ok, _} =
        case AbaModel.Repo.get_by(AbaModel.PlayerTalent, [player_id: player_db.id, level: level]) do
          nil -> %AbaModel.PlayerTalent{
            level: level
          }
          player_talent -> player_talent
        end
        |> AbaModel.Repo.preload(:player)
        |> AbaModel.Repo.preload(:talent)
        |> AbaModel.PlayerTalent.changeset(%{
          level: level
        })
        |> Ecto.Changeset.put_assoc(:player, player_db)
        |> Ecto.Changeset.put_assoc(:talent, talent_db)
        |> AbaModel.Repo.insert_or_update
    end
  end
end
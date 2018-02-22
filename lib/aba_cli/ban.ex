defmodule AbaCLI.Ban do
  # import Ecto.Query
  
  def db_update_bans(bans, replay_db) do
    # Ugly but functional
    case bans do
      nil -> nil
      bans ->
        Enum.each 0..1, fn team ->
          case Enum.at(bans, team) do
            nil -> nil
            team_bans ->
              Enum.each 0..1, fn index ->
                case Enum.at(team_bans, index) do
                  nil -> nil
                  hero_fullname ->
                    hero_db = AbaModel.Repo.get_by!(AbaModel.Hero, name: hero_fullname)
                    {:ok, _} =
                      case AbaModel.Repo.get_by(AbaModel.Ban, [replay_id: replay_db.id, index: index, team: team]) do
                        nil -> %AbaModel.Ban{
                          hero_name: hero_db.attribute_id,
                          index: index,
                          team: team
                        }
                        ban_db -> ban_db    
                      end
                      |> AbaModel.Repo.preload(:hero)
                      |> AbaModel.Repo.preload(:replay)
                      |> AbaModel.Ban.changeset(%{
                        hero_name: hero_db.attribute_id,
                        index: index,
                        team: team
                      })
                      |> Ecto.Changeset.put_assoc(:hero, hero_db)
                      |> Ecto.Changeset.put_assoc(:replay, replay_db)
                      |> AbaModel.Repo.insert_or_update  
                end        
              end
          end
        end
    end
  end
end
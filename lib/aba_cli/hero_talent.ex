defmodule AbaCLI.HeroTalent do
  
  def db_update_hero_talent(hero_db, talent_db) do
    {:ok, _} =
      case AbaModel.Repo.get_by(AbaModel.HeroTalent, [hero_id: hero_db.id, talent_id: talent_db.id]) do
        nil -> %AbaModel.HeroTalent{
          hero_id: hero_db.id,
          talent_id: talent_db.id
        }
        hero_talent -> hero_talent
      end
      |> AbaModel.Repo.preload(:hero)
      |> AbaModel.Repo.preload(:talent)
      |> AbaModel.HeroTalent.changeset(%{
        hero_id: hero_db.id,
        talent_id: talent_db.id
      })
      |> Ecto.Changeset.put_assoc(:hero, hero_db)
      |> Ecto.Changeset.put_assoc(:talent, talent_db)
      |> AbaModel.Repo.insert_or_update
  end
end
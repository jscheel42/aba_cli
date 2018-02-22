defmodule AbaCLI.Talent do
  import Ecto.Query
  
  def db_update_talents_current_status(heroes) do
    talents =
      Enum.reduce heroes, [], fn hero, acc ->
        t = Map.get(hero, "talents")
        acc ++ t
      end

    talent_id_list =
      Enum.reduce talents, [], fn talent, acc ->
        name = Map.get(talent, "name")
        talent_db =
          case AbaModel.Repo.get_by(AbaModel.Talent, name: name) do
            nil -> raise "ERROR: TALENT #{name} NOT FOUND"
            talent -> talent
          end
        acc ++ [talent_db.id]
      end
    
    from(t in AbaModel.Talent, where: t.id in ^talent_id_list)
    |> AbaModel.Repo.update_all(set: [current: true])

    from(t in AbaModel.Talent, where: t.id not in ^talent_id_list)
    |> AbaModel.Repo.update_all(set: [current: false])
  end

  def db_update_talents() do
    {:ok, heroes} = AbaAPI.Hero.heroes
    
    Enum.each heroes, fn hero ->
      hero_name = Map.get(hero, "name")
      hero_db = AbaModel.Repo.get_by!(AbaModel.Hero, name: hero_name)

      {:ok, _} =
        talents = Map.get(hero, "talents")
        Enum.each talents, fn talent ->
          ability_id = Map.get(talent, "ability")
          cooldown = Map.get(talent, "cooldown")
          description = Map.get(talent, "description")
          icon = Map.get(talent, "icon")
          level = Map.get(talent, "level")
          mana_cost = Map.get(talent, "mana_cost")
          name = Map.get(talent, "name")
          sort = Map.get(talent, "sort")
          title = Map.get(talent, "title")
      
          {:ok, talent_db} =
            case AbaModel.Repo.get_by(AbaModel.Talent, name: name) do
              nil -> %AbaModel.Talent{
                ability_id: ability_id,
                cooldown: cooldown,
                current: true,
                description: description,
                icon: icon,
                level: level,
                mana_cost: mana_cost,
                name: name,
                sort: sort,
                title: title
              }
              talent -> talent
            end
            |> AbaModel.Talent.changeset(%{
              ability_id: ability_id,
              cooldown: cooldown,
              current: true,
              description: description,
              icon: icon,
              level: level,
              mana_cost: mana_cost,
              name: name,
              sort: sort,
              title: title
            })
            |> AbaModel.Repo.insert_or_update

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

    db_update_talents_current_status(heroes)
  end
end
defmodule AbaCLI.Ability do
  
  # unique index abilities_hero_id_name_index on abilities table, should do lookups based on hero_id & name

  def db_update_abilities() do
    {:ok, heroes} = AbaAPI.Hero.heroes
    Enum.each heroes, fn hero ->
      hero_name = Map.get(hero, "name")
      hero_db = AbaModel.Repo.get_by!(AbaModel.Hero, name: hero_name)

      hero_id = hero_db.id
      
      abilities = Map.get(hero, "abilities")
      Enum.each abilities, fn ability ->
        cooldown = Map.get(ability, "cooldown")
        description = Map.get(ability, "description")
        hotkey = Map.get(ability, "hotkey")
        icon = Map.get(ability, "icon")
        mana_cost = Map.get(ability, "mana_cost")
        name = Map.get(ability, "name")
        owner = Map.get(ability, "owner")
        title = Map.get(ability, "title")
        trait = Map.get(ability, "trait")      

        {:ok, _} =
          case AbaModel.Repo.get_by(AbaModel.Ability, [hero_id: hero_id, name: name]) do
            nil -> %AbaModel.Ability{
              cooldown: cooldown,
              description: description,
              hotkey: hotkey,
              icon: icon,
              mana_cost: mana_cost,
              name: name,
              owner: owner,
              title: title,
              trait: trait
            }
            db_ability -> db_ability
          end
          |> AbaModel.Repo.preload(:hero)
          |> AbaModel.Ability.changeset(%{
            cooldown: cooldown,
            description: description,
            hotkey: hotkey,
            icon: icon,
            mana_cost: mana_cost,
            name: name,
            owner: owner,
            title: title,
            trait: trait
          })
          |> Ecto.Changeset.put_assoc(:hero, hero_db)
          |> AbaModel.Repo.insert_or_update
      end
    end
  end
end
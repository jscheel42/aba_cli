defmodule AbaCLI.Talent do
  
  def db_update_talents() do
    {:ok, heroes} = AbaAPI.Hero.heroes
    Enum.each heroes, fn hero ->
      hero_name = Map.get(hero, "name")
      hero_db = AbaModel.Repo.get_by(AbaModel.Hero, name: hero_name)
      
      if hero_db == nil do
        IO.puts "Hero '#{hero_name}' not found in database."
      else
        hero_id = hero_db.id
        talents = Map.get(hero, "talents")
        Enum.each talents, fn talent ->
          ability = Map.get(talent, "ability")
          cooldown = Map.get(talent, "cooldown")
          description = Map.get(talent, "description")
          icon = Map.get(talent, "icon")
          icon_url = Map.get(talent, "icon_url") |> Map.values |> List.first
          level = Map.get(talent, "level")
          mana_cost = Map.get(talent, "mana_cost")
          name = Map.get(talent, "name")
          sort = Map.get(talent, "sort")
          title = Map.get(talent, "title")
      
          result =
            case AbaModel.Repo.get_by(AbaModel.Talent, [name: name, hero_id: hero_id]) do
              nil -> %AbaModel.Talent{
                ability: ability,
                cooldown: cooldown,
                description: description,
                icon: icon,
                icon_url: icon_url,
                level: level,
                mana_cost: mana_cost,
                name: name,
                sort: sort,
                title: title
              }
              db_talent -> db_talent
            end
            |> AbaModel.Repo.preload(:hero)
            |> AbaModel.Talent.changeset(%{
              ability: ability,
              cooldown: cooldown,
              description: description,
              icon: icon,
              icon_url: icon_url,
              level: level,
              mana_cost: mana_cost,
              name: name,
              sort: sort,
              title: title
            })
            |> Ecto.Changeset.put_assoc(:hero, hero_db)
            |> AbaModel.Repo.insert_or_update
  
          case result do
            {:ok, struct} -> IO.inspect struct
            {:error, changeset} -> IO.inspect changeset
          end
        end  
      end
    end
  end
end
defmodule AbaCLI.Hero do

  def db_update_heroes() do
    {:ok, heroes} = AbaAPI.Hero.heroes
    Enum.each heroes, fn hero ->
      attribute_id = Map.get(hero, "attribute_id")
      icon_url = Map.get(hero, "icon_url") |> Map.values |> List.first
      name = Map.get(hero, "name")
      short_name = Map.get(hero, "short_name")
      release_date = Map.get(hero, "release_date")
      role = Map.get(hero, "role")
      translations = Map.get(hero, "translations")
      type = Map.get(hero, "type")

      # hero_changeset =
      #   case AbaModel.Repo.get_by(AbaModel.Hero, name: name) do
      #     nil -> %AbaModel.Hero{
      #       attribute_id: attribute_id,
      #       icon_url: icon_url,
      #       name: name,
      #       short_name: short_name,
      #       release_date: release_date,
      #       role: role,
      #       translations: translations,
      #       type: type
      #     }
      #     hero_db -> hero_db
      #   end
      #   |> AbaModel.Repo.preload(:abilities)
      #   |> AbaModel.Hero.changeset(%{
      #     attribute_id: attribute_id,
      #     icon_url: icon_url,
      #     name: name,
      #     short_name: short_name,
      #     release_date: release_date,
      #     role: role,
      #     translations: translations,
      #     type: type
      #   })

      # # ABILITY DATA
      # abilities = Map.get(hero, "abilities")
      # Enum.each abilities, fn ability ->
      #   cooldown = Map.get(ability, "cooldown")
      #   description = Map.get(ability, "description")
      #   hotkey = Map.get(ability, "hotkey")
      #   icon = Map.get(ability, "icon")
      #   mana_cost = Map.get(ability, "mana_cost")
      #   name = Map.get(ability, "name")
      #   owner = Map.get(ability, "owner")
      #   title = Map.get(ability, "title")
      #   trait = Map.get(ability, "trait")

      #   ability_changeset =
      #     case AbaModel.Repo.get_by(AbaModel.Ability, name: name) do
      #       nil -> %AbaModel.Ability{
      #         cooldown: cooldown,
      #         description: description,
      #         hotkey: hotkey,
      #         icon: icon,
      #         mana_cost: mana_cost,
      #         name: name,
      #         owner: owner,
      #         title: title,
      #         trait: trait
      #       }
      #       ability_db -> ability_db
      #     end
      #     |> AbaModel.Ability.changeset(%{
      #       cooldown: cooldown,
      #       description: description,
      #       hotkey: hotkey,
      #       icon: icon,
      #       mana_cost: mana_cost,
      #       name: name,
      #       owner: owner,
      #       title: title,
      #       trait: trait
      #     })

      #   # player_with_talents = Ecto.Changeset.put_assoc(player_changeset, :talents, [talent1, talent2])
      #   hero_with_ability = Ecto.Changeset.put_assoc(hero_changeset, :abilities, ability_changeset)
      #   IO.puts "hero_with_ability"
      #   IO.inspect hero_with_ability
      #   result2 = AbaModel.Repo.insert_or_update(hero_with_ability)
      #   IO.inspect result2
      # end
      
      # IO.puts "===CHANGESET==="
      # IO.inspect hero_changeset
      # result = AbaModel.Repo.insert_or_update(hero_changeset)

      result =
        case AbaModel.Repo.get_by(AbaModel.Hero, name: name) do
          nil -> %AbaModel.Hero{
            attribute_id: attribute_id,
            icon_url: icon_url,
            name: name,
            short_name: short_name,
            release_date: release_date,
            role: role,
            translations: translations,
            type: type
          }
          db_hero -> db_hero
        end
        |> AbaModel.Hero.changeset(%{
          attribute_id: attribute_id,
          icon_url: icon_url,
          name: name,
          short_name: short_name,
          release_date: release_date,
          role: role,
          translations: translations,
          type: type
        })
        |> AbaModel.Repo.insert_or_update      

      case result do
        {:ok, struct} -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset
      end
    end
  end
end
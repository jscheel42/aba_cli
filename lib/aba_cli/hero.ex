defmodule AbaCLI.Hero do

  def db_update_heroes() do
    {:ok, heroes} = AbaAPI.Hero.heroes
    Enum.each heroes, fn hero ->
      attribute_id = Map.get(hero, "attribute_id")
      name = Map.get(hero, "name")
      short_name = Map.get(hero, "short_name")
      release_date = Map.get(hero, "release_date")
      role = Map.get(hero, "role")
      type = Map.get(hero, "type")

      hero_result =
        case AbaModel.Repo.get_by(AbaModel.Hero, name: name) do
          nil -> %AbaModel.Hero{
            attribute_id: attribute_id,
            name: name,
            short_name: short_name,
            release_date: release_date,
            role: role,
            type: type
          }
          hero_db -> hero_db
        end
        |> AbaModel.Hero.changeset(%{
          attribute_id: attribute_id,
          name: name,
          short_name: short_name,
          release_date: release_date,
          role: role,
          type: type
        })
        |> AbaModel.Repo.insert_or_update()

      case hero_result do
        {:ok, struct} -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset
      end
    end
  end
end
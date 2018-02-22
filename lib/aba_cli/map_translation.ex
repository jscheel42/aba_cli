defmodule AbaCLI.MapTranslation do

  def db_update_map_translations() do
    {:ok, maps} = AbaAPI.Map.maps
    Enum.each maps, fn map ->
      name = Map.get(map, "name")
      translations = Map.get(map, "translations")

      map_db = AbaModel.Repo.get_by!(AbaModel.Map, name: name)

      Enum.each translations, fn translation ->
        {:ok, _} = 
          case AbaModel.Repo.get_by(AbaModel.MapTranslation, name: translation) do
            nil -> %AbaModel.MapTranslation{name: translation}
            translation -> translation
          end
          |> AbaModel.Repo.preload(:map)
          |> AbaModel.MapTranslation.changeset(%{name: translation})
          |> Ecto.Changeset.put_assoc(:map, map_db)
          |> AbaModel.Repo.insert_or_update()
      end
    end
  end
end
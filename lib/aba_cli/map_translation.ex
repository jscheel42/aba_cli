defmodule AbaCLI.MapTranslation do

  def db_update_map_translations() do
    {:ok, maps} = AbaAPI.Map.maps
    Enum.each maps, fn map ->
      name = Map.get(map, "name")
      translations = Map.get(map, "translations")

      map_db = AbaModel.Repo.get_by!(AbaModel.Map, name: name)

      Enum.each translations, fn translation ->
        translation_result = 
          case AbaModel.Repo.get_by(AbaModel.MapTranslation, name: translation) do
            nil -> %AbaModel.MapTranslation{name: translation}
            translation -> translation
          end
          |> AbaModel.Repo.preload(:map)
          |> AbaModel.MapTranslation.changeset(%{name: translation})
          |> Ecto.Changeset.put_assoc(:map, map_db)
          |> AbaModel.Repo.insert_or_update()
        case translation_result do
          {:ok, translation_db} -> IO.inspect translation_db
          {:error, changeset} -> IO.inspect changeset
        end
      end
    end
  end
end
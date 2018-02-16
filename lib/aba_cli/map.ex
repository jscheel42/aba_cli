defmodule AbaCLI.Map do

  def db_update_maps() do
    {:ok, maps} = AbaAPI.Map.maps
    Enum.each maps, fn map ->
      name = Map.get(map, "name")
      translations = Map.get(map, "translations")

      map_result = 
        case AbaModel.Repo.get_by(AbaModel.Map, name: name) do
          nil -> %AbaModel.Map{name: name}
          map -> map
        end
        |> AbaModel.Map.changeset(%{name: name})
        |> AbaModel.Repo.insert_or_update()

      case map_result do
        {:ok, translation_db} -> IO.inspect translation_db
        {:error, changeset} -> IO.inspect changeset
      end
    end
  end
end
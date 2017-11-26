defmodule AbaCLI.Map do

  def db_update_maps() do
    {:ok, maps} = AbaAPI.Map.maps
    Enum.each maps, fn map ->
      name = Map.get(map, "name")
      translations = Map.get(map, "translations")

      result = 
        case AbaModel.Repo.get_by(AbaModel.Map, name: name) do
          nil -> %AbaModel.Map{name: name, translations: translations}
          db_map -> db_map
        end
        |> AbaModel.Map.changeset(%{name: name, translations: translations})
        |> AbaModel.Repo.insert_or_update      
      case result do
        {:ok, struct} -> IO.inspect struct
        {:error, changeset} -> IO.inspect changeset
      end
    end
  end

end
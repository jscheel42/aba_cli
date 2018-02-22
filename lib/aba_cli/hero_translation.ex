defmodule AbaCLI.HeroTranslation do
  
  def db_update_hero_translation(translations, hero_db) do
    Enum.each translations, fn translation ->
      {:ok, _} =
        case AbaModel.Repo.get_by(AbaModel.HeroTranslation, name: translation) do
          nil -> %AbaModel.HeroTranslation{
            name: translation
          }
          hero_translation -> hero_translation
        end
        |> AbaModel.Repo.preload(:hero)
        |> AbaModel.HeroTranslation.changeset(%{
          name: translation
        })
        |> Ecto.Changeset.put_assoc(:hero, hero_db)
        |> AbaModel.Repo.insert_or_update()
    end
  end
end
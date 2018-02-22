defmodule AbaCLI.Replay do
  import Ecto.Query
  
  def get_next_replay_id() do
    # case AbaModel.Repo.one(from r in AbaModel.Replay, select: count(r.id), limit: 10) do
    case AbaModel.Repo.get_by(AbaModel.Replay, id: 1) do
      nil -> 1
      _ -> AbaModel.Repo.one(from replay in AbaModel.Replay, select: max(replay.id)) + 1
    end
  end

  def db_update_replay(id) do
    try do
      db_try_update_replay(id)
    rescue e ->
      message = Elixir.Exception.message(e)
      {:ok, _} =
        case AbaModel.Repo.get_by(AbaModel.FailedReplayImport, replay_id: id) do
          nil -> %AbaModel.FailedReplayImport{
            replay_id: id,
            message: message
          }
          failed_replay_import -> failed_replay_import
        end
        |> AbaModel.FailedReplayImport.changeset(%{
          replay_id: id,
          message: message
        })
        |> AbaModel.Repo.insert_or_update()
    end

    # returns the next replay id to parse
    id + 1
  end

  def db_try_update_replay(id) do
    {:ok, replay} = AbaAPI.Replay.replay(id)

    filename = Map.get(replay, "filename")
    fingerprint = Map.get(replay, "fingerprint")
    game_type = Map.get(replay, "game_type")
    game_date = Map.get(replay, "game_date")
    game_length = Map.get(replay, "game_length")
    game_map = Map.get(replay, "game_map")
    game_version = Map.get(replay, "game_version")
    region = Map.get(replay, "region")
    size = Map.get(replay, "size")

    map_db = AbaModel.Repo.get_by!(AbaModel.Map, name: game_map)

    {:ok, replay_db} = 
      case AbaModel.Repo.get_by(AbaModel.Replay, id: id) do
        nil -> %AbaModel.Replay{
          id: id,
          filename: filename,
          fingerprint: fingerprint,
          game_type: game_type,
          game_date: game_date,
          game_length: game_length,
          game_version: game_version,
          region: region,
          size: size
        }
        replay_db -> replay_db
      end
      |> AbaModel.Repo.preload(:game_map)
      |> AbaModel.Replay.changeset(%{
        id: id,
        filename: filename,
        fingerprint: fingerprint,
        game_type: game_type,
        game_date: game_date,
        game_length: game_length,
        game_version: game_version,
        region: region,
        size: size
      })
      |> Ecto.Changeset.put_assoc(:game_map, map_db)
      |> AbaModel.Repo.insert_or_update()

    # BANS
    Map.get(replay, "bans")
    |> AbaCLI.Ban.db_update_bans(replay_db)

    # PLAYERS
    Map.get(replay, "players")
    |> AbaCLI.Player.db_update_players(replay_db)
  end

  def db_update_replays() do
    get_next_replay_id()
    |> db_update_replay()
    |> db_update_replays()
  end

  def db_update_replays(id) do
    db_update_replay(id)
    |> db_update_replays()
  end
end
defmodule AbaCLI.Replay do
  import Ecto.Query
  
  def get_next_replay_id() do
    case AbaModel.Repo.one(from r in AbaModel.Replay, select: count(r.id)) do
      0 -> 1
      _ -> AbaModel.Repo.one(from replay in AbaModel.Replay, select: max(replay.id)) + 1
    end
  end

  def db_update_replay(id) do
    {:ok, replay} = AbaAPI.Replay.replay(id)
    # replay = AbaAPI.Replay.replay(api_replay_id)
    # IO.inspect replay

    # case AbaAPI.Replay.replay(api_replay_id) do
    #   { :error, status_code } -> 
    #   { :ok, replay } -> 
    # end

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
          game_map: game_map,
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
        game_map: game_map,
        game_version: game_version,
        region: region,
        size: size
      })
      |> Ecto.Changeset.put_assoc(:game_map, map_db)
      |> AbaModel.Repo.insert_or_update()

    # case map_result do
    #   {:ok, translation_db} -> IO.inspect translation_db
    #   {:error, changeset} -> IO.inspect changeset
    # end

    # # api_replay_id = Map.get(replay, "id")
    # filename = Map.get(replay, "filename")
    # fingerprint = Map.get(replay, "fingerprint")
    # game_type = Map.get(replay, "game_type")
    # game_date = Map.get(replay, "game_date")
    # game_length = Map.get(replay, "game_length")
    # game_map = Map.get(replay, "game_map")
    # game_version = Map.get(replay, "game_version")
    # region = Map.get(replay, "region")
    # size = Map.get(replay, "size")
    # url = Map.get(replay, "url")

    # Get associated bans based on heroes table
    # Map.get(replay, "bans")
    # |> Enum.at(0)
    # |> Enum.at(0)

    # Ugly but functional
    bans = Map.get(replay, "bans")
    case bans do
      nil -> nil
      bans ->
        Enum.each 0..1, fn team ->
          case Enum.at(bans, team) do
            nil -> nil
            team_bans ->
              Enum.each 0..1, fn index ->
                case Enum.at(team_bans, index) do
                  nil -> nil
                  hero_fullname ->
                    hero_db = AbaModel.Repo.get_by!(AbaModel.Hero, name: hero_fullname)
                    case AbaModel.Repo.get_by(AbaModel.Ban, [replay_id: replay_db.id, index: index, team: team]) do
                      nil -> %AbaModel.Ban{
                        hero_name: hero_db.attribute_id,
                        index: index,
                        team: team
                      }
                      ban_db -> ban_db    
                    end
                    |> AbaModel.Repo.preload(:hero)
                    |> AbaModel.Repo.preload(:replay)
                    |> AbaModel.Ban.changeset(%{
                      hero_name: hero_db.attribute_id,
                      index: index,
                      team: team
                    })
                    |> Ecto.Changeset.put_assoc(:hero, hero_db)
                    |> Ecto.Changeset.put_assoc(:replay, replay_db)
                    |> AbaModel.Repo.insert_or_update  
                end        
              end
          end
        end
    end



    # [bans_team_1 | [bans_team_2]] = Map.get(replay, "bans")
    # [ban_team_1_index_0, ban_team_1_index_1] = bans_team_1
    # [ban_team_2_index_0, ban_team_2_index_1] = bans_team_2

    # IO.puts "BANS TEAM 1"
    # IO.inspect bans_team_1
    # IO.puts "BANS TEAM 2"
    # IO.inspect bans_team_2
    # IO.puts "BAN 1 0"
    # IO.inspect ban_team_1_index_0
    # IO.puts "endzone"

    # Enum.each bans, fn ban ->
      
    # end
    
    # {:ok, ban_db} =
    #   case AbaModel.Repo.get_by(AbaModel.Ban, [hero_id: hero_id, name: name]) do
    #     nil -> %AbaModel.Ban{
    #       hero_name: hero_name,
    #       index: index,
    #       team: team
    #     }
    #     ban_db -> ban_db    
    #   end
    #   |> AbaModel.Repo.preload(:hero)
    #   |> AbaModel.Repo.preload(:replay)
    #   |> AbaModel.Ban.changeset(%{
    #     hero_name: hero_name,
    #     index: index,
    #     team: team
    #   })
    #   |> Ecto.Changeset.put_assoc(:hero, hero_db)
    #   |> Ecto.Changeset.put_assoc(:replay, replay_db)
    #   |> AbaModel.Repo.insert_or_update


    # IO.inspect bans
    # bans_db =
    #   case bans do
    #     nil -> []
    #     bans -> Enum.reduce List.flatten(bans), [], fn (ban, acc) ->
    #       if ban != nil do
    #         [ AbaModel.Repo.get_by(AbaModel.Hero, name: ban) | acc ]
    #       else
    #         acc
    #       end
    #     end
    #   end
    
    # # Accumulate all players as db references in a list for later association
    # players = Map.get(replay, "players")
    # players_db =
    #   Enum.reduce players, [], fn (player, acc) ->
    #     battletag = Map.get(player, "battletag")
    #     blizz_id = Map.get(player, "blizz_id")
    #     hero_name = Map.get(player, "hero") # This is used to lookup a hero in the db by name for later association
    #     hero_level = Map.get(player, "hero_level")
    #     party = Map.get(player, "party")
    #     silenced = Map.get(player, "silenced")
    #     team = Map.get(player, "team")
    #     winner = Map.get(player, "winner")

    #     # Iterate through nested talents map
    #     talents = 
    #       case Map.get(player, "talents") do
    #         nil -> %{"1": nil, "4": nil, "7": nil, "10": nil, "13": nil, "16": nil, "20": nil}
    #         map -> map
    #       end
    #     talent1 = Map.get(talents, "1")
    #     talent4 = Map.get(talents, "4")
    #     talent7 = Map.get(talents, "7")
    #     talent10 = Map.get(talents, "10")
    #     talent13 = Map.get(talents, "13")
    #     talent16 = Map.get(talents, "16")
    #     talent20 = Map.get(talents, "20")    
        
    #     # Iterate through nested score map
    #     # scores = Map.get(player, "score")

    #     scores =
    #       case Map.get(player, "score") do
    #         nil -> %{
    #           "level": nil,
    #           "kills": nil,
    #           "assists": nil,
    #           "takedowns": nil,
    #           "deaths": nil,
    #           "highest_kill_streak": nil,
    #           "hero_damage": nil,
    #           "siege_damage": nil,
    #           "structure_damage": nil,
    #           "minion_damage": nil,
    #           "creep_damage": nil,
    #           "summon_damage": nil,
    #           "time_cc_enemy_heroes": nil,
    #           "healing": nil,
    #           "self_healing": nil,
    #           "damage_taken": nil,
    #           "experience_contribution": nil,
    #           "town_kills": nil,
    #           "time_spent_dead": nil,
    #           "merc_camp_captures": nil,
    #           "watch_tower_captures": nil,
    #           "meta_experience": nil              
    #         }
    #         map -> map
    #       end

    #     score_level = Map.get(scores, "level")
    #     score_kills = Map.get(scores, "kills")
    #     score_assists = Map.get(scores, "assists")
    #     score_takedowns = Map.get(scores, "takedowns")
    #     score_deaths = Map.get(scores, "deaths")
    #     score_highest_kill_streak = Map.get(scores, "highest_kill_streak")
    #     score_hero_damage = Map.get(scores, "hero_damage")
    #     score_siege_damage = Map.get(scores, "siege_damage")
    #     score_structure_damage = Map.get(scores, "structure_damage")
    #     score_minion_damage = Map.get(scores, "minion_damage")
    #     score_creep_damage = Map.get(scores, "creep_damage")
    #     score_summon_damage = Map.get(scores, "summon_damage")
    #     score_time_cc_enemy_heroes = Map.get(scores, "time_cc_enemy_heroes")
    #     score_healing = Map.get(scores, "healing")
    #     score_self_healing = Map.get(scores, "self_healing")
    #     score_damage_taken = Map.get(scores, "damage_taken")
    #     score_experience_contribution = Map.get(scores, "experience_contribution")
    #     score_town_kills = Map.get(scores, "town_kills")
    #     score_time_spent_dead = Map.get(scores, "time_spent_dead")
    #     score_merc_camp_captures = Map.get(scores, "merc_camp_captures")
    #     score_watch_tower_captures = Map.get(scores, "watch_tower_captures")
    #     score_meta_experience = Map.get(scores, "meta_experience")

    #     # Get hero as a db reference for later association
    #     hero_db = AbaModel.Repo.get_by(AbaModel.Hero, name: hero_name)
  
    #     player_db =
    #       case AbaModel.Repo.get_by(AbaModel.Player, [
    #         api_replay_id: api_replay_id,
    #         blizz_id: blizz_id
    #       ]) do
    #         nil -> %AbaModel.Player{
    #           api_replay_id: api_replay_id,
    #           battletag: battletag,
    #           blizz_id: blizz_id,
    #           hero_level: hero_level,
    #           party: party,
    #           silenced: silenced,
    #           team: team,
    #           winner: winner,
    #           talent1: talent1,
    #           talent4: talent4,
    #           talent7: talent7,
    #           talent10: talent10,
    #           talent13: talent13,
    #           talent16: talent16,
    #           talent20: talent20,
    #           score_level: score_level,
    #           score_kills: score_kills,
    #           score_assists: score_assists,
    #           score_takedowns: score_takedowns,
    #           score_deaths: score_deaths,
    #           score_highest_kill_streak: score_highest_kill_streak,
    #           score_hero_damage: score_hero_damage,
    #           score_siege_damage: score_siege_damage,
    #           score_structure_damage: score_structure_damage,
    #           score_minion_damage: score_minion_damage,
    #           score_creep_damage: score_creep_damage,
    #           score_summon_damage: score_summon_damage,
    #           score_time_cc_enemy_heroes: score_time_cc_enemy_heroes,
    #           score_healing: score_healing,
    #           score_self_healing: score_self_healing,
    #           score_damage_taken: score_damage_taken,
    #           score_experience_contribution: score_experience_contribution,
    #           score_town_kills: score_town_kills,
    #           score_time_spent_dead: score_time_spent_dead,
    #           score_merc_camp_captures: score_merc_camp_captures,
    #           score_watch_tower_captures: score_watch_tower_captures,
    #           score_meta_experience: score_meta_experience
    #         }
    #         db_player -> db_player
    #       end
    #       |> AbaModel.Repo.preload(:hero)
    #       |> AbaModel.Player.changeset(%{
    #         api_replay_id: api_replay_id,
    #         battletag: battletag,
    #         blizz_id: blizz_id,
    #         hero_level: hero_level,
    #         party: party,
    #         silenced: silenced,
    #         team: team,
    #         winner: winner,
    #         talent1: talent1,
    #         talent4: talent4,
    #         talent7: talent7,
    #         talent10: talent10,
    #         talent13: talent13,
    #         talent16: talent16,
    #         talent20: talent20,
    #         score_level: score_level,
    #         score_kills: score_kills,
    #         score_assists: score_assists,
    #         score_takedowns: score_takedowns,
    #         score_deaths: score_deaths,
    #         score_highest_kill_streak: score_highest_kill_streak,
    #         score_hero_damage: score_hero_damage,
    #         score_siege_damage: score_siege_damage,
    #         score_structure_damage: score_structure_damage,
    #         score_minion_damage: score_minion_damage,
    #         score_creep_damage: score_creep_damage,
    #         score_summon_damage: score_summon_damage,
    #         score_time_cc_enemy_heroes: score_time_cc_enemy_heroes,
    #         score_healing: score_healing,
    #         score_self_healing: score_self_healing,
    #         score_damage_taken: score_damage_taken,
    #         score_experience_contribution: score_experience_contribution,
    #         score_town_kills: score_town_kills,
    #         score_time_spent_dead: score_time_spent_dead,
    #         score_merc_camp_captures: score_merc_camp_captures,
    #         score_watch_tower_captures: score_watch_tower_captures,
    #         score_meta_experience: score_meta_experience
    #       })
    #       |> Ecto.Changeset.put_assoc(:hero, [hero_db])
          
    #       [ player_db | acc ]
    #   end
    
    # result =
    #   case AbaModel.Repo.get_by(AbaModel.Replay, [api_replay_id: api_replay_id]) do
    #     nil -> %AbaModel.Replay{
    #       api_replay_id: api_replay_id,
    #       filename: filename,
    #       fingerprint: fingerprint,
    #       game_type: game_type,
    #       game_date: game_date,
    #       game_length: game_length,
    #       game_map: game_map,
    #       game_version: game_version,
    #       region: region,
    #       size: size,
    #       url: url
    #     }
    #     db_replay -> db_replay
    #   end
    #   |> AbaModel.Repo.preload(:bans)
    #   |> AbaModel.Repo.preload(:players)
    #   |> AbaModel.Replay.changeset(%{
    #     api_replay_id: api_replay_id,
    #     filename: filename,
    #     fingerprint: fingerprint,
    #     game_type: game_type,
    #     game_date: game_date,
    #     game_length: game_length,
    #     game_map: game_map,
    #     game_version: game_version,
    #     region: region,
    #     size: size,
    #     url: url
    #   })
    #   |> Ecto.Changeset.put_assoc(:bans, bans_db)
    #   |> Ecto.Changeset.put_assoc(:players, players_db)
    #   |> AbaModel.Repo.insert_or_update

    # result
    # # case result do
    # #   {:ok, struct} -> IO.inspect struct
    # #   {:error, changeset} -> IO.inspect changeset
    # # end
  end

  def db_update_replays do
    get_next_replay_id()
    |> db_update_replay()

    db_update_replays()
  end
end
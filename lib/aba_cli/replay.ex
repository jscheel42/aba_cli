defmodule AbaCLI.Replay do
  import Ecto.Query
  
  def get_next_replay_id() do
    # Check DB for MAX replays.api_id + 1
    query = from replay in AbaModel.Replay,
            select: max(replay.api_id)
    AbaModel.Repo.one(query) + 1
  end

  def db_update_replay(api_id) do
    {:ok, replay} = AbaAPI.Replay.replay(api_id)
    api_id = Map.get(replay, "id")
    filename = Map.get(replay, "filename")
    fingerprint = Map.get(replay, "fingerprint")
    game_type = Map.get(replay, "game_type")
    game_date = Map.get(replay, "game_date")
    game_length = Map.get(replay, "game_length")
    game_map = Map.get(replay, "game_map")
    game_version = Map.get(replay, "game_version")
    region = Map.get(replay, "region")
    size = Map.get(replay, "size")
    url = Map.get(replay, "url")

    bans = Map.get(replay, "bans") |> List.flatten
    bans_db =
      Enum.reduce bans, [], fn (ban, acc) ->
        [ AbaModel.Repo.get_by(AbaModel.Hero, name: ban) | acc ]
      end

    # result =
    #   case AbaModel.Repo.get_by(AbaModel.Replay, [api_id: api_id]) do
    #     nil -> %AbaModel.Replay{
    #       api_id: api_id,
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
    #   |> AbaModel.Replay.changeset(%{
    #     api_id: api_id,
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
    #   |> AbaModel.Repo.insert_or_update

    # case result do
    #   {:ok, struct} -> IO.inspect struct
    #   {:error, changeset} -> IO.inspect changeset
    # end


    # bans_db =
    # Enum.reduce bans, [], fn (ban, acc) ->
    #   [ AbaModel.Repo.get_by(AbaModel.Hero, name: ban) | acc ]
    # end

    # ADD PLAYERS
    players = Map.get(replay, "players")

    players_db =
      Enum.reduce players, [], fn (player, acc) ->
        battletag = Map.get(player, "battletag")
        blizz_id = Map.get(player, "blizz_id")
        hero_level = Map.get(player, "hero_level")
        party = Map.get(player, "party")
        silenced = Map.get(player, "silenced")
        team = Map.get(player, "team")
        winner = Map.get(player, "winner")

        # Iterate through nested score map
        scores = Map.get(player, "score")
        score_level = Map.get(scores, "level")
        score_kills = Map.get(scores, "kills")
        score_assists = Map.get(scores, "assists")
        score_takedowns = Map.get(scores, "takedowns")
        score_deaths = Map.get(scores, "deaths")
        score_highest_kill_streak = Map.get(scores, "highest_kill_streak")
        score_hero_damage = Map.get(scores, "hero_damage")
        score_siege_damage = Map.get(scores, "siege_damage")
        score_structure_damage = Map.get(scores, "structure_damage")
        score_minion_damage = Map.get(scores, "minion_damage")
        score_creep_damage = Map.get(scores, "creep_damage")
        score_summon_damage = Map.get(scores, "summon_damage")
        score_time_cc_enemy_heroes = Map.get(scores, "time_cc_enemy_heroes")
        score_healing = Map.get(scores, "healing")
        score_self_healing = Map.get(scores, "self_healing")
        score_damage_taken = Map.get(scores, "damage_taken")
        score_experience_contribution = Map.get(scores, "experience_contribution")
        score_town_kills = Map.get(scores, "town_kills")
        score_time_spent_dead = Map.get(scores, "time_spent_dead")
        score_merc_camp_captures = Map.get(scores, "merc_camp_captures")
        score_watch_tower_captures = Map.get(scores, "watch_tower_captures")
        score_meta_experience = Map.get(scores, "meta_experience")

        player_changeset =
          case AbaModel.Repo.get_by(AbaModel.Player, [
            blizz_id: blizz_id,
            # score_damage_taken: score_damage_taken,
            score_experience_contribution: score_experience_contribution,
            score_hero_damage: score_hero_damage,
            score_minion_damage: score_minion_damage,
            score_siege_damage: score_siege_damage,
            # score_time_spent_dead: score_time_spent_dead
          ]) do
            nil -> %AbaModel.Player{
              battletag: battletag,
              blizz_id: blizz_id,
              hero_level: hero_level,
              party: party,
              silenced: silenced,
              team: team,
              winner: winner,
              score_level: score_level,
              score_kills: score_kills,
              score_assists: score_assists,
              score_takedowns: score_takedowns,
              score_deaths: score_deaths,
              score_highest_kill_streak: score_highest_kill_streak,
              score_hero_damage: score_hero_damage,
              score_siege_damage: score_siege_damage,
              score_structure_damage: score_structure_damage,
              score_minion_damage: score_minion_damage,
              score_creep_damage: score_creep_damage,
              score_summon_damage: score_summon_damage,
              score_time_cc_enemy_heroes: score_time_cc_enemy_heroes,
              score_healing: score_healing,
              score_self_healing: score_self_healing,
              score_damage_taken: score_damage_taken,
              score_experience_contribution: score_experience_contribution,
              score_town_kills: score_town_kills,
              score_time_spent_dead: score_time_spent_dead,
              score_merc_camp_captures: score_merc_camp_captures,
              score_watch_tower_captures: score_watch_tower_captures,
              score_meta_experience: score_meta_experience
            }
            db_player -> db_player
          end
          # |> AbaModel.Repo.preload(:bans)
          |> AbaModel.Player.changeset(%{
            battletag: battletag,
            blizz_id: blizz_id,
            hero_level: hero_level,
            party: party,
            silenced: silenced,
            team: team,
            winner: winner,
            score_level: score_level,
            score_kills: score_kills,
            score_assists: score_assists,
            score_takedowns: score_takedowns,
            score_deaths: score_deaths,
            score_highest_kill_streak: score_highest_kill_streak,
            score_hero_damage: score_hero_damage,
            score_siege_damage: score_siege_damage,
            score_structure_damage: score_structure_damage,
            score_minion_damage: score_minion_damage,
            score_creep_damage: score_creep_damage,
            score_summon_damage: score_summon_damage,
            score_time_cc_enemy_heroes: score_time_cc_enemy_heroes,
            score_healing: score_healing,
            score_self_healing: score_self_healing,
            score_damage_taken: score_damage_taken,
            score_experience_contribution: score_experience_contribution,
            score_town_kills: score_town_kills,
            score_time_spent_dead: score_time_spent_dead,
            score_merc_camp_captures: score_merc_camp_captures,
            score_watch_tower_captures: score_watch_tower_captures,
            score_meta_experience: score_meta_experience
          })
          # |> Ecto.Changeset.put_assoc(:bans, bans_db)
          # |> AbaModel.Repo.insert_or_update

          [ player_changeset | acc ]
      end
    
    result =
      case AbaModel.Repo.get_by(AbaModel.Replay, [api_id: api_id]) do
        nil -> %AbaModel.Replay{
          api_id: api_id,
          filename: filename,
          fingerprint: fingerprint,
          game_type: game_type,
          game_date: game_date,
          game_length: game_length,
          game_map: game_map,
          game_version: game_version,
          region: region,
          size: size,
          url: url
        }
        db_replay -> db_replay
      end
      |> AbaModel.Repo.preload(:bans)
      |> AbaModel.Repo.preload(:players)
      |> AbaModel.Replay.changeset(%{
        api_id: api_id,
        filename: filename,
        fingerprint: fingerprint,
        game_type: game_type,
        game_date: game_date,
        game_length: game_length,
        game_map: game_map,
        game_version: game_version,
        region: region,
        size: size,
        url: url
      })
      |> Ecto.Changeset.put_assoc(:bans, bans_db)
      |> Ecto.Changeset.put_assoc(:players, players_db)
      |> AbaModel.Repo.insert_or_update

    case result do
      {:ok, struct} -> IO.inspect struct
      {:error, changeset} -> IO.inspect changeset
    end


    # Enum.each players, fn player ->
    #   battletag = Map.get(player, "battletag")
    #   blizz_id = Map.get(player, "blizz_id")
    #   hero_level = Map.get(player, "hero_level")
    #   party = Map.get(player, "party")
    #   silenced = Map.get(player, "silenced")
    #   team = Map.get(player, "team")
    #   winner = Map.get(player, "winner")

    #   # Iterate through nested score map
    #   scores = Map.get(player, "score")
    #   score_level = Map.get(scores, "level")
    #   score_kills = Map.get(scores, "kills")
    #   score_assists = Map.get(scores, "assists")
    #   score_takedowns = Map.get(scores, "takedowns")
    #   score_deaths = Map.get(scores, "deaths")
    #   score_highest_kill_streak = Map.get(scores, "highest_kill_streak")
    #   score_hero_damage = Map.get(scores, "hero_damage")
    #   score_siege_damage = Map.get(scores, "siege_damage")
    #   score_structure_damage = Map.get(scores, "structure_damage")
    #   score_minion_damage = Map.get(scores, "minion_damage")
    #   score_creep_damage = Map.get(scores, "creep_damage")
    #   score_summon_damage = Map.get(scores, "summon_damage")
    #   score_time_cc_enemy_heroes = Map.get(scores, "time_cc_enemy_heroes")
    #   score_healing = Map.get(scores, "healing")
    #   score_self_healing = Map.get(scores, "self_healing")
    #   score_damage_taken = Map.get(scores, "damage_taken")
    #   score_experience_contribution = Map.get(scores, "experience_contribution")
    #   score_town_kills = Map.get(scores, "town_kills")
    #   score_time_spent_dead = Map.get(scores, "time_spent_dead")
    #   score_merc_camp_captures = Map.get(scores, "merc_camp_captures")
    #   score_watch_tower_captures = Map.get(scores, "watch_tower_captures")
    #   score_meta_experience = Map.get(player, "meta_experience")
    # end

    # result_players =
    #   case AbaModel.Repo.get_by(AbaModel.Replay, [api_id: api_id]) do
    #     nil -> %AbaModel.Replay{
    #       api_id: api_id,
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
    #   |> AbaModel.Replay.changeset(%{
    #     api_id: api_id,
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
    #   |> AbaModel.Repo.insert_or_update
      
      

  end







  # def db_update_players(api_id) do
    
  # end


  # def () do
  #   {:ok, heroes} = AbaAPI.Hero.heroes
  #   Enum.each heroes, fn hero ->
  #     hero_name = Map.get(hero, "name")
  #     hero_db = AbaModel.Repo.get_by(AbaModel.Hero, name: hero_name)
      
  #     if hero_db == nil do
  #       IO.puts "Hero '#{hero_name}' not found in database."
  #     else
  #       abilities = Map.get(hero, "abilities")
  #       Enum.each abilities, fn replay ->
  #         cooldown = Map.get(replay, "cooldown")
  #         description = Map.get(replay, "description")
  #         hotkey = Map.get(replay, "hotkey")
  #         icon = Map.get(replay, "icon")
  #         mana_cost = Map.get(replay, "mana_cost")
  #         name = Map.get(replay, "name")
  #         owner = Map.get(replay, "owner")
  #         title = Map.get(replay, "title")
  #         trait = Map.get(replay, "trait")
  
  #         result_replay =
  #           case AbaModel.Repo.get_by(AbaModel.Replay, [owner: owner, title: title]) do
  #             nil -> %AbaModel.Replay{
  #               cooldown: cooldown,
  #               description: description,
  #               hotkey: hotkey,
  #               icon: icon,
  #               mana_cost: mana_cost,
  #               name: name,
  #               owner: owner,
  #               title: title,
  #               trait: trait
  #             }
  #             db_replay -> db_replay
  #           end
  #           |> AbaModel.Repo.preload(:hero)
  #           |> AbaModel.Replay.changeset(%{
  #             cooldown: cooldown,
  #             description: description,
  #             hotkey: hotkey,
  #             icon: icon,
  #             mana_cost: mana_cost,
  #             name: name,
  #             owner: owner,
  #             title: title,
  #             trait: trait
  #           })
  #           |> Ecto.Changeset.put_assoc(:hero, hero_db)
  #           |> AbaModel.Repo.insert_or_update
  
  #         case result_replay do
  #           {:ok, struct} -> IO.inspect struct
  #           {:error, changeset} -> IO.inspect changeset
  #         end
  #       end  
  #     end
  #   end
  # end
end
defmodule AbaCLI.Score do
  import Ecto.Query
  
  def db_update_score(score, player_db) do
    level = Map.get(score, "level")
    kills = Map.get(score, "kills")
    assists = Map.get(score, "assists")
    takedowns = Map.get(score, "takedowns")
    deaths = Map.get(score, "deaths")
    highest_kill_streak = Map.get(score, "highest_kill_streak")
    hero_damage = Map.get(score, "hero_damage")
    siege_damage = Map.get(score, "siege_damage")
    structure_damage = Map.get(score, "structure_damage")
    minion_damage = Map.get(score, "minion_damage")
    creep_damage = Map.get(score, "creep_damage")
    summon_damage = Map.get(score, "summon_damage")
    time_cc_enemy_heroes = Map.get(score, "time_cc_enemy_heroes")
    healing = Map.get(score, "healing")
    self_healing = Map.get(score, "self_healing")
    damage_taken = Map.get(score, "damage_taken")
    experience_contribution = Map.get(score, "experience_contribution")
    town_kills = Map.get(score, "town_kills")
    time_spent_dead = Map.get(score, "time_spent_dead")
    merc_camp_captures = Map.get(score, "merc_camp_captures")
    watch_tower_captures = Map.get(score, "watch_tower_captures")
    meta_experience = Map.get(score, "meta_experience")

    {:ok, score_db} = 
      case AbaModel.Repo.get_by(AbaModel.Score, [player_id: player_db.id]) do
        nil -> %AbaModel.Score{
          level: level,
          kills: kills,
          assists: assists,
          takedowns: takedowns,
          deaths: deaths,
          highest_kill_streak: highest_kill_streak,
          hero_damage: hero_damage,
          siege_damage: siege_damage,
          structure_damage: structure_damage,
          minion_damage: minion_damage,
          creep_damage: creep_damage,
          summon_damage: summon_damage,
          time_cc_enemy_heroes: time_cc_enemy_heroes,
          healing: healing,
          self_healing: self_healing,
          damage_taken: damage_taken,
          experience_contribution: experience_contribution,
          town_kills: town_kills,
          time_spent_dead: time_spent_dead,
          merc_camp_captures: merc_camp_captures,
          watch_tower_captures: watch_tower_captures,
          meta_experience: meta_experience
        }
        score -> score
      end
      |> AbaModel.Repo.preload(:player)
      |> AbaModel.Score.changeset(%{
        level: level,
        kills: kills,
        assists: assists,
        takedowns: takedowns,
        deaths: deaths,
        highest_kill_streak: highest_kill_streak,
        hero_damage: hero_damage,
        siege_damage: siege_damage,
        structure_damage: structure_damage,
        minion_damage: minion_damage,
        creep_damage: creep_damage,
        summon_damage: summon_damage,
        time_cc_enemy_heroes: time_cc_enemy_heroes,
        healing: healing,
        self_healing: self_healing,
        damage_taken: damage_taken,
        experience_contribution: experience_contribution,
        town_kills: town_kills,
        time_spent_dead: time_spent_dead,
        merc_camp_captures: merc_camp_captures,
        watch_tower_captures: watch_tower_captures,
        meta_experience: meta_experience
      })
      |> Ecto.Changeset.put_assoc(:player, player_db)
      |> AbaModel.Repo.insert_or_update()    
  end
end
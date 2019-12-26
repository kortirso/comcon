# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersGuildsInsertOrCharactersInsertOrStaticsInsert < ActiveRecord::Migration[5.2]
  def up
    create_trigger("guilds_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("guilds").
        after(:insert) do
      <<-SQL_ACTIONS
PERFORM pg_advisory_xact_lock(NEW.world_id);

INSERT INTO world_stats (world_id, guilds_count)
SELECT
  NEW.world_id as world_id,
  COUNT(guilds.id) as guilds_count
FROM guilds WHERE guilds.world_id = NEW.world_id
ON CONFLICT (world_id) DO UPDATE
SET
  guilds_count = EXCLUDED.guilds_count;
      SQL_ACTIONS
    end

    create_trigger("characters_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("characters").
        after(:insert) do
      <<-SQL_ACTIONS
PERFORM pg_advisory_xact_lock(NEW.world_id);

INSERT INTO world_stats (world_id, characters_count)
SELECT
  NEW.world_id as world_id,
  COUNT(characters.id) as characters_count
FROM characters WHERE characters.world_id = NEW.world_id
ON CONFLICT (world_id) DO UPDATE
SET
  characters_count = EXCLUDED.characters_count;
      SQL_ACTIONS
    end

    create_trigger("statics_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("statics").
        after(:insert) do
      <<-SQL_ACTIONS
PERFORM pg_advisory_xact_lock(NEW.world_id);

INSERT INTO world_stats (world_id, statics_count)
SELECT
  NEW.world_id as world_id,
  COUNT(statics.id) as statics_count
FROM statics WHERE statics.world_id = NEW.world_id
ON CONFLICT (world_id) DO UPDATE
SET
  statics_count = EXCLUDED.statics_count;
      SQL_ACTIONS
    end
  end

  def down
    drop_trigger("guilds_after_insert_row_tr", "guilds", :generated => true)

    drop_trigger("characters_after_insert_row_tr", "characters", :generated => true)

    drop_trigger("statics_after_insert_row_tr", "statics", :generated => true)
  end
end

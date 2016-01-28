class EventsEnforceUniqueness < ActiveRecord::Migration
  def change
    add_index :skills_translator_events, [:query_uuid, :event_number], unique: true
  end
end

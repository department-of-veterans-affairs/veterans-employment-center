class AddLastEventToModels < ActiveRecord::Migration
  def change
  	add_column :skills_translator_models, :last_processed_event_timestamp, :datetime, :default => nil
  end
end

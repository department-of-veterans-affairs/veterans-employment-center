class AddMocToExperiences < ActiveRecord::Migration
  def change
    add_column :experiences, :moc, :string
  end
end

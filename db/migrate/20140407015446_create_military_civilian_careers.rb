class CreateMilitaryCivilianCareers < ActiveRecord::Migration
  def change
    create_table :military_civilian_careers do |t|
      t.string :soc
      t.string :moc
      t.timestamps
    end
  end
end

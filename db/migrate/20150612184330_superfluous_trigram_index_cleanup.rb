class SuperfluousTrigramIndexCleanup < ActiveRecord::Migration
  def change
    remove_index :veterans, [:skills, :objective, :desiredPosition]
    remove_index :awards, [:title, :organization]
    remove_index :affiliations, [:organization, :job_title]
    remove_index :experiences, [:job_title, :description]
  end
end

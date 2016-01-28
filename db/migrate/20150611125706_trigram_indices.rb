class TrigramIndices < ActiveRecord::Migration
  def change
    enable_extension 'pg_trgm'
    add_index :affiliations, [:organization, :job_title], operator_class: "gin_trgm_ops", kind: "gin"
    add_index :awards, [:title, :organization], operator_class: "gin_trgm_ops", kind: "gin"
    add_index :experiences, [:job_title, :description], operator_class: "gin_trgm_ops", kind: "gin"
    add_index :veterans, [:skills, :objective, :desiredPosition], operator_class: "gin_trgm_ops", kind: "gin"
  end
end

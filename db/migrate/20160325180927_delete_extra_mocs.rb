class DeleteExtraMocs < ActiveRecord::Migration
  def change
    execute "delete from military_occupations where source != 'DOD_ODB'"
  end
end

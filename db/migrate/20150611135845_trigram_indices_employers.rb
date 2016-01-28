class TrigramIndicesEmployers < ActiveRecord::Migration
  def change
    add_index :users, :email, operator_class: "gin_trgm_ops", kind: "gin"
    add_index :employers, [:company_name, :poc_email, :poc_name, :ein, :location], operator_class: "gin_trgm_ops", kind: "gin", name: 'employers_gin_by_cn_pe_pn_ein_loc'
  end
end

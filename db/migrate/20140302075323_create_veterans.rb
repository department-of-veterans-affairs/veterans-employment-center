class CreateVeterans < ActiveRecord::Migration
  def change
    create_table :veterans do |t|
        t.string :desiredLocation, :default => "[]"
        t.string :desiredPosition, :default => "[]"
        t.string :skills, :default => "[]"
        t.string :objective
      t.timestamps
    end
    
    create_table :awards do |t|
        t.string :date
        t.string :title
        t.string :organization
      t.timestamps
    end
    
    create_table :references do |t|
        t.string :first_name
        t.string :last_name
        t.string :email
        t.string :job_title
      t.timestamps
    end
    
    create_table :experiences do |t|
        t.string :experience_type
        t.string :job_title
        t.text :description
        t.date :start_date
        t.date :end_date
        t.string :organization
        t.string :educational_organziation
        t.string :credential_type
        t.string :credential_topic
      t.timestamps
    end
    
    create_table :affiliations do |t|
        t.string :organization
        t.string :job_title
      t.timestamps
    end
    
  end
end

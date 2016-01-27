def fill_in_resume_fields
  veteran_info = {
    "veteran_name"                                        => "Suzy P Veteran",
    "veteran_email"                                       => "my@email.com",
    "veteran[objective]"                                  => "this is my objective",
    "Name of school or training"                          => "Harvard",
    "veteran[experiences_attributes][0][description]"     => "Really great time here."
  }
  veteran_info.each do |item, value|
    fill_in item, with: value
  end
end
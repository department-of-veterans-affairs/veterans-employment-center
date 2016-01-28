module EmployerHelper
  
  def employer_website(website)
    website.start_with?("http") ? website : "http://#{website}"
  end
end
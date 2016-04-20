module ApplicationHelper
  
  def is_approved value
    if value 
      return "Approved"
    else
      return "Not Approved"
    end 
  end
  
  def link_to_add_fields(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render(association.to_s.singularize + "_fields", f: builder)
      end
      fields = content_tag(:p,fields + content_tag(:span, "Remove Section", class: "delete-link experience-deleter"))
      link_to(name, '#', class: "add_fields leftOffset", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  def link_to_add_fields_education(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("education_fields", f: builder)
      end
      fields = content_tag(:p,fields + content_tag(:span, "Remove Section", class: "delete-link experience-deleter"))
      link_to(name, '#', class: "add_fields leftOffset", data: {id: id, fields: fields.gsub("\n", "")})
  end
    
  def link_to_add_fields_military(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("military_fields", f: builder)
      end
      fields = content_tag(:p,fields + content_tag(:span, "Remove Section", class: "delete-link experience-deleter"))
      link_to(name, '#', class: "add_fields leftOffset", data: {id: id, fields: fields.gsub("\n", "")})
  end
    
  def link_to_add_fields_work(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("employment_fields", f: builder)
      end
      fields = content_tag(:p,fields + content_tag(:span, "Remove Section", class: "delete-link experience-deleter"))
      link_to(name, '#', class: "add_fields leftOffset", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  def link_to_add_fields_location(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("location_fields", f: builder)
      end
      fields = content_tag(:p,fields + content_tag(:span, "Remove Section", class: "delete-link experience-deleter"))
      link_to(name, '#', id: "addLocationField", class: "add_fields leftOffset", data: {id: id, fields: fields.gsub("\n", "")})
  end

end

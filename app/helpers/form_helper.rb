module FormHelper
  def form_field(form:, type:, name:, label_text: nil, errors: {})
    # http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-concat
    if error_message = errors.fetch(name, []).first
      content_tag :div, class: 'usa-input-error' do
        [
          form.label(name, label_text, class: 'usa-input-error-label'),
          content_tag(:span, "#{name.capitalize} #{error_message}", class: 'usa-input-error-message'),
          form.send(type, name),
        ].reduce(&:concat)
      end
    else
      content_tag(:div) do
        concat form.label name, label_text
        concat form.send(type, name)
      end
    end
  end
end

class AutocompleteInput < SimpleForm::Inputs::CollectionInput

  def input
    label, value = detect_collection_methods
    @reflection = @reflection || object.class.reflections[attribute_name]
    entity_value = object.send(reflection.name)

    # raise "PCCR: #{entity_value}"
    case reflection.macro
    when :belongs_to
      @builder.hidden_field("#{attribute_name}_id", value: entity_value.try(:id)) +
      template.text_field_tag(
        "autocomplete_for[#{field_name}]",
        object.send(reflection.name).try(label),
          :value => entity_value.try(:name),
          :"data-source" => options[:source],
          :"data-field" => '#' + field_name.gsub(/\[/, '_').gsub(/\]/, '') + '_id',
          :"data-min-chars" => options[:min_chars] || 3,
          :class => input_options[:class],
          :disabled => input_options[:disabled]
      )
    else
      template.content_tag(:ul, current_selections.map { |s|
          selection_tag(s.send(value), s.send(label))
        }.join('').html_safe,
        :id => "autocomplete_selections_for_#{object_name}_#{reflection.name}",
        :class => 'autocomplete_selections') +
      template.text_field_tag(
        "autocomplete_multiple_for[#{object_name}_#{reflection.name}]",
        '',
        :"data-source" => options[:source],
        :"data-selections" =>
          "#autocomplete_selections_for_#{object_name}_#{reflection.name}",
        :"data-min-chars" => options[:min_chars] || 3,
        :"data-template" => CGI.escapeHTML(selection_tag("ID", "VALUE")))
    end
  end

  def field_name
    if @builder.options[:parent_builder].nil?
      return "#{object_name}_#{attribute_name}"
    else
      return "#{object_name}[#{attribute_name}]"
    end
  end

  def current_selections
    object.send(reflection.name)
  end

  def label_method
    reflection.klass.new
  end

  def selection_tag(id, name)
    template.content_tag(:li) do
      template.hidden_field_tag(
        "#{object_name}[#{attribute_name}][]",
        id,
          :id => nil) +
      template.sanitize(name) +
      template.link_to('Remove', '#', :class => 'remove')
    end
  end
end

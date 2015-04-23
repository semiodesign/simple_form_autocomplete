class AutocompleteInput < SimpleForm::Inputs::CollectionInput
  # @param wrapp_options []
  # @param input_options:
  #   name_method: [Symbol] method to call on the object for the display value
  #   id_method: [Symbol] method to call on the object for the stored value
  #   search_path: [String] URL to send search request to
  #   disabled_if: (optional)
  #   disabled_unless: (optional)
  #   disabled: [Boolean] True if field should be disabled; defaults: false
  #   class: [String] CSS classes to add to the input element
  #   min_chars: [integer] Minimum number of characters the user has to enter
  #   into the input box before a search will commence
  def input wrapper_options
    @reflection = @reflection || object.class.reflections[attribute_name]
    entity_value = predefined_entity
    if entity_value.nil?
      if reflection.respond_to? :name and !@reflection.is_a?Class
        entity_value = object.send(reflection.name)
      else
        entity_value = nil
      end
    end

    id_method = input_options[:id_method] || :id
    value_method = input_options[:value_method] || input_options[:name_method] || :name

    @builder.hidden_field("#{attribute_name}_id", value: entity_value.try(id_method)) +
    template.text_field_tag(
      "autocomplete_for[#{field_name}]",
        entity_value.try(value_method),
        :"data-source" => options[:source],
        :"data-field" => '#' + field_name.gsub(/\[/, '_').gsub(/\]/, '') + '_id',
        :"data-min-chars" => options[:min_chars] || 3,
        :class => input_options[:class],
        :placeholder => input_options[:placeholder],
        :disabled => input_options[:disabled]
    )
  end

  private

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

  def predefined_entity
    input_options[:entity]
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

module Formtastic

  module Inputs
    module Base
      module Hints

        alias_method :hint_html_without_customizations, :hint_html

        # Overrides the hint_html method to include customer customizations defined using HelpText objects.
        # If a custom HelpText exists for the model attribute that this input is rendering, the +hint+
        # stored in the database will be added as an extra +<p>+ element with the CSS class "customized".
        #
        # To disable this functionality for a single form, specify +label_customizations: false+ as an
        # option to +semantic_form_for()+.
        def hint_html
          return hint_html_without_customizations if builder.options[:label_customizations] == false
          
          output = "".html_safe
          output << hint_html_without_customizations

          audience = template.try(:current_user).try(:person_type)
          help_text = HelpText.for(object_name.to_s.classify, method, audience)

          # Add customer-specific help text
          if help_text
            output << template.content_tag(
            :p,
            Formtastic::Util.html_safe(help_text.try(:hint)),
            class: "#{builder.default_hint_class} customized"
            ) unless help_text.try(:hint).blank?
          end
          
          return output
        end
        
      end
      
      module Labelling
        
        alias_method :label_html_without_customizations, :label_html
        
        # Overrides the label_html method to include customer customizations defined using HelpText objects.
        # If a custom HelpText exists for the model attribute that this input is rendering, the +title+
        # stored in the database will be used instead of the default label text for this input. Additionally,
        # if the HelpText defines some +instructions+ text, that text will be rendered in a +<div>+ with the
        # CSS class "button icon info icon-only help-text", which can be styled as a tooltip as needed.
        #
        # To disable this functionality for a single form, specify +label_customizations: false+ as an
        # option to +semantic_form_for()+.
        def label_html
          return label_html_without_customizations if builder.options[:label_customizations] == false
          
          if render_label?
            audience = template.try(:current_user).try(:person_type)
            help_text = HelpText.for(object_name.to_s.classify, method, audience)
            custom_label_text = Formtastic::Util.html_safe(help_text.try(:title)) || label_text
            # Add customer-specific instructions text
            custom_label_text << template.content_tag(
              :div,
              template.content_tag(
                :span, Formtastic::Util.html_safe(help_text.try(:instructions))
              ),
              class: "button icon info icon-only help-text"
            ) unless help_text.try(:instructions).blank?
            
            builder.label(input_name, custom_label_text, label_html_options)
          else
            "".html_safe
          end
        end
        
      end

      module Choices

        alias_method :legend_html_without_customizations, :legend_html

        # Overrides the legend_html method to include customer customizations for radio inputs defined using HelpText
        # objects. If a custom HelpText exists for the model attribute that this input is rendering, the +title+
        # stored in the database with the specified +audience+ will be used instead of the default label text for this
        # input. Additionally, if the HelpText defines some +instructions+ text, that text will be rendered in a +<div>+
        # with the CSS class "button icon info icon-only help-text", which can be styled as a tooltip as needed.
        #
        # To disable this functionality for a single form, specify +label_customizations: false+ as an
        # option to +semantic_form_for()+.
        def legend_html
          return legend_html_without_customizations if builder.options[:label_customizations] == false
          if render_label?
            audience = template.try(:current_user).try(:person_type)
            help_text = HelpText.for(object_name.to_s.classify, method, audience)
            custom_label_text = Formtastic::Util.html_safe(help_text.try(:title)) || label_text
            # Add customer-specific instructions text
            custom_label_text << template.content_tag(
              :div,
              template.content_tag(
                :span, Formtastic::Util.html_safe(help_text.try(:instructions))
              ),
              class: "button icon info icon-only help-text"
            ) unless help_text.try(:instructions).blank?
            
            builder.label(input_name, custom_label_text, label_html_options)
          else
            "".html_safe
          end
        end
      
      end
    end
  end
  
end


module FormtasticBootstrap
  module Helpers
    module ActionsHelper

      alias_method :actions_without_wrapper, :actions
      
      # Add an extra wrapper around our actions so that we can stylize horizontal forms properly.
      def actions(*args, &block)
        return actions_without_wrapper(*args) unless block_given?
        actions_without_wrapper(*args) do
          template.content_tag(:div,
            template.capture(&block),
            class: "actions-wrapper"
          )
        end
      end
      
    end
    
    module FieldsetWrapper
      protected
      
      def field_set_and_list_wrapping(*args, &block) #:nodoc:
        contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
        html_options = args.extract_options!

        if block_given?
          contents = if template.respond_to?(:is_haml?) && template.is_haml?
            template.capture_haml(&block)
          else
            template.capture(&block)
          end
        end

        # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
        contents = contents.join if contents.respond_to?(:join)
        contents = template.content_tag(:div, contents, class: "inputs-wrapper")

        legend = field_set_legend(html_options)
        fieldset = template.content_tag(:fieldset,
          Formtastic::Util.html_safe(legend) << Formtastic::Util.html_safe(contents),
          html_options.except(:builder, :parent, :name)
        )

        fieldset
      end
      
      def field_set_legend(html_options)
        legend  = (html_options[:name] || '').to_s
        # only applying if String includes '%i' avoids argument error when $DEBUG is true
        legend %= parent_child_index(html_options[:parent]) if html_options[:parent] && legend.include?('%i')
        legend_header = template.content_tag(:span, legend.html_safe)
        legend_description = template.content_tag(:small, html_options[:hint]) unless html_options[:hint].blank?
        legend  = template.content_tag(:legend, legend_header + legend_description) unless legend.blank?
        legend
      end
      
    end
  end
end

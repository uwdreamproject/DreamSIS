module Formtastic
  module Inputs
    module Base
      module Hints

        def hint_html
          output = "".html_safe
          
          if hint?
            output << template.content_tag(
            :p, 
            Formtastic::Util.html_safe(hint_text), 
            :class => builder.default_hint_class
            )
          end
          
          # Add customer-specific help text
          if help_text = HelpText.for(object_name.classify, method)
            output << template.content_tag(
            :p,
            Formtastic::Util.html_safe(help_text.try(:hint)),
            :class => "#{builder.default_hint_class} customized"
            ) unless help_text.try(:hint).blank?
          end
          
          return output
        end
        
      end
      
      module Labelling
        
        def label_html
          if render_label?
            help_text = HelpText.for(object_name.classify, method)
            custom_label_text = Formtastic::Util.html_safe(help_text.try(:title)) || label_text
            
            # Add customer-specific instructions text
            custom_label_text << template.content_tag(
              :div,
              template.content_tag(
                :span, Formtastic::Util.html_safe(help_text.try(:instructions))
              ),
              :class => "button icon info icon-only help-text"
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

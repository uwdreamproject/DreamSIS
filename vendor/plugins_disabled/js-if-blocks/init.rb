require 'generator_if_blocks'
require 'javascript_element_proxy_extraction'

ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods.class_eval do
  include GeneratorIfBlocks
end

ActionView::Helpers::JavaScriptProxy.class_eval do
  include JavaScriptElementProxyExtraction
end

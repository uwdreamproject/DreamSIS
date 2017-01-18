# class RegistrationResourceXMLFormatter
#   include ActiveResource::Formats::XmlFormat
#
#   # This method decodes the xml from the student web service. We do a couple of things to prep it for our app:
#   #
#   # * give back just the [Registrations][Registration] portion of the data payload
#   # * rename the "Person" attribute key to "PersonResource" so that ActiveRecord doesn't get confused
#   def decode(xml)
#     xml_hash = ActiveResource::Formats::XmlFormat.decode(xml)
#     valid_hash = xml_hash.try(:[],'Registrations').try(:[],'Registration') || xml_hash
#     valid_hash["StudentPersonResource"] = valid_hash.delete("Person") if valid_hash.is_a?(Hash) && valid_hash["Person"]
#     valid_hash
#   end
# end

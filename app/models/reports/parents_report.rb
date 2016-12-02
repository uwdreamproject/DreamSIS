class ParentsReport < Report

	def objects
		Parent.where(participant_id: object_ids)
	end
	
	def column_headers
		Parent.xlsx_columns
	end
	
	def row(object)
		object.attributes
	end
	
end

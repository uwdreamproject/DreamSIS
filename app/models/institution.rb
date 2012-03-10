# Institution Codes
class Institution < StudentInfo
  set_table_name "sys_tbl_02_ed_inst_info"
  set_primary_key :table_key
  
  default_scope :order => 'institution_name ASC'
  
  def <=>(o)
    name <=> o.name rescue 0
  end
  
  def id
    read_attribute(:table_key).to_i
  end
  
  def name
    institution_name.titleize
  end
  
end

class ChangeStudentIdNumberToString < ActiveRecord::Migration[5.0]
  def change
    change_column :people, :student_id_number, :string
  end
end

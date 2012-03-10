def db_concat(*args)

  adapter = ActiveRecord::Base.connection.instance_variable_get("@config")[:adapter].to_sym rescue nil
  args.map!{ |arg| arg.class==Symbol ? arg.to_s : "'#{arg}'" }

  case adapter
    when :mysql
      "CONCAT(#{args.join(',')})"
    when :sqlserver
      args.join('+')
    else
      args.join('||')
  end

end

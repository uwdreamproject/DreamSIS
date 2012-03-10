module JavaScriptElementProxyExtraction
  def respond_to?(name)
    return true if name.to_sym == :to_script
    super
  end

  def to_script
    @script ||= @generator.instance_variable_get("@lines").pop.chomp(';')
  end
end

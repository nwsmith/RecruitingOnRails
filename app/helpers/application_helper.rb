module ApplicationHelper
  def code_name(code)
    code.nil? ? 'N/A' : code.name
  end
end

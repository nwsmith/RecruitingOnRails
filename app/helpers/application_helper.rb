module ApplicationHelper
  def code_name(code)
    code.nil? ? 'N/A' : code.name
  end

  def approved_span(reviewable_element)
    is_unapproved, is_approved = false, !reviewable_element.reviews.empty?
    reviewable_element.reviews.each do |reviewer|
      is_unapproved = true if reviewer.unapproved?
      is_approved = false unless reviewer.approved?
    end
    color_property = ''
    color_property = 'style="color: red;"' if is_unapproved
    color_property = 'style="color: green;"' if is_approved
    "<span #{color_property} >#{reviewable_element.name}</span>".html_safe
  end
end

module ApplicationHelper
  def get_name(code)
    code.nil? ? 'N/A' : code.name
  end

  def approved_span(*args, &block)
    reviewable_element ||= (args.nil? || args.first.nil?) ? nil : args.first
    return "" if reviewable_element.nil?

    options = args.second || {}

    text = options[:text] || reviewable_element.name
    approved_text = options[:approved_text] || text
    unapproved_text = options[:unapproved_text] || text
    unknown_text = options[:unknown_text] || text

    is_unapproved, is_approved = false, false

    if reviewable_element.respond_to?('reviews')
      is_unapproved, is_approved = false, !reviewable_element.reviews.empty?
      reviewable_element.reviews.each do |review|
        is_unapproved = true if !review.review_result.nil? && review.review_result.is_disapproval?
        is_approved = false unless !review.review_result.nil? && review.review_result.is_approval?
      end
    end

    if reviewable_element.respond_to?('review_result')
      is_approved = true if !reviewable_element.review_result.nil? && reviewable_element.review_result.is_approval
      is_unapproved = true if !reviewable_element.review_result.nil? && reviewable_element.review_result.is_disapproval
    end

    if reviewable_element.respond_to?('is_approval')
      is_approved = true if reviewable_element.is_approval?
      is_unapproved = true if reviewable_element.is_disapproval?
    end

    color_property = ''
    color_property = 'style="color: red;"' if is_unapproved
    color_property = 'style="color: green;"' if is_approved

    out_text = text
    out_text = approved_text if is_approved
    out_text = unapproved_text if is_unapproved
    out_text = unknown_text if !is_unapproved && !is_approved

    "<span #{color_property} >#{out_text}</span>".html_safe
  end

  def color_span(colorable, text, bold = false)
    color = colorable.respond_to?('color') ? colorable.color : ''
    color ||= ''
    style = "style='"
    style += "color: #{color};" if (!color.nil? && !color.empty?)
    style += "font-weight: bold;" if bold
    style += "'"
    "<span #{style}>#{text}</span.".html_safe
  end
end

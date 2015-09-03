module ApplicationHelper
  def get_name(code)
    code.nil? ? 'N/A' : code.name
  end

  def approved_span(*args, &block)
    reviewable_element ||= (args.nil? || args.first.nil?) ? nil : args.first
    return '' if reviewable_element.nil?

    options = args.second || {}

    text = options[:text] || reviewable_element.name
    approved_text = options[:approved_text] || text
    unapproved_text = options[:unapproved_text] || text
    unknown_text = options[:unknown_text] || text
    link = options[:link]

    if reviewable_element.respond_to?('each')
      is_approved = !reviewable_element.empty?
      is_unapproved = false
      reviewable_element.each do |reviewable|
        tmp_approved, tmp_unapproved = approval_flags(reviewable)
        is_approved &= tmp_approved
        is_unapproved |= tmp_unapproved
      end
    else
      is_approved, is_unapproved = approval_flags(reviewable_element)
    end

    color_property = ''
    color_property = 'style="color: red;"' if is_unapproved
    color_property = 'style="color: green;"' if is_approved

    out_text = ''
    out_text = approved_text if is_approved
    out_text = unapproved_text if is_unapproved
    out_text = unknown_text unless is_unapproved && !is_approved

    my_class = ''
    my_class = 'approved' if is_approved
    my_class = 'unapproved' if is_unapproved

    if link
      out_text = link_to(text, reviewable_element, :class => my_class)
    else
      out_text = "<span #{color_property}>#{out_text}</span>".html_safe
    end

    yield block out_text

    out_text
  end

  def approval_flags(reviewable_element)
    return false, false if reviewable_element.nil?

    is_approved, is_unapproved = false, false

    #TODO: Clean up this mess
    if reviewable_element.respond_to?('reviews')
      is_approved, is_unapproved = !reviewable_element.reviews.empty?, false
      reviewable_element.reviews.each do |review|
        is_approved = false unless review.review_result.nil? && review.review_result.is_disapproval?
        is_unapproved = true unless review.review_result.nil? && review.review_result.is_disapproval?
      end
    end

    if reviewable_element.respond_to?('review_result')
      is_approved = true unless reviewable_element.review_result.nil? && reviewable_element.review_result.is_approval?
      is_unapproved = true unless reviewable_element.review_result.nil? && reviewable_element.review_result.is_disapproval?
    end

    if reviewable_element.respond_to?('is_approval')
      is_approved = true if reviewable_element.is_approval?
      is_unapproved = true if reviewable_element.is_disapproval?
    end

    return is_approved, is_unapproved
  end

  def color_span(colorable, text, bold = false)
    color = colorable.respond_to?('color') ? colorable.color : ''
    color ||= ''
    style = "style='"
    style += "color: #{color};" if (!color.nil? && !color.empty?)
    style += 'font-weight: bold;' if bold
    style += "'"
    "<span #{style}>#{text}</span>".html_safe
  end
end

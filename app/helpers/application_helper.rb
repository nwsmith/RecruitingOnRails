module ApplicationHelper
  def display_text(text)
    text.nil? ? '' : text.gsub("\n", '<br>')
  end

  def get_name(code)
    code.nil? ? 'N/A' : code.name
  end

  def user_select(f)
    f.collection_select(:user_id, User.all_active.sort_by{|u| u.first_name}, :id, :name)
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

    a_type = approval_type(reviewable_element)

    if a_type.eql? :approved
      color_property = 'style="color: green;"'
      out_text = approved_text
      my_class = 'approved'
    elsif a_type.eql? :not_approved
      color_property = 'style="color: red;"'
      out_text = unapproved_text
      my_class = 'unapproved'
    else
      color_property = ''
      out_text = unknown_text
      my_class = ''
    end

    if link
      out_text = link_to(text, reviewable_element, :class => my_class)
    else
      out_text = "<span #{color_property}>#{out_text}</span>".html_safe
    end

    out_text
  end

  def approval_type(reviewable_element)
    a_type = :approval_unknown

    return a_type if reviewable_element.nil?

    if reviewable_element.respond_to?('is_approval')
      if reviewable_element.is_approval?
        a_type = :approved
      end

      if reviewable_element.is_disapproval?
        a_type = :not_approved
      end
    end

    if reviewable_element.respond_to?('review_result')
      a_type = approval_type(reviewable_element.review_result)
    end

    if reviewable_element.respond_to?('reviews') && !reviewable_element.reviews.empty?
      a_type = :approved
      reviewable_element.reviews.each do |review|
        tmp = approval_type(review)
        next if a_type.eql?(tmp) && tmp.eql?(:approved)
        a_type = tmp
        break if a_type.eql? :not_approved
      end
    end

    a_type
  end

  def color_span(colorable, text, bold = false)
    color = colorable.respond_to?('color') ? colorable.color : ''
    color ||= ''
    style = "style='"
    style += "color: #{color};" if (!color.nil? && !color.empty?)
    style += "font-weight: bold;" if bold
    style += "'"
    "<span #{style}>#{text}</span>".html_safe
  end
end

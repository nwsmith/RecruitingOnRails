require 'redcarpet'

module ApplicationHelper
  def display_text(text)
    return '' if text.nil?
    ERB::Util.html_escape(text).gsub("\n", '<br>').html_safe
  end

  def get_name(code)
    code.nil? ? 'N/A' : code.name
  end

  def user_select(f)
    f.collection_select(:user_id, User.all_active.sort_by{|u| u.first_name}, :id, :name)
  end

  def approved_span(*args, &block)
    reviewable_element = args.first
    return '' if reviewable_element.nil?

    options = args.second || {}

    text = options[:text] || reviewable_element.name
    approved_text = options[:approved_text] || text
    unapproved_text = options[:unapproved_text] || text
    unknown_text = options[:unknown_text] || text
    link = options[:link]

    a_type = approval_type(reviewable_element)

    case a_type
    when :approved
      style = 'color: green;'
      out_text = approved_text
      my_class = 'approved'
    when :not_approved
      style = 'color: red;'
      out_text = unapproved_text
      my_class = 'unapproved'
    else
      style = nil
      out_text = unknown_text
      my_class = nil
    end

    if link
      link_to(text, reviewable_element, class: my_class)
    else
      content_tag(:span, out_text, style: style)
    end
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

  def color_span(*args, &block)
    colorable = args.first
    options = args.second || {}

    content = options[:text]
    content = capture(&block) if block

    color = colorable.respond_to?(:color) ? colorable.color : nil
    style_parts = []
    style_parts << "color: #{color}" if color.present?
    style_parts << 'font-weight: bold' if options[:bold]

    content_tag(:span, content, style: style_parts.join('; ').presence)
  end

  def markdown(text)
    text ||= ''

    options = {
        filter_html: true,
        hard_wrap: true,
        link_attributes: { rel: 'nofollow', target: '_blank' },
        space_after_headers: true,
        fenced_code_blocks: true
    }

    extensions = {
        autolink: true,
        superscript: true,
        disable_indented_code_blocks: true,
        tables: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end

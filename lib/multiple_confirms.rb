module MultipleConfirms

  def convert_options_to_javascript!(html_options, url = '')
    confirm, popup = html_options.delete("confirm"), html_options.delete("popup")

    method, href = html_options.delete("method"), html_options['href']

    html_options["onclick"] = case
      when popup && method
        raise ActionView::ActionViewError, "You can't use :popup and :method in the same link"
      when confirm && popup
        multiple_confirm_javascript_function(confirm, popup_javascript_function(popup))
      when confirm && method
        multiple_confirm_javascript_function(confirm, method_javascript_function(method))
      when confirm
        "return #{multiple_confirm_javascript_function(confirm)};"
      when method
        "#{method_javascript_function(method, url, href)}return false;"
      when popup
        "#{popup_javascript_function(popup)}return false;"
      else
        html_options["onclick"]
      end
  end

  def multiple_confirm_javascript_function(confirm, body = nil)
    if confirm.is_a?(Array) 
      body.nil? ?
        confirm.collect{|c| confirm_javascript_function(c)}.join("&& ") :
        "#{nested_confirm_javascript_function(confirm.reverse, body)};return false;" 
    else
      body.nil? ? 
        "#{confirm_javascript_function(confirm)}" :
        "if (#{confirm_javascript_function(confirm)}) { #{body} };return false;"
    end
  end


  def nested_confirm_javascript_function(confirm, body)
    if confirm.empty?
      return body
    else
      condition = confirm.first
      confirm.delete_if {|x| x.eql?(confirm.first)}
      new_body = "if (#{confirm_javascript_function(condition)}) { #{body} }"
      nested_confirm_javascript_function(confirm, new_body)
    end
  end

end

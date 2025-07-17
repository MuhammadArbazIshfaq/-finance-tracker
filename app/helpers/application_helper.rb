module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :notice
      "success" # green
    when :alert, :error
      "danger"  # red
    else
      "info"    # default (blue)
    end
  end
end

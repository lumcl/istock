module ApplicationHelper
  def select_options_tag(name='',select_options={},options={})
    #set selected from value
    selected = ''
    unless options[:value].blank?
      selected = options[:value]
      options.delete(:value)
    end
    select_tag(name,options_for_select(select_options,selected),options)
  end
end

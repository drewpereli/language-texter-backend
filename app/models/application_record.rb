# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected

  def event_messages
    I18n.t(event_message_key, event_message_variables.merge(deep_interpolation: true))
  end

  private

  def event_message_variables
    {}
  end

  def event_message_key
    "event_messages.#{self.class.name.underscore.pluralize}"
  end
end

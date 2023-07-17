# frozen_string_literal: true

Puppet::Type.type(:setter_call).provide(:setter_call) do
  desc 'Unique provider'

  def desired_state
    resource[:previous_state]
  end

  def desired_state=(_)
    nil
  end
end

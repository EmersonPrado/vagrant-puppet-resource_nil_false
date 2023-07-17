# frozen_string_literal: true

Puppet::Type.newtype(:setter_call) do
  @doc = <<-TYPE_DOC
    @summary Dummy type to test setter call depending on previous and desired states
    @example Test changing True to False
      setter_call { 'true_2_false':
        previous_state => true,
        desired_state  => false,
      }
    @param previous_state
      Previous state of test property of dummy resource
    @param desired_state
      Desired state of test property of dummy resource
  TYPE_DOC

  newparam(:title, namevar: true) do
    desc 'Resource title'
  end

  newparam(:previous_state) do
    desc 'Test property previous state'
  end

  newproperty(:desired_state) do
    desc 'Test property desired state'
  end
end

# Polisher Config Helper Mixin
#
# Licensed under the MIT license
# Copyright (C) 2013-2014 Red Hat, Inc.

module ConfHelpers
  module ClassMethods
    # Defines a 'config attribute' or attribute on the class
    # which this is defined in. Accessors to the single shared
    # attribute will be added to the class as well as instances
    # of the class. Specify the default value with the attr name
    # or via an env variable
    #
    # @example
    #   class Custom
    #     extend ConfHelpers
    #     conf_attr :data_dir, '/etc/'
    #   end
    #   Custom.data_dir # => '/etc/'
    #   ENV['POLISHER_DATA_DIR'] = '/usr/'
    #   Custom.data_dir # => '/usr/'
    #   Custom.data_dir == Custom.new.data_dir # => true
    #
    def conf_attr(name, default = nil)
      send(:define_singleton_method, name) do |*args|
        nvar = "@#{name}".intern
        current = self.instance_variable_get(nvar)
        envk    = "POLISHER_#{name.to_s.upcase}"
        instance_variable_set(nvar, default)    unless current
        instance_variable_set(nvar, ENV[envk])  if ENV.key?(envk)
        # TODO also allow vars to be able to be set from a conf file
        instance_variable_set(nvar, args.first) unless args.empty?
        instance_variable_get(nvar)
      end

      send(:define_method, name) do
        self.class.send(name)
      end
    end

    def cmd_available?(cmd)
      File.exist?(cmd) && File.executable?(cmd)
    end

    def require_cmd!(cmd)
      raise "command #{cmd} not available" unless cmd_available?(cmd)
    end # module ClassMethods
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def require_cmd!(cmd)
    self.class.require_cmd!(cmd)
  end
end

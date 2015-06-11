# Polisher missing_deps cli util
#
# Licensed under the MIT license
# Copyright (C) 2015 Red Hat, Inc.
###########################################################

require 'optparse'

def missing_deps_conf
  conf.merge!(default_conf)
      .merge!(targets_conf)
      .merge!(sources_conf)
end

def missing_deps_parser
  OptionParser.new do |opts|
    default_options opts
    targets_options opts
    sources_options opts
  end
end

def check_alt_dep(gem, dep)
  versions = Polisher::VersionChecker.versions_for(dep.name)
  puts "#{gem.name} #{gem.version} missing dep #{dep.name} #{dep.requirement} - alt versions: #{versions}"
end

def check_missing_deps(source)
  source.dependency_tree(:recursive => true,
                         :dev_deps  => conf[:devel_deps],
                         :matching  => conf[:matching]) do |gem, dep, resolved_dep|
    check_alt_dep(gem, dep) if resolved_dep.nil?
  end
end

def check_deps(conf)
  check_missing_deps(conf_source) if conf_gem? || conf_gemfile?
end

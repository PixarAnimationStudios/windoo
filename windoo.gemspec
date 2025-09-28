# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

proj_name = 'windoo'
require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|
  # General
  #####
  s.name        = proj_name
  s.version     = Windoo::VERSION
  s.authors     = ['Chris Lasell']
  s.email       = 'windoo@pixar.com'
  s.homepage    = 'https://github.com/PixarAnimationStudios/windoo'

  # s.license     = 'Nonstandard'
  s.license     = 'LicenseRef-LICENSE.txt'

  s.date        = Time.now.strftime('%F')
  s.summary     = 'Ruby interface to the REST API of the Jamf Title Editor, formerly known as Kinobi.'
  s.description = <<~EODDESC
    Windoo provides a Ruby interface to the REST API of the [Jamf Title Editor](https://docs.jamf.com/title-editor/documentation/About_Title_Editor.html), formerly known as 'Kinobi'. The Title Editor is a 'patch source' provided to users of Jamf Pro that provides a way to manage macOS software titles and their versions. Windoo allows ruby developers to interact with the Title Editor's API to automate tasks such as creating, updating, and managing patches and related resources.
  EODDESC

  # Files
  #####
  s.files = Dir['lib/**/*.rb']

  # Ruby version
  #####
  s.required_ruby_version = '>= 2.6.3'

  # Dependencies
  #####

  s.add_runtime_dependency 'pixar-ruby-extensions', '~>1.0'

  # https://github.com/fxn/zeitwerk MIT License (no dependencies)
  s.add_runtime_dependency 'zeitwerk', '~> 2.5'

  # https://github.com/lostisland/faraday: MIT License
  s.add_runtime_dependency 'faraday', '~> 2.8'

  # Rdoc
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt', 'CHANGES.md']
  s.rdoc_options << '--title' << 'Windoo' << '--line-numbers' << '--main' << 'README.md'
end

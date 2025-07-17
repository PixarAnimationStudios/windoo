# Copyright 2025 Pixar
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
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
  s.homepage    = 'http://pixaranimationstudios.github.io/depot3/'
  s.license     = 'Nonstandard'
  s.date        = Time.now.strftime('%F')
  s.summary     = 'Ruby interface to the REST API of the Jamf Title Editor, formerly known as Kinobi.'
  s.description = <<~EODDESC
    Mace Windu was a colleague of Obi-Wan Kenobi
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
  s.add_runtime_dependency 'zeitwerk', '~> 2.5', '>= 2.5.4'

  # https://github.com/lostisland/faraday: MIT License
  s.add_runtime_dependency 'faraday', '~> 2.8'

  # Rdoc
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt', 'CHANGES.md']
  s.rdoc_options << '--title' << 'Windoo' << '--line-numbers' << '--main' << 'README.md'
end

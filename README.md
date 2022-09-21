# Windu - a colleague of Kenobi

Windu provides a Ruby interface to the REST API of the Jamf Title Editor, formerly known as 'Kinobi'.

It works very much like ruby-jss.

Quick Summary:

```ruby
require 'windu'

url = 'https://chrisltest@xi3wix5y.appcatalog.jamfcloud.com'

Windu.connect url, pw: :prompt

t1 = Windu::API::SoftwareTitle.fetch softwareTitleId: 1
#  => #<Windu::API::SoftwareTitle:0x00007fdb478cdf00...
t1.name
#  => "Test"
t1.publisher
#  => "Pixar Animation Studios"
t1.id
#  => "com.pixar.test"
t1.enabled?
#  => false
t1.lastModified
#  => 2022-09-10 22:06:39 UTC
t1.currentVersion
#  => "5.2.3"
t1.patches.count
#  => 3
t1.patches.first.class
#  => Windu::API::Patch
t1.patches.first.version
#  => "5.2.3"
t1.patches.last.version
#  => "4.8.2"
t1.patches.first.killApps.first.appName
#  => "PixarTest"
t1.patches.first.killApps.first.bundleId
#  => "com.pixar.test"

t1.extensionAttributes.first.script
# #!/bin/zsh
#
# # true if the unix epoch is even, false if its odd
# [ $((`date +%s` % 2)) -eq 0 ]  && result=true || result=false
#
 # echo <result>$result</result>
```
More documentation is on the way
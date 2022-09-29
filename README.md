# Windu - a colleague of Kenobi

Windu provides a Ruby interface to the REST API of the Jamf Title Editor, formerly known as 'Kinobi'.

It works very much like [ruby-jss](http://pixaranimationstudios.github.io/ruby-jss/index.html), with a huge, important difference:

**Changes made to Ruby objects happen immediately on the server** There is no need to '.save' anything.

Another difference is that, for now anyway, there is only one 'default' connection to the server.  All server interaction happens using the default connection.

This means that, for now, you can't connect to multiple servers at the same time and pass around connection objects. This will probably change in future versions.

As with ruby-jss, the entire API is not implemented here, only the objects necessary to maintain Software Titles. For other purposes (Acct management, overall settings, etc) please use the Title Editor Web UI.

See also:
- [Documentation about using the Title Editor via its GUI WebApp](https://docs.jamf.com/title-editor/documentation/index.html)
- [Documentation about the underlying REST API used by Windu](https://developer.jamf.com/title-editor/reference)

Usage:

```ruby
require 'windu'

#### CONNECT
url = 'https://mylogin@a1b2c3d4.appcatalog.jamfcloud.com'

# Connect the default connection.
Windu.connect url, pw: :prompt

#### SOFTWARE TITLES
#####################################
# All access to API objects happens through the SoftewareTitle that contains them.
# So to work with Requirements, Patches, KillApps, ExtensionAttributes, etc... you must
# fetch or create the SoftwareTitle that they are a part of.

# Get an Array of Hashes with summary data about all existing SoftwareTitles
all_titles = Windu::SoftwareTitle.all

# Create a SoftwareTitle. This happens immediately on the server
test_title = Windu::SoftwareTitle.create(
  id: 'com.mycompany.windu.test-0-rama',
  name: 'Windu Test Oh Rama',
  publisher: 'My Company',
  currentVersion: '0.0.1b1'
)

# or fetch an existing one by softwareTitleId or 'id'
title = Windu::SoftwareTitle.fetch softwareTitleId: test_title.softwareTitleId
title = Windu::SoftwareTitle.fetch id: test_title.id

# update title attributes, these are immediately changed on the server
title.id = 'com.mycompany.windutest'
title.name = 'Windu Test'
title.publisher = 'My Company, Inc.'
title.currentVersion = '0.0.1a1'

# To delete the title, use 'title.delete'

#### EXTENSION ATTRIBUTES
#####################################

# add an extension attribute to the title, there can only be one per title
title.add_extensionAttribute(
  key: 'can-run-windu-test1',
  displayName: 'Can Run Windu Test1',
  script: "#!/bin/bash\necho <result>UBETCHA!</result>"
)

# update EA attributes
title.extensionAttribute.key = 'can-run-windu-test'
title.extensionAttribute.displayName = 'Can Run Windu Test'
title.extensionAttribute.script = "#!/bin/bash\necho <result>yes</result>"

# delete the EA with: title.delete_extensionAttribute

#### REQUIREMENTS - criteria identifying macs that have any version of this Title installed
#####################################

# add two requirements
title.requirements.add_criterion(
  name: 'Application Title',
  operator: 'is',
  value: 'WinduTest.app'
)

title.requirements.add_criterion(
  name: 'Application Bundle ID',
  operator: 'is',
  value: 'com.mycompany.windutest1',
  and_or: :or
)

# Criteria like these are used in requirements, patch capabilities, and patch component criteria
# Criteria are immutable, if you need to change one, you can replace it with a new one
# like this:

req_id = title.requirements.find_by_attr(:name, 'Application Bundle ID').requirementId

title.requirements.replace_criterion(
  req_id,
  name: 'Application Bundle ID',
  operator: 'is',
  value: 'com.mycompany.windutest',
  and_or: :or
)

# To delete a requirement: title.requirements.delete_criterion requirementId

#### PATCHES
#####################################

# add a patch
new_patch_id = title.patches.add_patch(
  version: '0.0.1a1',
  minimumOperatingSystem: '10.14.0',
  releaseDate: Time.now,
  reboot: false,
  standalone: true
)

# update attributes of a patch
title.patches.update_patch new_patch_id, version: '0.0.1a2', releaseDate: Time.now

# add another.  New patches are added to the front of the list by default, with the
# assumption that they are newer versions than the patches that already exist.
title.patches.add_patch(
  version: '0.0.1a3',
  minimumOperatingSystem: '10.14.4',
  releaseDate: Time.now
)

#### KILLAPPS
#####################################

# add a killApp to a patch
patch = title.patches.first

kaid = patch.killApps.add_killApp(
  appName: 'WinduTest.app',
  bundleId: 'com.mycompany.windutest1'
)

# Update a killApp attribute
patch.killApps.update_killApp  kaid, bundleId: 'com.pixartest.windutest'

# delete a killall
patch.killApps.delete_killApp kaid

##### CAPABILITIES - criteria identifying macs that can install/run this patch
#####################################

# Add some criteria...

patch.capabilities.add_criterion(
  name: 'Total RAM MB',
  operator: 'more than',
  value: 16_374
)

patch.capabilities.add_criterion(
  name: 'Computer Group',
  operator: 'member of',
  value: 'someGroupName'
)

patch.capabilities.add_criterion(
  name: 'Operating System Version',
  operator: 'greater than or equal',
  value: patch.minimumOperatingSystem
)

patch.capabilities.add_criterion(
  name: title.extensionAttribute.key, # must be the 'key' of the ext attr for this title
  operator: 'is',
  value: 'yes',
  type: 'extensionAttribute'
)

##### COMPONENT - including criteria identifying macs that have this patch installed
#####################################

# add one
patch.add_component(
  name: 'Windu SoftwareTitle Test',
  version: '0.0.1a5a'
)

# edit it to fix those values
patch.component.name =  title.name
patch.component.version = patch.version

patch.component.criteria.add_criterion(
  name: 'Application Title',
  operator: 'is',
  value: 'WinduTest.app'
)

patch.component.criteria.add_criterion(
  name: 'Application Bundle ID',
  operator: 'is',
  value: title.id
)

patch.component.criteria.add_criterion(
  name: 'Application Version',
  operator: 'is',
  value: patch.version
)

# Once the patch as at least one Capability, and its Component has at least on criterion,
# you can enable it
patch.enable

# Once your software title has at least on Requirement, and one enabled Patch, you can
# enable it too!
title.enable

```
More documentation is on the way
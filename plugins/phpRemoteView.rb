##
# This file is part of WhatWeb and may be subject to
# redistribution and commercial restrictions. Please see the WhatWeb
# web site for more information on licensing and terms of use.
# http://www.morningstarsecurity.com/research/whatweb
##
Plugin.define "phpRemoteView" do
author "Brendan Coles <bcoles@gmail.com>" # 2011-05-24
version "0.1"
description "phpRemoteView - web backdoor - allows users to browse the filesystem, edit files on the server, execute PHP code, or Shell commands, etc. Works on Windows and Unix servers - Homepage: http://php.spb.ru/remview/"

# Google results as at 2011-05-24 #
# 72 for intitle:"phpRemoteView: " +perms

# Dorks #
dorks [
'intitle:"phpRemoteView: " "perms"'
]

# Examples #
examples %w|
loraart.ru/SamyGO/redaktor/index.php
aodaitimhue.com/hack/rem_view.php
codecrew.110mb.com/index.php
www.themovement.info/Images/maln.php
rukinoshnik.info/index.php
www.marestan.com/theme/imgs.php
www.wz.lviv.ua/image/4225/news/rsmv.php
www.gremlinsolutions.co.uk/rem.php
scumdesign.ru/wp-content/plugins/hello.php
rastest.fatal.ru
pomagamy.portowcy.org/vcart.php
|

# Matches #
matches [

# Filepath Detection
{ :certainty=>75, :filepath=>/<title>phpRemoteView: ([^<]+)<\/title>/ },

# Version Detection
{ :version=>/<font size=1 style='Font: 8pt Verdana'>phpRemoteView &copy; Dmitry Borodin \(version ([\d]{4}-[\d]{2}-[\d]{2})\)<br>/ },

# Index of HTML
{ :certainty=>75, :text=>"'><font face=fixedsys size=+2>*</font></a><font size=5><b>Index of</b></font>" },

]

end


##
# This file is part of WhatWeb and may be subject to
# redistribution and commercial restrictions. Please see the WhatWeb
# web site for more information on licensing and terms of use.
# http://www.morningstarsecurity.com/research/whatweb
##
Plugin.define "Jcow" do
author "Brendan Coles <bcoles@gmail.com>" # 2011-05-20
version "0.1"
description "Jcow - social networking - Homepage: http://www.jcow.net/"

# Google results as at 2011-05-20 #
# 161 for "Go to" "Admin CP" "Themes" "Username or Email" "Manage Blocks"

# Dorks #
dorks [
'"Go to" "Admin CP" "Themes" "Username or Email" "Manage Blocks"'
]

# Examples #
examples %w|
demo.jcow.net
jcow.pv.biz
indoflit.co.cc
shiftysplayground.co.cc
salingcela.co.cc
japemete.tk
online-flower-delivery.co.cc
www.supyall.com
www.chatmax.my3host.tk
www.snindia.com
www.esindhis.com
mystrudel.com
bombaylist.com/jcow/
www.justbieb.com
realestatesbb.com
www.follow.id.gp
www.escort4.me
social636.com
www.inscienet.org
www.thejdsbook.com
mysociallife.mack-christian-network.org
|

# Matches #
matches [

# Version Detection # Meta Generator
{ :version=>/<meta name="Generator" content="Jcow Social Networking Software\. ([\d\.]+)" \/>/ },

# Version Detection # Powered by footer
{ :version=>/Powered by <a href="http:\/\/www\.jcow\.net" title="Social Networking Software, Community Software" target="_blank"><strong>Jcow<\/strong> ([\d\.]+)<\/a>/ },

# Meta Generator
{ :text=>'<meta name="Generator" content="Powered by Jcow" />' },

# HTML Comments
{ :text=>'<!-- do NOT remove the Jcow Attribution Information -->' },
{ :text=>'<!-- jcow branding -->' },
{ :text=>'<!-- end jcow_application_box -->' },

]

end


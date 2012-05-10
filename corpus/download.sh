#!/bin/bash

# C projects
# mkdir c
# cd c
 
# wget ftp://ftp.fu-berlin.de/pc/games/idgames/source/doomsrc.zip # Doom
# wget ftp://ftp.idsoftware.com/idstuff/source/q1source.zip       # Quake 1
# wget ftp://ftp.idsoftware.com/idstuff/source/quake2.zip         # Quake 2
# wget ftp://ftp.idsoftware.com/idstuff/source/wolfsrc.zip        # Wolfenstein

# cd ..

# Java projects
mkdir java
cd java

git clone git://github.com/jbossas/jboss-as.git jboss
git clone git://github.com/bytemanproject/byteman.git jboss-byteman
git clone git://github.com/droolsjbpm/drools.git jboss-drools
git clone git://github.com/hibernate/hibernate-orm.git hibernate
git clone git://github.com/SpringSource/spring-framework.git spring-framework

svn checkout http://svn.apache.org/repos/asf/nutch/trunk nutch
svn checkout http://svn.apache.org/repos/asf/hadoop/common/trunk/hadoop-common-project hadoop-common
svn checkout http://svn.apache.org/repos/asf/mahout/trunk mahout
svn checkout http://svn.apache.org/repos/asf/hive/trunk hive
svn checkout http://svn.apache.org/repos/asf/lucene/dev/trunk/lucene lucene
svn checkout http://svn.apache.org/repos/asf/lucene/dev/trunk/solr solr
svn checkout https://svn.apache.org/repos/asf/tapestry/tapestry5/trunk tapestry
svn checkout http://svn.codehaus.org/xstream/trunk xstream
svn checkout https://htmlunit.svn.sourceforge.net/svnroot/htmlunit/trunk htmlunit

cd ..

# .Net projects
mkdir dotnet
cd dotnet

svn checkout https://json.svn.codeplex.com/svn/trunk json-net
svn checkout https://wbfsmanager.svn.codeplex.com/svn/WBFSManager/trunk wbfs-manager
svn checkout https://virtualrouter.svn.codeplex.com/svn virtualrouter
svn checkout https://imageresizer.svn.codeplex.com/svn imageresizer
svn checkout https://de.svn.codeplex.com/svn/trunk/DroidExplorer droidexplorer
svn checkout https://bibword.svn.codeplex.com/svn bibword
svn checkout https://htmlagilitypack.svn.codeplex.com/svn/Trunk htmlagility
svn checkout https://pcapdotnet.svn.codeplex.com/svn pcap-net
svn checkout https://ituner.svn.codeplex.com/svn ituner

cd ..

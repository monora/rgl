# 
#  make test   - run the tests
#  make clean  - tidy up
#

LIB=./lib
RGL=rgl-$(VERSION)
BOOST_DOC=http://www.boost.org/libs/graph/doc

default: test
test:
	cd tests && ruby -I../lib runtests.rb

# Release must have VERSION variable set
#
#    make VERSION=0.2 release
#

release: doc stamp clean tar

ftpput: ${RGL}.tgz
	ftpput.rb $<

releasedoc: doc
	rm -f htdocs
	ln -fs doc htdocs
	tar --dereference --exclude='*.bak' -czf htdocs.tgz htdocs
	rm htdocs
	scp htdocs.tgz monora@rgl.sf.net:/home/groups/r/rg/rgl

stamp:
		ruby -i.bak -pe 'sub!(/V\d+(\.\d+)+/, "V$(VERSION)") if /_VERSION =/' ${LIB}/rgl/base.rb
		rm ${LIB}/rgl/base.rb.bak
		cvs commit
		cvs rtag `echo V$(VERSION) | sed s/\\\\./_/g` rgl

doc: ${LIB}/rgl/*.rb README
#	cd ${LIB} && rdoc --diagram --fileboxes --title RGL --main rgl/base.rb --op ../doc
	cd ${LIB} && rdoc.bat --title RGL --main rgl/base.rb --op ../doc
	cp examples/*.jpg doc
	find doc -name \*.html -print | xargs	ruby -i.bak -pe 'sub!(/BOOST_DOC.(.*.html)/,"<a href=${BOOST_DOC}/\\1>\\1<a>")'

install:
	ruby install.rb

tags:
	 rtags `find ${LIB} -name  '*.rb'`

tar: test
		ln -fs rgl ../${RGL}
		tar --directory=..			\
			--create			\
			--dereference			\
			--file=${RGL}.tgz 	\
			--gzip 			\
			--exclude='CVS' 		\
			--exclude='cvs' 		\
			--exclude='misc' 		\
			--exclude='doc' 		\
			--exclude='homepage' 		\
			--exclude='*.tgz' 		\
			--exclude='*/.*'		\
			${RGL}
		rm ../${RGL}

clean:
		rm -rf rgl*.tgz graph.dot TAGS examples/*/*.dot
		find . -name \*~ -print | xargs rm -f
		find . -name \*.bak -print | xargs rm -f
		find . -name core -print | xargs rm -f


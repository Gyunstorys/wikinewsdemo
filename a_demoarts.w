m4_include(inst.m4)m4_dnl
\documentclass[twoside]{rapport3}
\newcommand{\thedoctitle}{m4_doctitle}
\newcommand{\theauthor}{m4_author}
\newcommand{\thesubject}{m4_subject}
\title{\thedoctitle}
\author{\theauthor}
m4_include(texinclusions.m4)m4_dnl
\begin{document}
\maketitle
\begin{abstract}
  
\end{abstract}
\tableofcontents
%
% Replace this chapter by your own material
%

\chapter{Introduction}
\label{chap:introduction}

Make the following scripts:

\begin{enumerate}
\item A script to generate a project, a medium and an articleset.
\item A script to scrape articles from \verb|m4_articlesource|.
\item A script to serialize the articles.
\item A script to deserialize the articles.
\item A demo script that runs everything and that proves that it works.
\end{enumerate}

\section{The script that runs everything}
\label{sec:everythingscript}


\textbf{NOTE:} assumes that Amcat has been installed in directory \verb|~/amcat|.

@o ../wikinewsdemo @{@%
<!#!>!/bin/bash
<!#!> wikinewsdemo -- generate Amcat project with news-articles in it.
<!#!> m4_header
@< set amcat parameters @>
@< renew the database @>
@< create a project and a medium @>
@< scrape articles @>
@< serialize the articles @>
@< renew the database @>
@< create a project and a medium @>
@< deserialize the articles @>
cd \$OLDD
@| @}

@d set amcat parameters @{@%
OLDD=`pwd`
AMCATDIR=m4_amcatdir
<!#!>cd \$AMCATDIR
PYTHONPATH=\$AMCATDIR
DJANGO_SETTINGS_MODULE='settings'
@| AMCATDIR PYTHONPATH @}

@d run manage.py @{@%
cd \$AMCATDIR
./manage.py @1
cd \$OLDD
@| @}

@d renew the database @{@%
dropdb amcat
createdb amcat
@< run manage.py @(syncdb@) @>
@| @}



\section{Create a demo project environment}
\label{sec:createdemoenv}

The structure of Amcat is, that there are projects in which articles
are managed. The articles are grouped in article-sets. An article-set
contains a number of articles collected from a certain medium. So, to
generate a project with articles, we have to generate a project object, a
medium object (specifying a language) and an articleset object. Note
that the scraper generates a medium named \verb|m4_mediumname| and
uses that if it is not available. Therefore we have to generate a
medium with this name. Script
\verb|m4_democreate_py| does that for us. Furthermore, part of the
project is, to store the articles as objects in an archive file.
Let us first specify names for the entities involved in this demo-project.

@%@d store projectname, mediumname and articlename in python variables @{@%
@d names of entities in this python project @{@%
projectname='m4_projectname'
projectdescription='m4_projectdescription'
setname='m4_setname'
mediumname='m4_mediumname'
mediumabb='m4_mediumabb'
archivename='m4_serialised_articlefile'
@| projectname projectdescription setname mediumname mediumabb archivename @}



@d create a project and a medium @{@%
@< run a self-invented python script @(m4_democreate_py@) @>
@| @}


@o ../m4_democreate_py @{@%
<!#!>!/usr/bin/python
<!#!> m4_democreate_py -- generate an Amcat demo project with news-articles.
@< opening of python file @>
@< names of entities in this python project @>
@< packages that m4_democreate_py_ loads @>
@%@< variables of m4_democreate_py_ @>
@< method to create a wikinews project @>
@< method to create a wikinews medium @>
@%@< method to create a wikinews articleset @>
@< perform the creation of the demo environment @>
@| @}


Create a project. A project must be linked to a user and to a role
(permissions) that this user has with respect to the project. Right
after the installation of Amcat there exists a user named ``amcat'' and
there exists a \verb|read/write| role. So, find this user and that role
and create the project using them. There is also something called
``ProjectRole'', that links projects, roles and user. I do not yet
know how this works precisely, but anyhow, it has to be defined.

@d method to create a wikinews project @{@%
def create_demoproject(projectname, projdescription):
    amcatuser = User.objects.get(username='amcat')
    amcatrole = Role.objects.get(label='read/write', projectlevel=True)
    p = Project.objects.create( insert_user=amcatuser
                              , name = projectname
                              , guest_role=amcatrole
                              , owner = amcatuser
                              , active =  True
                              , description = projectdescription
                              )
    pr = ProjectRole(project=p, user=amcatuser)
    pr.role = Role.objects.get(projectlevel=True, label='admin')
    pr.save()
    p.save()
    return p

@|create_demoproject @}

Load the packages for the Django models User, Role, Project:

@d packages that m4_democreate_py_ loads @{@%
from amcat.models.authorisation import Role, ProjectRole
from django.contrib.auth.models import User
from amcat.models.project import Project
@| @}



@d perform the creation of the demo environment @{@%
demoproject = create_demoproject(projectname, projectdescription)
@| demoproject @}


Create a medium for the articles. The medium specifies a language as
another object in the Django system. On initialization of the Amcat
database objects have been generated for the languages ``nl'', ``en''
and ``de''. (How to find this out? Run \verb|psql| and perform the
\textsc{sql} query ``select * from languages;''). Pass the language
object, the name and the abbreviated name (max.~10~characters long) to
the medium object to be created.

@d method to create a wikinews medium @{@%
def create_demo_medium(demoproject, mediumname, abbrevname):
    l = Language.objects.get(label='en')
    s = Medium.objects.create( name = mediumname
                             , abbrev = abbrevname
                             , language = l
                             )
    s.save()
    return s

@| create_demo_medium @}

@d packages that m4_democreate_py_ loads @{@%
from amcat.models.language import Language
from amcat.models.medium import Medium, get_or_create_medium
@| @}



Use the above method:

@d perform the creation of the demo environment @{@%
medium = create_demo_medium(demoproject, mediumname, mediumabb)
@| medium @}


@%Create an article-set object with a proper name and specify the project
@%to which it belongs and a name for the ``provenance''.
@%
@%@d method to create a wikinews articleset @{@%
@%def create_demo_articleset(demoproject, setname):
@%    s = ArticleSet.objects.create( name = setname
@%                                 , project = demoproject
@%                                 , provenance =  "Wiki"
@%                                 )
@%    s.save()
@%    return s
@%
@%
@%@| create_demo_articleset provenance @}
@%
@%@d packages that m4_democreate_py_ loads @{@%
@%from amcat.models.articleset import ArticleSet, get_or_create_articleset
@%@| @}
@%
@%@d perform the creation of the demo environment @{@%
@%articleset = create_demo_articleset(demoproject, setname)
@%
@%@| articleset @}

\section{Scrape articles}
\label{sec:scrape}

Previously we created a Python script that scrapes the articles from
\url{http://m4_articlesource}. Use this script to scrape. The help
response of this script says:

\begin{verbatim}
usage: en_wikinews_org_scraper.py [-h] [--articleset articleset]
                                  [--articleset_name articleset_name]
                                  [--verbose]
                                  project
\end{verbatim}

So, we have to supply an articleset and a project. Some experimenting
reveals that the script works when we pass the name of an articleset
that that does not yet exist and the \verb|id| of a project. In our
testcase the id of the project is unity.  Hence:

@d scrape articles @{@%
@%@< run a self-invented python script @(m4_scrape_py@) @>
python m4_scraperdir/m4_scraperscript --articleset_name m4_setname m4_projectid
@| @}

\section{Serialize/deserialize the articles}
\label{sec:serialize}

Script \verb|m4_serialize_py| serializes the scraped articles into
file \verb|m4_serialised_articlefile| and
script \verb|m4_deserialize_py| restores them. 

@d serialize the articles @{@%
@< run a self-invented python script @(m4_serialize_py@) @>
@| @}

The articles must be stored in an articleset. 

@d deserialize the articles @{@%
@< run a self-invented python script @(m4_deserialize_py@) @>
@| @}


@o ../m4_serialize_py @{@%
<!#!>!/usr/bin/python
<!#!> serialize_articles.py -- serialize demo articles 
@< opening of python file @>
@< names of entities in this python project @>
@< python packages for serializing/deserializing articles @>
@< the method to serialize something @>
@%serialize_something(Project, "wikinews.projects.json")
@%serialize_something(Medium, "wikinews.media.json")
@%serialize_something(ArticleSet, "wikinews.articlesets.json")
serialize_something(Article, "m4_serialised_articlefile")

@| @}

@o ../m4_deserialize_py @{@%
<!#!>!/usr/bin/python
<!#!> m4_deserialize_py -- extract articleset from a serialized string
@< opening of python file @>
@< names of entities in this python project @>
@< python packages for serializing/deserializing articles @>
@%@< get name of articleset @>
@%import json
@%from django.core import serializers
@%#from django.utils.functional import Promise
@%#from django.utils.encoding import force_text
@%from django.contrib.auth.models import User
@%from amcat.models.authorisation import Role, ProjectRole
@%from amcat.models.project import Project
@%from amcat.models.articleset import ArticleSet, get_or_create_articleset
@%from amcat.models.article import Article
@%from amcat.models.medium import Medium, get_or_create_medium
@%from amcat.models.language import Language
@%from sys import argv
@%projname='m4_projectname'
@%projdescription='A demo-project containing some articles.'
@%setname='m4_setname'
@%archivename='m4_serialised_articlefile'
@%mediumname='en.wikinews.org'
@%mediumabb='enwikinews'
@%
@%script, projname = argv
@%def deserialize_something(serieclass, filnam):
@%   f = open(filnam, 'r')
@%   data=f.read()
@%   f.close()
@%   for obj in serializers.deserialize("json", data):
@%      obj.save()
@< method to deserialize articles @>
@%# Create a demo-project.
@%# Still to find out:
@%
@%def create_demoproject(projname, projdescription):
@%    amcatuser = User.objects.get(username='amcat')
@%    amcatrole = Role.objects.get(label='read/write', projectlevel=True)
@%#    p = Project(name=projname)
@%    p = Project.objects.create( insert_user=amcatuser
@%                              , name = projname
@%                              , guest_role=amcatrole
@%                              , owner = amcatuser
@%                              , active =  True
@%                              , description =  "Test insert user"
@%                              )
@%    pr = ProjectRole(project=p, user=amcatuser)
@%    pr.role = Role.objects.get(projectlevel=True, label='admin')
@%    pr.save()
@%
@%    p.save()
@%    return p
@%
@%def create_demo_articleset(demoproject, setname):
@%    s = ArticleSet.objects.create( name = setname
@%                                 , project = demoproject
@%                                 , provenance =  "Wiki"
@%                                 )
@%    s.save()
@%    return s
@%
@%def create_demo_medium(demoproject, mediumname, abbrevname):
@%    l = Language.objects.get(label='en')
@%    s = Medium.objects.create( name = mediumname
@%                             , abbrev = abbrevname
@%                             , language = l
@%                             )
@%    s.save()
@%    return s

@%demoproject = create_demoproject(projname, projdescription)
@%articleset = create_demo_articleset(demoproject, setname)
@%medium = create_demo_medium(demoproject, mediumname, mediumabb)
@%deserialize_articles(archivename, demoproject, articleset)

@%#deserialize_something(Project   , "wikinews.projects.json"   )
@%#deserialize_something(Medium    , "wikinews.media.json"      )
@%#deserialize_something(ArticleSet, "wikinews.articlesets.json")
@%#deserialize_something(Article   , "wikinews.articles.json"   )

@< get the articleset in which to store the articles @(articleset@) @>
deserialize_articles(archivename, articleset)

@| @}

@%@d get name of articleset @{@%
@%from getargs import *
@%arglist=(
@%        )
@%@| @}



@d python packages for serializing/deserializing articles @{@%
import json
from django.core import serializers
from amcat.models.articleset import ArticleSet, get_or_create_articleset
from amcat.models.article import Article
from amcat.models.project import Project
from amcat.models.medium import Medium
@| @}

@d the method to serialize something @{@%
def serialize_something(serieclass, filnam):
   data = serializers.serialize("json", serieclass.objects.all())
   f = open(filnam, 'w')
   f.write(data)
   f.close()

@| @}

Deserialize the articles and connect them to the articleset. It seems
not possible to perform this connection with the article object as it
is obtained from the deserializer. So, to perform the connection, save
the deserialized object, retrieve it (identified by \texttt{pk}) and
add the retrieved object to the articleset.

@d  method to deserialize articles @{@%
def deserialize_articles(filnam, articleset):
        f = open(filnam, 'r')
        data=f.read()
        f.close()
        result = []
        for art in serializers.deserialize("json", data):
           apk = art.object.pk
           art.save()
           a2=Article.objects.get(pk=apk)
           result.append(a2)
        articleset.add_articles(result)

@| @}

Get the proper ArticleSet object: 

@d get the articleset in which to store the articles @{@%
p = Project.objects.get(name=projectname)
@%@1=ArticleSet.get_or_create_articleset(setname, p)
@1=get_or_create_articleset(setname, p)
@%@1=ArticleSet.objects.get(name=setname)
@| @}

\section{Problems}
\label{sec:problems}

The problem with serializing and deserializing is, that on
deserializing objects it is assumed that the environment in Amcat is
identical to that when the objects had been serialized. For instance,
article objects contain pointers to project objects, but on
deserializing these project objects may not exist at all.




\chapter{The programs}
\label{chap:programs}

\begin{itemize}
\item A script to perform everything
\item A python program to generate a project that contains articles from \verb|en.wikinews.org|
\item A python script to serialize the project with the articles
\item A python script to install the project in a fresh amcat installation
\end{itemize}

\section{Get example documents}
\label{sec:getdocs}



\appendix

\chapter{Miscellaneous}
\label{chap:misc}

@d opening of python file @{@%
<!#!> m4_header
from __future__ import unicode_literals, print_function, absolute_import
###########################################################################
#          (C) Vrije Universiteit, Amsterdam (the Netherlands)            #
#                                                                         #
# This file is part of AmCAT - The Amsterdam Content Analysis Toolkit     #
#                                                                         #
# AmCAT is free software: you can redistribute it and/or modify it under  #
# the terms of the GNU Affero General Public License as published by the  #
# Free Software Foundation, either version 3 of the License, or (at your  #
# option) any later version.                                              #
#                                                                         #
# AmCAT is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or   #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public     #
# License for more details.                                               #
#                                                                         #
# You should have received a copy of the GNU Affero General Public        #
# License along with AmCAT.  If not, see <http://www.gnu.org/licenses/>.  #
###########################################################################
@| @}

@d run a self-invented python script @{@%
chmod 775 ./@1
./@1
@| @}



\chapter{Translate and run}
\label{chap:transrun}

This chapter assembles the Makefile for this project.

@o Makefile -t @{@%
@< default target @>

@< parameters in Makefile @> 

@< impliciete make regels @>
@< expliciete make regels @>
@< make targets @>
@| @}

The default target of make is \verb|all|.

@d  default target @{@%
all : @< all targets @>
.PHONY : all

@|PHONY all @}

One of the targets is certainly the \textsc{pdf} version of this
document.

revert-buffer
@d all targets @{m4_progname.pdf@}

We use many suffixes that were not known by the C-programmers who
constructed the \texttt{make} utility. Add these suffixes to the list.

@d parameters in Makefile @{@%
.SUFFIXES: .pdf .w .tex .html .aux .log

@| SUFFIXES @}



\section{Pre-processing}
\label{sec:pre-processing}

To make usable things from the raw input \verb|a_`'m4_progname`'.w|, do the following:

\begin{enumerate}
\item Process \verb|\$| characters.
\item Run the m4 pre-processor.
\item Run nuweb.
\end{enumerate}

This results in a \LaTeX{} file, that can be converted into a \pdf{}
or a \html{} document, and in the program sources and scripts.

\subsection{Process `dollar' characters }
\label{sec:procdollars}

Many ``intelligent'' \TeX{} editors (e.g.\ the auctex utility of
Emacs) handle \verb|\$| characters as special, to switch into
mathematics mode. This is irritating in program texts, that often
contain \verb|\$| characters as well. Therefore, we make a stub, that
translates the two-character sequence \verb|\\$| into the single
\verb|\$| character.

@d expliciete make regels @{@%
m4_`'m4_progname`'.w : a_`'m4_progname`'.w
	gawk '{gsub(/[\\][\\$\$]/, "$$");print}' a_`'m4_progname`'.w > m4_`'m4_progname`'.w

@% $
@| @}

Run the M4 pre-processor:

@d  expliciete make regels @{@%
m4_progname`'.w : m4_`'m4_progname`'.w
	m4 -P m4_`'m4_progname`'.w > m4_progname`'.w

@| @}

\section{Typeset this document}
\label{sec:typeset}

Enable the following:
\begin{enumerate}
\item Create a \pdf{} document.
\item Print the typeset document.
\item View the typeset document with a viewer.
\end{enumerate}

In the three items, a typeset \pdf{} document is required or it is the
requirement itself.

Make a \pdf{} document.

@d make targets @{@%
pdf : m4_progname.pdf

print : m4_progname.pdf
	m4_printpdf(m4_progname)

view : m4_progname.pdf
	m4_viewpdf(m4_progname)

@| pdf view print @}

Create the \pdf{} document. This may involve multiple runs of nuweb,
the \LaTeX{} processor and the bib\TeX{} processor, and dpends on the
state of the \verb|aux| file that the \LaTeX{} processor creates as a
by-product. Therefore, this is performed in a separate script,
\verb|w2pdf|.

\subsubsection{The w2pdf script}
\label{sec:w2pdf}

The three processors nuweb, \LaTeX{} and bib\TeX{} are
intertwined. \LaTeX{} and bib\TeX{} create parameters or change the
value of parameters, and write them in an auxiliary file. The other
processors may need those values to produce the correct output. The
\LaTeX{} processor may even need the parameters in a second
run. Therefore, consider the creation of the (\pdf) document finished
when none of the processors causes the auxiliary file to change. This
is performed by a shell script \verb|w2pdf|

Note, that in the following \texttt{make} construct, the implicit rule
\verb|.w.pdf| is not used. It turned out, that make did not calculate
the dependencies correctly when I did use this rule.

@d  impliciete make regels@{@%
@%.w.pdf :
%.pdf : %.w \$(W2PDF)
	chmod 775 \$(W2PDF)
	\$(W2PDF) \$*

@| @}

@d parameters in Makefile @{@%
W2PDF=./w2pdf
@| @}

@d expliciete make regels  @{@%
\$(W2PDF) : m4_progname.w
	nuweb m4_progname.w
@| @}

@o w2pdf @{@%
#!/bin/bash
# w2pdf -- make a pdf file from a nuweb file
# usage: w2pdf [filename]
#  [filename]: Name of the nuweb source file.
<!#!> m4_header
echo "translate " \$1 >w2pdf.log
@< filenames in w2pdf @>

@< perform the task of w2pdf @>

@| @}

The script retains a copy of the latest version of the auxiliary file.
Then it runs the three processors nuweb, \LaTeX{} and bib\TeX{}, until
they do not change the auxiliary file. 

@d perform the task of w2pdf @{@%
@< run the processors until the aux file remains unchanged @>
@< remove the copy of the aux file @>
@| @}

The user provides the name of the nuweb file as argument. Strip the
extension (e.g.\ \verb|.w|) from the filename and create the names of
the \LaTeX{} file (ends with \verb|.tex|), the auxiliary file (ends
with \verb|.aux|) and the copy of the auxiliary file (add \verb|old.|
as a prefix to the auxiliary filename).

@d filenames in w2pdf @{@%
nufil=\$1
trunk=\${1%%.*}
texfil=\${trunk}.tex
auxfil=\${trunk}.aux
oldaux=old.\${trunk}.aux
@| nufil trunk texfil auxfil oldaux @}

Remove the old copy if it is no longer needed.
@d remove the copy of the aux file @{@%
rm \$oldaux
@| @}

Run the three processors. Do not use the option \verb|-o| (to suppres
generation of program sources) for nuweb,  because \verb|w2pdf| must
be kept up to date as well.

@d run the three processors @{@%
nuweb \$nufil
m4_latex(\$texfil)
bibtex \$trunk
@| nuweb pdflatex bibtex @}


Repeat to copy the auxiliary file an run the processors until the
auxiliary and a copy do both exist and are equal to each other.

@d run the processors until the aux file remains unchanged @{@%
while
 ! cmp -s \$auxfil \$oldaux
do
  if [ -e \$auxfil ]
  then
   cp \$auxfil \$oldaux
  fi
  @< run the three processors @>
done
@| @}

\subsubsection{create the program sources}
\label{sec:createsources}

Run nuweb, but suppress the creation of the \LaTeX{}
documentation. Nuweb creates only sources that do not yet exist or
that have been modified. Therefore make does not have to check this. 

@d make targets @{@%
sources : m4_progname.w
	nuweb -t m4_progname.w
@%@< make executables executable @>

@| @}

\chapter{Indexes}
\label{chap:indexes}


\section{Filenames}
\label{sec:filenames}

@f

\section{Macro's}
\label{sec:macros}

@m

\section{Variables}
\label{sec:veriables}

@u

\end{document}

% Local IspellDict: british 

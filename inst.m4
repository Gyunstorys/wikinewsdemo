m4_define(m4_progname, `demoarts')m4_dnl
m4_define(m4_doctitle, `Demo-project')m4_dnl
m4_define(m4_author, `Paul Huygen <p.e.m.huygen@@cli.vu>')m4_dnl
m4_define(m4_subject, `demoproject')m4_dnl
m4_dnl
m4_dnl System-dependent definitions
m4_dnl
m4_define(m4_printpdf, `lpr '$1`.pdf')m4_dnl
m4_define(m4_viewpdf, `xpdf '$1`.pdf')m4_dnl
m4_define(m4_latex, `pdflatex '$1)m4_dnl
m4_dnl
m4_dnl (style) things that probably do not have to be modified
m4_dnl
m4_changequote(`?',`!')m4_dnl
m4_define(m4_header, ?m4_esyscmd(date +'%Y%m%d at %H%Mh'| tr -d '\012'): Generated by nuweb from a_!m4_progname?.w!)
m4_changequote(?`!,?'!)m4_dnl
m4_define(m4_articlesource, `en.wikinews.org')m4_dnl
m4_define(m4_articleabb, `enwikinews')m4_dnl
m4_define(m4_articlesource, `en.wikinews.org')m4_dnl
m4_define(m4_articleabb, `enwikinews')m4_dnl
m4_define(m4_democreate_py, `create_demo_environment.py')m4_dnl
m4_define(m4_democreate_py_, `create\_demo\_environment.py')m4_dnl
m4_define(m4_projectname,`wikiproject')m4_dnl
m4_define(m4_projectdescription,`Demo with news-articles from m4_articlesource')m4_dnl
m4_define(m4_setname,`enwiki')m4_dnl
m4_dnl m4_define(m4_mediumname, `m4_articlesource')m4_dnl
m4_dnl m4_define(m4_mediumabb, `m4_articleabb')m4_dnl
m4_define(m4_mediumname, `wikinews')m4_dnl
m4_define(m4_mediumabb, `wikinews')m4_dnl
m4_define(m4_scraperdir, `~/amcatscraping/news')m4_dnl
m4_define(m4_scraperscript, `en_wikinews_org_scraper.py')m4_dnl
m4_define(m4_projectid, `1')m4_dnl
m4_define(m4_serialize_py, `serialize_articles.py')m4_dnl
m4_define(m4_serialize_py_, `serialize\_articles.py')m4_dnl
m4_define(m4_deserialize_py, `deserialize_articles.py')m4_dnl
m4_define(m4_deserialize_py_, `deserialize\_articles.py')m4_dnl
m4_define(m4_serialised_articlefile, `en_wikinews_articles.json')m4_dnl
m4_changequote(`<!',`!>')m4_dnl

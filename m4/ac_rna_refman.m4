# RNA_ENABLE_DOXYGEN_REFMAN(PROJECT_NAME, [config-file], [documentation-output-directory])
#
#




AC_DEFUN([RNA_ENABLE_DOXYGEN_REFMAN],[

    AC_REQUIRE([RNA_LATEX_ENVIRONMENT])

RNA_ADD_PACKAGE([doc_pdf],
                [PDF RNAlib reference manual],
                [yes])
RNA_ADD_PACKAGE([doc_html],
                [HTML RNAlib reference manual],
                [yes])
RNA_ADD_PACKAGE([doc],
                [RNAlib reference manual],
                [yes],
                [ with_doc=no
                  with_doc_pdf=no
                  with_doc_html=no],
                [])


AC_PATH_PROG(doxygen, [doxygen],no)
AC_PATH_PROG(dot,[dot],no)
AC_PATH_PROG(grep,[grep],no)
AC_PATH_PROG(perl,[perl],no)
AC_CHECK_PROGS([SPHINXBUILD], [sphinx-build sphinx-build3], [no])

# check whether we are able to generate the doxygen documentation
RNA_PACKAGE_IF_ENABLED([doc],[
  if test "x$doxygen" != xno;
  then
    if test "x$perl" = xno;
    then
      AC_MSG_WARN([perl command not found on your system!])
      AC_MSG_WARN([deactivating automatic (re)generation of reference manual!])
      doxygen_failed="perl command is missing!"
      doxygen=no
    fi
  else
    doxygen_failed="doxygen command is missing!"
  fi

  AS_IF([test "x$SPHINXBUILD" = xno],
        [
          AC_MSG_WARN(sphinx-build is required to build the reference manual)
          sphinx_failed="(sphinx-build unavailable)"
          with_doc=no
        ])
  RNA_PACKAGE_IF_DISABLED([python],
        [
          AC_MSG_WARN(Python module build required to build the reference manual)
          sphinx_failed="Python module not to be build"
          with_doc=no
        ])

])


# setup everything in order to generate the doxygen configfile

RNA_PACKAGE_IF_ENABLED([doc],[

  AC_SUBST([DOXYGEN_PROJECT_NAME], [$1-$PACKAGE_VERSION])
  AC_SUBST([DOXYGEN_SRCDIR], [$srcdir])
  AC_SUBST([SPHINX_SRCDIR], [doc/source])
  AC_SUBST([DOXYGEN_DOCDIR], [ifelse([$3], [], [doc/doxygen], [$3])])
  AC_SUBST([DOXYGEN_CONF], [ifelse([$2], [], [doxygen.conf], [$2])])


# prepare the config file for doxygen if we are able to generate a reference manual
  if test "x$doxygen" != xno;
  then

    AC_SUBST([DOXYGEN_CMD_LATEX], ["$LATEX_CMD -interaction=nonstopmode -halt-on-error"])
    AC_SUBST([DOXYGEN_CMD_BIBTEX], [$BIBTEX_CMD])
    AC_SUBST([DOXYGEN_CMD_MAKEINDEX], [$MAKEINDEX_CMD])
    AC_SUBST([DOXYGEN_HAVE_DOT],[ifelse([$dot], [no], [NO], [YES])])

    AC_CONFIG_FILES([${DOXYGEN_DOCDIR}/${DOXYGEN_CONF}])
    AC_CONFIG_FILES([doc/conf.py])
    AC_CONFIG_FILES([${SPHINX_SRCDIR}/conf.py])
    AC_CONFIG_FILES([${SPHINX_SRCDIR}/install.rst])

  else

# otherwise check if a generated reference manual already exists

    RNA_PACKAGE_IF_ENABLED([doc_pdf],[
      AC_RNA_TEST_FILE( [$DOXYGEN_DOCDIR/$DOXYGEN_PROJECT_NAME.pdf],
                        [with_doc_pdf=yes],
                        [with_doc_pdf=no
                         doc_pdf_failed="($doxygen_failed)"])])

    RNA_PACKAGE_IF_ENABLED([doc_html],[
      AC_RNA_TEST_FILE( [$DOXYGEN_DOCDIR/html/index.html],
                        [with_doc_html=yes],
                        [with_doc_html=no
                         doc_html_failed="($doxygen_failed)"])])

    AC_RNA_TEST_FILE( [$DOXYGEN_DOCDIR/xml/index.xml],
                      [with_doc=yes],
                      [with_doc=no
                       doc_failed="($doxygen_failed)"])

    if test "x$with_doc_pdf" = "x$with_doc_html";
    then
      if test "x$with_doc_pdf" = "x$with_doc";
      then
          if test "x$with_doc_pdf" = "xno";
          then
              with_doc=no
          fi
      fi
    fi
  fi
])

AC_SUBST([REFERENCE_MANUAL_PDF_NAME], [ifelse([$with_doc_pdf],
                                              [no],
                                              [],
                                              [$DOXYGEN_PROJECT_NAME.pdf])])
AC_SUBST([REFERENCE_MANUAL_TAGFILE],  [ifelse([$doxygen],
                                              [no],
                                              [],
                                              [$DOXYGEN_PROJECT_NAME.tag])])


# setup variables used in Makefile.am

# Define ${htmldir} if the configure script was created with a version of
# autoconf older than 2.60
# Alternatively, if ${htmldir} is exactly '${docdir}', append a /html to
# separate html files from rest of doc.
# Otherwise, just append the PACKAGE_NAME to the htmldir
if test "x${htmldir}" = "x";
then
  AC_MSG_WARN([resetting htmldir])
  htmldir="${docdir}/html"
fi

if test "x${htmldir}" = 'x${docdir}';
then
  htmldir="${docdir}/html"
else
  htmldir=${htmldir}/${PACKAGE_NAME}
fi

AC_SUBST(htmldir, [${htmldir}])

#

AM_CONDITIONAL(WITH_REFERENCE_MANUAL, test "x$with_doc" != xno)
AM_CONDITIONAL(WITH_REFERENCE_MANUAL_BUILD, test "x$doxygen" != xno)
AM_CONDITIONAL(WITH_REFERENCE_MANUAL_PDF, test "x$with_doc_pdf" != xno)
AM_CONDITIONAL(WITH_REFERENCE_MANUAL_HTML, test "x$with_doc_html" != xno)
AM_CONDITIONAL(WITH_REFERENCE_MANUAL_XML, test "x$with_doc_xml" != xno)
])


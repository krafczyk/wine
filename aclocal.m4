dnl Macros used to build the Wine configure script
dnl
dnl Copyright 2002 Alexandre Julliard
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2.1 of the License, or (at your option) any later version.
dnl
dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.
dnl
dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
dnl
dnl As a special exception to the GNU Lesser General Public License,
dnl if you distribute this file as part of a program that contains a
dnl configuration script generated by Autoconf, you may include it
dnl under the same distribution terms that you use for the rest of
dnl that program.

dnl WINE_CHECK_HOST_TOOL(VARIABLE, PROG-TO-CHECK-FOR, [VALUE-IF-NOT-FOUND], [PATH])
dnl
dnl Like AC_CHECK_TOOL but without the broken fallback to non-prefixed name
dnl
AC_DEFUN([WINE_CHECK_HOST_TOOL],
[AS_VAR_SET_IF([ac_tool_prefix],
  AC_CHECK_PROG([$1],[${ac_tool_prefix}$2],[${ac_tool_prefix}$2],,[$4]))
AS_VAR_IF([ac_cv_prog_$1],[],
  [AS_VAR_IF([cross_compiling],[yes],[],
    [AS_UNSET([ac_cv_prog_$1])
     AC_CHECK_PROG([$1],[$2],[$2],[$3],[$4])])],
[AS_VAR_COPY([$1],[ac_cv_prog_$1])])])

dnl **** Initialize the programs used by other checks ****
dnl
dnl Usage: WINE_PATH_SONAME_TOOLS
dnl Usage: WINE_PATH_PKG_CONFIG
dnl
AC_DEFUN([WINE_PATH_SONAME_TOOLS],
[AC_PATH_PROG(LDD,ldd,true,/sbin:/usr/sbin:$PATH)
AC_CHECK_TOOL(OTOOL,otool,otool)
AC_CHECK_TOOL(READELF,[readelf],true)])

AC_DEFUN([WINE_PATH_PKG_CONFIG],
[WINE_CHECK_HOST_TOOL(PKG_CONFIG,[pkg-config])])

dnl **** Extract the soname of a library ****
dnl
dnl Usage: WINE_CHECK_SONAME(library, function, [action-if-found, [action-if-not-found, [other_libraries, [pattern]]]])
dnl
AC_DEFUN([WINE_CHECK_SONAME],
[AC_REQUIRE([WINE_PATH_SONAME_TOOLS])dnl
AS_VAR_PUSHDEF([ac_Lib],[ac_cv_lib_soname_$1])dnl
m4_pushdef([ac_lib_pattern],m4_default([$6],[lib$1]))dnl
AC_MSG_CHECKING([for -l$1])
AC_CACHE_VAL(ac_Lib,
[ac_check_soname_save_LIBS=$LIBS
LIBS="-l$1 $5 $LIBS"
  AC_LINK_IFELSE([AC_LANG_CALL([], [$2])],
  [case "$LIBEXT" in
    dll) AS_VAR_SET(ac_Lib,[`$ac_cv_path_LDD conftest.exe | grep "$1" | sed -e "s/dll.*/dll/"';2,$d'`]) ;;
    dylib) AS_VAR_SET(ac_Lib,[`$OTOOL -L conftest$ac_exeext | grep "ac_lib_pattern\\.[[0-9A-Za-z.]]*dylib" | sed -e "s/^.*\/\(ac_lib_pattern\.[[0-9A-Za-z.]]*dylib\).*$/\1/"';2,$d'`]) ;;
    *) AS_VAR_SET(ac_Lib,[`$READELF -d conftest$ac_exeext | grep "NEEDED.*ac_lib_pattern\\.$LIBEXT" | sed -e "s/^.*\\m4_dquote(\\(ac_lib_pattern\\.$LIBEXT[[^	 ]]*\\)\\).*$/\1/"';2,$d'`])
       AS_VAR_IF([ac_Lib],[],
             [AS_VAR_SET(ac_Lib,[`$LDD conftest$ac_exeext | grep "ac_lib_pattern\\.$LIBEXT" | sed -e "s/^.*\(ac_lib_pattern\.$LIBEXT[[^	 ]]*\).*$/\1/"';2,$d'`])]) ;;
  esac])
  LIBS=$ac_check_soname_save_LIBS])dnl
AS_VAR_IF([ac_Lib],[],
      [AC_MSG_RESULT([not found])
       $4],
      [AC_MSG_RESULT(AS_VAR_GET(ac_Lib))
       AC_DEFINE_UNQUOTED(AS_TR_CPP(SONAME_LIB$1),["]AS_VAR_GET(ac_Lib)["],
                          [Define to the soname of the lib$1 library.])
       $3])dnl
m4_popdef([ac_lib_pattern])dnl
AS_VAR_POPDEF([ac_Lib])])

dnl **** Get flags from pkg-config or alternate xxx-config program ****
dnl
dnl Usage: WINE_PACKAGE_FLAGS(var,pkg-name,[default-lib,[cflags-alternate,libs-alternate,[checks]]])
dnl
AC_DEFUN([WINE_PACKAGE_FLAGS],
[AC_REQUIRE([WINE_PATH_PKG_CONFIG])dnl
AS_VAR_PUSHDEF([ac_cflags],[[$1]_CFLAGS])dnl
AS_VAR_PUSHDEF([ac_libs],[[$1]_LIBS])dnl
AC_ARG_VAR(ac_cflags, [C compiler flags for $2, overriding pkg-config])dnl
AS_VAR_IF([ac_cflags],[],
      [AS_VAR_SET_IF([PKG_CONFIG],
      [ac_cflags=`$PKG_CONFIG --cflags [$2] 2>/dev/null`])])
m4_ifval([$4],[test "$cross_compiling" = yes || ac_cflags=[$]{ac_cflags:-[$4]}])
AC_ARG_VAR(ac_libs, [Linker flags for $2, overriding pkg-config])dnl
AS_VAR_IF([ac_libs],[],
      [AS_VAR_SET_IF([PKG_CONFIG],
      [ac_libs=`$PKG_CONFIG --libs [$2] 2>/dev/null`])])
m4_ifval([$5],[test "$cross_compiling" = yes || ac_libs=[$]{ac_libs:-[$5]}])
m4_ifval([$3],[ac_libs=[$]{ac_libs:-"$3"}])
AS_ECHO(["$as_me:${as_lineno-$LINENO}: $2 cflags: $ac_cflags"]) >&AS_MESSAGE_LOG_FD
AS_ECHO(["$as_me:${as_lineno-$LINENO}: $2 libs: $ac_libs"]) >&AS_MESSAGE_LOG_FD
ac_save_CPPFLAGS=$CPPFLAGS
CPPFLAGS="$CPPFLAGS $ac_cflags"
$6
CPPFLAGS=$ac_save_CPPFLAGS
test -z "$ac_cflags" || ac_cflags=`echo " $ac_cflags" | sed 's/ -I\([[^/]]\)/ -I\$(top_builddir)\/\1/g'`
test -z "$ac_libs" || ac_libs=`echo " $ac_libs" | sed 's/ -L\([[^/]]\)/ -L\$(top_builddir)\/\1/g'`
AS_VAR_POPDEF([ac_libs])dnl
AS_VAR_POPDEF([ac_cflags])])dnl

dnl **** Get include path from pkg-config ****
dnl
dnl Usage: WINE_PACKAGE_INCLUDE_FLAGS(var,pkg-name,[cflags-alternate,[checks]]])
dnl
AC_DEFUN([WINE_PACKAGE_INCLUDE_FLAGS],
[AC_REQUIRE([WINE_PATH_PKG_CONFIG])dnl
AS_VAR_PUSHDEF([ac_cflags],[[$1]_CFLAGS])dnl
AC_ARG_VAR(ac_cflags, [C compiler flags for $2, overriding pkg-config])dnl
AS_VAR_IF([ac_cflags],[],
      [AS_VAR_SET_IF([PKG_CONFIG],
      [ac_cflags=`$PKG_CONFIG --cflags-only-I [$2] 2>/dev/null`])])
m4_ifval([$3],[test "$cross_compiling" = yes || ac_cflags=[$]{ac_cflags:-[$3]}])
AS_ECHO(["$as_me:${as_lineno-$LINENO}: $2 cflags: $ac_cflags"]) >&AS_MESSAGE_LOG_FD
ac_save_CPPFLAGS=$CPPFLAGS
CPPFLAGS="$CPPFLAGS $ac_cflags"
$4
CPPFLAGS=$ac_save_CPPFLAGS
test -z "$ac_cflags" || ac_cflags=`echo " $ac_cflags" | sed 's/ -I\([[^/]]\)/ -I\$(top_builddir)\/\1/g'`
AS_VAR_POPDEF([ac_cflags])])dnl

dnl **** Link C code with an assembly file ****
dnl
dnl Usage: WINE_TRY_ASM_LINK(asm-code,includes,function,[action-if-found,[action-if-not-found]])
dnl
AC_DEFUN([WINE_TRY_ASM_LINK],
[AC_LINK_IFELSE([AC_LANG_PROGRAM([[$2]],[[asm($1); $3]])],[$4],[$5])])

dnl **** Check if we can link an empty program with special CFLAGS ****
dnl
dnl Usage: WINE_TRY_CFLAGS(flags,[action-if-yes,[action-if-no]])
dnl
dnl The default action-if-yes is to append the flags to EXTRACFLAGS.
dnl
AC_DEFUN([WINE_TRY_CFLAGS],
[AS_VAR_PUSHDEF([ac_var], ac_cv_cflags_[[$1]])dnl
AC_CACHE_CHECK([whether the compiler supports $1], ac_var,
[ac_wine_try_cflags_saved=$CFLAGS
CFLAGS="$CFLAGS $1"
AC_LINK_IFELSE([AC_LANG_SOURCE([[int main(int argc, char **argv) { return 0; }]])],
               [AS_VAR_SET(ac_var,yes)], [AS_VAR_SET(ac_var,no)])
CFLAGS=$ac_wine_try_cflags_saved])
AS_VAR_IF([ac_var],[yes],[m4_default([$2], [EXTRACFLAGS="$EXTRACFLAGS $1"])], [$3])dnl
AS_VAR_POPDEF([ac_var])])

dnl **** Check if we can link an empty shared lib (no main) with special CFLAGS ****
dnl
dnl Usage: WINE_TRY_SHLIB_FLAGS(flags,[action-if-yes,[action-if-no]])
dnl
AC_DEFUN([WINE_TRY_SHLIB_FLAGS],
[ac_wine_try_cflags_saved=$CFLAGS
CFLAGS="$CFLAGS $1"
AC_LINK_IFELSE([AC_LANG_SOURCE([void myfunc() {}])],[$2],[$3])
CFLAGS=$ac_wine_try_cflags_saved])

dnl **** Check whether we need to define a symbol on the compiler command line ****
dnl
dnl Usage: WINE_CHECK_DEFINE(name),[action-if-yes,[action-if-no]])
dnl
AC_DEFUN([WINE_CHECK_DEFINE],
[AS_VAR_PUSHDEF([ac_var],[ac_cv_cpp_def_$1])dnl
AC_CACHE_CHECK([whether we need to define $1],ac_var,
    AC_EGREP_CPP(yes,[#ifndef $1
yes
#endif],
    [AS_VAR_SET(ac_var,yes)],[AS_VAR_SET(ac_var,no)]))
AS_VAR_IF([ac_var],[yes],
      [CFLAGS="$CFLAGS -D$1"
  LINTFLAGS="$LINTFLAGS -D$1"])dnl
AS_VAR_POPDEF([ac_var])])

dnl **** Check for functions with some extra libraries ****
dnl
dnl Usage: WINE_CHECK_LIB_FUNCS(funcs,libs,[action-if-found,[action-if-not-found]])
dnl
AC_DEFUN([WINE_CHECK_LIB_FUNCS],
[ac_wine_check_funcs_save_LIBS="$LIBS"
LIBS="$LIBS $2"
AC_CHECK_FUNCS([$1],[$3],[$4])
LIBS="$ac_wine_check_funcs_save_LIBS"])

dnl **** Check for a mingw program, trying the various mingw prefixes ****
dnl
dnl Usage: WINE_CHECK_MINGW_PROG(variable,prog,[value-if-not-found],[path])
dnl
AC_DEFUN([WINE_CHECK_MINGW_PROG],
[case "$host_cpu" in
  i[[3456789]]86*)
    ac_prefix_list="m4_foreach([ac_wine_prefix],[w64-mingw32, pc-mingw32, mingw32msvc, mingw32],
                        m4_foreach([ac_wine_cpu],[i686,i586,i486,i386],[ac_wine_cpu-ac_wine_prefix-$2 ]))
                        mingw32-$2" ;;
  x86_64)
    ac_prefix_list="m4_foreach([ac_wine_prefix],[pc-mingw32, w64-mingw32, mingw32msvc],
                        m4_foreach([ac_wine_cpu],[x86_64,amd64],[ac_wine_cpu-ac_wine_prefix-$2 ]))" ;;
  *)
    ac_prefix_list="" ;;
esac
AC_CHECK_PROGS([$1],[$ac_prefix_list],[$3],[$4])])


dnl **** Define helper functions for creating config.status files ****
dnl
dnl Usage: AC_REQUIRE([WINE_CONFIG_HELPERS])
dnl
AC_DEFUN([WINE_CONFIG_HELPERS],
[wine_rules_file=conf$$rules.make
rm -f $wine_rules_file
ALL_POT_FILES=""
GITIGNORE="# Automatically generated by configure; DO NOT EDIT!!"
AC_SUBST(ALL_TEST_RESOURCES,"")

wine_fn_append_file ()
{
    AS_VAR_APPEND($[1]," \\$as_nl	$[2]")
}

wine_fn_ignore_file ()
{
    case "$[1]" in
      */*) AS_VAR_APPEND([GITIGNORE],"$as_nl$[1]") ;;
      \**) AS_VAR_APPEND([GITIGNORE],"$as_nl$[1]") ;;
      *)   AS_VAR_APPEND([GITIGNORE],"$as_nl/$[1]") ;;
    esac
}

wine_fn_append_rule ()
{
    AS_ECHO("$[1]") >>$wine_rules_file
}

wine_fn_has_flag ()
{
    expr ",$ac_flags," : ".*,$[1],.*" >/dev/null
}

wine_fn_depend_rules ()
{
    wine_fn_append_rule \
"$ac_dir/Makefile: $srcdir/$ac_dir/Makefile.in Makefile \$(MAKEDEP)
	\$(MAKEDEP) $ac_dir
depend: $ac_dir/depend
.PHONY: $ac_dir/depend
$ac_dir/depend: \$(MAKEDEP) dummy
	\$(MAKEDEP) $ac_dir"
}

wine_fn_pot_rules ()
{
    test "x$with_gettextpo" = xyes || return

    if wine_fn_has_flag mc
    then
        wine_fn_append_file ALL_POT_FILES $ac_dir/msg.pot
        wine_fn_append_rule \
"$ac_dir/msg.pot: $ac_dir/Makefile dummy
	@cd $ac_dir && \$(MAKE) msg.pot
$ac_dir/msg.pot: tools/wmc include"
    fi
    if wine_fn_has_flag po
    then
        wine_fn_append_file ALL_POT_FILES $ac_dir/rsrc.pot
        wine_fn_append_rule \
"$ac_dir/rsrc.pot: $ac_dir/Makefile dummy
	@cd $ac_dir && \$(MAKE) rsrc.pot
$ac_dir/rsrc.pot: tools/wrc include"
    fi
}

wine_fn_all_rules ()
{
    wine_fn_depend_rules
    wine_fn_append_rule \
"all: $ac_dir
.PHONY: $ac_dir
$ac_dir: $ac_dir/Makefile dummy
	@cd $ac_dir && \$(MAKE)"
}

wine_fn_install_rules ()
{
    wine_fn_has_flag install-lib || wine_fn_has_flag install-dev || return

    wine_fn_append_rule \
".PHONY: $ac_dir/install $ac_dir/uninstall
$ac_dir/install:: $ac_dir
	@cd $ac_dir && \$(MAKE) install
$ac_dir/uninstall:: $ac_dir/Makefile
	@cd $ac_dir && \$(MAKE) uninstall
install:: $ac_dir/install
__uninstall__: $ac_dir/uninstall"

    if wine_fn_has_flag install-lib
    then
        wine_fn_append_rule \
".PHONY: $ac_dir/install-lib
$ac_dir/install-lib:: $ac_dir
	@cd $ac_dir && \$(MAKE) install-lib
install-lib:: $ac_dir/install-lib"
    fi

    if wine_fn_has_flag install-dev
    then
        wine_fn_append_rule \
".PHONY: $ac_dir/install-dev
$ac_dir/install-dev:: $ac_dir
	@cd $ac_dir && \$(MAKE) install-dev
install-dev:: $ac_dir/install-dev"
    fi
}

wine_fn_clean_rules ()
{
    ac_clean=$[@]
    ac_extraclean="$ac_dir/Makefile"
    test "$srcdir" = . && ac_extraclean="$ac_extraclean $ac_dir/.gitignore"
    case $ac_dir in
        */tests) ac_extraclean="$ac_extraclean $ac_dir/testlist.c" ;;
    esac

    if wine_fn_has_flag clean
    then
        wine_fn_append_rule \
"__clean__: $ac_dir/clean
.PHONY: $ac_dir/clean
$ac_dir/clean: $ac_dir/Makefile
	@cd $ac_dir && \$(MAKE) clean
	\$(RM) $ac_extraclean"
    else
        wine_fn_append_rule \
"__clean__: $ac_dir/clean
.PHONY: $ac_dir/clean
$ac_dir/clean: dummy
	\$(RM) \$(CLEAN_FILES:%=$ac_dir/%) $ac_clean $ac_extraclean"
    fi
}

wine_fn_disabled_rules ()
{
    ac_clean=$[@]
    ac_extraclean="$ac_dir/Makefile"
    test "$srcdir" = . && ac_extraclean="$ac_extraclean $ac_dir/.gitignore"

    wine_fn_append_rule \
"__clean__: $ac_dir/clean
.PHONY: $ac_dir/clean
$ac_dir/clean: dummy
	\$(RM) \$(CLEAN_FILES:%=$ac_dir/%) $ac_clean $ac_extraclean"
}

wine_fn_config_makefile ()
{
    ac_dir=$[1]
    ac_enable=$[2]
    ac_flags=$[3]

    AS_VAR_IF([$ac_enable],[no],[wine_fn_disabled_rules; return])
    wine_fn_all_rules
    wine_fn_install_rules
    wine_fn_clean_rules
}

wine_fn_config_lib ()
{
    ac_name=$[1]
    ac_flags=$[2]
    ac_dir=dlls/$ac_name
    ac_deps="include"

    AS_VAR_IF([enable_tools],[no],,[ac_deps="tools/widl tools/winebuild tools/winegcc $ac_deps"])
    wine_fn_all_rules
    wine_fn_clean_rules

    wine_fn_append_rule \
".PHONY: $ac_dir/install $ac_dir/uninstall
$ac_dir/install:: $ac_dir
	\$(INSTALL_DATA) $ac_dir/lib$ac_name.a \$(DESTDIR)\$(dlldir)/lib$ac_name.a
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/lib$ac_name.a
install install-dev:: $ac_dir/install
__uninstall__: $ac_dir/uninstall
__builddeps__: $ac_dir
$ac_dir: $ac_deps"
}

wine_fn_config_dll ()
{
    ac_name=$[1]
    ac_dir=dlls/$ac_name
    ac_enable=$[2]
    ac_flags=$[3]
    ac_implib=${4:-$ac_name}
    ac_file=$ac_dir/lib$ac_implib
    ac_dll=$ac_name
    ac_deps="include"
    ac_implibflags=""

    AS_VAR_IF([enable_tools],[no],,[ac_deps="tools/widl tools/winebuild tools/winegcc $ac_deps"])
    case $ac_name in
      *16) ac_implibflags=" -m16" ;;
      *.*) ;;
      *)   ac_dll=$ac_dll.dll ;;
    esac

    ac_clean=
    wine_fn_has_flag implib && ac_clean="$ac_clean $ac_file.$IMPLIBEXT"
    wine_fn_has_flag mc && ac_clean="$ac_clean $ac_dir/msg.pot"
    wine_fn_has_flag po && ac_clean="$ac_clean $ac_dir/rsrc.pot"
    test -n "$DLLEXT" || ac_clean="$ac_clean $ac_dir/$ac_dll"

    AS_VAR_IF([$ac_enable],[no],
              dnl enable_win16 is special in that it disables import libs too
              [if test "$ac_enable" != enable_win16
               then
                   wine_fn_depend_rules
                   wine_fn_clean_rules $ac_clean
                   wine_fn_pot_rules
               else
                   wine_fn_disabled_rules $ac_clean
                   return
               fi],

              [wine_fn_all_rules
               wine_fn_clean_rules $ac_clean
               wine_fn_append_rule \
"$ac_dir: __builddeps__
manpages htmlpages sgmlpages xmlpages:: $ac_dir/Makefile
	@cd $ac_dir && \$(MAKE) \$[@]
.PHONY: $ac_dir/install-lib $ac_dir/uninstall
install install-lib:: $ac_dir/install-lib
__uninstall__: $ac_dir/uninstall"
                if test -n "$DLLEXT"
                then
                    wine_fn_append_rule \
"$ac_dir/install-lib:: $ac_dir
	\$(INSTALL_PROGRAM) $ac_dir/$ac_dll$DLLEXT \$(DESTDIR)\$(dlldir)/$ac_dll$DLLEXT
	\$(INSTALL_DATA) $ac_dir/$ac_dll.fake \$(DESTDIR)\$(fakedlldir)/$ac_dll
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/$ac_dll$DLLEXT \$(DESTDIR)\$(fakedlldir)/$ac_dll"
                else
                    wine_fn_append_rule \
"$ac_dir/install-lib:: $ac_dir
	\$(INSTALL_PROGRAM) $ac_dir/$ac_dll \$(DESTDIR)\$(dlldir)/$ac_dll
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/$ac_dll"
                fi

                wine_fn_pot_rules])

    if wine_fn_has_flag staticimplib
    then
        wine_fn_append_rule \
"__builddeps__: $ac_file.$IMPLIBEXT $ac_file.$STATIC_IMPLIBEXT
$ac_file.$IMPLIBEXT $ac_file.$STATIC_IMPLIBEXT $ac_file.cross.a: $ac_deps
$ac_file.def: $srcdir/$ac_dir/$ac_name.spec $ac_dir/Makefile \$(WINEBUILD)
	\$(WINEBUILD) \$(TARGETFLAGS)$ac_implibflags -w --def -o \$[@] --export $srcdir/$ac_dir/$ac_name.spec
$ac_file.$STATIC_IMPLIBEXT: $ac_dir/Makefile dummy
	@cd $ac_dir && \$(MAKE) lib$ac_implib.$STATIC_IMPLIBEXT
.PHONY: $ac_dir/install-dev $ac_dir/uninstall
$ac_dir/install-dev:: $ac_file.$IMPLIBEXT
	\$(INSTALL_DATA) $ac_file.$IMPLIBEXT \$(DESTDIR)\$(dlldir)/lib$ac_implib.$IMPLIBEXT
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/lib$ac_implib.$IMPLIBEXT
install install-dev:: $ac_dir/install-dev
__uninstall__: $ac_dir/uninstall"

        if test "$IMPLIBEXT" != "$STATIC_IMPLIBEXT"
        then
            wine_fn_append_rule \
"$ac_dir/install-dev:: $ac_file.$STATIC_IMPLIBEXT __builddeps__
	\$(INSTALL_DATA) $ac_file.$STATIC_IMPLIBEXT \$(DESTDIR)\$(dlldir)/lib$ac_implib.$STATIC_IMPLIBEXT
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/lib$ac_implib.$STATIC_IMPLIBEXT"
        fi

        if test -n "$CROSSTARGET" -a -z "$ac_implibflags"
        then
            wine_fn_append_rule \
"__builddeps__: $ac_file.cross.a
$ac_file.cross.a: $ac_dir/Makefile dummy
	@cd $ac_dir && \$(MAKE) lib$ac_implib.cross.a"
        fi

    elif wine_fn_has_flag implib
    then
        wine_fn_append_rule \
"__builddeps__: $ac_file.$IMPLIBEXT
$ac_file.def: $srcdir/$ac_dir/$ac_name.spec $ac_dir/Makefile \$(WINEBUILD)
	\$(WINEBUILD) \$(TARGETFLAGS)$ac_implibflags -w --def -o \$[@] --export $srcdir/$ac_dir/$ac_name.spec
$ac_file.a: $srcdir/$ac_dir/$ac_name.spec $ac_dir/Makefile \$(WINEBUILD)
	\$(WINEBUILD) \$(TARGETFLAGS)$ac_implibflags -w --implib -o \$[@] --export $srcdir/$ac_dir/$ac_name.spec
.PHONY: $ac_dir/install-dev $ac_dir/uninstall
$ac_dir/install-dev:: $ac_file.$IMPLIBEXT
	\$(INSTALL_DATA) $ac_file.$IMPLIBEXT \$(DESTDIR)\$(dlldir)/lib$ac_implib.$IMPLIBEXT
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/lib$ac_implib.$IMPLIBEXT
install install-dev:: $ac_dir/install-dev
__uninstall__: $ac_dir/uninstall"
        if test -n "$CROSSTARGET" -a -z "$ac_implibflags"
        then
            wine_fn_append_rule \
"__builddeps__: $ac_file.cross.a
$ac_file.cross.a: $srcdir/$ac_dir/$ac_name.spec $ac_dir/Makefile \$(WINEBUILD)
	\$(WINEBUILD) \$(CROSSTARGET:%=-b %)$ac_implibflags -w --implib -o \$[@] --export $srcdir/$ac_dir/$ac_name.spec"
        fi

        if test "$ac_name" != "$ac_implib"
        then
            wine_fn_append_rule \
"__builddeps__: dlls/lib$ac_implib.$IMPLIBEXT
dlls/lib$ac_implib.$IMPLIBEXT: $ac_file.$IMPLIBEXT
	\$(RM) \$[@] && \$(LN_S) $ac_name/lib$ac_implib.$IMPLIBEXT \$[@]
clean::
	\$(RM) dlls/lib$ac_implib.$IMPLIBEXT"
            wine_fn_ignore_file "dlls/lib$ac_implib.$IMPLIBEXT"
            if test -n "$CROSSTARGET" -a -z "$ac_implibflags"
            then
                wine_fn_append_rule \
"__builddeps__: dlls/lib$ac_implib.cross.a
dlls/lib$ac_implib.cross.a: $ac_file.cross.a
	\$(RM) \$[@] && \$(LN_S) $ac_name/lib$ac_implib.cross.a \$[@]
clean::
	\$(RM) dlls/lib$ac_implib.cross.a"
                wine_fn_ignore_file "dlls/lib$ac_implib.cross.a"
            fi
        fi
    fi
}

wine_fn_config_program ()
{
    ac_name=$[1]
    ac_dir=programs/$ac_name
    ac_enable=$[2]
    ac_flags=$[3]
    ac_program=$ac_name

    case $ac_name in
      *.*) ;;
      *)   ac_program=$ac_program.exe ;;
    esac

    ac_clean=
    wine_fn_has_flag mc && ac_clean="$ac_clean $ac_dir/msg.pot"
    wine_fn_has_flag po && ac_clean="$ac_clean $ac_dir/rsrc.pot"
    wine_fn_has_flag manpage && ac_clean="$ac_clean $ac_dir/$ac_name.man"
    test -n "$DLLEXT" || ac_clean="$ac_clean $ac_dir/$ac_program"

    AS_VAR_IF([$ac_enable],[no],[wine_fn_disabled_rules $ac_clean; return])

    wine_fn_all_rules
    wine_fn_clean_rules $ac_clean
    wine_fn_append_rule "$ac_dir: __builddeps__"
    wine_fn_pot_rules

    wine_fn_has_flag install || return
    wine_fn_append_rule \
".PHONY: $ac_dir/install $ac_dir/uninstall
install install-lib:: $ac_dir/install
__uninstall__: $ac_dir/uninstall"

    if test -n "$DLLEXT"
    then
        wine_fn_append_rule \
"$ac_dir/install:: $ac_dir
	\$(INSTALL_PROGRAM) $ac_dir/$ac_program$DLLEXT \$(DESTDIR)\$(dlldir)/$ac_program$DLLEXT
	\$(INSTALL_DATA) $ac_dir/$ac_program.fake \$(DESTDIR)\$(fakedlldir)/$ac_program
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(dlldir)/$ac_program$DLLEXT \$(DESTDIR)\$(fakedlldir)/$ac_program"

        if test -z "$with_wine64" && wine_fn_has_flag installbin
        then
            wine_fn_append_rule \
"$ac_dir/install:: __tooldeps__
	\$(INSTALL_SCRIPT) \$(TOOLSDIR)/tools/wineapploader \$(DESTDIR)\$(bindir)/$ac_name
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(bindir)/$ac_name"
        fi
    else
        wine_fn_append_rule \
"$ac_dir/install:: $ac_dir
	\$(INSTALL_PROGRAM) $ac_dir/$ac_program \$(DESTDIR)\$(bindir)/$ac_program
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(bindir)/$ac_program"
    fi

    if test -z "$with_wine64" && wine_fn_has_flag manpage
    then
        wine_fn_append_rule \
"$ac_dir/install:: $ac_dir
	\$(INSTALL_DATA) $ac_dir/$ac_name.man \$(DESTDIR)\$(mandir)/man\$(prog_manext)/$ac_name.\$(prog_manext)
$ac_dir/uninstall::
	\$(RM) \$(DESTDIR)\$(mandir)/man\$(prog_manext)/$ac_name.\$(prog_manext)"
    fi
}

wine_fn_config_test ()
{
    ac_dir=$[1]
    ac_name=$[2]
    ac_flags=$[3]

    ac_clean=
    test -n "$CROSSTARGET" && ac_clean=`expr $ac_dir/${ac_name} : "\\(.*\\)_test"`_crosstest.exe
    test -n "$DLLEXT" || ac_clean="$ac_dir/${ac_name}.exe $ac_dir/${ac_name}-stripped.exe"

    AS_VAR_IF([enable_tests],[no],[wine_fn_disabled_rules $ac_clean; return])

    wine_fn_append_file ALL_TEST_RESOURCES $ac_name.res
    wine_fn_all_rules
    wine_fn_clean_rules $ac_clean

    wine_fn_append_rule \
"$ac_dir: programs/winetest/Makefile __builddeps__
programs/winetest: $ac_dir
check test: $ac_dir/test
.PHONY: $ac_dir/test
$ac_dir/test: dummy
	@cd $ac_dir && \$(MAKE) test
testclean::
	\$(RM) $ac_dir/*.ok"

        if test -n "$CROSSTARGET"
        then
            wine_fn_append_rule \
"crosstest: $ac_dir/crosstest
.PHONY: $ac_dir/crosstest
$ac_dir/crosstest: $ac_dir/Makefile __builddeps__ dummy
	@cd $ac_dir && \$(MAKE) crosstest"
        fi
}

wine_fn_config_resource ()
{
    ac_dir=$[1]
    ac_name=$[2]
    ac_flags=$[3]
    ac_dll=$ac_name

    case $ac_name in
      *.*) ;;
      *)   ac_dll=$ac_dll.dll ;;
    esac

    ac_clean=
    test -n "$CROSSTARGET" && ac_clean=`expr $ac_dir/$ac_dll : "\\(.*\\)\\."`_crossres.`expr $ac_dll : ".*\\.\\(.*\\)"`
    test -n "$DLLEXT" || ac_clean="$ac_dir/$ac_dll"

    AS_VAR_IF([enable_tests],[no],[wine_fn_disabled_rules $ac_clean; return])

    wine_fn_depend_rules
    wine_fn_clean_rules $ac_clean
}

wine_fn_config_tool ()
{
    ac_dir=$[1]
    ac_flags=$[2]
    AS_VAR_IF([enable_tools],[no],[return])

    wine_fn_all_rules
    wine_fn_install_rules
    wine_fn_clean_rules

    wine_fn_append_rule "__tooldeps__: $ac_dir"
    wine_fn_append_rule "$ac_dir: libs/port"
    case $ac_dir in
      tools/winebuild) wine_fn_append_rule "\$(WINEBUILD): $ac_dir" ;;
    esac
}

wine_fn_config_symlink ()
{
    ac_linkdir=
    if test "x$[1]" = "x-d"
    then
        ac_linkdir=$[2]
        shift; shift
    fi
    ac_links=$[@]
    wine_fn_append_rule \
"$ac_links:
	@./config.status \$[@]
distclean::
	\$(RM) $ac_links"
    for f in $ac_links; do wine_fn_ignore_file $f; done
    test -n "$ac_linkdir" || return
    wine_fn_append_rule "$ac_linkdir/Makefile $ac_linkdir/depend: $ac_links"
}])

dnl **** Define helper function to append a file to a makefile file list ****
dnl
dnl Usage: WINE_APPEND_FILE(var,file)
dnl
AC_DEFUN([WINE_APPEND_FILE],[AC_REQUIRE([WINE_CONFIG_HELPERS])wine_fn_append_file $1 "$2"])

dnl **** Define helper function to append a rule to a makefile command list ****
dnl
dnl Usage: WINE_APPEND_RULE(rule)
dnl
AC_DEFUN([WINE_APPEND_RULE],[AC_REQUIRE([WINE_CONFIG_HELPERS])wine_fn_append_rule "$1"])

dnl **** Create symlinks from config.status ****
dnl
dnl Usage: WINE_CONFIG_SYMLINK(target,src,files,enable,srcfile)
dnl
AC_DEFUN([WINE_CONFIG_SYMLINK],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_ifval([$4],[if test "x$[$4]" != xno; then
])m4_foreach([f],[$3],
[AC_CONFIG_LINKS(m4_ifval([$1],[$1/])f[:]m4_ifval([$2],[$2/])m4_ifval([$5],[$5],f))])dnl
m4_if([$1],[$2],[test "$srcdir" = "." || ])dnl
wine_fn_config_symlink[]m4_if([$1],[$2],,m4_ifval([$1],[ -d $1]))[]m4_foreach([f],[$3],[ ]m4_ifval([$1],[$1/])f)m4_ifval([$4],[
fi])[]dnl
])])

dnl **** Create a makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_MAKEFILE(file,enable,flags)
dnl
AC_DEFUN([WINE_CONFIG_MAKEFILE],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
AS_VAR_PUSHDEF([ac_enable],m4_default([$2],[enable_]$1))dnl
m4_append_uniq([_AC_USER_OPTS],ac_enable,[
])dnl
wine_fn_config_makefile [$1] ac_enable [$3]dnl
AS_VAR_POPDEF([ac_enable])])

dnl **** Create a dll makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_DLL(name,enable,flags,implib)
dnl
AC_DEFUN([WINE_CONFIG_DLL],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
AS_VAR_PUSHDEF([ac_enable],m4_default([$2],[enable_]$1))dnl
m4_append_uniq([_AC_USER_OPTS],ac_enable,[
])dnl
wine_fn_config_dll [$1] ac_enable [$3] [$4]dnl
AS_VAR_POPDEF([ac_enable])])

dnl **** Create a program makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_PROGRAM(name,enable,flags)
dnl
AC_DEFUN([WINE_CONFIG_PROGRAM],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
AS_VAR_PUSHDEF([ac_enable],m4_default([$2],[enable_]$1))dnl
m4_append_uniq([_AC_USER_OPTS],ac_enable,[
])dnl
wine_fn_config_program [$1] ac_enable [$3]dnl
AS_VAR_POPDEF([ac_enable])])

dnl **** Create a test makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_TEST(dir,flags)
dnl
AC_DEFUN([WINE_CONFIG_TEST],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_pushdef([ac_suffix],m4_if(m4_substr([$1],0,9),[programs/],[.exe_test],[_test]))dnl
m4_pushdef([ac_name],[m4_bpatsubst([$1],[.*/\(.*\)/tests$],[\1])])dnl
wine_fn_config_test $1 ac_name[]ac_suffix [$2]dnl
m4_popdef([ac_suffix])dnl
m4_popdef([ac_name])])

dnl **** Create a test resource makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_RESOURCE(dir,flags)
dnl
AC_DEFUN([WINE_CONFIG_RESOURCE],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_pushdef([ac_name],[m4_bpatsubst([$1],[.*/\([^/\]*\)$],[\1])])dnl
wine_fn_config_resource $1 ac_name [$2]dnl
m4_popdef([ac_name])])

dnl **** Create a static lib makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_LIB(name,flags)
dnl
AC_DEFUN([WINE_CONFIG_LIB],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
wine_fn_config_lib [$1] [$2]])

dnl **** Create a tool makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_TOOL(name,flags)
dnl
AC_DEFUN([WINE_CONFIG_TOOL],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_append_uniq([_AC_USER_OPTS],[enable_tools],[
])dnl
wine_fn_config_tool [$1] [$2]])

dnl **** Append a file to the .gitignore list ****
dnl
dnl Usage: WINE_IGNORE_FILE(file,enable)
dnl
AC_DEFUN([WINE_IGNORE_FILE],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_ifval([$2],[test "x$[$2]" = xno || ])wine_fn_ignore_file $1])

dnl **** Add a message to the list displayed at the end ****
dnl
dnl Usage: WINE_NOTICE(notice)
dnl Usage: WINE_NOTICE_WITH(with_flag, test, notice)
dnl Usage: WINE_WARNING(warning)
dnl Usage: WINE_WARNING_WITH(with_flag, test, warning)
dnl Usage: WINE_PRINT_MESSAGES
dnl
AC_DEFUN([WINE_NOTICE],[AS_VAR_APPEND([wine_notices],["|$1"])])
AC_DEFUN([WINE_WARNING],[AS_VAR_APPEND([wine_warnings],["|$1"])])

AC_DEFUN([WINE_NOTICE_WITH],[AS_IF([$2],[case "x$with_$1" in
  x)   WINE_NOTICE([$3]) ;;
  xno) ;;
  *)   AC_MSG_ERROR([$3
This is an error since --with-$1 was requested.]) ;;
esac])])

AC_DEFUN([WINE_WARNING_WITH],[AS_IF([$2],[case "x$with_$1" in
  x)   WINE_WARNING([$3]) ;;
  xno) ;;
  *)   AC_MSG_ERROR([$3
This is an error since --with-$1 was requested.]) ;;
esac])])

AC_DEFUN([WINE_ERROR_WITH],[AS_IF([$2],[case "x$with_$1" in
  xno) ;;
  *)   AC_MSG_ERROR([$3
Use the --without-$1 option if you really want this.]) ;;
esac])])

AC_DEFUN([WINE_PRINT_MESSAGES],[ac_save_IFS="$IFS"
if test "x$wine_notices" != x; then
    echo >&AS_MESSAGE_FD
    IFS="|"
    for msg in $wine_notices; do
        IFS="$ac_save_IFS"
        AS_VAR_IF([msg],[],,[AC_MSG_NOTICE([$msg])])
    done
fi
IFS="|"
for msg in $wine_warnings; do
    IFS="$ac_save_IFS"
    AS_VAR_IF([msg],[],,[echo >&2
        AC_MSG_WARN([$msg])])
done
IFS="$ac_save_IFS"])

dnl Local Variables:
dnl compile-command: "autoreconf --warnings=all"
dnl End:

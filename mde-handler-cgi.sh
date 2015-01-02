#!/usr/bin/env bash
#
# mde-handler-cgi.sh
# CGI-script to parse Markdown files with the PHP-MarkdownExtended package
# <http://github.com/piwi/mde-cgi>
# by @pierowbmstr (me at e-piwi dot fr)
# licensed under <http://unlicense.org>
#
# Please see the README.md file of the package as a documentation.
#
# You can define custom values for the variables below by setting them in the environment
# of your virtual host configuration:
#
#       SetEnv MYVAR my-value   # with Apache
#       env MYVAR=my-value;     # with Nginx
#
# The script is designed to render the raw original file content if you use a `?plain` query string.
#
# You can visualize some debug information by using a `?debug` query string.
#

# array to store errors
declare -a ERRORS=()

## Required commands
declare -a CMDS=( readlink dirname echo cat php )
for cmd in "${CMDS[@]}"
do
    command -v "$cmd" >/dev/null 2>&1 || ERRORS+=("Command '$cmd' not found!");
done

## Config values

# MDE_DEBUG: see debugging infos (MDE parsing is NOT processed)
[ -z "$MDE_DEBUG" ] && MDE_DEBUG=false;

# MDE_BASEPATH: base path to use for all links of this script
[ -z "$MDE_BASEPATH" ] && MDE_BASEPATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")";

# MDE_BIN: path to the markdown parser binary script
[ -z "$MDE_BIN" ] && MDE_BIN="$(command -v markdown-extended)";
( [ -z "$MDE_BIN" ]||[ ! -f "$MDE_BIN" ] ) && ERRORS+=("MDE binary '${MDE_BIN}' not found!");

# MDE_TEMPLATE: path to a template file to include parsed content in
[ -z "$MDE_TEMPLATE" ] && MDE_TEMPLATE="$(readlink -f "${MDE_BASEPATH}/mde-template.html")";
[ ! -f "$MDE_TEMPLATE" ] && ERRORS+=("MDE template '${MDE_TEMPLATE}' not found!");

# MDE_CHARSET: default character set to use while parsing Markdown content
[ -z "$MDE_CHARSET" ] && MDE_CHARSET='utf-8';

# MDE_OPTIONS: options to pass to the parser
[ -z "$MDE_OPTIONS" ] && MDE_OPTIONS="--template=${MDE_TEMPLATE}";

# MDE_PHP_BIN: path to the `php` program to use to call the parser
[ -z "$MDE_PHP_BIN" ] && MDE_PHP_BIN="$(command -v php)";

## Debug
if [ "$QUERY_STRING" = 'debug' ]||[ "$MDE_DEBUG" = 'true' ]
then
    echo "Content-type: text/plain;charset=${MDE_CHARSET}"
    echo
    echo '--------------------------'
    echo "${GATEWAY_INTERFACE} ${SERVER_NAME} ${SERVER_SOFTWARE}"
    echo '--------------------------'
    echo
    echo "## Request env:"
    echo
    echo "QUERY_STRING      : ${QUERY_STRING}"
    echo "PATH_INFO         : ${PATH_INFO}"
    echo "PATH_TRANSLATED   : ${PATH_TRANSLATED}"
    echo "REDIRECT_HANDLER  : ${REDIRECT_HANDLER}"
    echo
    echo "## MDE env:"
    echo
    echo "MDE_BASEPATH      : ${MDE_BASEPATH}"
    echo "MDE_BIN           : ${MDE_BIN}"
    echo "MDE_PHP_BIN       : ${MDE_PHP_BIN}"
    echo "MDE_CHARSET       : ${MDE_CHARSET}"
    echo "MDE_TEMPLATE      : ${MDE_TEMPLATE}"
    echo "MDE_OPTIONS       : ${MDE_OPTIONS}"
    echo
    echo "## Errors:"
    echo
    ( IFS=$'\n'; echo "${ERRORS[*]:-none}" )
    echo
    echo '--------------------------'
    echo "I am there        : $(readlink -f "${BASH_SOURCE[0]}")"
    echo '--------------------------'
#    env # uncomment this to visualize full environment
    exit 0
fi

## Start with outputting the HTTP headers
## And then the content
if [ "$QUERY_STRING" = 'plain' ]
then
    echo "Content-type: text/plain;charset=${MDE_CHARSET}"
    echo
    cat "$PATH_TRANSLATED"
else

    ## Process
    MDE_RESULT="$("$MDE_PHP_BIN" "$MDE_BIN" "$MDE_OPTIONS" "$PATH_TRANSLATED" 2>/dev/null)"
    MDE_STATUS="$?"

    if [ ! -z "$MDE_RESULT" ] && [ "$MDE_STATUS" = 0 ]
    then
        echo "Content-type: text/html;charset=${CHARSET}"
        echo
        echo "$MDE_RESULT"
    else
        echo "Content-type: text/plain;charset=${CHARSET}"
        echo
        cat "$PATH_TRANSLATED"
    fi

fi
echo

exit 0
# Endfile
# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=sh

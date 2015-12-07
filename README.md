MarkdownExtended CGI server handler
===================================

A CGI script to parse Markdown files with the [PHP-MarkdownExtended package](http://github.com/piwi/markdown-extended).

The `mde-cgi-handler.sh` script of this package is a shell script to use as a *CGI* binary 
to automatically parse the contents of certain files of the server written in Markdown syntax
(based on the file extension) and display the result instead of the raw content of
the file. All the features of the [`markdown-extended` command](http://github.com/piwi/markdown-extended/tree/master/docs/MANPAGE.md)
are available and configurable, such as using a template to construct a rich HTML
rendering.


How does it work?
-----------------

The idea behind the feature described here is quite simple: replace the default rendering
of a server when loading the URI of a Markdown syntax file by its rendering after the syntax
transformation. Instead of having the raw content of the file in your browser (the default
behavior of a web-server for static files), you will have a rich HTML content.

This works by asking to the server to treat concerned files, filtered by their extensions,
with a special script that makes the transformation and returns the result.


Installation
------------

To make the CGI script work, you will need three things:

-   a copy of this package,
-   a web server with a CGI binaries directory and running [PHP 5.3](http://php.net/) or higher,
-   a copy of the [PHP-MarkdownExtended package](http://github.com/piwi/markdown-extended) tool
    (you must install it by yourself - you can install it in a global or user's `bin/` directory 
    or locally in your CGI binaries directory).

For a complete fresh installation (NOT including the markdown-extended package), you can use:

    $ wget --no-check-certificate https://github.com/markdown-extended/mde-cgi/archive/master.tar.gz
    $ tar -xvf master.tar.gz
    $ cd mde-cgi-master
    $ ln -s "$(pwd)/mde-cgi-handler.sh" {path to your server CGI binaries}/
    $ ln -s "$(pwd)/mde-template.html" {path to your server CGI binaries}/

You may ensure the binary script have execution rights for your server user running:

    $ chmod a+x {path to your server CGI binaries}/mde-cgi-handler.sh

Doing so, the CGI script is ready to handle Markdown files. You now need to adapt your
server configuration to let it transmit the treatments to the script. See the *Configuration*
section below for more information.


The CGI script
--------------

The `mde-cgi-handler.sh` script is a [Bash](http://www.gnu.org/software/bash/) shell script
that will only transmit the request to the `markdown-extended` command with special options.

To adapt the `markdown-extended` work to your needs, you can define some environment
variables to override the defaults defined in the script. The default values are defined
in the case where you followed the usage described above by making a symbolic link to the 
local version of the script.

Basically, you need two files paths for the default handler to work:

-   the path to a working `markdown-extended` command (this can be the default `bin/markdown-extended`
    script of an installed package or a `markdown-extended.phar` archive)
-   the path to a template file to use.

The following variables are available:

-   `MDE_DEBUG` : enable the CGI debug mode ; information are written but the parsing will
    not be done ; it defaults to `false`

-   `MDE_BASEPATH` : the base directory path to use for all links of the script (this is
    optional if you define the `MDE_BIN` and `MDE_TEMPLATE` as absolute paths)

-   `MDE_BIN` : the path to the `markdown-extended` parser binary script to use ; this
    defaults to a global or "per-user" installed version of the `markdown-extended` OR
    a `${MDE_BASEPATH}/markdown-extended` script

-   `MDE_TEMPLATE` : the path to a template file to include parsed content in ; this defaults
    to `${MDE_BASEPATH}/mde-template.html`

-   `MDE_CHARSET` : the default character set to use while parsing Markdown content ; it
    defaults to `utf-8`

-   `MDE_OPTIONS` : the options to pass to the parser ; this defaults to `--template=${MDE_TEMPLATE}`

-   `MDE_PHP_BIN` : the path to the `php` program to use to call the parser ; the default
    system's command will be used by default

The script is designed to handle a query string in two ways:

-   using `?plain` will render the raw content of the file (not parsed) ; a automatic link
    is added in the footer of the default template)
-   using `?debug` will render some information about the environment which can be useful
    during installation and configuration ; the output stops after the rendering (no content
    of the file is rendered).


Server's configuration
----------------------

### Server running [Apache](http://httpd.apache.org/)

As the CGI script uses some internal Apache's features, you will need to enable the following
Apache modules:

-   [mod_rewrite](http://httpd.apache.org/docs/2.2/en/mod/mod_rewrite.html)
-   [mod_actions](http://httpd.apache.org/docs/trunk/en/mod/mod_actions.html)
-   [mod_mime](http://httpd.apache.org/docs/2.2/en/mod/mod_mime.html)
-   [mod_cgi](http://httpd.apache.org/docs/2.2/en/mod/mod_cgi.html)
-   [mod_include](http://httpd.apache.org/docs/2.2/mod/mod_include.html)

You will need to add the configuration below to concerned *[virtual host](http://httpd.apache.org/docs/2.2/en/vhosts/)*, 
which means you can use these configurations in a global `httpd-vhosts.conf` or 
a single `.htaccess` file.

    # enable CGIs and follow symbolic links
    Options         +ExecCGI +FollowSymLinks
    
    # add 'sh' scripts as CGI-scripts
    AddHandler      cgi-script  .sh
    
    # display '.md' files as text if something went wrong (you can add any extensions)
    AddType         text/html   .md .mde .markd .mdown .markdown
    
    # treat '.md' files by the CGI handler
    AddHandler      mde         .md .mde .markd .mdown .markdown
    Action          mde         /cgi-bin/mde-cgi-handler.sh virtual

To define a configuration variable, write:

    SetEnv MDE_BIN {custom path to}/markdown-extended


### Server running [Nginx](http://nginx.org/)

*this documentation part has to be done, sorry :(*


About the template
------------------

The HTML template proposed in this package is VERY simple. It is just the basic structure
of an HTML content with the basic elements of a MarkdownExtended content. You can (of course)
build you own template following the notation described in 
[the original package](http://github.com/piwi/markdown-extended/tree/master/docs/).

A rich version using [Bootstrap](http://getbootstrap.com/) is available in the `mde-master` 
branch of my other package [HTML5 quick template](http://github.com/piwi/html5-quick-template/tree/mde-master).

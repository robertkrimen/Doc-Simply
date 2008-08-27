/* 
 * =head1 NAME
 * 
 * b9j.path - Path handling made easy
 *
 * =head1 SYNOPSIS 
 *  
 *      var path = new b9j.path.Path("/a/b/c")
 *
 *      // /a/b/c/xyzzy
 *      var child = path.child("xyzzy")
 *
 *      // /a/b
 *      var parent = path.parent()
 *
 * =head1 DESCRIPTION
 *
 * b9j.path is a package for making path handling (path construction, manipulation and clean-up) easier
 *
 * [An example link](http://example.com)
 * 
 */

(function(){

    var pckg = b9j.namespace.declare('b9j.path');

    function canonical_string() {
        return b9j.path._canonical.apply(b9j.path, arguments);
    }

    function canonical_array() {
        return canonical_string.apply(this, arguments).split('/');
    }

    function _flatten(array, value) {
        if ("string" == typeof value) {
            array.push(value);
        }
        else if ("object" == typeof value) {
            if ("function" == typeof value.get) { // We probably have a Path object
                array.push(value.get());
            }
            else { // Assume an array
                for (var ii = 0; ii < value.length; ii++) {
                    _flatten(array, value[ii]);
                }
            }
        }
    }

    /*
        $path =~ s|/{2,}|/|g;                           # xx////xx  -> xx/xx
        $path =~ s{(?:/\.)+(?:/|\z)}{/}g;               # xx/././xx -> xx/xx
        $path =~ s|^(?:\./)+||s unless $path eq "./";	# ./xx      -> xx
        $path =~ s|^/(?:\.\./)+|/|;			            # /../../xx -> /xx
        $path =~ s|^/\.\.$|/|;				            # /..       -> /
        $path =~ s|/\z|| unless $path eq "/";		    # xx/       -> xx
    */

    pckg._canonical = function() {
        var path = [];
        _flatten(path, arguments);
        path = path.join('/').split(/\/+/).join('/');       // xx////xx     -> xx/xx
        path = path.replace(/(?:\/\.)+(?:\/|$)/g, '/');     // xx/././xx    -> xx/xx
        if ("./" != path)
            path = path.replace(/^(?:\.\/)+/, '');          // ./xx         -> xx
        path = path.replace(/^\/(?:\.\.\/)+/, '/');         // /../../xx    -> /xx
        path = path.replace(/^\/\.\.$/, '/');               // /..          -> /
        return path;
    };

/* =head1 METHODS
 *
 * =head2 new b9j.path.Path()
 *
 * Returns a new object representing the empty path
 *
 * =head2 new b9j.path.Path( $part1, [ $part2, ... ] )
 *
 * Returns a new object representing a path formed by joining $partN together with '/'
 *
 *          var path = b9j.path.Path( "a/b", "c", "d//e/f/" ) // a/b/c/d/e/f/
 *
 */

    pckg.Path = function() {
        this.set.apply(this, arguments);
    };

    pckg.Path.prototype = {

/* =head2 path.clone()
 *
 * Returns a clone of path
 *
 */
        clone: function() {
            return new b9j.path.Path(this.get());
        },

/* =head2 path.set( $path )
 *
 * =head2 path.set( $part1, $part2, ...  )
 *
 * Set the path to a cleaned-up version of the arguments
 *
 *          path.set( "////a", "b/c" ) // /a/b/c
 *
 */
        set: function() {
            this._path = canonical_array(arguments);
            if (this._path.length > 1 && this._path[0] == "") {
                this._root = true;
                if (2 == this._path.length && this._path[1] == "") { /* Dealing with [ "", "" ] case */
                    this._path = [ "" ];
                }
            }
            return this;
        },

/* =head2 path.toString()
 *
 * =head2 path.get() 
 *
 * Return a string representing path
 *
 */
        get: function() {
            return this.toString();
        },

        toString: function() {
            if (this._path.length == 1 && "" == this._path[0]) // Might be at "/"
                return this._root ? '/' : '';
            return this._path.join('/');
        },

/* =head2 path.pop( [ $count ] )
 *
 * Pop $count parts (a part is what is between slashes) off the end of path
 *
 * If $count is not specified, then it defaults to 1
 *
 * Returns a b9j.path.Path object representing the popped parts
 *
 *          var path = new b9j.path.Path( "a/b/c/d/e/f/g" )
 *          var popped_path = path.pop(3)
 *          // path is a/b/c/d
 *          // popped_path is e/f/g
 *
 */
        pop: function() {
            var popped = [];
            var count = arguments.length ? arguments[0] : 1;
        
            if (this.isEmpty()) return new b9j.path.Path();
            if (this.isRoot()) return new b9j.path.Path();

            if (count > 0 && this._path.length > 1 && "" == this._path[this._path.length - 1]) // Get rid of "extra" slash at end: a/b/c/
                this._path.pop();

            while (count-- && this._path.length) {
                if (this._path.length == 1 && "" == this._path[0]) // Preserve "/"
                    break;
                popped.push(this._path.pop());
            }

            return new b9j.path.Path(popped);
        },

/* =head2 path.up( [ $count ] )
 *
 * Behaves similarly to path.pop, in that it takes off $count parts from the end
 * of the path. However, path.up returns path, so you can use it for chaining:
 *
 *          var path = new b9j.path.Path( "a/b/c/d/e/f/g" )
 *          path.up().up(2).toString() // a/b/c/d
 *
 */          
        up: function() {
            this.pop.apply(this, arguments);
            return this;
        },

/* =head2 path.parent()
 *
 * Returns the parent path of path as a new, separate b9j.path.Path object
 *
 *          var path = new b9j.path.Path( "a/b/c" )
 *          var parent_path = path.parent()
 *          // path is STILL a/b/c
 *          // parent_path is a/b
 *
 */
        parent: function() {
            var path = this.clone();
            path.pop.apply(this, arguments);
            return path;
        },

/* =head2 path.push( $part1, [ $part2 ], ... )
 *
 * =head2 path.down( $part1, [ $part2 ], ... )
 *
 * Modifies path by appending $part1, $part2, to path separated by slashes
 *
 * Returns path so you can use it for chaining:
 *
 *          var path = new b9j.path.Path( "a/b/c" )
 *          path.down( "d//e", "f" ).down( "g" ) // "a/b/c/d/e/f/g
 *
 */

        push: function() {
            this._path = canonical_array(this._path, arguments);
            return this;
        },

        down: function() {
            this.push.apply(this, arguments);
            return this;
        },

/* =head2 path.child( $part1, [ $part2 ], ... )
 *
 * Returns a child path of path as a new, separate b9j.path.Path object with $partN appended
 * (separated by slashes)
 *
 *          var path = new b9j.path.Path( "a/b/c" )
 *          var child_path = path.child( "d/e" )
 *          // path is STILL a/b/c
 *          // child_path is a/b/c/d/e
 *
 */
        child: function() {
            var path = this.clone();
            path.push.apply(this, arguments);
            return path;
        },

/* =head2 path.isEmpty()
 *
 * Returns true if path is the empty path ("")
 *
 *          new b9j.path.Path().isEmpty()     // true
 *          new b9j.path.Path("").isEmpty()   // true
 *          new b9j.path.Path("/").isEmpty()  // false
 *          new b9j.path.Path("a").isEmpty()  // false
 */

        isEmpty: function() {
            return 1 == this._path.length && "" == this._path[0] && ! this._root ? true : false;
        },

/* =head2 path.isRoot()
 *
 * Returns true if path is the root path ("/")
 *
 *          new b9j.path.Path("").isRoot()   // false
 *          new b9j.path.Path("/").isRoot()  // true
 *          new b9j.path.Path("a").isRoot()  // false
 */

        isRoot: function() {
            return 1 == this._path.length && "" == this._path[0] && this._root ? true : false;
        },

/* =head2 path.isTree()
 *
 * Returns true if path begins with a slash
 *
 *          new b9j.path.Path("").isTree()    // false
 *          new b9j.path.Path("/").isTree()   // true
 *          new b9j.path.Path("a").isTree()   // false
 *          new b9j.path.Path("/a").isTree()  // true
 */

        isTree: function() {
            return this._root ? true : false;
        },

/* =head2 path.isBranch()
 *
 * Returns true if path does NOT begin with a slash
 *
 *          new b9j.path.Path("").isBranch()    // true
 *          new b9j.path.Path("/").isBranch()   // false
 *          new b9j.path.Path("a").isBranch()   // true
 *          new b9j.path.Path("/a").isBranch()  // false
 */

        isBranch: function() {
            return ! this.isTree();
        },

/* =head2 path.toTree()
 *
 * Modifies path by prepending a slash
 *
 *          new b9j.path.Path("").toTree()    // /
 *          new b9j.path.Path("/").toTree()   // /
 *          new b9j.path.Path("a").toTree()   // /a
 *          new b9j.path.Path("/a").toTree()  // /a
 */

        toTree: function() {
            this._root = true;
            if ("" == this._path[0]) return;
            this._path.splice(0, 0, "");
        },

/* =head2 path.toBranch()
 *
 * Modifies path by removing the leading slash, if any
 *
 *          new b9j.path.Path("").toBranch()    // ""
 *          new b9j.path.Path("/").toBranch()   // ""
 *          new b9j.path.Path("a").toBranch()   // a
 *          new b9j.path.Path("/a").toBranch()  // a
 */

        toBranch: function() {
            this._root = false;
            if ("" != this._path[0]) return;
            this._path.splice(0, 1);
        },

/* =head2 path.first()
 *
 * Returns the first part of path, not including any slashes
 *
 *          new b9j.path.Path("/a/b/c/").first()  // a
 */

        first: function() {
            return this.at(0);
        },

/* =head2 path.last()
 *
 * Returns the last part of path, not including any slashes
 *
 *          new b9j.path.Path("/a/b/c/").last()  // c
 */

        last: function() {
            return this.at(-1);
        },

/* =head2 path.at( $index )
 *
 * Returns the part of path at $index, not including any slashes
 * You can use a negative $index to start from the end of path
 *
 *          new b9j.path.Path("/a/b/c/").at(0)  // a (equivalent to path.first())
 *          new b9j.path.Path("/a/b/c/").at(-1) // c (equivalent to path.last())
 *          new b9j.path.Path("/a/b/c/").at(1)  // b
 *
 */
        at: function(ii) {
            if (this.isEmpty()) return "";
            if (1 == this._path.length && "" == this._path[0])
                return "";
            if (0 > ii)
                ii += this._path.length;
            else if ("" == this._path[0])
                ii += 1;
            if (ii >= this._path.length)
                return "";
            if (ii == this._path.length - 1 && "" == this._path[ii])
                ii -= 1;
            return this._path[ii];
        },

/* =head2 path.beginning()
 *
 * Returns the first part of path, including the leading slash, if any
 *
 *          new b9j.path.Path("/a/b/c/").beginning() // /a
 *          new b9j.path.Path("a/b/c/").beginning()  // a
 *
 */
        beginning: function() {
            if (this.isEmpty()) return "";
            if (this.isRoot()) return "/";
            var first = this.at(0);
            if (this.isBranch()) return first;
            return "/" + first;
            
        },

/* =head2 path.ending()
 *
 * Returns the last part of path, including the trailing slash, if any
 *
 *          new b9j.path.Path("/a/b/c/").beginning() // c/
 *          new b9j.path.Path("a/b/c/").beginning()  // c
 *
 */
        ending: function() {
            if (this.isEmpty()) return "";
            if (this.isRoot()) return "/";
            var last = this.at(-1);
            if (last == this._path[this._path.length - 1]) return last;
            return last + "/";
            
        },

/* =head2 path.list()
 *
 * Returns an array of the parts of path
 *
 *          new b9j.path.Path().list()          // []
 *          new b9j.path.Path("/").list()       // []
 *          new b9j.path.Path("/a/b/c/").list() // [ "a", "b", "c" ]
 *          new b9j.path.Path("a/b/c/").list()  // [ "a", "b", "c" ]
 *
 */
        list: function() {
            if (this.isEmpty()) return [];
            if (this.isRoot()) return [];
            var path = [].concat(this._path);
            if ("" == path[0]) path.splice(0, 1);
            if ("" == path[path.length - 1]) path.splice(path.length - 1, 1);
            return path;
        }
    };

}());

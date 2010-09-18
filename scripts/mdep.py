#!/usr/bin/env python
import re, os, sys, getopt

include_pat = re.compile(r'#include\s*"([^"]*)"')
pcx_pat = re.compile(r'\s(\S+\.[pP][cCnN][xXgG])\s')

def scan_file(fname):
    """
    Scan a file for other files it needs.

    @param fname: Name of the file to scan.
    @type  fname: C{str}

    @return: Included source files, included graphics files.
    @rtype:  C{set} of C{str}, C{set} of C{str}
    """
    fp = open(fname, 'r')
    line = fp.read()
    fp.close()
    data= re.sub('//.*', '', line)

    includes = set()
    s = 0
    while s < len(data):
        m = include_pat.search(data, s)
        if m:
            includes.add(m.group(1))
            s = m.end()
        else:
            break

    graphics = set()
    s = 0
    while s < len(data):
        m = pcx_pat.search(data, s)
        if m:
            graphics.add(m.group(1))
            s = m.end()
        else:
            break

    return includes, graphics

existing_files = set() #: Files that are known to exist.

def check_existence(include_dirs, depnames):
    """
    Normalize the path of a file so we can find double entries.

    @param existing_files: Cache of known files at the file system.
    @type  existing_files: C{set} of C{str}

    @param include_dirs: Directories to try.
    @type  include_dirs: C{list} of C{str}

    @param depnames: Files to resolve.
    @type  depnames: C{iter} of C{str}

    @return: Set of existing files, and a set of non-existing files.
    @rtype:  C{tuple} of (C{set} of C{str}, C{set} of C{str})
    """
    global existing_files

    good_files, bad_files = set(), set()
    for dep in depnames:
        if dep in existing_files:
            good_files.add(dep)
            continue

        if os.path.isfile(dep):
            existing_files.add(dep)
            good_files.add(dep)
            continue

        found = False
        for base in include_dirs:
            fname = os.path.join(base, dep)
            if fname in existing_files:
                good_files.add(fname)
                found = True
                break

            if os.path.isfile(fname):
                existing_files.add(fname)
                good_files.add(fname)
                found = True
                break

        if not found:
            # File does not exist, add it as bad file in the root
            bad_files.add(dep)

    return good_files, bad_files


def scan_files(startfiles, opt_dict):
    """
    Scan source files, looking for included dependencies (optionally
    recursively).

    @param startfiles: Set of files that are definitely known to be needed.
    @type  startfiles: C{set} of C{str}

    @param opt_dict: Mapping with option values.
    @type  opt_dict: C{dict} of C{str} to C{<something>}

    @return: Mapping of scanned files to their dependencies
    @rtype:  C{dict} of C{str} to C{set} of C{str}
    """
    dependencies = {} #: Mapping of filenames to its dependencies.
    missing = {} #: Mapping of filenames to missing files.

    good_st, bad_st = check_existence(opt_dict['include_dirs'], startfiles)
    notdone = good_st
    if len(bad_st) > 0:
        missing['*start*'] = bad_st

    # Collect files.
    while notdone:
        fname = notdone.pop()
        includes, graphics = scan_file(fname)
        good_inc, bad_inc = check_existence(opt_dict['include_dirs'], includes)
        good_gfx, bad_gfx = check_existence(opt_dict['include_dirs'], graphics)
        dependencies[fname] = good_inc.union(bad_inc) \
                              .union(good_gfx).union(bad_gfx)
        if len(bad_inc) > 0 or len(bad_gfx) > 0:
            missing[fname] = bad_inc.union(bad_gfx)

        if not opt_dict['non_recursive']:
            for fname in good_inc:
                if fname not in dependencies:
                    notdone.add(fname)

    return dependencies

def output_deps(dependencies, opt_dict):
    """
    Write dependencies to output.
    """
    if opt_dict['output'] is not None:
        handle = open(opt_dict['output'], 'w')
    else:
        handle = sys.stdout

    if opt_dict['target'] is None:
        for fname, depnames in dependencies.iteritems():
            if len(depnames) > 0:
                handle.write(fname + ": " + " ".join(depnames) + "\n")
            if opt_dict['touch']:
                handle.write("\t$(_V) touch $@\n")

    else:
        target = opt_dict['target']
        sources = set()
        for depnames in dependencies.itervalues():
            sources.update(depnames)
        sources.discard(target)

        handle.write(target + ": " + " ".join(sources) + "\n")
        if opt_dict['touch']:
            handle.write("\t$(_V) touch $@\n")

    if opt_dict['output'] is not None:
        handle.close()


def run():
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'I:ho:',
                                ['target=', 'touch', 'help', 'non-recursive',
                                 'output='])
    except getopt.GetoptError, err:
        print str(err)
        sys.exit(1)

    opt_dict = \
        {'include_dirs'  : set(), # Set of directories to search for files.
         'non_recursive' : False, # Don't recursively add new .pnfo files.
         'touch'         : False, # Generate a '\t$(_V) touch $@' line.
         'target'        : None,  # Use this as target instead of the file.
         'output'        : None,  # Destination.
        }
    for opt, val in optlist:
        if opt == '-I':
            opt_dict['include_dirs'].add(val)
            continue
        if opt == '--non-recursive':
            opt_dict['non_recursive'] = True
            continue
        if opt == '--touch':
            opt_dict['touch'] = True
            continue
        if opt == '--target':
            opt_dict['target'] = val
        if opt == '-h' or opt == '--help':
            print "mdeps.py [options] startfile ..."
            sys.exit(0)
        if opt == '--output' or opt == '-o':
            opt_dict['output'] = val

    dependencies = scan_files(set(args), opt_dict)
    output_deps(dependencies, opt_dict)

if __name__ == '__main__':
    run()

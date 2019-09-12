# This script turns markdown back into a plaintext document (more or less).
# It word-wraps lines while keeping indentation. Currently at 80 characters width.
# I'm sorry this is in sed. It started simple and once you hold a hammer...

# level 1 headers: surround with =
/^# / { s/^# //; h; s/./=/g; p; g; p; s/./=/g; b }

# level 2 headers: underline with =
/^## / { s/^## //; p; s/./=/g; b }

# level 3 headers: underline with -
/^### / { s/^### //; p; s/./-/g; b }

# local links: [name](link) -> name
s/\[([^]]+)\]\(\#[^\)]+\)/\1/g

# links: [name](url) -> name (url)
s/\[([^]]+)\](\([^\)]+\))/\1 \2/g

# code: remove ``
s/`([^`]+)`/\1/g

# word wrapping
/^.{0,80}$/b                             # no wrap required, we're done
s/^(.{0,80})([[:blank:]].*)/\1\n\2/      # find the last space before at most n characters and insert newline

# bullet lists need the marker replaced by space on the next line to correctly keep indentation
/^[[:blank:]]*[-\*][[:blank:]]+/ {
	s/^([[:blank:]]*)([-\*])([[:blank:]]+)([^\n]*)\n[[:blank:]]*/\1\2\3\4\n\1 \3/
	bz
}

# numbered lists need the index and dot replaced by space
/^[[:blank:]]*[0-9]\.[[:blank:]]+/ {
	s/^([[:blank:]]*)([0-9])\.([[:blank:]]+)([^\n]*)\n[[:blank:]]*/\1\2\.\3\4\n\1  \3/
	bz
} 

# everything else just keeps indentation from spaces and tabs
by

:x
/^.{0,80}$/b                             # no wrap required
s/^(.{0,80})([[:blank:]].*)/\1\n\2/      # find the last space before at most n characters and insert newline

:y
# if the line is blank, it was too long and the newline was placed after the indentation
# move the newline to the first blank after the word, ie ignore the width
s/^([[:blank:]]*)\n([[:blank:]]*)([^[:blank:]]*)/\1\2\3\n/

# if the line has no newline, it was too long. place a newline at the first space
/\n/!s/([[:blank:]])/\n\1/ 

# copy indentation and remove existing from the next line
s/^([[:blank:]]*)([^\n]*)\n[[:blank:]]*/\1\2\n\1/

:z
P
s/[^\n]*\n?//     # remove what's printed (end of line does not have a newline)
/^[[:space:]]*$/d # we may have created an empty line by copying the indentation
bx                # loop remaining

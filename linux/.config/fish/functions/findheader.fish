# Find C/C++ headers by name across the system include paths.
function findheader
    find /usr/include /usr/local/include -name "$argv[1]" 2>/dev/null
end
